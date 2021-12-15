module Components.ActionPanel exposing (Msg(..), State, init, isOpen_, subscriptions, update, view)

import Auth exposing (ErrState(..), parseErr)
import Browser.Events as Events
import Components.Loading as Loading exposing (GqlData, ModalData, RequestResult(..), isSuccess, viewGqlErrors)
import Components.ModalConfirm as ModalConfirm exposing (ModalConfirm, TextMessage)
import Components.MoveTension as MoveTension
import Components.UserInput as UserInput
import Dict exposing (Dict)
import Dom
import Extra exposing (mor, ternary)
import Extra.Events exposing (onClickPD)
import Extra.Views exposing (showMsg)
import Form exposing (isPostEmpty, isUsersSendable)
import Fractal.Enum.ContractStatus as ContractStatus
import Fractal.Enum.ContractType as ContractType
import Fractal.Enum.NodeMode as NodeMode
import Fractal.Enum.NodeType as NodeType
import Fractal.Enum.NodeVisibility as NodeVisibility
import Fractal.Enum.RoleType as RoleType
import Fractal.Enum.TensionAction as TensionAction
import Fractal.Enum.TensionEvent as TensionEvent
import Generated.Route as Route exposing (Route, toHref)
import Global exposing (send, sendNow, sendSleep)
import Html exposing (Html, a, br, button, div, h1, h2, hr, i, input, label, li, nav, option, p, pre, section, select, span, text, textarea, ul)
import Html.Attributes exposing (attribute, checked, class, classList, disabled, for, href, id, list, name, placeholder, required, rows, selected, target, type_, value)
import Html.Events exposing (onBlur, onClick, onFocus, onInput, onMouseEnter)
import Icon as I
import Iso8601 exposing (fromTime)
import List.Extra as LE
import Maybe exposing (withDefault)
import ModelCommon exposing (ActionForm, Ev, UserState(..), blobFromTensionHead, buildVote, ev2eventFragment, initActionForm)
import ModelCommon.Codecs exposing (ActionType(..), DocType(..), TensionCharac, contractIdCodec, nid2rootid, voteIdCodec)
import ModelCommon.View exposing (roleColor, viewUserFull)
import ModelSchema exposing (..)
import Ports
import Query.AddContract exposing (addOneContract)
import Query.PatchTension exposing (actionRequest)
import Query.QueryTension exposing (getTensionHead)
import Session exposing (Apis, GlobalCmd(..))
import String.Format as Format
import Text as T exposing (textH, textT, upH)
import Time


type State
    = State Model


type alias Model =
    { user : UserState
    , action_result : GqlData IdPayload
    , isOpen : Bool
    , isModalActive : Bool
    , form : ActionForm
    , state : PanelState
    , step : ActionStep
    , domid : String -- allow multiple panel to coexists

    -- Common
    , refresh_trial : Int -- use to refresh user token
    , modal_confirm : ModalConfirm Msg

    -- Components
    , moveTension : MoveTension.State
    , userInput : UserInput.State
    }


type PanelState
    = MoveAction
    | VisibilityAction
    | AuthorityAction
    | LinkAction
    | UnLinkAction User
    | ArchiveAction
    | UnarchiveAction
    | LeaveAction


type ActionStep
    = StepOne
    | StepAck


initModel : UserState -> Model
initModel user =
    { user = user
    , action_result = NotAsked
    , isOpen = False
    , isModalActive = False
    , form = initActionForm "" user
    , state = LinkAction -- random
    , step = StepOne
    , domid = ""

    -- Common
    , refresh_trial = 0
    , modal_confirm = ModalConfirm.init NoMsg
    , moveTension = MoveTension.init user
    , userInput = UserInput.init user
    }


init : UserState -> State
init user =
    initModel user |> State


action2str : PanelState -> String
action2str action =
    case action of
        MoveAction ->
            upH T.move

        VisibilityAction ->
            upH T.visibility

        AuthorityAction ->
            upH T.authority

        LinkAction ->
            upH T.invite

        UnLinkAction _ ->
            upH T.unlink

        ArchiveAction ->
            upH T.archive

        UnarchiveAction ->
            upH T.unarchive

        LeaveAction ->
            upH T.leaveRole


auth2str : NodeType.NodeType -> String
auth2str type_ =
    case type_ of
        NodeType.Circle ->
            upH T.governance

        NodeType.Role ->
            upH T.authority


