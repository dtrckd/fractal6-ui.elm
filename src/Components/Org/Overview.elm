port module Components.Org.Overview exposing (Flags, Model, Msg, init, page, subscriptions, update, view)

import Array
import Browser.Events exposing (onKeyDown)
import Browser.Navigation as Nav
import Components.Fa as Fa
import Components.HelperBar as HelperBar
import Components.Loading as Loading exposing (viewAuthNeeded, viewErrors, viewWarnings)
import Components.Text as Text exposing (..)
import Date exposing (formatTime)
import Debug
import Dict exposing (Dict)
import Extra.Events exposing (onEnter, onKeydown, onTab)
import Form
import Form.NewCircle
import Form.NewTension
import Fractal.Enum.NodeMode as NodeMode
import Fractal.Enum.NodeType as NodeType
import Fractal.Enum.RoleType as RoleType
import Fractal.Enum.TensionAction as TensionAction
import Fractal.Enum.TensionStatus as TensionStatus
import Fractal.Enum.TensionType as TensionType
import Global exposing (Msg(..))
import Html exposing (Html, a, br, button, datalist, div, h1, h2, hr, i, input, li, nav, option, p, span, tbody, td, text, textarea, th, thead, tr, ul)
import Html.Attributes exposing (attribute, class, classList, disabled, href, id, list, placeholder, rows, type_, value)
import Html.Events exposing (onClick, onInput, onMouseEnter)
import Iso8601 exposing (fromTime)
import Json.Decode as JD exposing (Value, decodeValue)
import Json.Encode as JE
import Json.Encode.Extra as JEE
import Maybe exposing (withDefault)
import ModelCommon exposing (..)
import ModelCommon.Uri exposing (Flags_, FractalBaseRoute(..), NodeFocus, NodePath, basePathChanged, focusFromNameid, nameidFromFlags, uriFromNameid, uriFromUsername)
import ModelCommon.View exposing (edgeArrow, tensionTypeColor, viewNodeRef)
import ModelSchema exposing (..)
import Page exposing (Document, Page)
import Ports
import Process
import Query.AddNode exposing (addNewMember, addOneCircle)
import Query.AddTension exposing (addCircleTension, addOneTension)
import Query.QueryMandate exposing (queryMandate)
import Query.QueryNodesOrga exposing (queryGraphPack)
import Query.QueryTension exposing (queryCircleTension)
import Task
import Time


page : Page Flags Model Msg
page =
    Page.component
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



--
-- Model
--


type alias Model =
    { node_focus : NodeFocus
    , node_path : Maybe NodePath
    , orga_data : OrgaData
    , circle_tensions : CircleTensionsData
    , mandate : GqlData Mandate
    , node_action : ActionState
    , isModalActive : Bool -- Only use by JoinOrga for now. (other actions rely on Bulma drivers)
    , node_quickSearch : NodesQuickSearch
    }



--
-- INIT
--


type alias Flags =
    Flags_


init : Global.Model -> Flags -> ( Model, Cmd Msg, Cmd Global.Msg )
init global flags =
    let
        -- init Flags and Session
        session =
            global.session

        newFocus =
            flags
                |> nameidFromFlags
                |> focusFromNameid

        -- What has changed
        oldFocus =
            session.node_focus |> withDefault newFocus

        isInit =
            session.node_focus == Nothing

        orgChange =
            (newFocus.rootnameid /= oldFocus.rootnameid) || isInit

        focusChange =
            (newFocus.nameid /= oldFocus.nameid) || isInit

        --d1 = Debug.log "isInit, orgChange, focuChange" [ isInit, orgChange, focusChange ]
        --d2 = Debug.log "newfocus" [ newFocus ]
        refresh =
            basePathChanged OverviewBaseUri global.session.referer

        qs =
            session.node_quickSearch |> withDefault { pattern = "", lookup = Array.empty, idx = 0 }

        model =
            { orga_data =
                session.orga_data
                    |> Maybe.map (\x -> Success x)
                    |> withDefault Loading
            , circle_tensions =
                session.circle_tensions
                    |> Maybe.map (\x -> Success x)
                    |> withDefault Loading
            , mandate =
                session.mandate
                    |> Maybe.map (\x -> Success x)
                    |> withDefault Loading
            , node_action = session.node_action |> withDefault NotAsk
            , node_focus = newFocus
            , node_path = session.node_path
            , isModalActive = False
            , node_quickSearch = { qs | pattern = "", idx = 0 }
            }

        cmds =
            if orgChange || refresh then
                [ queryGraphPack newFocus.rootnameid GotOrga
                , queryCircleTension newFocus.nameid GotTensions
                , queryMandate newFocus.nameid GotMandate
                , Task.perform (\_ -> PassedSlowLoadTreshold) (Process.sleep 500)
                ]

            else if focusChange then
                [ Ports.focusGraphPack newFocus.nameid
                , queryCircleTension newFocus.nameid GotTensions
                , queryMandate newFocus.nameid GotMandate
                , Task.perform (\_ -> PassedSlowLoadTreshold) (Process.sleep 500)
                ]

            else
                []
    in
    ( model
    , Cmd.batch cmds
    , Global.send (UpdateSessionFocus newFocus)
    )



--
-- UPDATE
--


