module Org.Members exposing (Flags, Model, Msg, init, page, subscriptions, update, view)

import Array
import Assets as A
import Auth exposing (ErrState(..), parseErr)
import Browser.Navigation as Nav
import Codecs exposing (QuickDoc)
import Components.AuthModal as AuthModal
import Components.HelperBar as HelperBar exposing (HelperBar)
import Components.JoinOrga as JoinOrga
import Components.OrgaMenu as OrgaMenu
import Components.TreeMenu as TreeMenu
import Dict exposing (Dict)
import Extra exposing (ternary, textH, upH)
import Extra.Date exposing (formatDate)
import Extra.Events exposing (onClickPD, onEnter, onKeydown, onTab)
import Form exposing (isPostSendable)
import Form.Help as Help
import Form.NewTension as NTF exposing (NewTensionInput(..), TensionTab(..))
import Fractal.Enum.Lang as Lang
import Fractal.Enum.NodeMode as NodeMode
import Fractal.Enum.NodeType as NodeType
import Fractal.Enum.RoleType as RoleType
import Fractal.Enum.TensionAction as TensionAction
import Fractal.Enum.TensionEvent as TensionEvent
import Fractal.Enum.TensionStatus as TensionStatus
import Fractal.Enum.TensionType as TensionType
import Generated.Route as Route exposing (Route, toHref)
import Global exposing (Msg(..), send, sendSleep)
import Html exposing (Html, a, br, button, datalist, div, h1, h2, hr, i, input, li, nav, option, p, span, table, tbody, td, text, textarea, th, thead, tr, ul)
import Html.Attributes exposing (attribute, class, classList, disabled, href, id, list, placeholder, rows, target, type_, value)
import Html.Events exposing (onClick, onInput, onMouseEnter, onMouseLeave)
import Html.Lazy as Lazy
import Iso8601 exposing (fromTime)
import List.Extra as LE
import Loading exposing (GqlData, ModalData, RequestResult(..), WebData, fromMaybeData, viewAuthNeeded, viewGqlErrors, withDefaultData, withMaybeData)
import Maybe exposing (withDefault)
import ModelCommon exposing (..)
import ModelCommon.Codecs exposing (Flags_, FractalBaseRoute(..), NodeFocus, basePathChanged, contractIdCodec, focusFromNameid, focusState, hasAdminRole, nameidFromFlags, uriFromNameid, uriFromUsername)
import ModelCommon.Requests exposing (fetchMembersSub)
import ModelCommon.View exposing (roleColor, viewRole, viewUser, viewUsernameLink)
import ModelSchema exposing (..)
import Page exposing (Document, Page)
import Ports
import Query.PatchTension exposing (actionRequest)
import Query.QueryContract exposing (getContractId)
import Query.QueryNode exposing (fetchNode, queryLocalGraph, queryMembersLocal)
import RemoteData exposing (RemoteData)
import Session exposing (GlobalCmd(..))
import Task
import Text as T
import Time
import Url as Url


page : Page Flags Model Msg
page =
    Page.component
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


mapGlobalOutcmds : List GlobalCmd -> ( List (Cmd Msg), List (Cmd Global.Msg) )
mapGlobalOutcmds gcmds =
    gcmds
        |> List.map
            (\m ->
                case m of
                    DoNavigate link ->
                        ( Cmd.none, send (NavigateRaw link) )

                    DoReplaceUrl url ->
                        ( Cmd.none, send (ReplaceUrl url) )

                    DoUpdateToken ->
                        ( Cmd.none, send UpdateUserToken )

                    DoUpdateUserSession uctx ->
                        ( Cmd.none, send (UpdateUserSession uctx) )

                    DoUpdateOrgs orgs ->
                        ( Cmd.none, send (UpdateSessionOrgs orgs) )

                    DoUpdateTree tree ->
                        ( Cmd.none, send (UpdateSessionTree tree) )

                    DoCreateTension nameid ->
                        ( Cmd.map NewTensionMsg <| send (NTF.OnOpen (FromNameid nameid)), Cmd.none )

                    _ ->
                        ( Cmd.none, Cmd.none )
            )
        |> List.unzip



--
-- Model
--