action2submitstr : PanelState -> String
action2submitstr action =
    case action of
        MoveAction ->
            upH T.move

        VisibilityAction ->
            upH T.submit

        AuthorityAction ->
            upH T.submit

        LinkAction ->
            upH T.invite

        UnLinkAction _ ->
            upH T.unlink

        ArchiveAction ->
            upH T.archive

        UnarchiveAction ->
            upH T.unarchive

        LeaveAction ->
            upH T.leaveRole


action2header : PanelState -> NodeType.NodeType -> String
action2header action type_ =
    case action of
        MoveAction ->
            "Move {{type}}: "

        VisibilityAction ->
            "Change Visibility of: "

        AuthorityAction ->
            case type_ of
                NodeType.Circle ->
                    "Change Governance process of: "

                NodeType.Role ->
                    "Change Authority of: "

        LinkAction ->
            "New first-link for Role: "

        UnLinkAction _ ->
            "Unlink the Role: "

        ArchiveAction ->
            "Archive {{type}}: "

        UnarchiveAction ->
            "Unarchive {{type}}: "

        LeaveAction ->
            "Leave {{type}}: "


action2post : PanelState -> String
action2post action =
    case action of
        MoveAction ->
            T.moved

        VisibilityAction ->
            T.visibility ++ " " ++ T.changed

        AuthorityAction ->
            T.authority ++ " " ++ T.changed

        LinkAction ->
            "User has been invited"

        UnLinkAction _ ->
            "User unlinked"

        ArchiveAction ->
            T.documentArchived

        UnarchiveAction ->
            T.documentUnarchived

        LeaveAction ->
            T.roleLeft


action2color : PanelState -> String
action2color action =
    case action of
        VisibilityAction ->
            "warning"

        AuthorityAction ->
            "warning"

        ArchiveAction ->
            "warning"

        LinkAction ->
            "link"

        UnLinkAction _ ->
            "danger"

        LeaveAction ->
            "danger"

        _ ->
            -- default
            ""



-- Global methods


isOpen_ : State -> Bool
isOpen_ (State model) =
    model.isOpen



--- State Controls


open : String -> String -> String -> Node -> Model -> Model
open domid tid bid node data =
    let
        f =
            data.form
    in
    { data | isOpen = True, domid = domid }
        |> setTid tid
        |> setBid bid
        |> setNode node
        |> setFragment (\frag -> { frag | type_ = Just node.type_ })


close : Model -> Model
close data =
    { data | isOpen = False }


setActionResult : GqlData IdPayload -> Model -> Model
setActionResult result data =
    let
        ( isModalActive, step ) =
            case result of
                Success _ ->
                    ( data.isModalActive, StepAck )

                Failure _ ->
                    ( data.isModalActive, data.step )

                _ ->
                    ( data.isModalActive, data.step )
    in
    { data | action_result = result, isModalActive = isModalActive, step = step }


openModal : Model -> Model
openModal data =
    { data | isModalActive = True }


closeModal : Model -> Model
closeModal data =
    { data | isModalActive = False }


reset : Model -> Model
reset data =
    let
        f =
            data.form
    in
    { data | isOpen = False, isModalActive = False, form = initActionForm f.tid (LoggedIn f.uctx), action_result = NotAsked }


setStep : ActionStep -> Model -> Model
setStep step data =
    { data | step = step }


setAction : PanelState -> Model -> Model
setAction action data =
    { data | state = action }


setActionForm : Model -> Model
setActionForm data =
    let
        node =
            data.form.node

        frag =
            data.form.fragment

        events =
            case data.state of
                MoveAction ->
                    -- @see MoveTension.elm
                    []

                VisibilityAction ->
                    [ Ev TensionEvent.Visibility
                        (node.visibility |> NodeVisibility.toString)
                        (frag.visibility |> withDefault node.visibility |> NodeVisibility.toString)
                    ]

                AuthorityAction ->
                    case node.type_ of
                        NodeType.Circle ->
                            [ Ev TensionEvent.Authority
                                (node.mode |> NodeMode.toString)
                                (frag.mode |> withDefault node.mode |> NodeMode.toString)
                            ]

                        NodeType.Role ->
                            [ Ev TensionEvent.Authority
                                (node.role_type |> Maybe.map (\rt -> RoleType.toString rt) |> withDefault "")
                                (mor frag.role_type node.role_type |> Maybe.map (\rt -> RoleType.toString rt) |> withDefault "")
                            ]

                LinkAction ->
                    [ Ev TensionEvent.MemberLinked
                        (node.first_link |> Maybe.map (\x -> x.username) |> withDefault "")
                        (mor frag.first_link (node.first_link |> Maybe.map (\x -> x.username)) |> withDefault "")
                    ]

                UnLinkAction user ->
                    [ Ev TensionEvent.MemberUnlinked
                        user.username
                        ""
                    ]

                ArchiveAction ->
                    [ Ev TensionEvent.BlobArchived "" "" ]

                UnarchiveAction ->
                    [ Ev TensionEvent.BlobUnarchived "" "" ]

                LeaveAction ->
                    [ Ev TensionEvent.UserLeft
                        (node.role_type |> Maybe.map (\rt -> RoleType.toString rt) |> withDefault "")
                        node.nameid
                    ]
    in
    data |> setEvents events


