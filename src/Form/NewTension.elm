module Form.NewTension exposing (..)

import Components.I as I
import Components.LabelSearchPanel as LabelSearchPanel
import Components.Loading as Loading exposing (GqlData, RequestResult(..), viewGqlErrors, withDefaultData, withMaybeData)
import Components.Markdown exposing (renderMarkdown)
import Components.NodeDoc as NodeDoc
import Dict
import Extra exposing (ternary)
import Extra.Events exposing (onClickPD, onClickPD2, onEnter, onKeydown, onTab)
import Form exposing (isPostEmpty, isPostSendable)
import Fractal.Enum.BlobType as BlobType
import Fractal.Enum.NodeType as NodeType
import Fractal.Enum.RoleType as RoleType
import Fractal.Enum.TensionAction as TensionAction
import Fractal.Enum.TensionEvent as TensionEvent
import Fractal.Enum.TensionStatus as TensionStatus
import Fractal.Enum.TensionType as TensionType
import Generated.Route as Route exposing (toHref)
import Html exposing (Html, a, br, button, datalist, div, h1, h2, hr, i, input, li, nav, option, p, span, tbody, td, text, textarea, th, thead, tr, ul)
import Html.Attributes exposing (attribute, class, classList, disabled, href, id, list, placeholder, required, rows, target, type_, value)
import Html.Events exposing (onClick, onInput, onMouseEnter)
import List.Extra as LE
import Maybe exposing (withDefault)
import ModelCommon exposing (InputViewMode(..), TensionForm, initTensionForm)
import ModelCommon.Codecs exposing (NodeFocus)
import ModelCommon.View exposing (edgeArrow, getTensionText, tensionTypeColor)
import ModelSchema exposing (..)
import Text as T exposing (textH, textT, upH)
import Time


type alias NewTensionForm =
    { form : TensionForm
    , result : GqlData Tension
    , activeButton : Maybe Int
    , viewMode : InputViewMode
    , isLookupOpen : Bool
    , doAddLinks : Bool
    , doAddResponsabilities : Bool
    , doAddDomains : Bool
    , doAddPolicies : Bool
    }


init : NodeFocus -> NewTensionForm
init focus =
    { form = initTensionForm focus
    , result = NotAsked
    , activeButton = Nothing
    , viewMode = Write
    , isLookupOpen = False
    , doAddLinks = False
    , doAddResponsabilities = False
    , doAddDomains = False
    , doAddPolicies = False
    }


initCircle : Node -> NodeType.NodeType -> NewTensionForm -> NewTensionForm
initCircle target type_ data =
    -- New Circle Tension
    let
        form =
            data.form

        action =
            case type_ of
                NodeType.Role ->
                    TensionAction.NewRole

                NodeType.Circle ->
                    TensionAction.NewCircle

        node =
            initNodeFragment (Just type_)

        newForm =
            { form
                | target = target
                , tension_type = TensionType.Governance
                , action = Just action
                , blob_type = Just BlobType.OnNode
                , node = { node | charac = Just target.charac } -- inherit charac
                , users = [ { username = "", role_type = ternary (type_ == NodeType.Circle) RoleType.Coordinator RoleType.Peer, pattern = "" } ]
            }
    in
    { data | form = newForm, result = NotAsked }



--- State Controls


setUctx : UserCtx -> NewTensionForm -> NewTensionForm
setUctx uctx data =
    let
        form =
            data.form
    in
    { data | form = { form | uctx = uctx } }


setTensionType : TensionType.TensionType -> NewTensionForm -> NewTensionForm
setTensionType type_ data =
    let
        form =
            data.form
    in
    { data | form = { form | tension_type = type_ } }


setActiveButton : Bool -> NewTensionForm -> NewTensionForm
setActiveButton doClose data =
    if doClose then
        { data | activeButton = Just 0 }

    else
        { data | activeButton = Just 1 }


setViewMode : InputViewMode -> NewTensionForm -> NewTensionForm
setViewMode viewMode data =
    { data | viewMode = viewMode }


setForm : TensionForm -> NewTensionForm -> NewTensionForm
setForm form data =
    { data | form = form }


setResult : GqlData Tension -> NewTensionForm -> NewTensionForm
setResult result data =
    { data | result = result }


addLinks : NewTensionForm -> NewTensionForm
addLinks data =
    { data | doAddLinks = True }


addResponsabilities : NewTensionForm -> NewTensionForm
addResponsabilities data =
    { data | doAddResponsabilities = True }


addDomains : NewTensionForm -> NewTensionForm
addDomains data =
    { data | doAddDomains = True }


addPolicies : NewTensionForm -> NewTensionForm
addPolicies data =
    { data | doAddPolicies = True }


hasData : NewTensionForm -> Bool
hasData data =
    isPostEmpty [ "title", "message" ] data.form.post == False



-- Update Form


setSource : UserRole -> NewTensionForm -> NewTensionForm
setSource source data =
    let
        f =
            data.form

        newForm =
            { f | source = source }
    in
    { data | form = newForm }