type Msg
    = PassedSlowLoadTreshold -- timer
      -- Gql Data Queries
    | GotOrga (GqlData NodesData) -- graphql
    | GotTensions (GqlData TensionsData) -- graphql
    | GotMandate (GqlData Mandate) -- graphql
      -- Node Actions
    | DoNodeAction Node_ -- ports receive / tooltip click
    | Submit (Time.Posix -> Msg) -- Get Current Time
      -- AddTension Action
    | DoTensionInit Node -- {target}
    | DoTensionSource TensionType.TensionType -- {type}
    | DoTensionFinal UserRole --  {source}
    | ChangeTensionPost String String -- {field value}
    | SubmitTension TensionForm Time.Posix -- Send form
    | TensionAck (GqlData Tension) -- decode better to get IdPayload
      -- AddCircle Action
    | DoCircleInit Node NodeType.NodeType -- {target}
    | DoCircleSource -- String -- {nodeMode} @DEBUG: node mode is inherited by default.
    | DoCircleFinal UserRole -- {source}
    | ChangeCirclePost String String -- {field value}
    | ChangeCircleRole RoleType.RoleType
    | SubmitCircle CircleForm Bool Time.Posix -- Send form
    | CircleAck (GqlData (List Node)) -- decode better to get IdPayload
      -- JoinOrga Action
    | DoJoinOrga String Time.Posix
    | JoinAck (GqlData Node)
      -- Quick search
    | ChangePattern String
    | ChangeLookup Nodes_
    | SearchKeyDown Int
      -- JS Interop
    | NodeClicked String -- ports receive / Node clicked
    | NodeFocused NodePath -- ports receive / Node focused
    | DoCloseModal String -- ports receive / Close modal
    | DoOpenModal -- ports receive / Open  modal
    | DoClearTooltip -- ports send
    | ToggleGraphReverse -- ports send
    | ToggleTooltips -- ports send / Not implemented @DEBUG multiple tooltip/ see name of circle