updatePost : String -> String -> Model -> Model
updatePost field value data =
    let
        f =
            data.form
    in
    { data | form = { f | post = Dict.insert field value f.post } }


setTid : String -> Model -> Model
setTid tid data =
    let
        f =
            data.form
    in
    { data | form = { f | tid = tid } }


setBid : String -> Model -> Model
setBid bid data =
    let
        f =
            data.form
    in
    { data | form = { f | bid = bid } }


setNode : Node -> Model -> Model
setNode n data =
    let
        f =
            data.form
    in
    { data | form = { f | node = n } }


setFragment : (NodeFragment -> NodeFragment) -> Model -> Model
setFragment fun data =
    let
        f =
            data.form
    in
    { data | form = { f | fragment = fun f.fragment } }


setEvents : List Ev -> Model -> Model
setEvents events data =
    let
        f =
            data.form
    in
    { data | form = { f | events = events } }



-- utils


canExitSafe : Model -> Bool
canExitSafe model =
    -- Condition to close safely (e.g. empty form data)
    (hasData model
        == False
        && (case model.state of
                VisibilityAction ->
                    List.member model.form.fragment.visibility [ Just model.form.node.visibility, Nothing ]

                AuthorityAction ->
                    case model.form.node.type_ of
                        NodeType.Circle ->
                            List.member model.form.fragment.mode [ Just model.form.node.mode, Nothing ]

                        NodeType.Role ->
                            List.member model.form.fragment.role_type [ model.form.node.role_type, Nothing ]

                LinkAction ->
                    not (isUsersSendable model.form.users)

                _ ->
                    True
           )
    )
        || isSuccess model.action_result


hasData : Model -> Bool
hasData model =
    -- When you can commit (e.g. empty form data)
    isPostEmpty [ "message" ] model.form.post == False


isSendable : Model -> Bool
isSendable model =
    case model.state of
        VisibilityAction ->
            model.form.node.visibility /= withDefault model.form.node.visibility model.form.fragment.visibility

        AuthorityAction ->
            case model.form.node.type_ of
                NodeType.Circle ->
                    model.form.node.mode /= withDefault model.form.node.mode model.form.fragment.mode

                NodeType.Role ->
                    model.form.node.role_type /= mor model.form.fragment.role_type model.form.node.role_type

        LinkAction ->
            isUsersSendable model.form.users

        _ ->
            True



-- ------------------------------
-- U P D A T E
-- ------------------------------


type Msg
    = -- Data
      OnOpen String String String Node
    | OnClose
    | OnReset
    | PushAction ActionForm PanelState
    | OnSubmit (Time.Posix -> Msg)
    | OnOpenModal PanelState
    | OnOpenModal2 PanelState (GqlData NodesDict)
    | OnCloseModal ModalData
    | OnCloseModalSafe String String
    | OnUpdatePost String String
    | OnChangeVisibility NodeVisibility.NodeVisibility
    | OnChangeMode NodeMode.NodeMode
    | OnChangeRoleType RoleType.RoleType
    | OnActionSubmit Time.Posix
    | OnActionMove
      --
      --| ActionStep1 xxx
    | GotTensionToMove (GqlData TensionHead)
    | PushAck (GqlData IdPayload)
      -- move tension
    | DoMove TensionHead
      -- Confirm Modal
    | DoModalConfirmOpen Msg TextMessage
    | DoModalConfirmClose ModalData
    | DoModalConfirmSend
      -- Common
    | NoMsg
    | LogErr String
    | Navigate String
      -- Components
    | MoveTensionMsg MoveTension.Msg
    | UserInputMsg UserInput.Msg


type alias Out =
    { cmds : List (Cmd Msg)
    , gcmds : List GlobalCmd
    , result : Maybe NodeFragment
    }


noOut : Out
noOut =
    Out [] [] Nothing