type alias Model =
    { -- Focus
      node_focus : NodeFocus
    , path_data : GqlData LocalGraph

    -- Page
    , members_top : GqlData (List Member)
    , members_sub : GqlData (List Member)
    , pending_hover : Bool
    , pending_hover_i : Maybe Int

    -- Common
    , helperBar : HelperBar
    , refresh_trial : Int
    , now : Time.Posix
    , empty : {}

    -- Components
    , help : Help.State
    , tensionForm : NTF.State
    , joinOrga : JoinOrga.State
    , authModal : AuthModal.State
    , orgaMenu : OrgaMenu.State
    , treeMenu : TreeMenu.State
    }



--
-- Msg
--


type Msg
    = PassedSlowLoadTreshold -- timer
    | Submit (Time.Posix -> Msg) -- Get Current Time
      -- Data Queries
    | GotPath Bool (GqlData LocalGraph) -- GraphQL
      -- Page
    | GotMembers (GqlData (List Member)) -- GraphQL
    | GotMembersSub (GqlData (List Member)) -- Rest
    | OnPendingHover Bool
    | OnPendingRowHover (Maybe Int)
    | OnGoToContract String
    | OnGoContractAck (GqlData IdPayload)
      -- Common
    | NoMsg
    | LogErr String
    | Navigate String
    | ExpandRoles
    | CollapseRoles
    | OnGoRoot
      -- Components
    | HelpMsg Help.Msg
    | NewTensionMsg NTF.Msg
    | JoinOrgaMsg JoinOrga.Msg
    | AuthModalMsg AuthModal.Msg
    | OrgaMenuMsg OrgaMenu.Msg
    | TreeMenuMsg TreeMenu.Msg



--
-- INIT
--


type alias Flags =
    Flags_


init : Global.Model -> Flags -> ( Model, Cmd Msg, Cmd Global.Msg )
init global flags =
    let
        apis =
            global.session.apis

        -- Focus
        newFocus =
            flags
                |> nameidFromFlags
                |> focusFromNameid

        -- What has changed
        fs =
            focusState MembersBaseUri global.session.referer global.url global.session.node_focus newFocus

        model =
            { node_focus = newFocus
            , path_data =
                global.session.path_data
                    |> Maybe.map (\x -> Success x)
                    |> withDefault Loading
            , members_top = Loading
            , members_sub = Loading
            , pending_hover = False
            , pending_hover_i = Nothing

            -- Common
            , helperBar = HelperBar.create
            , help = Help.init global.session.user
            , tensionForm = NTF.init global.session.user
            , refresh_trial = 0
            , now = global.now
            , empty = {}
            , joinOrga = JoinOrga.init newFocus.nameid global.session.user
            , authModal = AuthModal.init global.session.user Nothing
            , orgaMenu = OrgaMenu.init newFocus global.session.orga_menu global.session.orgs_data global.session.user
            , treeMenu = TreeMenu.init MembersBaseUri global.url.query newFocus global.session.tree_menu global.session.tree_data global.session.user
            }

        cmds =
            [ ternary fs.focusChange (queryLocalGraph apis newFocus.nameid (GotPath True)) Cmd.none
            , queryMembersLocal apis newFocus.nameid GotMembers
            , fetchMembersSub apis newFocus.nameid GotMembersSub
            , sendSleep PassedSlowLoadTreshold 500
            , Cmd.map OrgaMenuMsg (send OrgaMenu.OnLoad)
            , Cmd.map TreeMenuMsg (send TreeMenu.OnLoad)
            ]
    in
    ( model
    , Cmd.batch cmds
    , if fs.refresh then
        send (UpdateSessionFocus (Just newFocus))

      else
        Cmd.none
    )


