module Org.Members exposing (Flags, Model, Msg, init, page, subscriptions, update, view)

import Array
import Assets as A
import Auth exposing (ErrState(..), parseErr)
import Browser.Navigation as Nav
import Codecs exposing (QuickDoc)
import Components.AuthModal as AuthModal
import Components.HelperBar as HelperBar exposing (HelperBar)
import Components.JoinOrga as JoinOrga
import Components.Loading as Loading exposing (GqlData, ModalData, RequestResult(..), WebData, fromMaybeData, viewAuthNeeded, viewGqlErrors, withDefaultData, withMaybeData)
import Components.OrgaMenu as OrgaMenu
import Components.TreeMenu as TreeMenu
import Dict exposing (Dict)
import Extra exposing (ternary)
import Extra.Date exposing (formatDate)
import Extra.Events exposing (onClickPD, onEnter, onKeydown, onTab)
import Form exposing (isPostSendable)
import Form.Help as Help
import Form.NewTension as NTF exposing (TensionTab(..))
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
import Maybe exposing (withDefault)
import ModelCommon exposing (..)
import ModelCommon.Codecs exposing (Flags_, FractalBaseRoute(..), NodeFocus, basePathChanged, contractIdCodec, focusFromNameid, focusState, hasAdminRole, nameidFromFlags, uriFromNameid, uriFromUsername)
import ModelCommon.Requests exposing (fetchMembersSub, getQuickDoc, login)
import ModelCommon.View exposing (roleColor, viewMemberRole, viewUser, viewUsernameLink)
import ModelSchema exposing (..)
import Page exposing (Document, Page)
import Ports
import Query.PatchTension exposing (actionRequest)
import Query.QueryContract exposing (getContractId)
import Query.QueryNode exposing (fetchNode, queryLocalGraph, queryMembersLocal)
import RemoteData exposing (RemoteData)
import Session exposing (GlobalCmd(..))
import Task
import Text as T exposing (textH, textT, upH)
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
    | InitModals
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
            , joinOrga = JoinOrga.init newFocus.nameid global.session.user
            , authModal = AuthModal.init global.session.user Nothing
            , orgaMenu = OrgaMenu.init newFocus global.session.orga_menu global.session.orgs_data global.session.user
            , treeMenu = TreeMenu.init newFocus global.session.tree_menu global.session.tree_data global.session.user
            }

        cmds =
            [ ternary fs.focusChange (queryLocalGraph apis newFocus.nameid (GotPath True)) Cmd.none
            , queryMembersLocal apis newFocus.nameid GotMembers
            , fetchMembersSub apis newFocus.nameid GotMembersSub
            , sendSleep PassedSlowLoadTreshold 500
            , sendSleep InitModals 400
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
            let
                newModel =
                    { model | members_sub = result }
            in
            ( newModel, Cmd.none, Cmd.none )

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

        InitModals ->
            ( { model | tensionForm = NTF.fixGlitch_ model.tensionForm }, Cmd.none, Cmd.none )

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
            ( model, send (Navigate (uriFromNameid MembersBaseUri model.node_focus.rootnameid ++ query)), Cmd.none )

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
            }
    in
    { title = upH T.members ++ " · " ++ (String.join "/" <| LE.unique [ model.node_focus.rootnameid, model.node_focus.nameid |> String.split "#" |> List.reverse |> List.head |> withDefault "" ])
    , body =
        [ Lazy.lazy HelperBar.view helperData
        , div [ id "mainPane" ] [ view_ global.session.user model ]
        , Help.view {} model.help |> Html.map HelpMsg
        , NTF.view { path_data = model.path_data } model.tensionForm |> Html.map NewTensionMsg
        , JoinOrga.view {} model.joinOrga |> Html.map JoinOrgaMsg
        , AuthModal.view {} model.authModal |> Html.map AuthModalMsg
        , OrgaMenu.view {} model.orgaMenu |> Html.map OrgaMenuMsg
        , TreeMenu.view { baseUri = MembersBaseUri, uriQuery = global.url.query } model.treeMenu |> Html.map TreeMenuMsg
        ]
    }