setTarget : Node -> Maybe NodeData -> NewTensionForm -> NewTensionForm
setTarget target node_data data =
    let
        f =
            data.form

        newForm =
            { f | target = target, targetData = node_data |> withDefault initNodeData }
    in
    { data | form = newForm }


setStatus : TensionStatus.TensionStatus -> NewTensionForm -> NewTensionForm
setStatus status data =
    let
        f =
            data.form

        newForm =
            { f | status = status }
    in
    { data | form = newForm }


setEvents : List TensionEvent.TensionEvent -> NewTensionForm -> NewTensionForm
setEvents events data =
    let
        f =
            data.form

        newForm =
            { f | events_type = Just events }
    in
    { data | form = newForm }


setLabels : List Label -> NewTensionForm -> NewTensionForm
setLabels labels data =
    let
        f =
            data.form

        newForm =
            { f | labels = labels }
    in
    { data | form = newForm }


addLabel : Label -> NewTensionForm -> NewTensionForm
addLabel label data =
    let
        f =
            data.form

        newForm =
            { f | labels = f.labels ++ [ label ] }
    in
    { data | form = newForm }


removeLabel : Label -> NewTensionForm -> NewTensionForm
removeLabel label data =
    let
        f =
            data.form

        newForm =
            { f | labels = LE.remove label f.labels }
    in
    { data | form = newForm }


post : String -> String -> NewTensionForm -> NewTensionForm
post field value data =
    let
        f =
            data.form

        newForm =
            { f | post = Dict.insert field value f.post }
    in
    { data | form = newForm }


resetPost : NewTensionForm -> NewTensionForm
resetPost data =
    let
        f =
            data.form

        newForm =
            { f | post = Dict.empty }
    in
    { data | form = newForm }


postNode : String -> String -> NewTensionForm -> NewTensionForm
postNode field value data =
    { data | form = NodeDoc.updateNodeForm field value data.form }



-- User Lookup


updateUserPattern : Int -> String -> NewTensionForm -> NewTensionForm
updateUserPattern pos pattern data =
    let
        f =
            data.form

        newForm =
            { f | users = NodeDoc.updateUserPattern_ pos pattern f.users }
    in
    { data | form = newForm }


updateUserRole : Int -> String -> NewTensionForm -> NewTensionForm
updateUserRole pos role data =
    let
        f =
            data.form

        newForm =
            { f | users = NodeDoc.updateUserRole_ pos role f.users }
    in
    { data | form = newForm }


selectUser : Int -> String -> NewTensionForm -> NewTensionForm
selectUser pos username data =
    let
        f =
            data.form

        newForm =
            { f | users = NodeDoc.selectUser_ pos username f.users }
    in
    { data | form = newForm, isLookupOpen = False }


cancelUser : Int -> NewTensionForm -> NewTensionForm
cancelUser pos data =
    let
        f =
            data.form

        newForm =
            { f | users = NodeDoc.cancelUser_ pos f.users }
    in
    { data | form = newForm, isLookupOpen = False }


openLookup : NewTensionForm -> NewTensionForm
openLookup data =
    { data | isLookupOpen = True }


closeLookup : NewTensionForm -> NewTensionForm
closeLookup data =
    { data | isLookupOpen = False }


canExitSafe : NewTensionForm -> Bool
canExitSafe data =
    hasData data && withMaybeData data.result == Nothing


type alias Op msg =
    { lookup : List User
    , users_data : GqlData UsersData
    , targets : List String
    , data : NewTensionForm

    -- Modal control
    , onChangeInputViewMode : InputViewMode -> msg
    , onSubmitTension : NewTensionForm -> Bool -> Time.Posix -> msg
    , onSubmit : (Time.Posix -> msg) -> msg
    , onCloseModal : String -> String -> Bool -> msg

    -- Doc change
    , onChangeTensionType : TensionType.TensionType -> msg
    , onChangeNode : String -> String -> msg
    , onAddLinks : msg
    , onAddResponsabilities : msg
    , onAddDomains : msg
    , onAddPolicies : msg

    -- User search and change
    , onChangeUserPattern : Int -> String -> msg
    , onChangeUserRole : Int -> String -> msg
    , onSelectUser : Int -> String -> msg
    , onCancelUser : Int -> msg
    , onShowLookupFs : msg
    , onCancelLookupFs : msg

    -- Labels
    , labelsPanel : LabelSearchPanel.State
    , onLabelSearchPanelMsg : LabelSearchPanel.Msg -> msg
    }