update : Global.Model -> Msg -> Model -> ( Model, Cmd Msg, Cmd Global.Msg )
update global message model =
    let
        apis =
            global.session.apis
    in
    case message of
        PassedSlowLoadTreshold ->
            let
                members_top =
                    ternary (model.members_top == Loading) LoadingSlowly model.members_top

                members_sub =
                    ternary (model.members_sub == Loading) LoadingSlowly model.members_sub
            in
            ( { model | members_top = members_top, members_sub = members_sub }, Cmd.none, Cmd.none )

        Submit nextMsg ->
            ( model, Task.perform nextMsg Time.now, Cmd.none )

        -- Data queries
        GotPath isInit result ->
            case result of
                Success path ->
                    let
                        prevPath =
                            if isInit then
                                { path | path = [] }

                            else
                                withDefaultData path model.path_data
                    in
                    case path.root of
                        Just root ->
                            let
                                newPath =
                                    { prevPath | root = Just root, path = path.path ++ (List.tail prevPath.path |> withDefault []) }
                            in
                            ( { model | path_data = Success newPath }, Cmd.none, send (UpdateSessionPath (Just newPath)) )

                        Nothing ->
                            let
                                newPath =
                                    { prevPath | path = path.path ++ (List.tail prevPath.path |> withDefault []) }

                                nameid =
                                    List.head path.path |> Maybe.map (\p -> p.nameid) |> withDefault ""
                            in
                            ( { model | path_data = Success newPath }, queryLocalGraph apis nameid (GotPath False), Cmd.none )

                _ ->
                    ( { model | path_data = result }, Cmd.none, Cmd.none )

        GotMembers result ->
            let
                newModel =
                    { model | members_top = result }
            in
            ( newModel, Cmd.none, Cmd.none )

        GotMembersSub result ->
            case result of
                Success mbs ->
                    ( { model
                        | members_sub =
                            List.map
                                (\m ->
                                    case memberRolesFilter m.roles of
                                        [] ->
                                            Nothing

                                        roles ->
                                            Just { m | roles = roles }
                                )
                                mbs
                                |> List.filterMap identity
                                |> Success
                      }
                    , Cmd.none
                    , Cmd.none
                    )

                _ ->
                    ( { model | members_sub = result }, Cmd.none, Cmd.none )

        OnPendingHover b ->
            ( { model | pending_hover = b }, Cmd.none, Cmd.none )

        OnPendingRowHover i ->
            ( { model | pending_hover_i = i }, Cmd.none, Cmd.none )

        OnGoToContract username ->
            let
                tid =
                    tidFromPath model.path_data |> withDefault ""

                contractid =
                    contractIdCodec tid (TensionEvent.toString TensionEvent.UserJoined) "" username
            in
            ( model, getContractId apis contractid OnGoContractAck, Cmd.none )

        OnGoContractAck result ->
            case result of
                Success c ->
                    let
                        tid =
                            tidFromPath model.path_data |> withDefault ""

                        link =
                            toHref <| Route.Tension_Dynamic_Dynamic_Contract_Dynamic { param1 = model.node_focus.rootnameid, param2 = tid, param3 = c.id }
                    in
                    ( model, send (Navigate link), Cmd.none )

                _ ->
                    ( model, Cmd.none, Cmd.none )

        -- Common
        NoMsg ->
            ( model, Cmd.none, Cmd.none )

        LogErr err ->
            ( model, Ports.logErr err, Cmd.none )

        Navigate url ->
            ( model, Cmd.none, Nav.pushUrl global.key url )

        ExpandRoles ->
            ( { model | helperBar = HelperBar.expand model.helperBar }, Cmd.none, Cmd.none )

        CollapseRoles ->
            ( { model | helperBar = HelperBar.collapse model.helperBar }, Cmd.none, Cmd.none )

        OnGoRoot ->
            let
                query =
                    global.url.query |> Maybe.map (\uq -> "?" ++ uq) |> Maybe.withDefault ""
            in
            ( model, send (Navigate (uriFromNameid MembersBaseUri model.node_focus.rootnameid [] ++ query)), Cmd.none )

        -- Components
        NewTensionMsg msg ->
            let
                ( tf, out ) =
                    NTF.update apis msg model.tensionForm

                ( cmds, gcmds ) =
                    mapGlobalOutcmds out.gcmds
            in
            ( { model | tensionForm = tf }, out.cmds |> List.map (\m -> Cmd.map NewTensionMsg m) |> List.append cmds |> Cmd.batch, Cmd.batch gcmds )

        HelpMsg msg ->
            let
                ( help, out ) =
                    Help.update apis msg model.help

                ( cmds, gcmds ) =
                    mapGlobalOutcmds out.gcmds
            in
            ( { model | help = help }, out.cmds |> List.map (\m -> Cmd.map HelpMsg m) |> List.append cmds |> Cmd.batch, Cmd.batch gcmds )

        JoinOrgaMsg msg ->
            let
                ( data, out ) =
                    JoinOrga.update apis msg model.joinOrga

                ( cmds, gcmds ) =
                    mapGlobalOutcmds out.gcmds
            in
            ( { model | joinOrga = data }, out.cmds |> List.map (\m -> Cmd.map JoinOrgaMsg m) |> List.append cmds |> Cmd.batch, Cmd.batch gcmds )

        AuthModalMsg msg ->
            let
                ( data, out ) =
                    AuthModal.update apis msg model.authModal

                ( cmds, gcmds ) =
                    mapGlobalOutcmds out.gcmds

                -- reload silently the page if needed
                cmds_extra =
                    out.result
                        |> Maybe.map
                            (\o ->
                                if Tuple.first o == True then
                                    [ Nav.replaceUrl global.key (Url.toString global.url) ]

                                else
                                    []
                            )
                        |> withDefault []
            in
            ( { model | authModal = data }, out.cmds |> List.map (\m -> Cmd.map AuthModalMsg m) |> List.append (cmds ++ cmds_extra) |> Cmd.batch, Cmd.batch gcmds )

        OrgaMenuMsg msg ->
            let
                ( data, out ) =
                    OrgaMenu.update apis msg model.orgaMenu

                ( cmds, gcmds ) =
                    mapGlobalOutcmds out.gcmds
            in
            ( { model | orgaMenu = data }, out.cmds |> List.map (\m -> Cmd.map OrgaMenuMsg m) |> List.append cmds |> Cmd.batch, Cmd.batch gcmds )

        TreeMenuMsg msg ->
            let
                ( data, out ) =
                    TreeMenu.update apis msg model.treeMenu

                ( cmds, gcmds ) =
                    mapGlobalOutcmds out.gcmds
            in
            ( { model | treeMenu = data }, out.cmds |> List.map (\m -> Cmd.map TreeMenuMsg m) |> List.append cmds |> Cmd.batch, Cmd.batch gcmds )