out0 : List (Cmd Msg) -> Out
out0 cmds =
    Out cmds [] Nothing


out1 : List GlobalCmd -> Out
out1 cmds =
    Out [] cmds Nothing


out2 : List (Cmd Msg) -> List GlobalCmd -> Out
out2 cmds gcmds =
    Out cmds gcmds Nothing


update : Apis -> Msg -> State -> ( State, Out )
update apis message (State model) =
    update_ apis message model
        |> Tuple.mapFirst State


update_ apis message model =
    case message of
        -- Data
        OnOpen domid tid bid node ->
            if model.isOpen == False then
                ( open domid tid bid node model, noOut )

            else
                -- Ports.click: unlock canvas Tooltip. when clickinb back.
                ( close model
                , out0 [ ternary (model.domid == "actionPanelContentTooltip") (Ports.click "canvasOrga") Cmd.none ]
                )

        OnClose ->
            ( close model, noOut )

        OnReset ->
            ( reset model, noOut )

        PushAction form state ->
            case state of
                LinkAction ->
                    let
                        -- @codefactor: put it in Codec.contractIdCodec.
                        -- (pobleme with circular import due to TensionEvent defined in ModelCommon)
                        ( et, old, new ) =
                            List.head form.events
                                |> Maybe.map (\x -> ( TensionEvent.toString x.event_type, x.old, x.new ))
                                |> withDefault ( "", "", "" )

                        contractid =
                            contractIdCodec form.tid et old new

                        rootnameid =
                            nid2rootid form.node.nameid

                        -- Feed candidate and pendingcandidate
                        ( candidates, pending_candidates ) =
                            List.foldl
                                (\uf ( cand, pend ) ->
                                    ( [], [] )
                                )
                                ( [], [] )
                                form.users

                        --form.users |> ...
                        contractForm =
                            { uctx = form.uctx
                            , tid = form.tid
                            , event = form.events |> List.map ev2eventFragment |> List.head |> withDefault initEventFragment
                            , post = form.post
                            , status = ContractStatus.Open
                            , contract_type = ContractType.AnyCandidates
                            , contractid = contractid
                            , participants = [ buildVote contractid rootnameid form.uctx.username 1 ]
                            , candidates = candidates
                            , pending_candidates = pending_candidates
                            }
                    in
                    ( model, out0 [ addOneContract apis.gql contractForm PushAck ] )

                _ ->
                    ( model, out0 [ actionRequest apis.gql form PushAck ] )

        OnSubmit next ->
            ( model, out0 [ sendNow next ] )

        OnOpenModal action ->
            let
                newModel =
                    model
                        |> openModal
                        |> setAction action
                        |> setStep StepOne
            in
            ( newModel, out0 [ Ports.open_modal ("actionPanelModal" ++ model.domid) ] )

        OnOpenModal2 action orga_data ->
            let
                newModel =
                    model
                        |> openModal
                        |> setAction action
                        |> setStep StepOne

                cmds =
                    case action of
                        LinkAction ->
                            [ Cmd.map UserInputMsg (send (UserInput.OnLoad orga_data)) ]

                        _ ->
                            []
            in
            ( newModel, out0 ([ Ports.open_modal ("actionPanelModal" ++ model.domid) ] ++ cmds) )

        OnCloseModal data ->
            let
                cmds =
                    ternary data.reset [ sendSleep OnReset 333 ] []

                gcmds =
                    if data.link /= "" then
                        [ DoNavigate data.link ]

                    else if isSuccess model.action_result then
                        case model.state of
                            MoveAction ->
                                []

                            VisibilityAction ->
                                let
                                    visibility =
                                        withDefault model.form.node.visibility model.form.fragment.visibility
                                in
                                [ DoUpdateNode model.form.node.nameid (\n -> { n | visibility = visibility }) ]

                            AuthorityAction ->
                                case model.form.node.type_ of
                                    NodeType.Circle ->
                                        let
                                            mode =
                                                withDefault model.form.node.mode model.form.fragment.mode
                                        in
                                        [ DoUpdateNode model.form.node.nameid (\n -> { n | mode = mode }) ]

                                    NodeType.Role ->
                                        let
                                            role_type =
                                                mor model.form.fragment.role_type model.form.node.role_type
                                        in
                                        [ DoUpdateNode model.form.node.nameid (\n -> { n | role_type = role_type }) ]

                            LinkAction ->
                                let
                                    fs =
                                        Just { username = withDefault "" model.form.fragment.first_link, name = Nothing }
                                in
                                [ DoUpdateNode model.form.node.nameid (\n -> { n | first_link = fs }) ]

                            UnLinkAction _ ->
                                [ DoUpdateNode model.form.node.nameid (\n -> { n | first_link = Nothing }) ]

                            ArchiveAction ->
                                [ DoDelNodes [ model.form.node.nameid ] ]

                            UnarchiveAction ->
                                []

                            LeaveAction ->
                                -- Ignore Guest deletion (either non visible or very small)
                                [ DoUpdateNode model.form.node.nameid (\n -> { n | first_link = Nothing }) ]

                    else
                        []
            in
            ( closeModal model
              -- Ports.click: unock the tooltip if click from the tooltip, else avoid id as the click will move to the parent node
            , Out
                (cmds ++ [ Ports.close_modal, ternary (model.domid == "actionPanelContentTooltip") (Ports.click "canvasOrga") Cmd.none ])
                gcmds
                (ternary (isSuccess model.action_result)
                    (Just model.form.fragment)
                    Nothing
                )
            )

        OnUpdatePost field value ->
            ( updatePost field value model, noOut )

        OnChangeVisibility visibility ->
            ( setFragment (\frag -> { frag | visibility = Just visibility }) model, noOut )

        OnChangeMode mode ->
            ( setFragment (\frag -> { frag | mode = Just mode }) model, noOut )

        OnChangeRoleType role_type ->
            ( setFragment (\frag -> { frag | role_type = Just role_type }) model, noOut )

        OnActionSubmit time ->
            let
                data =
                    model
                        |> updatePost "createdAt" (fromTime time)
                        |> setActionForm
                        |> setActionResult LoadingSlowly
            in
            ( data, out0 [ send (PushAction data.form data.state) ] )

        PushAck result ->
            case parseErr result model.refresh_trial of
                Authenticate ->
                    ( setActionResult NotAsked model
                    , out1 [ DoAuth model.form.uctx ]
                    )

                RefreshToken i ->
                    ( { model | refresh_trial = i }, out2 [ sendSleep (PushAction model.form model.state) 500 ] [ DoUpdateToken ] )

                OkAuth _ ->
                    ( model |> setActionResult result, noOut )

                _ ->
                    ( model |> setActionResult result, noOut )

        OnActionMove ->
            ( model, out0 [ getTensionHead apis.gql model.form.tid GotTensionToMove ] )

        GotTensionToMove result ->
            case result of
                Success th ->
                    ( model, out0 [ send (DoMove th) ] )

                _ ->
                    ( model, noOut )

        DoMove t ->
            ( model, out0 [ Cmd.map MoveTensionMsg (send (MoveTension.OnOpen t.id t.receiver.nameid (blobFromTensionHead t))) ] )

        -- Confirm Modal
        DoModalConfirmOpen msg mess ->
            ( { model | modal_confirm = ModalConfirm.open msg mess model.modal_confirm }, noOut )

        DoModalConfirmClose _ ->
            ( { model | modal_confirm = ModalConfirm.close model.modal_confirm }, noOut )

        DoModalConfirmSend ->
            ( { model | modal_confirm = ModalConfirm.close model.modal_confirm }, out0 [ send model.modal_confirm.msg ] )

        -- Common
        NoMsg ->
            ( model, noOut )

        LogErr err ->
            ( model, out0 [ Ports.logErr err ] )

        Navigate link ->
            ( model, out1 [ DoNavigate link ] )

        OnCloseModalSafe link onCloseTxt ->
            if canExitSafe model then
                ( model, out0 [ send (OnCloseModal { reset = True, link = link }) ] )

            else
                ( model
                , out0 [ send (DoModalConfirmOpen (OnCloseModal { reset = True, link = link }) { message = Nothing, txts = [ ( upH T.confirmUnsaved, onCloseTxt ) ] }) ]
                )

        -- Components
        MoveTensionMsg msg ->
            let
                ( data, out ) =
                    MoveTension.update apis msg model.moveTension

                ( cmds, gcmds ) =
                    out.result
                        |> Maybe.map
                            (\x ->
                                let
                                    closing =
                                        Tuple.first x
                                in
                                if closing && Tuple.second x /= Nothing then
                                    let
                                        ( nameid, parentid_new, nameid_new ) =
                                            Tuple.second x |> withDefault ( "", "", "" )
                                    in
                                    ( [], [ DoMoveNode nameid parentid_new nameid_new ] )

                                else if closing && (model.domid == "actionPanelContentTooltip") then
                                    ( [ Ports.click "canvasOrga" ], [] )

                                else
                                    ( [], [] )
                            )
                        |> withDefault ( [], [] )
            in
            ( { model | moveTension = data }, out2 (List.map (\m -> Cmd.map MoveTensionMsg m) out.cmds |> List.append cmds) (out.gcmds ++ gcmds) )

        UserInputMsg msg ->
            let
                ( data, out ) =
                    UserInput.update apis msg model.userInput

                users =
                    out.result
                        |> Maybe.map
                            (\( t, u ) ->
                                if t then
                                    u

                                else
                                    []
                            )
                        |> withDefault model.form.users

                ( cmds, gcmds ) =
                    ( [], [] )

                form =
                    model.form
            in
            ( { model | userInput = data, form = { form | users = users } }, out2 (List.map (\m -> Cmd.map UserInputMsg m) out.cmds |> List.append cmds) (out.gcmds ++ gcmds) )