view_ : UserState -> Model -> Html Msg
view_ us model =
    let
        rtid =
            tidFromPath model.path_data |> withDefault ""

        isAdmin =
            case us of
                LoggedIn uctx ->
                    hasAdminRole uctx model.node_focus.rootnameid

                LoggedOut ->
                    False
    in
    div [ class "columns is-centered" ]
        [ div [ class "column is-12 is-11-desktop is-9-fullhd mt-5" ]
            [ div [ class "section mt-2" ]
                [ if isAdmin then
                    div
                        [ class "button is-primary is-pulled-right"
                        , onClick (JoinOrgaMsg (JoinOrga.OnOpen model.node_focus.rootnameid JoinOrga.InviteOne))
                        ]
                        [ A.icon1 "icon-user-plus" (upH T.inviteMember) ]

                  else
                    text ""
                , div [ class "columns mb-6" ]
                    [ Lazy.lazy3 viewMembers model.now model.members_top model.node_focus ]

                -- pl-3 because "is-pulled-right" causes a uwanted padding to the next element.
                , div [ class "columns mb-6", classList [ ( "pl-3", isAdmin ) ] ]
                    [ Lazy.lazy3 viewMembersSub model.now model.members_sub model.node_focus ]
                , div [ class "columns mb-6", classList [ ( "pl-3", isAdmin ) ] ]
                    [ div [ class "column is-3 pl-0" ] [ Lazy.lazy4 viewGuest model.now model.members_top T.guest model.node_focus ]
                    , div [ class "column is-3" ] [ Lazy.lazy7 viewPending model.now model.members_top "pending" model.node_focus model.pending_hover model.pending_hover_i rtid ]
                    ]
                ]
            ]
        ]


viewUserRow : Time.Posix -> Member -> Html Msg
viewUserRow now m =
    tr []
        [ td [ class "pt-2 pr-0" ] [ viewUser True m.username ]
        , td [ class "pt-3" ] [ viewUsernameLink m.username ]
        , td [ class "pt-3" ] [ m.name |> withDefault "--" |> text ]
        , td [ class "pt-3" ] [ viewMemberRoles now OverviewBaseUri m.roles ]
        ]


viewMembers : Time.Posix -> GqlData (List Member) -> NodeFocus -> Html Msg
viewMembers now data focus =
    let
        goToParent =
            if focus.nameid /= focus.rootnameid then
                span [ class "help-label is-grey-light button-light is-h has-text-weight-light", onClick OnGoRoot ] [ A.icon "arrow-up", text T.goRoot ]

            else
                text ""
    in
    case data of
        Success members_ ->
            let
                members =
                    members_
                        |> List.map
                            (\m ->
                                case memberRolesFilter focus m.roles of
                                    [] ->
                                        Nothing

                                    r ->
                                        Just { m | roles = r }
                            )
                        |> List.filterMap identity
            in
            case members of
                [] ->
                    div [] [ [ "No", T.member, "yet." ] |> String.join " " |> text, goToParent ]

                mbs ->
                    div []
                        [ h2 [ class "subtitle has-text-weight-semibold" ] [ textH T.directMembers, goToParent ]
                        , div [ class "table-container" ]
                            [ div [ class "table is-fullwidth" ]
                                [ thead []
                                    [ tr [ class "has-background-header" ]
                                        [ th [] []
                                        , th [] [ textH T.username ]
                                        , th [] [ textH T.name ]
                                        , th [ class "" ] [ textH T.roles ]
                                        ]
                                    ]
                                , tbody [] <|
                                    List.map
                                        (\m -> viewUserRow now m)
                                        mbs
                                ]
                            ]
                        ]

        Failure err ->
            viewGqlErrors err

        LoadingSlowly ->
            div [ class "spinner" ] []

        _ ->
            text ""