view : Op msg -> Html msg
view op =
    let
        form =
            op.data.form

        txt =
            getTensionText

        isLoading =
            op.data.result == LoadingSlowly

        isSendable =
            isPostSendable [ "title" ] form.post

        submitTension =
            ternary isSendable [ onClick (op.onSubmit <| op.onSubmitTension op.data False) ] []

        message =
            Dict.get "message" form.post |> withDefault ""
    in
    case op.data.result of
        Success res ->
            let
                link =
                    Route.Tension_Dynamic_Dynamic { param1 = form.target.rootnameid, param2 = res.id } |> toHref
            in
            div [ class "box is-light" ]
                [ I.icon1 "icon-check icon-2x has-text-success" " "
                , textH txt.added
                , text " "
                , a
                    [ href link
                    , onClickPD (op.onCloseModal link "" (canExitSafe op.data))
                    , target "_blank"
                    ]
                    [ textH T.checkItOut ]
                ]

        other ->
            div [ class "panel modal-card finalModal" ]
                [ div [ class "panel-heading" ]
                    [ div [ class "level modal-card-title" ]
                        [ div [ class "level-left" ] <|
                            List.intersperse (text "\u{00A0}")
                                [ span [ class "is-size-6 has-text-weight-semibold has-text-grey" ]
                                    [ textT txt.title
                                    , span [ class "has-text-weight-medium" ] [ text " | " ]
                                    , span [ class "dropdown" ]
                                        [ span [ class "dropdown-trigger button-light" ]
                                            [ span [ attribute "aria-controls" "type-menu" ]
                                                [ span [ class <| "has-text-weight-medium " ++ tensionTypeColor "text" form.tension_type ]
                                                    [ text (TensionType.toString form.tension_type), span [ class "ml-2 arrow down" ] [] ]
                                                ]
                                            ]
                                        , div [ id "type-menu", class "dropdown-menu", attribute "role" "menu" ]
                                            [ div [ class "dropdown-content" ] <|
                                                List.map
                                                    (\t ->
                                                        div
                                                            [ class <| "dropdown-item button-light " ++ tensionTypeColor "text" t
                                                            , onClick (op.onChangeTensionType t)
                                                            ]
                                                            [ TensionType.toString t |> text ]
                                                    )
                                                    TensionType.list
                                            ]
                                        ]
                                    ]
                                ]
                        , div [ class "level-right has-text-weight-medium" ] <| edgeArrow "button" (text form.source.name) (text form.target.name)
                        ]
                    ]
                , div [ id "tensionTab1", class "tabs is-boxed has-text-weight-medium" ]
                    [ ul []
                        [ li [ class "is-active" ] [ a [] [ I.icon1 "icon-exchange" "Tension" ] ]
                        , li [ class "" ] [ a [] [ I.icon1 "icon-target" "Role or Circle" ] ]
                        ]
                    ]
                , div [ class "modal-card-body" ]
                    [ div [ class "field" ]
                        [ div [ class "control" ]
                            [ input
                                [ class "input autofocus followFocus"
                                , attribute "data-nextfocus" "textAreaModal"
                                , type_ "text"
                                , placeholder (upH T.title)
                                , required True
                                , onInput (op.onChangeNode "title")
                                ]
                                []
                            ]
                        , p [ class "help-label" ] [ textH txt.name_help ]
                        , br [] []
                        ]
                    , div [ class "message" ]
                        [ div [ class "message-header" ]
                            [ div [ class "tabs is-boxed is-small" ]
                                [ ul []
                                    [ li [ classList [ ( "is-active", op.data.viewMode == Write ) ] ] [ a [ onClickPD2 (op.onChangeInputViewMode Write), target "_blank" ] [ text "Write" ] ]
                                    , li [ classList [ ( "is-active", op.data.viewMode == Preview ) ] ] [ a [ onClickPD2 (op.onChangeInputViewMode Preview), target "_blank" ] [ text "Preview" ] ]
                                    ]
                                ]
                            ]
                        , div [ class "message-body" ]
                            [ div [ class "field" ]
                                [ div [ class "control" ]
                                    [ case op.data.viewMode of
                                        Write ->
                                            textarea
                                                [ id "textAreaModal"
                                                , class "textarea"
                                                , rows 5
                                                , placeholder (upH T.leaveCommentOpt)
                                                , value message
                                                , onInput (op.onChangeNode "message")
                                                ]
                                                []

                                        Preview ->
                                            div [] [ renderMarkdown "is-dark" message, hr [] [] ]
                                    ]
                                , p [ class "help-label" ] [ textH txt.message_help ]
                                , br [] []
                                ]
                            ]
                        ]
                    , div [ class "field" ]
                        [ div [ class "control" ]
                            [ LabelSearchPanel.viewNew
                                { selectedLabels = form.labels
                                , targets = op.targets
                                , isAdmin = False
                                , exitSafe = canExitSafe op.data
                                }
                                op.labelsPanel
                                |> Html.map op.onLabelSearchPanelMsg
                            ]
                        ]
                    ]
                , div [ class "modal-card-foot", attribute "style" "display: block;" ]
                    [ case other of
                        Failure err ->
                            viewGqlErrors err

                        _ ->
                            text ""
                    , div [ class "field is-grouped is-grouped-right" ]
                        [ div [ class "control" ]
                            [ div [ class "buttons" ]
                                [ button
                                    ([ class "button is-success"
                                     , classList [ ( "is-loading", isLoading ) ]
                                     , disabled (not isSendable)
                                     ]
                                        ++ submitTension
                                    )
                                    [ textH txt.submit ]
                                ]
                            ]
                        ]
                    ]
                ]