subscriptions : State -> List (Sub Msg)
subscriptions (State model) =
    [ --Ports.mcPD Ports.closeActionPanelModalFromJs LogErr OnCloseModal
      Ports.mcPD Ports.closeModalConfirmFromJs LogErr DoModalConfirmClose
    ]
        ++ (MoveTension.subscriptions |> List.map (\s -> Sub.map MoveTensionMsg s))
        ++ (UserInput.subscriptions |> List.map (\s -> Sub.map UserInputMsg s))
        ++ (if model.isOpen then
                [ Events.onMouseUp (Dom.outsideClickClose model.domid OnClose)
                , Events.onKeyUp (Dom.key "Escape" OnClose)
                ]

            else if model.isModalActive then
                [ Events.onKeyUp (Dom.key "Escape" (OnCloseModal { reset = False, link = "" }))
                ]

            else
                []
           )



-- ------------------------------
-- V I E W
-- ------------------------------


type alias Op =
    { tc : Maybe TensionCharac
    , isAdmin : Bool
    , hasRole : Bool
    , isRight : Bool -- view option
    , domid : String
    , orga_data : GqlData NodesDict
    }


view : Op -> State -> Html Msg
view op (State model) =
    div [] <|
        if model.domid == op.domid then
            [ if model.isOpen then
                viewPanel op model

              else
                text ""
            ]
                ++ [ viewModal op model
                   , ModalConfirm.view { data = model.modal_confirm, onClose = DoModalConfirmClose, onConfirm = DoModalConfirmSend }
                   , MoveTension.view { orga_data = op.orga_data } model.moveTension |> Html.map MoveTensionMsg
                   ]

        else
            []