subscriptions : Global.Model -> Model -> Sub Msg
subscriptions _ model =
    []
        ++ (Help.subscriptions |> List.map (\s -> Sub.map HelpMsg s))
        ++ (NTF.subscriptions model.tensionForm |> List.map (\s -> Sub.map NewTensionMsg s))
        ++ (JoinOrga.subscriptions model.joinOrga |> List.map (\s -> Sub.map JoinOrgaMsg s))
        ++ (AuthModal.subscriptions |> List.map (\s -> Sub.map AuthModalMsg s))
        ++ (OrgaMenu.subscriptions |> List.map (\s -> Sub.map OrgaMenuMsg s))
        ++ (TreeMenu.subscriptions |> List.map (\s -> Sub.map TreeMenuMsg s))
        |> Sub.batch



---- VIEW ----


view : Global.Model -> Model -> Document Msg
view global model =
    let
        helperData =
            { user = global.session.user
            , uriQuery = global.url.query
            , path_data = withMaybeData model.path_data
            , focus = model.node_focus
            , baseUri = MembersBaseUri
            , data = model.helperBar
            , onExpand = ExpandRoles
            , onCollapse = CollapseRoles
            , onToggleTreeMenu = TreeMenuMsg TreeMenu.OnToggle
            , onJoin = JoinOrgaMsg (JoinOrga.OnOpen model.node_focus.rootnameid JoinOrga.JoinOne)
            }
    in
    { title = T.members ++ " · " ++ (String.join "/" <| LE.unique [ model.node_focus.rootnameid, model.node_focus.nameid |> String.split "#" |> List.reverse |> List.head |> withDefault "" ])
    , body =
        [ div [ class "orgPane" ]
            [ HelperBar.view helperData
            , div [ id "mainPane" ] [ view_ global model ]
            ]
        , Help.view model.empty model.help |> Html.map HelpMsg
        , NTF.view { tree_data = TreeMenu.getOrgaData_ model.treeMenu, path_data = model.path_data } model.tensionForm |> Html.map NewTensionMsg
        , JoinOrga.view model.empty model.joinOrga |> Html.map JoinOrgaMsg
        , AuthModal.view model.empty model.authModal |> Html.map AuthModalMsg
        , OrgaMenu.view model.empty model.orgaMenu |> Html.map OrgaMenuMsg
        , TreeMenu.view model.empty model.treeMenu |> Html.map TreeMenuMsg
        ]
    }