viewMembersSub : Time.Posix -> GqlData (List Member) -> NodeFocus -> Html Msg
viewMembersSub now data focus =
    case data of
        Success members_ ->
            let
                members =
                    members_
                        |> List.map
                            (\m ->
                                case memberRolesFilter focus m.roles of
                                    [] ->
                                        Nothing

                                    r ->
                                        Just { m | roles = r }
                            )
                        |> List.filterMap identity
            in
            case members of
                [] ->
                    div [] [ [ "No sub-circle", T.member, "yet." ] |> String.join " " |> text ]

                mbs ->
                    div []
                        [ h2 [ class "subtitle has-text-weight-semibold" ] [ textH T.subMembers ]
                        , div [ class "table-container" ]
                            [ div [ class "table is-fullwidth" ]
                                [ thead []
                                    [ tr [ class "has-background-header" ]
                                        [ th [] []
                                        , th [] [ textH T.username ]
                                        , th [] [ textH T.name ]
                                        , th [ class "" ] [ textH T.roles ]
                                        ]
                                    ]
                                , tbody [] <|
                                    List.map
                                        (\m -> viewUserRow now m)
                                        mbs
                                ]
                            ]
                        ]

        Failure err ->
            viewGqlErrors err

        LoadingSlowly ->
            div [ class "spinner" ] []

        _ ->
            text ""


viewGuest : Time.Posix -> GqlData (List Member) -> String -> NodeFocus -> Html Msg
viewGuest now members_d title focus =
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
            [ h2 [ class "subtitle has-text-weight-semibold" ] [ textH title ]
            , div [ class "table-container" ]
                [ div [ class "table is-fullwidth" ]
                    [ thead []
                        [ tr [ class "has-background-header" ]
                            [ th [] [ textH T.username ]
                            , th [] [ textH T.name ]
                            ]
                        ]
                    , tbody [] <|
                        List.indexedMap
                            (\i m ->
                                tr []
                                    [ td [] [ viewUsernameLink m.username ]
                                    , td [] [ m.name |> withDefault "--" |> text ]
                                    ]
                            )
                            guests
                    ]
                ]
            ]

    else
        div [] []


viewPending : Time.Posix -> GqlData (List Member) -> String -> NodeFocus -> Bool -> Maybe Int -> String -> Html Msg
viewPending now members_d title focus pending_hover pending_hover_i tid =
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
                [ textH title
                , a
                    [ class "button is-small is-primary mx-3"
                    , classList [ ( "is-invisible", not pending_hover ) ]
                    , href <| toHref <| Route.Tension_Dynamic_Dynamic_Contract { param1 = "", param2 = tid }
                    ]
                    [ text "Go to contracts" ]
                ]
            , div [ class "table-container" ]
                [ div [ class "table is-fullwidth" ]
                    [ thead []
                        [ tr [ class "has-background-header" ]
                            [ th [] [ textH T.username ]
                            , th [] [ textH T.name ]
                            ]
                        ]
                    , tbody [] <|
                        List.indexedMap
                            (\i m ->
                                tr [ onMouseEnter (OnPendingRowHover (Just i)), onMouseLeave (OnPendingRowHover Nothing) ]
                                    [ td [] [ viewUsernameLink m.username ]
                                    , td [] [ m.name |> withDefault "--" |> text ]
                                    , if Just i == pending_hover_i then
                                        td [] [ div [ class "button is-small is-primary", onClick (OnGoToContract m.username) ] [ text "Go to contract" ] ]

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


memberRolesFilter : NodeFocus -> List UserRoleExtended -> List UserRoleExtended
memberRolesFilter focus roles =
    roles
        |> List.map
            (\r ->
                if List.member r.role_type [ RoleType.Guest, RoleType.Pending ] then
                    -- Filter Special roles
                    []

                else if r.role_type == RoleType.Member && List.length roles > 1 then
                    -- Filter Member with roles
                    []

                else if focus.nameid == (r.parent |> Maybe.map (\p -> p.nameid) |> withDefault "") then
                    -- Dont include top level member for sub circle member (which contains all member)
                    -- Note: .parentid not defined in the top member query
                    []

                else
                    [ r ]
            )
        |> List.concat


viewMemberRoles : Time.Posix -> FractalBaseRoute -> List UserRoleExtended -> Html Msg
viewMemberRoles now baseUri roles =
    div [ class "buttons" ] <|
        List.map
            (\r -> viewMemberRole now baseUri r)
            roles