viewPanel : Op -> Model -> Html Msg
viewPanel op model =
    div [ class "actionPanelStyle" ]
        [ div [ class "dropdown-content", classList [ ( "is-right", op.isRight ) ] ] <|
            (-- EDIT ACTION
             if model.form.node.role_type /= Just RoleType.Guest then
                [ div
                    [ class "dropdown-item button-light"
                    , onClick
                        (Navigate
                            ((Route.Tension_Dynamic_Dynamic_Action { param1 = nid2rootid model.form.node.nameid, param2 = model.form.tid } |> toHref)
                                ++ "?v=edit"
                            )
                        )
                    ]
                    [ I.icon1 "icon-edit-2" (upH T.edit) ]
                , hr [ class "dropdown-divider" ] []
                ]

             else
                []
            )
                -- ACTION
                ++ (if op.isAdmin then
                        [ -- Move Action
                          div [ class "dropdown-item button-light", onClick OnActionMove ]
                            [ span [ class "right-arrow2 pl-0 pr-3" ] [], text (action2str MoveAction) ]

                        -- Authority Action
                        , div [ class "dropdown-item button-light", onClick (OnOpenModal AuthorityAction) ]
                            [ I.icon1 "icon-key" (auth2str model.form.node.type_) ]
                        , case model.form.node.type_ of
                            -- Visibility Action
                            NodeType.Circle ->
                                div [ class "dropdown-item button-light", onClick (OnOpenModal VisibilityAction) ]
                                    [ I.icon1 "icon-lock" (action2str VisibilityAction) ]

                            -- Link/Unlink Action
                            NodeType.Role ->
                                case model.form.node.first_link of
                                    Just user ->
                                        div [ class "dropdown-item button-light", onClick (OnOpenModal (UnLinkAction user)) ]
                                            [ I.icon1 "icon-user-plus" (action2str (UnLinkAction user)) ]

                                    Nothing ->
                                        div [ class "dropdown-item button-light", onClick (OnOpenModal2 LinkAction op.orga_data) ]
                                            [ I.icon1 "icon-user-plus" (action2str LinkAction) ]

                        --
                        , hr [ class "dropdown-divider" ] []

                        -- Archive Action
                        , case Maybe.map (\c -> c.action_type) op.tc of
                            Just EDIT ->
                                div [ class "dropdown-item button-light is-warning", onClick (OnOpenModal ArchiveAction) ]
                                    [ I.icon1 "icon-archive" (action2str ArchiveAction) ]

                            Just ARCHIVE ->
                                div [ class "dropdown-item button-light", onClick (OnOpenModal UnarchiveAction) ]
                                    [ I.icon1 "icon-archive" (action2str UnarchiveAction) ]

                            _ ->
                                div [] [ text "not implemented" ]
                        ]

                    else
                        []
                   )
                -- LEAVE ACTION
                ++ (if op.hasRole then
                        [ div [ class "dropdown-item button-light is-danger", onClick (OnOpenModal LeaveAction) ]
                            [ p []
                                [ I.icon1 "icon-log-out" (action2str LeaveAction) ]
                            ]
                        ]
                            |> List.append [ hr [ class "dropdown-divider" ] [] ]

                    else
                        []
                   )
        ]