view_ : Global.Model -> Model -> Html Msg
view_ global model =
    let
        rtid =
            tidFromPath model.path_data |> withDefault ""

        isAdmin =
            case global.session.user of
                LoggedIn uctx ->
                    hasAdminRole uctx model.node_focus.rootnameid

                LoggedOut ->
                    False

        lang =
            global.session.lang
    in
    div [ class "columns is-centered" ]
        [ div [ class "column is-12 is-11-desktop is-9-fullhd mt-5" ]
            [ div [ class "section_ mt-2" ]
                [ if isAdmin then
                    div
                        [ class "button is-primary is-pulled-right"
                        , onClick (JoinOrgaMsg (JoinOrga.OnOpen model.node_focus.rootnameid JoinOrga.InviteOne))
                        ]
                        [ A.icon1 "icon-user-plus" T.inviteMembers ]

                  else
                    text ""
                , div [ class "columns mb-6 px-3-mobile" ]
                    [ Lazy.lazy4 viewMembers lang model.now model.members_sub model.node_focus ]
                , div [ class "columns mb-6 px-3" ]
                    [ div [ class "column is-4 pl-0" ] [ Lazy.lazy4 viewGuest lang model.now model.members_top model.node_focus ]
                    , div [ class "column is-3" ] [ viewPending model.now model.members_top model.node_focus model.pending_hover model.pending_hover_i rtid ]
                    ]
                ]
            ]
        ]


viewMembers : Lang.Lang -> Time.Posix -> GqlData (List Member) -> NodeFocus -> Html Msg
viewMembers lang now data focus =
    let
        goToParent =
            if focus.nameid /= focus.rootnameid then
                span [ class "help-label button-light is-h is-discrete", onClick OnGoRoot ] [ A.icon "arrow-up", text T.goRoot ]

            else
                text ""
    in
    case data of
        Success members ->
            if List.length members == 0 then
                div [] [ text T.noMemberYet, goToParent ]

            else
                div []
                    [ h2 [ class "subtitle is-size-3" ] [ text T.members, goToParent ]
                    , div [ class "table-container" ]
                        [ div [ class "table is-fullwidth" ]
                            [ thead []
                                [ tr [ class "has-background-header" ]
                                    [ th [] []
                                    , th [] [ text T.username ]
                                    , th [] [ text T.name ]
                                    , th [] [ text T.rolesHere ]
                                    , th [] [ text T.rolesSub ]
                                    ]
                                ]
                            , tbody [] <|
                                List.map
                                    (\m ->
                                        Lazy.lazy4 viewMemberRow lang now focus m
                                    )
                                    members
                            ]
                        ]
                    ]

        Failure err ->
            viewGqlErrors err

        LoadingSlowly ->
            div [ class "spinner" ] []

        _ ->
            text ""


viewGuest : Lang.Lang -> Time.Posix -> GqlData (List Member) -> NodeFocus -> Html Msg
viewGuest lang now members_d focus =
    let
        guests =
            members_d
                |> withDefaultData []
                |> List.filter
                    (\u ->
                        u.roles
                            |> List.map (\r -> r.role_type)
                            |> List.member RoleType.Guest
                    )
    in
    if List.length guests > 0 then
        div []
            [ h2 [ class "subtitle has-text-weight-semibold" ] [ text T.guest ]
            , div [ class "table-container" ]
                [ div [ class "table is-fullwidth" ]
                    [ thead []
                        [ tr [ class "has-background-header" ]
                            [ th [] []
                            , th [] [ text T.username ]
                            , th [] [ text T.name ]
                            , th [] [ text T.roles ]
                            ]
                        ]
                    , tbody [] <|
                        List.indexedMap
                            (\i m ->
                                Lazy.lazy3 viewGuestRow lang now m
                            )
                            guests
                    ]
                ]
            ]

    else
        div [] []