update : Global.Model -> Msg -> Model -> ( Model, Cmd Msg, Cmd Global.Msg )
update global msg model =
    case msg of
        PassedSlowLoadTreshold ->
            let
                orga_data =
                    case model.orga_data of
                        Loading ->
                            LoadingSlowly

                        other ->
                            other

                circle_tensions =
                    case model.circle_tensions of
                        Loading ->
                            LoadingSlowly

                        other ->
                            other
            in
            ( { model | orga_data = orga_data, circle_tensions = circle_tensions }, Cmd.none, Cmd.none )

        GotOrga result ->
            case result of
                Success data ->
                    if Dict.size data > 0 then
                        ( { model | orga_data = Success data }
                        , Ports.initGraphPack data model.node_focus.nameid
                        , Global.send (UpdateSessionOrga data)
                        )

                    else
                        ( { model | orga_data = Failure [ Text.nodeNotExist ] }, Cmd.none, Cmd.none )

                other ->
                    ( { model | orga_data = result }, Cmd.none, Cmd.none )

        GotTensions result ->
            case result of
                Success data ->
                    ( { model | circle_tensions = result }, Cmd.none, Global.send (UpdateSessionTensions data) )

                other ->
                    ( { model | circle_tensions = result }, Cmd.none, Cmd.none )

        GotMandate result ->
            case result of
                Success data ->
                    ( { model | mandate = result }, Cmd.none, Global.send (UpdateSessionMandate data) )

                other ->
                    ( { model | mandate = result }, Cmd.none, Cmd.none )

        -- Search
        ChangePattern pattern ->
            let
                qs =
                    model.node_quickSearch

                newIdx =
                    if pattern == "" then
                        0

                    else
                        qs.idx
            in
            ( { model | node_quickSearch = { qs | pattern = pattern, idx = newIdx } }
            , Cmd.none
            , Ports.searchNode pattern
            )

        ChangeLookup nodes_ ->
            let
                qs =
                    model.node_quickSearch
            in
            case nodes_ of
                Ok nodes ->
                    ( { model | node_quickSearch = { qs | lookup = Array.fromList nodes } }
                    , Cmd.none
                    , Cmd.none
                    )

                Err err ->
                    ( model, Cmd.none, Cmd.none )

        SearchKeyDown key ->
            let
                qs =
                    model.node_quickSearch

                len =
                    Array.length qs.lookup
            in
            case key of
                13 ->
                    --ENTER
                    case Array.get model.node_quickSearch.idx model.node_quickSearch.lookup of
                        Just n ->
                            ( model
                            , Cmd.none
                            , Nav.replaceUrl global.key (uriFromNameid OverviewBaseUri n.nameid)
                            )

                        Nothing ->
                            ( model, Cmd.none, Cmd.none )

                27 ->
                    --ESC
                    ( model, Global.send (ChangePattern ""), Cmd.none )

                40 ->
                    --DOWN
                    let
                        newIdx =
                            if len > 0 && qs.idx < len - 1 then
                                qs.idx + 1

                            else
                                0
                    in
                    ( { model | node_quickSearch = { qs | idx = newIdx } }, Cmd.none, Cmd.none )

                38 ->
                    --UP
                    let
                        newIdx =
                            if len > 0 && qs.idx > 0 then
                                qs.idx - 1

                            else if len > 0 && qs.idx == 0 then
                                len - 1

                            else
                                0
                    in
                    ( { model | node_quickSearch = { qs | idx = newIdx } }, Cmd.none, Cmd.none )

                other ->
                    ( model, Cmd.none, Cmd.none )

        -- Action
        DoNodeAction node_ ->
            let
                newAction =
                    case node_ of
                        Ok node ->
                            ActionChoice node

                        Err err ->
                            AskErr err
            in
            ( { model | node_action = newAction }, Global.send DoOpenModal, Cmd.none )

        Submit nextMsg ->
            ( model, Task.perform nextMsg Time.now, Cmd.none )

        -- Tension
        DoTensionInit node ->
            let
                form =
                    { uctx = UserCtx "" Nothing (UserRights False False) []
                    , source = UserRole "" "" "" RoleType.Guest
                    , target = node
                    , type_ = TensionType.Governance
                    , post = Dict.empty
                    }

                newStep =
                    TensionInit form
            in
            ( { model | node_action = AddTension newStep }, Cmd.none, Ports.bulma_driver "actionModal" )

        DoTensionSource tensionType ->
            case global.session.user of
                LoggedOut ->
                    ( { model | node_action = ActionAuthNeeded }, Cmd.none, Cmd.none )

                LoggedIn uctx ->
                    case model.node_action of
                        AddTension (TensionInit form) ->
                            let
                                newForm =
                                    { form | uctx = uctx, type_ = tensionType }

                                orgaRoles =
                                    uctx.roles |> List.filter (\r -> r.rootnameid == form.target.rootnameid)

                                newStep =
                                    case orgaRoles of
                                        [] ->
                                            TensionNotAuthorized [ Text.notOrgMember, Text.joinForTension ]

                                        [ r ] ->
                                            let
                                                newForm2 =
                                                    { newForm | source = r }
                                            in
                                            TensionFinal newForm2 NotAsked

                                        roles ->
                                            TensionSource newForm roles
                            in
                            ( { model | node_action = AddTension newStep }, Cmd.none, Ports.bulma_driver "actionModal" )

                        other ->
                            ( { model | node_action = AskErr "Step moves not implemented" }, Cmd.none, Cmd.none )

        DoTensionFinal source ->
            case model.node_action of
                AddTension (TensionSource form roles) ->
                    let
                        newForm =
                            { form | source = source }
                    in
                    ( { model | node_action = AddTension <| TensionFinal newForm NotAsked }, Cmd.none, Ports.bulma_driver "actionModal" )

                other ->
                    ( { model | node_action = AskErr "Step moves not implemented" }, Cmd.none, Cmd.none )

        ChangeTensionPost field value ->
            case model.node_action of
                AddTension (TensionFinal form result) ->
                    let
                        newForm =
                            { form | post = Dict.insert field value form.post }
                    in
                    ( { model | node_action = AddTension <| TensionFinal newForm result }, Cmd.none, Cmd.none )

                other ->
                    ( { model | node_action = AskErr "Step moves not implemented" }, Cmd.none, Cmd.none )

        SubmitTension form time ->
            let
                newForm =
                    { form | post = Dict.insert "createdAt" (fromTime time) form.post }
            in
            ( model, addOneTension newForm TensionAck, Cmd.none )

        TensionAck result ->
            let
                tensions =
                    case result of
                        Success t ->
                            hotTensionPush t model.circle_tensions

                        other ->
                            []
            in
            case model.node_action of
                AddTension (TensionFinal form _) ->
                    ( { model
                        | node_action = AddTension <| TensionFinal form result
                        , circle_tensions = Success tensions
                      }
                    , Cmd.none
                    , Global.send (UpdateSessionTensions tensions)
                    )

                AddCircle (CircleFinal form _) ->
                    ( { model
                        | node_action = AddTension <| TensionFinal (circle2tensionForm form) result
                        , circle_tensions = Success tensions
                      }
                    , Cmd.none
                    , Global.send (UpdateSessionTensions tensions)
                    )

                other ->
                    ( { model | node_action = AskErr "Query method implemented" }, Cmd.none, Cmd.none )

        -- Circle
        DoCircleInit node nodeType ->
            let
                form =
                    { uctx = UserCtx "" Nothing (UserRights False False) []
                    , source = UserRole "" "" "" RoleType.Guest
                    , target = node
                    , type_ = nodeType
                    , tension_type = TensionType.Governance
                    , role_type = RoleType.Member
                    , post = Dict.empty
                    }

                newStep =
                    CircleInit form
            in
            ( { model | node_action = AddCircle newStep }, Global.send DoCircleSource, Ports.bulma_driver "actionModal" )

        DoCircleSource ->
            case global.session.user of
                LoggedOut ->
                    ( { model | node_action = ActionAuthNeeded }, Cmd.none, Cmd.none )

                LoggedIn uctx ->
                    case model.node_action of
                        AddCircle (CircleInit form) ->
                            let
                                newForm =
                                    { form
                                        | uctx = uctx
                                        , post =
                                            form.post
                                                |> Dict.union (Dict.fromList [ ( "node_mode", NodeMode.toString nodeMode ), ( "first_links", "@" ++ uctx.username ) ])
                                    }

                                orgaRoles =
                                    uctx.roles |> List.filter (\r -> r.rootnameid == form.target.rootnameid)

                                nodeMode =
                                    getNodeMode form.target.rootnameid model.orga_data |> withDefault NodeMode.Coordinated

                                newStep =
                                    case orgaRoles of
                                        [] ->
                                            CircleNotAuthorized [ Text.notOrgMember, Text.joinForCircle ]

                                        roles ->
                                            let
                                                circleRoles =
                                                    roles |> List.filter (\r -> getParentidFromRole r == newForm.target.nameid)
                                            in
                                            case circleRoles of
                                                [] ->
                                                    CircleNotAuthorized [ Text.notCircleMember, Text.askCoordo ]

                                                subRoles ->
                                                    case nodeMode of
                                                        NodeMode.Chaos ->
                                                            case subRoles of
                                                                [ r ] ->
                                                                    let
                                                                        newForm2 =
                                                                            { newForm | source = r }
                                                                    in
                                                                    CircleFinal newForm2 NotAsked

                                                                subRoles2 ->
                                                                    CircleSource newForm subRoles2

                                                        NodeMode.Coordinated ->
                                                            let
                                                                coordoRoles =
                                                                    subRoles |> List.filter (\r -> r.role_type == RoleType.Coordinator)
                                                            in
                                                            case coordoRoles of
                                                                [] ->
                                                                    CircleNotAuthorized [ Text.notCircleCoordo, Text.askCoordo ]

                                                                [ r ] ->
                                                                    let
                                                                        newForm2 =
                                                                            { newForm | source = r }
                                                                    in
                                                                    CircleFinal newForm2 NotAsked

                                                                subRoles2 ->
                                                                    CircleSource newForm subRoles2
                            in
                            ( { model | node_action = AddCircle newStep }, Cmd.none, Ports.bulma_driver "actionModal" )

                        other ->
                            ( { model | node_action = AskErr "Step moves not implemented" }, Cmd.none, Cmd.none )

        DoCircleFinal source ->
            case model.node_action of
                AddCircle (CircleSource form roles) ->
                    let
                        newForm =
                            { form | source = source }
                    in
                    ( { model | node_action = AddCircle <| CircleFinal newForm NotAsked }, Cmd.none, Ports.bulma_driver "actionModal" )

                other ->
                    ( { model | node_action = AskErr "Step moves not implemented" }, Cmd.none, Cmd.none )

        ChangeCirclePost field value ->
            case model.node_action of
                AddCircle (CircleFinal form result) ->
                    let
                        newPost =
                            Dict.insert field value form.post

                        newForm =
                            case field of
                                "name" ->
                                    let
                                        newNodeLabel =
                                            case form.type_ of
                                                NodeType.Circle ->
                                                    Text.newCircle

                                                NodeType.Role ->
                                                    Text.newRole

                                        autoFields =
                                            Dict.fromList
                                                [ ( "title", "[" ++ newNodeLabel ++ "] " ++ value )
                                                , ( "nameid"
                                                  , value
                                                        |> String.toLower
                                                        |> String.trim
                                                        |> String.map
                                                            (\c ->
                                                                if List.member c [ ' ', '/', '=', '?', '#', '&', '?', '|', '%', '$', '\\' ] then
                                                                    '-'

                                                                else if List.member c [ '(', ')', '<', '>', '[', ']', '{', '}', '"', '`', '\'' ] then
                                                                    '_'

                                                                else
                                                                    c
                                                            )
                                                  )
                                                ]
                                    in
                                    { form | post = Dict.union autoFields newPost }

                                other ->
                                    { form | post = newPost }
                    in
                    ( { model | node_action = AddCircle <| CircleFinal newForm result }, Cmd.none, Cmd.none )

                other ->
                    ( { model | node_action = AskErr "Step moves not implemented" }, Cmd.none, Cmd.none )

        ChangeCircleRole roleType ->
            case model.node_action of
                AddCircle (CircleFinal form result) ->
                    let
                        newForm =
                            { form | role_type = roleType }
                    in
                    ( { model | node_action = AddCircle <| CircleFinal newForm result }, Cmd.none, Cmd.none )

                other ->
                    ( { model | node_action = AskErr "Step moves not implemented" }, Cmd.none, Cmd.none )

        SubmitCircle form doClose time ->
            let
                status =
                    if doClose == True then
                        TensionStatus.Closed |> TensionStatus.toString

                    else
                        TensionStatus.Open |> TensionStatus.toString

                newForm =
                    { form | post = Dict.union (Dict.fromList [ ( "createdAt", fromTime time ), ( "status", status ) ]) form.post }
            in
            if doClose == True then
                ( model, addOneCircle newForm CircleAck, Cmd.none )

            else
                ( model, addCircleTension newForm TensionAck, Cmd.none )

        CircleAck result ->
            case model.node_action of
                AddCircle (CircleFinal form _) ->
                    case result of
                        Success nodes ->
                            let
                                ndata =
                                    hotNodePush nodes model.orga_data
                            in
                            ( { model | node_action = AddCircle <| CircleFinal form result, orga_data = Success ndata }
                            , Ports.redrawGraphPack ndata
                            , Cmd.batch [ Global.send UpdateUserToken, Global.send (UpdateSessionOrga ndata) ]
                            )

                        other ->
                            ( { model | node_action = AddCircle <| CircleFinal form result }, Cmd.none, Cmd.none )

                other ->
                    ( { model | node_action = AskErr "Query method not implemented" }, Cmd.none, Cmd.none )

        -- Join
        DoJoinOrga rootnameid time ->
            case global.session.user of
                LoggedOut ->
                    ( { model | node_action = JoinOrga JoinAuthNeeded }, Global.send DoOpenModal, Cmd.none )

                LoggedIn uctx ->
                    let
                        form =
                            { uctx = uctx
                            , rootnameid = rootnameid
                            , post = Dict.fromList [ ( "createdAt", fromTime time ) ]
                            }

                        newModel =
                            { model | node_action = JoinOrga (JoinInit form) }
                    in
                    ( newModel, Cmd.batch [ addNewMember form JoinAck, Global.send DoOpenModal ], Cmd.none )

        JoinAck result ->
            case model.node_action of
                JoinOrga (JoinInit form) ->
                    case result of
                        Success n ->
                            let
                                ndata =
                                    hotNodePush [ n ] model.orga_data
                            in
                            ( { model | node_action = JoinOrga (JoinValidation form result), orga_data = Success ndata }
                            , Ports.redrawGraphPack ndata
                            , Cmd.batch [ Global.send UpdateUserToken, Global.send (UpdateSessionOrga ndata) ]
                            )

                        other ->
                            ( { model | node_action = JoinOrga (JoinValidation form result) }, Cmd.none, Cmd.none )

                default ->
                    ( model, Cmd.none, Cmd.none )

        -- Modal
        DoCloseModal _ ->
            ( { model | isModalActive = False }, Cmd.none, Cmd.none )

        DoOpenModal ->
            ( { model | isModalActive = True }, Cmd.none, Ports.open_modal )

        DoClearTooltip ->
            ( model, Cmd.none, Ports.clearTooltip )

        -- JS interop
        NodeClicked nameid ->
            ( model
            , Cmd.none
            , Nav.replaceUrl global.key (uriFromNameid OverviewBaseUri nameid)
            )

        NodeFocused path ->
            ( { model | node_path = Just path }, Ports.drawButtonsGraphPack, Global.send (UpdateSessionPath path) )

        ToggleGraphReverse ->
            ( model, () |> sendToggleGraphReverse, Cmd.none )

        ToggleTooltips ->
            ( model, () |> sendToggleTooltips, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Global.Model -> Model -> Sub Msg
subscriptions _ _ =
    Sub.batch
        [ nodeClickedFromJs NodeClicked
        , nodeFocusedFromJs NodeFocused
        , nodeDataFromJs_ DoNodeAction
        , lookupFromJs_ ChangeLookup
        , closeModalFromJs DoCloseModal
        ]



-- Receive to Javascript


port closeModalFromJs : (String -> msg) -> Sub msg


port nodeClickedFromJs : (String -> msg) -> Sub msg


port nodeFocusedFromJs : (NodePath -> msg) -> Sub msg


port nodeDataFromJs : (JD.Value -> a) -> Sub a


nodeDataFromJs_ : (Node_ -> msg) -> Sub msg
nodeDataFromJs_ rawNode =
    nodeDataFromJs
        (rawNode
            << (\x ->
                    case x of
                        Ok n ->
                            Ok n

                        Err err ->
                            Err (JD.errorToString err)
               )
            << JD.decodeValue nodeDecoder
        )


port lookupFromJs : (JD.Value -> a) -> Sub a


lookupFromJs_ : (Nodes_ -> msg) -> Sub msg
lookupFromJs_ rawNode =
    lookupFromJs
        (rawNode
            << (\x ->
                    case x of
                        Ok n ->
                            Ok n

                        Err err ->
                            Err (JD.errorToString err)
               )
            << JD.decodeValue (JD.list nodeDecoder)
        )



-- Send to JS


port sendToggleGraphReverse : () -> Cmd msg


port sendToggleTooltips : () -> Cmd msg



-- VIEW
--


view : Global.Model -> Model -> Document Msg
view global model =
    { title = String.join " · " [ model.node_focus.rootnameid, model.node_focus.nameid |> String.split "#" |> List.reverse |> List.head |> withDefault "" ]
    , body = [ view_ global model ]
    }


view_ : Global.Model -> Model -> Html Msg
view_ global model =
    let
        maybeOrgFocus =
            case model.orga_data of
                Success d ->
                    let
                        focus =
                            Dict.get model.node_focus.nameid d
                    in
                    case model.node_path of
                        Just path ->
                            if Array.length path > 0 then
                                ( Success d, focus )

                            else
                                ( Failure [ Text.nodeNotExist ], Nothing )

                        Nothing ->
                            ( Success d, focus )

                other ->
                    ( other, Nothing )

        maybeOrg =
            Tuple.first maybeOrgFocus

        nodeFocus =
            Tuple.second maybeOrgFocus
    in
    -- [div [ class "column is-1 is-fullheight is-hidden-mobile", id "leftPane" ] [ viewLeftPane model ]
    div [ id "mainPane" ]
        [ HelperBar.view OverviewBaseUri
            global.session.user
            model.node_path
            (Submit <| DoJoinOrga model.node_focus.rootnameid)
        , div [ class "columns is-centered is-variable is-4" ]
            [ div [ class "column is-5" ]
                [ viewSearchBar model.orga_data model.node_path model.node_quickSearch
                , viewCanvas maybeOrg
                , br [] []
                , viewMandate model.mandate nodeFocus
                , setupActionModal model
                ]
            , div [ class "column is-5" ]
                [ div [ class "columns is-gapless" ]
                    [ div [ class "column is-12", id "nextToChart" ]
                        [ viewActivies model ]
                    ]
                ]
            ]
        ]


viewLeftPane : Model -> Html Msg
viewLeftPane model =
    nav [ class "menu" ]
        [ p [ class "menu-label" ]
            [ div [ class "hero is-small is-primary is-bold" ]
                [ div [ class "hero-body has-text-centered" ] [ text model.node_focus.rootnameid ] ]
            ]
        , ul [ class "menu-list" ]
            [ li [ class "menu-label" ]
                [ div [ class "hero is-small is-info is-bold" ]
                    [ div [ class "hero-body" ]
                        [ Fa.icon "far fa-circle fa-lg" model.node_focus.nameid ]
                    ]
                ]
            , li []
                [ ul [ class "menu-list" ]
                    [ li []
                        [ a []
                            [ Fa.icon "fas fa-scroll fa-xs" "Mandates" ]
                        ]
                    , li []
                        [ a []
                            --  fa-exclamation-circle
                            [ Fa.icon "fas fa-exchange-alt fa-xs" "Tensions" ]
                        ]
                    , li []
                        [ a []
                            [ Fa.icon "fas fa-history fa-xs" "Journal" ]
                        ]
                    , li []
                        [ a []
                            [ Fa.icon "fas fa-user fa-xs" "Members" ]
                        ]
                    ]
                ]
            ]
        ]


viewSearchBar : OrgaData -> Maybe NodePath -> NodesQuickSearch -> Html Msg
viewSearchBar nodes maybePath qs =
    let
        maybeLast =
            maybePath
                |> withDefault Array.empty
                |> (\a -> Array.get (Array.length a - 1) a)
    in
    case maybeLast of
        Just last ->
            let
                node_ =
                    case nodes of
                        Success d ->
                            Dict.get last.nameid d
                                |> Maybe.map (\n -> Ok n)
                                |> withDefault (Err "Node not found")

                        other ->
                            Err "No nodes data"

                isActive =
                    if Array.length qs.lookup > 0 then
                        " is-active "

                    else
                        ""
            in
            div
                [ id "searchBar"
                , class "field has-addons"
                , onMouseEnter DoClearTooltip
                ]
                [ div [ class ("control has-icons-left is-expanded dropdown" ++ isActive) ]
                    [ input
                        [ class "input is-small autofocus"
                        , type_ "text"
                        , placeholder "Find a Role or Circle"
                        , value qs.pattern
                        , onInput ChangePattern
                        , onKeydown SearchKeyDown

                        --, list "searchList" -- impossible interaction !
                        ]
                        []
                    , span [ class "icon is-left" ] [ i [ class "fas fa-search" ] [] ]
                    , div [ id "searchList", class "dropdown-menu" ]
                        [ qs.lookup
                            |> Array.indexedMap
                                (\i n ->
                                    let
                                        isSelected =
                                            if i == qs.idx then
                                                " is-active "

                                            else
                                                ""
                                    in
                                    --a [ href (uriFromNameid OverviewBaseUri n.nameid) ]
                                    tr
                                        [ class ("drpdwn-item" ++ isSelected), onClick (NodeClicked n.nameid) ]
                                    <|
                                        [ th [] [ text n.name ] ]
                                            ++ (case n.type_ of
                                                    NodeType.Circle ->
                                                        [ td [] [ n.parent |> Maybe.map (\p -> p.nameid |> String.split "#" |> List.reverse |> List.head |> withDefault "") |> withDefault "" |> text ]
                                                        , td [] [ n.first_link |> Maybe.map (\p -> "@" ++ p.username) |> withDefault "" |> text ]
                                                        ]

                                                    NodeType.Role ->
                                                        [ td [] [ n.parent |> Maybe.map (\p -> p.nameid |> String.split "#" |> List.reverse |> List.head |> withDefault "") |> withDefault "" |> text ]
                                                        , td [] [ n.first_link |> Maybe.map (\p -> "@" ++ p.username) |> withDefault "--" |> text ]
                                                        ]
                                               )
                                )
                            |> Array.toList
                            |> tbody []
                            |> List.singleton
                            |> List.append [ thead [] [ tr [] [ th [] [ text Text.nameQS ], th [] [ text Text.circleQS ], th [] [ text Text.firstLinkQS ] ] ] ]
                            |> div [ class "dropdown-content table is-fullwidth" ]
                        ]
                    , div [ class "control" ]
                        [ div
                            [ class "button is-small is-info _modalTrigger_"
                            , attribute "data-modal" "actionModal"
                            , onClick (DoNodeAction node_)
                            ]
                            [ span [ class "has-text-weight-semibold" ] [ last.name |> text ] -- Node name
                            , span [ class "fa-stack  ellipsisArt" ]
                                [ i [ class "fas fa-ellipsis-h fa-stack-1x" ] [] ]
                            ]
                        ]
                    ]
                ]

        Nothing ->
            div [ id "searchBar", class "field has-addons is-invisible" ] [ div [ class "control has-icons-left is-expanded is-loading" ] [ input [ class "input is-small ", type_ "text", placeholder Text.phQS, disabled True ] [] ] ]


viewCanvas : OrgaData -> Html Msg
viewCanvas orgaData =
    div []
        [ div [ id "canvasParent", classList [ ( "spinner", orgaData == LoadingSlowly ) ] ] <|
            case orgaData of
                Failure err ->
                    [ viewErrors err ]

                default ->
                    [ div [ id "canvasButtons", class "buttons are-small is-invisible" ]
                        -- Hidden class use in graphpack_d3.js
                        [ div
                            [ id "invGraph_cvbtn"
                            , class "button buttonToggle tooltip has-tooltip-right"
                            , attribute "data-tooltip" Text.reverseTooltip
                            , onClick ToggleGraphReverse
                            ]
                            [ Fa.icon0 "fas fa-sort-amount-up" "" ]

                        --, div
                        --    [ id "showLabel_cvbtn"
                        --    , class "button buttonToggle tooltip has-tooltip-right"
                        --    , attribute "data-tooltip" "Show/Hide circle tooltips."
                        --    , onClick ToggleTooltips
                        --    ]
                        --    [ Fa.icon0 "fas fa-caret-square-down" "" ]
                        ]
                    ]
        , div
            [ id "nodeTooltip"
            , class "_modalTrigger_ is-invisible"
            , attribute "data-modal" "actionModal"
            ]
            [ span [] [ text "void" ] -- Node name
            , span [ class "fa-stack fa-sm ellipsisArt" ]
                [ i [ class "fas fa-ellipsis-h fa-stack-1x" ] []

                -- To be copied before fa-ellipis !
                --, i[class "far fa-circle fa-stack-2x"][]
                --, i[class "fas fa-circle fa-stack-2x"][]
                ]
            ]
        ]


viewMandate : GqlData Mandate -> Maybe Node -> Html Msg
viewMandate mandateData maybeFocus =
    div [ id "mandateContainer", class "hero is-small is-light heroViewer" ]
        [ div [ class "hero-body" ]
            [ h1 [ class "title is-3" ]
                [ Fa.icon "fas fa-scroll fa-xs" "Mandate" ]
            , hr [ class "has-background-grey-light" ] []
            , div [ class "content" ] <|
                case mandateData of
                    Failure err ->
                        -- Exception for Guest Node
                        case maybeFocus of
                            Just focus ->
                                case focus.role_type of
                                    Just r ->
                                        let
                                            fs =
                                                focus.first_link |> Maybe.map (\u -> u.username) |> withDefault "[Unknown]"
                                        in
                                        case r of
                                            RoleType.Guest ->
                                                [ List.intersperse " " [ "No mandate for Guest", fs, "." ] |> String.join " " |> text ]

                                            other ->
                                                [ viewErrors err ]

                                    Nothing ->
                                        [ viewErrors err ]

                            Nothing ->
                                [ viewErrors err ]

                    Loading ->
                        [ div [] [] ]

                    NotAsked ->
                        [ div [] [] ]

                    LoadingSlowly ->
                        [ div [ class "spinner" ] [] ]

                    Success mandate ->
                        [ viewMandateDoc mandate ]
            ]
        ]


viewMandateDoc : Mandate -> Html Msg
viewMandateDoc mandate =
    let
        purpose =
            mandate.purpose

        responsabilities =
            mandate.responsabilities |> withDefault Text.noResponsabilities

        domains =
            mandate.domains |> withDefault Text.noDomains

        policies =
            mandate.policies |> withDefault Text.noPolicies
    in
    div []
        [ h2 [ class "title is-5" ] [ text Text.purposeH ]
        , p [] [ purpose |> text ]
        , h2 [ class "title is-5" ] [ text Text.responsabilitiesH ]
        , p [] [ responsabilities |> text ]
        , h2 [ class "title is-5" ] [ text Text.domainsH ]
        , p [] [ domains |> text ]
        , h2 [ class "title is-5" ] [ text Text.policiesH ]
        , p [] [ policies |> text ]
        ]


viewActivies : Model -> Html Msg
viewActivies model =
    div
        [ class "box"
        , attribute "style" "flex-grow: 1; padding-top: 0px;"
        ]
        [ div [ class "title" ]
            [ span
                [ class "help has-text-weight-semibold"
                , attribute "style" "top: 20px; position: relative;" -- @DEBUG: How to Jump line when flex overflow occurs?
                ]
                [ text "Recent activities:" ]
            , div [ class "tabs is-right is-small" ]
                [ ul []
                    [ li [ class "is-active" ]
                        [ a [] [ Fa.icon "fas fa-exchange-alt fa-sm" Text.tensionH ]
                        ]
                    , li []
                        [ a [ class "has-text-grey" ] [ Fa.icon "fas fa-history fa-sm" Text.journalH ]
                        ]
                    ]
                ]
            ]
        , div [ classList [ ( "content", True ), ( "spinner", model.circle_tensions == LoadingSlowly ) ] ]
            [ case model.circle_tensions of
                Success tensions ->
                    if List.length tensions > 0 then
                        List.map (\t -> mediaTension t) tensions
                            |> div [ class "is-size-7", id "tensionsTab" ]

                    else
                        case model.node_focus.type_ of
                            NodeType.Role ->
                                div [] [ text Text.noTensionRole ]

                            NodeType.Circle ->
                                div [] [ text Text.noTensionCircle ]

                Failure err ->
                    viewErrors err

                default ->
                    div [] []
            ]
        ]


mediaTension : Tension -> Html Msg
mediaTension tension =
    div [ class "media mediaTension" ]
        [ div [ class "media-left" ]
            [ div
                [ class "tooltip has-tooltip-top"
                , attribute "data-tooltip" ("type: " ++ TensionType.toString tension.type_)
                ]
                [ div [ class <| "Circle " ++ tensionTypeColor "text" tension.type_ ] [ text "" ] ]
            ]
        , div [ class "media-content" ]
            [ div [ class "content" ]
                [ div [ class "has-text-weight-semibold" ]
                    [ text tension.title ]
                ]
            , div [ class "labelsList" ] <|
                (tension.labels
                    |> withDefault []
                    |> List.map
                        (\label ->
                            span [ class "tag" ] [ text label.name ]
                        )
                )
            , br [ class "is-block" ] []
            , span [] <| edgeArrow "has-text-weight-light" (viewNodeRef OverviewBaseUri tension.emitter) (viewNodeRef OverviewBaseUri tension.receiver)
            , span [] []
            , span [ class "is-pulled-right has-text-weight-light" ]
                [ case tension.action of
                    Just TensionAction.NewCircle ->
                        Fa.icon0 "far fa-circle" ""

                    Just TensionAction.NewRole ->
                        Fa.icon0 "far fa-user" ""

                    Nothing ->
                        span [] []
                , span []
                    [ "opened the " ++ formatTime tension.createdAt ++ " by " |> text
                    , a [ href (uriFromUsername UsersBaseUri tension.createdBy.username) ] [ "@" ++ tension.createdBy.username |> text ]
                    ]
                ]
            ]
        , div
            [ class "media-right" ]
            [ let
                n_comments =
                    tension.n_comments |> withDefault 0
              in
              if n_comments > 0 then
                div
                    [ class "tooltip has-tooltip-top"
                    , attribute "data-tooltip" ("comments: " ++ String.fromInt n_comments)
                    ]
                    [ Fa.icon0 "fas fa-comment-dots" (String.fromInt n_comments)
                    ]

              else
                text ""
            ]
        ]


setupActionModal : Model -> Html Msg
setupActionModal model =
    div
        [ id "actionModal"
        , classList
            [ ( "modal", True )
            , ( "modal-fx-fadeIn", True )
            , ( "is-active", model.isModalActive )
            , ( "protected_", model.isModalActive )
            ]
        ]
        [ div
            [ classList
                [ ( "modal-background", True )
                , ( "protected_", model.isModalActive )
                ]
            ]
            []
        , div [ class "modal-content" ]
            [ case model.node_action of
                action ->
                    viewActionStep model action
            ]
        , button
            [ classList
                [ ( "modal-close", True )
                , ( "is-large", True )
                , ( "protected_", model.isModalActive )
                ]
            ]
            []
        ]


viewJoinOrgaStep : OrgaData -> JoinStep JoinOrgaForm -> Html Msg
viewJoinOrgaStep orga step =
    case step of
        JoinInit _ ->
            div [ class "box spinner" ] [ text Text.loading ]

        JoinAuthNeeded ->
            viewAuthNeeded

        JoinNotAuthorized errMsg ->
            viewErrors errMsg

        JoinValidation form result ->
            case result of
                Success _ ->
                    div [ class "box has-background-success" ] [ "Welcome in " ++ getNodeName form.rootnameid orga |> text ]

                Failure err ->
                    viewErrors err

                default ->
                    div [ class "box spinner" ] [ text Text.loading ]


viewActionStep : Model -> ActionState -> Html Msg
viewActionStep model action =
    case action of
        ActionChoice node ->
            div [ class "modal-card" ]
                [ div [ class "modal-card-head" ]
                    [ div [] <|
                        List.intersperse (text "\u{00A0}")
                            [ span [ class "has-text-weight-medium" ] [ text "What action do you want to do with the" ]
                            , span [ class "has-text-weight-bold is-underline-dotted" ] [ text node.name ]
                            , span [ class "is-lowercase has-text-weight-semibold" ] [ text <| NodeType.toString node.type_ ]
                            , text "?"
                            ]
                    ]
                , div [ class "modal-card-body" ]
                    [ div [ class "level" ] <|
                        if node.type_ == NodeType.Circle then
                            [ div [ class "level-item" ] [ div [ class "button has-background-primary", onClick (DoTensionInit node) ] [ text "New Tension" ] ]
                            , div [ class "level-item" ] [ div [ class "button has-background-info", onClick (DoCircleInit node NodeType.Role) ] [ text "New Role" ] ]
                            , div [ class "level-item" ] [ div [ class "button has-background-link", onClick (DoCircleInit node NodeType.Circle) ] [ text "New Sub-Circle" ] ]
                            ]

                        else
                            [ div [ class "level-item" ] [ div [ class "button is-primary", onClick (DoTensionInit node) ] [ text "New Tension" ] ] ]
                    ]
                ]

        AddTension step ->
            viewTensionStep step

        AddCircle step ->
            viewCircleStep step

        JoinOrga step ->
            viewJoinOrgaStep model.orga_data step

        NotAsk ->
            text ""

        AskErr err ->
            viewErrors [ err ]

        ActionAuthNeeded ->
            viewAuthNeeded


viewTensionStep : TensionStep TensionForm -> Html Msg
viewTensionStep step =
    case step of
        TensionNotAuthorized errMsg ->
            viewWarnings errMsg

        TensionInit form ->
            div [ class "modal-card" ]
                [ div [ class "modal-card-head" ]
                    [ span [ class "has-text-weight-medium" ] [ text "Choose the type of tension to communicate:" ] ]
                , div [ class "modal-card-body" ]
                    [ div [ class "level buttonRadio" ] <|
                        List.map
                            (\tensionType ->
                                div [ class "level-item" ]
                                    [ div
                                        [ class <| "button " ++ tensionTypeColor "background" tensionType
                                        , onClick (DoTensionSource tensionType)
                                        ]
                                        [ TensionType.toString tensionType |> text ]
                                    ]
                            )
                        <|
                            TensionType.list
                    ]
                ]

        TensionSource form roles ->
            div [ class "modal-card" ]
                [ div [ class "modal-card-head" ]
                    [ span [ class "has-text-weight-medium" ] [ text "You have several roles in this organisation. Please select the role from which you want to create this Tension:" ] ]
                , div [ class "modal-card-body" ]
                    [ div [ class "buttons buttonRadio" ] <|
                        List.map (\role -> div [ class "button", onClick (DoTensionFinal role) ] [ String.join "/" [ getParentFragmentFromRole role, role.name ] |> text ]) roles
                    ]
                ]

        TensionFinal form result ->
            Form.NewTension.view form result ChangeTensionPost DoCloseModal Submit SubmitTension


viewCircleStep : CircleStep CircleForm -> Html Msg
viewCircleStep step =
    case step of
        CircleNotAuthorized errMsg ->
            viewWarnings errMsg

        CircleInit form ->
            -- Node mode selection not implemented yet.
            div [] [ text "" ]

        CircleSource form roles ->
            let
                nT =
                    NodeType.toString form.type_
            in
            div [ class "modal-card" ]
                [ div [ class "modal-card-head" ]
                    [ span [ class "has-text-weight-medium" ] [ "You have several roles in this organisation. Please select the role from which you want to create this" ++ nT ++ ":" |> text ] ]
                , div [ class "modal-card-body" ]
                    [ div [ class "buttons buttonRadio" ] <|
                        List.map (\role -> div [ class "button", onClick (DoCircleFinal role) ] [ String.join "/" [ getParentFragmentFromRole role, role.name ] |> text ]) roles
                    ]
                ]

        CircleFinal form result ->
            Form.NewCircle.view form result ChangeCirclePost DoCloseModal Submit SubmitCircle



-------------------------------------------------
-- Model Getters and Setters
-------------------------------------------------


{-|

    Push a new tension in the model if data is success

-}
hotTensionPush : Tension -> CircleTensionsData -> TensionsData
hotTensionPush tension circle_tensions =
    case circle_tensions of
        Success tensions ->
            [ tension ] ++ tensions

        other ->
            []


{-|

    Push a new node in the model if data is success

-}
hotNodePush : List Node -> OrgaData -> NodesData
hotNodePush nodes odata =
    case odata of
        Success data ->
            Dict.union (List.map (\n -> ( n.nameid, n )) nodes |> Dict.fromList) data

        other ->
            Dict.empty