viewModal : Op -> Model -> Html Msg
viewModal op model =
    div
        [ id ("actionPanelModal" ++ model.domid)
        , class "modal modal-fx-fadeIn"
        , classList [ ( "is-active", model.isModalActive ) ]

        --, attribute "data-modal-close" "closeActionPanelModalFromJs"
        ]
        [ div
            [ class "modal-background modal-escape"
            , attribute "data-modal" ("actionPanelModal" ++ model.domid)
            , onClick (OnCloseModalSafe "" "")
            ]
            []
        , div [ class "modal-content" ] [ viewModalContent op model ]
        , button [ class "modal-close is-large", onClick (OnCloseModalSafe "" "") ] []
        ]


viewModalContent : Op -> Model -> Html Msg
viewModalContent op model =
    case model.step of
        StepOne ->
            viewStep1 op model

        StepAck ->
            case model.action_result of
                Success _ ->
                    div
                        [ class "box is-light" ]
                        [ I.icon1 "icon-check icon-2x has-text-success" " "
                        , textH (action2post model.state ++ ".")
                        ]

                Failure err ->
                    viewGqlErrors err

                _ ->
                    viewGqlErrors [ "not implemented." ]



--- Viewer


viewStep1 : Op -> Model -> Html Msg
viewStep1 op model =
    let
        color =
            action2color model.state

        isLoading =
            model.action_result == LoadingSlowly
    in
    div [ class "modal-card" ]
        [ div [ class ("modal-card-head has-background-" ++ color) ]
            [ div [ class "modal-card-title is-size-6 has-text-weight-semibold" ]
                [ action2header model.state model.form.node.type_
                    |> Format.namedValue "type" (NodeType.toString model.form.node.type_)
                    |> text
                    |> List.singleton
                    |> span []
                , span [ class "has-text-primary" ] [ text model.form.node.name ]
                ]
            ]
        , div [ class "modal-card-body" ] <|
            case model.state of
                VisibilityAction ->
                    [ viewVisibility op model ]

                AuthorityAction ->
                    case model.form.node.type_ of
                        NodeType.Circle ->
                            [ viewCircleAuthority op model ]

                        NodeType.Role ->
                            [ viewRoleAuthority op model ]

                LinkAction ->
                    [ UserInput.view {} model.userInput |> Html.map UserInputMsg
                    , viewComment op model
                    ]

                UnLinkAction user ->
                    [ div [ class "mb-5" ] [ text "Confirm to unlink user: ", viewUserFull 2 True True user ]
                    , viewComment op model
                    ]

                _ ->
                    [ viewComment op model ]
        , div [ class "modal-card-foot", attribute "style" "display: block;" ]
            [ case model.action_result of
                Failure err ->
                    div [ class "field" ] [ viewGqlErrors err ]

                _ ->
                    text ""
            , div [ class "field" ]
                [ div [ class "is-pulled-left" ]
                    [ button
                        [ class "button is-light"
                        , onClick (OnCloseModalSafe "" "")
                        ]
                        [ textH T.cancel ]
                    ]
                , div [ class "is-pulled-right" ]
                    [ button
                        ([ class ("button defaultSubmit is-light is-" ++ color)
                         , classList [ ( "is-loading", isLoading ) ]
                         , disabled (not (isSendable model) || isLoading)
                         ]
                            ++ [ onClick (OnSubmit <| OnActionSubmit) ]
                        )
                        [ model.state |> action2submitstr |> text ]
                    ]
                ]
            ]
        ]