viewPending : Time.Posix -> GqlData (List Member) -> NodeFocus -> Bool -> Maybe Int -> String -> Html Msg
viewPending now members_d focus pending_hover pending_hover_i tid =
    let
        guests =
            members_d
                |> withDefaultData []
                |> List.filter
                    (\u ->
                        u.roles
                            |> List.map (\r -> r.role_type)
                            |> List.member RoleType.Pending
                    )
    in
    if List.length guests > 0 then
        div []
            [ h2 [ class "subtitle has-text-weight-semibold", onMouseEnter (OnPendingHover True), onMouseLeave (OnPendingHover False) ]
                [ text T.pending
                , a
                    [ class "button is-small is-primary mx-3"
                    , classList [ ( "is-invisible", not pending_hover ) ]
                    , href <| toHref <| Route.Tension_Dynamic_Dynamic_Contract { param1 = "", param2 = tid }
                    ]
                    [ text T.goContracts ]
                ]
            , div [ class "table-container" ]
                [ div [ class "table is-fullwidth" ]
                    [ thead []
                        [ tr [ class "has-background-header" ]
                            [ th [] [ text T.username ]
                            , th [] [ text T.name ]
                            ]
                        ]
                    , tbody [] <|
                        List.indexedMap
                            (\i m ->
                                tr [ onMouseEnter (OnPendingRowHover (Just i)), onMouseLeave (OnPendingRowHover Nothing) ]
                                    [ td [] [ viewUsernameLink m.username ]
                                    , td [] [ m.name |> withDefault "--" |> text ]
                                    , if Just i == pending_hover_i then
                                        td [] [ div [ class "button is-small is-primary", onClick (OnGoToContract m.username) ] [ text T.goContract ] ]

                                      else
                                        text ""
                                    ]
                            )
                            guests
                    ]
                ]
            ]

    else
        div [] []


viewMemberRow : Lang.Lang -> Time.Posix -> NodeFocus -> Member -> Html Msg
viewMemberRow lang now focus m =
    let
        ( roles_, sub_roles_ ) =
            List.foldl
                (\r ( roles, sub_roles ) ->
                    if (Maybe.map .nameid r.parent |> withDefault focus.nameid) == focus.nameid then
                        ( r :: roles, sub_roles )

                    else
                        ( roles, r :: sub_roles )
                )
                ( [], [] )
                m.roles
                |> (\( x, y ) -> ( List.reverse x, List.reverse y ))
    in
    tr []
        [ td [ class "pt-2 pr-0" ] [ viewUser True m.username ]
        , td [ class "pt-3" ] [ viewUsernameLink m.username ]
        , td [ class "pt-3" ] [ m.name |> withDefault "--" |> text ]
        , td [ class "pt-3" ]
            [ case roles_ of
                [] ->
                    text "--"

                _ ->
                    viewMemberRoles lang now OverviewBaseUri roles_
            ]
        , td [ class "pt-3" ]
            [ case sub_roles_ of
                [] ->
                    text "--"

                _ ->
                    viewMemberRoles lang now OverviewBaseUri sub_roles_
            ]
        ]


viewGuestRow : Lang.Lang -> Time.Posix -> Member -> Html Msg
viewGuestRow lang now m =
    tr []
        [ td [ class "pt-2 pr-0" ] [ viewUser True m.username ]
        , td [ class "pt-3" ] [ viewUsernameLink m.username ]
        , td [ class "pt-3" ] [ m.name |> withDefault "--" |> text ]
        , td [ class "pt-3" ] [ viewMemberRoles lang now OverviewBaseUri m.roles ]
        ]


viewMemberRoles : Lang.Lang -> Time.Posix -> FractalBaseRoute -> List UserRoleExtended -> Html Msg
viewMemberRoles lang now baseUri roles =
    div [ class "buttons" ] <|
        List.map
            (\r -> viewRole (Just ( lang, now, r.createdAt )) (uriFromNameid baseUri r.nameid []) r)
            roles



--
-- Utils
--
--


memberRolesFilter : List UserRoleExtended -> List UserRoleExtended
memberRolesFilter roles =
    roles
        |> List.map
            (\r ->
                if List.member r.role_type [ RoleType.Guest, RoleType.Pending ] then
                    -- Filter Special roles
                    []

                else if r.role_type == RoleType.Member && List.length roles > 1 then
                    -- Filter Member with roles
                    []

                else
                    [ r ]
            )
        |> List.concat