viewComment : Op -> Model -> Html Msg
viewComment op model =
    let
        message =
            Dict.get "message" model.form.post |> withDefault ""
    in
    div [ class "field" ]
        [ div [ class "control submitFocus" ]
            [ textarea
                [ class "textarea in-modal"
                , rows 3
                , placeholder (upH T.leaveCommentOpt)
                , value message
                , onInput <| OnUpdatePost "message"
                ]
                []
            ]
        , p [ class "help-label" ] [ textH T.tensionMessageHelp ]
        ]



-- Specific Viewer


viewVisibility : Op -> Model -> Html Msg
viewVisibility op model =
    div []
        [ -- Show the help information
          showMsg "visibility-0" "is-info" "icon-info" T.visibilityInfoHeader ""

        -- Show the choices as card.
        , NodeVisibility.list
            |> List.map
                (\x ->
                    let
                        isActive =
                            x == withDefault model.form.node.visibility model.form.fragment.visibility

                        ( icon, description ) =
                            case x of
                                NodeVisibility.Public ->
                                    ( "icon-globe", T.visibilityPublic )

                                NodeVisibility.Private ->
                                    ( "icon-users", T.visibilityPrivate )

                                NodeVisibility.Secret ->
                                    ( "icon-lock", T.visibilitySeccret )
                    in
                    div
                        [ class "card column is-paddingless m-3 is-w"
                        , classList [ ( "is-selected", isActive ) ]
                        , onClick (OnChangeVisibility x)
                        ]
                        [ div [ class "card-content p-4" ]
                            [ h2 [ class "is-strong is-size-5" ]
                                [ I.icon1 (icon ++ " icon-bg") (NodeVisibility.toString x) ]
                            , div [ class "content is-small" ]
                                [ text description ]
                            ]
                        ]
                )
            |> div [ class "columns" ]
        ]


viewCircleAuthority : Op -> Model -> Html Msg
viewCircleAuthority op model =
    div []
        [ -- Show the help information
          showMsg "circleAuthority-0" "is-info" "icon-info" T.circleAuthorityHeader T.circleAuthorityDoc

        -- Show the choices as card.
        , NodeMode.list
            |> List.map
                (\x ->
                    let
                        isActive =
                            x == withDefault model.form.node.mode model.form.fragment.mode

                        ( icon, description ) =
                            case x of
                                NodeMode.Coordinated ->
                                    ( "icon-", T.authCoordinated )

                                NodeMode.Agile ->
                                    ( "icon-", T.authAgile )
                    in
                    div
                        [ class "card column is-paddingless m-3 is-w"
                        , classList [ ( "is-selected", isActive ) ]
                        , onClick (OnChangeMode x)
                        ]
                        [ div [ class "card-content p-4" ]
                            [ h2 [ class "is-strong is-size-5" ]
                                [ I.icon1 (icon ++ " icon-bg") (NodeMode.toString x) ]
                            , div [ class "content is-small" ]
                                [ text description ]
                            ]
                        ]
                )
            |> div [ class "columns is-multiline" ]
        ]


viewRoleAuthority : Op -> Model -> Html Msg
viewRoleAuthority op model =
    div []
        [ -- Show the help information
          --showMsg "roleAuthority-0" "is-info" "icon-info" T.roleAuthorityHeader ""
          -- Show the choices as card.
          --RoleType.list
          [ ( RoleType.Peer, "Basic Role with restricted authorization." ), ( RoleType.Coordinator, "Role with administration rights at the circle level." ) ]
            |> List.map
                (\( x, description ) ->
                    let
                        isActive =
                            Just x == mor model.form.fragment.role_type model.form.node.role_type

                        icon =
                            "icon-user has-text-" ++ roleColor x
                    in
                    div
                        [ class "card column is-paddingless m-3 is-w"
                        , attribute "style" "min-width: 150px;"
                        , classList [ ( "is-selected", isActive ) ]
                        , onClick (OnChangeRoleType x)
                        ]
                        [ div [ class "card-content p-4" ]
                            [ h2 [ class "is-strong is-size-5" ]
                                [ I.icon1 (icon ++ " icon-bg") (RoleType.toString x) ]
                            , div [ class "content is-small" ]
                                [ text description ]
                            ]
                        ]
                )
            |> div [ class "columns is-multiline" ]
        ]
