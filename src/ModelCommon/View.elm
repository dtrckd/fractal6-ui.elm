module ModelCommon.View exposing (..)

import Dict exposing (Dict)
import Extra exposing (colorToTextColor, ternary)
import Extra.Date exposing (formatDate)
import Fractal.Enum.BlobType as BlobType
import Fractal.Enum.ContractType as ContractType
import Fractal.Enum.NodeType as NodeType
import Fractal.Enum.NodeVisibility as NodeVisibility
import Fractal.Enum.RoleType as RoleType
import Fractal.Enum.TensionAction as TensionAction
import Fractal.Enum.TensionEvent as TensionEvent
import Fractal.Enum.TensionStatus as TensionStatus
import Fractal.Enum.TensionType as TensionType
import Generated.Route as Route exposing (toHref)
import Global
import Html exposing (Html, a, br, button, div, hr, i, p, span, sub, text)
import Html.Attributes exposing (attribute, class, classList, disabled, href, id)
import Html.Events exposing (onClick)
import Icon as I
import Identicon
import Maybe exposing (withDefault)
import ModelCommon exposing (UserState(..), getParentFragmentFromRole)
import ModelCommon.Codecs
    exposing
        ( ActionType(..)
        , FractalBaseRoute(..)
        , NodeFocus
        , getTensionCharac
        , nid2rootid
        , uriFromNameid
        , uriFromUsername
        )
import ModelSchema exposing (EmitterOrReceiver, Label, NodeExt, Post, Tension, User, UserCtx, Username)
import Text as T exposing (textH, textT, upH)
import Time



{-
   @DEBUG: Factor this file to appropriate places in Component.{Tension, Node, User ,Color...}
-}
{-
   Tension
-}


tensionTypeSpan : TensionType.TensionType -> Html msg
tensionTypeSpan type_ =
    span [ class <| "has-text-weight-medium " ++ tensionTypeColor "text" type_ ] [ text (TensionType.toString type_), span [ class "ml-2 arrow down" ] [] ]


mediaTension : Time.Posix -> NodeFocus -> Tension -> Bool -> Bool -> String -> (String -> msg) -> Html msg
mediaTension now focus tension showStatus showRecip size navigate =
    let
        n_comments =
            --tension.comments_agg |> Maybe.map (\x -> withDefault 0 x.count) |> withDefault 0
            withDefault 0 tension.n_comments

        labels_m =
            tension.labels |> Maybe.map (\ls -> ternary (List.length ls == 0) Nothing (Just ls)) |> withDefault Nothing
    in
    div
        [ class ("media mediaBox is-hoverable " ++ size)
        , onClick (Route.Tension_Dynamic_Dynamic { param1 = focus.rootnameid, param2 = tension.id } |> toHref |> navigate)
        ]
        [ div [ class "media-left" ]
            [ div
                [ class "tooltip has-tooltip-arrow"
                , attribute "data-tooltip" (TensionType.toString tension.type_)
                ]
                [ div [ class <| "Circle " ++ tensionTypeColor "text" tension.type_ ] [ text "" ] ]
            ]
        , div [ class "media-content" ]
            [ div
                [ class "content mb-0"
                ]
                [ a
                    [ class "has-text-weight-semibold"
                    , href (Route.Tension_Dynamic_Dynamic { param1 = focus.rootnameid, param2 = tension.id } |> toHref)
                    ]
                    [ text tension.title ]
                , case labels_m of
                    Just labels ->
                        viewLabels labels

                    Nothing ->
                        text ""
                , span [ class "level is-pulled-right icons-list" ]
                    [ case tension.action of
                        Just action ->
                            viewActionIconLink action focus.rootnameid tension.id "" "is-small level-item"

                        Nothing ->
                            text ""
                    , if n_comments > 1 then
                        a
                            [ class "tooltip has-tooltip-arrow level-item"
                            , attribute "data-tooltip" (String.fromInt (n_comments - 1) ++ " comments")
                            , href (Route.Tension_Dynamic_Dynamic { param1 = focus.rootnameid, param2 = tension.id } |> toHref)
                            ]
                            [ I.icon1 "icon-message-square icon-sm" "", text (String.fromInt (n_comments - 1)) ]

                      else
                        text ""
                    ]
                ]
            , span [ class "is-smaller" ]
                [ if showStatus then
                    span
                        [ class "tooltip has-tooltip-arrow has-tooltip-right"
                        , attribute "data-tooltip" (TensionStatus.toString tension.status)
                        ]
                        [ I.icon ("icon-alert-circle icon-sm is-overlay marginTensionStatus has-text-" ++ statusColor tension.status) ]

                  else
                    text ""
                , if showRecip then
                    span []
                        [ viewTensionArrow "has-text-weight-light" tension.emitter tension.receiver
                        , span [] [ viewTensionDateAndUser now "has-text-weight-light is-pulled-right" tension.createdAt tension.createdBy ]
                        ]

                  else
                    --span [] [ atBy now "has-text-weight-light" tension.createdAt tension.createdBy ]
                    span []
                        [ -- span [ class "is-invisible" ] [ text "fixme" ]
                          span [ class "has-text-weight-light is-pulled-righ" ] [ text (T.by ++ " "), viewUsernameLink tension.createdBy.username ]
                        ]
                ]

            --[ span [ class "column is-7 is-variable" ] [ viewTensionArrow "has-text-weight-light" tension.emitter tension.receiver ]
            --, span [ class "column" ]
            --    [ case tension.action of
            --        Just action ->
            --            viewActionIconLink action focus.rootnameid tension.id "" "is-small"
            --        Nothing ->
            --            text ""
            --    , span [ class "is-pulled-right" ] [ viewTensionDateAndUser now tension.createdAt tension.createdBy ]
            --    ]
            --]
            ]
        ]


viewTensionArrow : String -> EmitterOrReceiver -> EmitterOrReceiver -> Html msg
viewTensionArrow cls emitter receiver =
    span [ class cls ]
        [ span [ class "is-small is-light is-inverted is-static" ]
            [ viewNodeRef OverviewBaseUri emitter ]
        , span [ class "right-arrow" ] []
        , span [ class "is-small is-light is-inverted is-static" ]
            [ viewNodeRef OverviewBaseUri receiver ]
        ]


viewTensionArrowB : String -> EmitterOrReceiver -> EmitterOrReceiver -> Html msg
viewTensionArrowB cls emitter receiver =
    span [ class cls ]
        [ span [ class "is-small is-inverted is-hovered button", attribute "style" "margin-top: -3px !important;" ]
            [ viewNodeRef OverviewBaseUri emitter ]
        , span [ class "right-arrow" ] []
        , span [ class "is-small is-inverted is-hovered button", attribute "style" "margin-top: -3px !important;" ]
            [ viewNodeRef OverviewBaseUri receiver ]
        ]


viewLabels : List Label -> Html msg
viewLabels labels =
    span [ class "labelsList" ] (List.map (\label -> viewLabel "" label) labels)


viewLabel : String -> Label -> Html msg
viewLabel cls label =
    let
        color =
            label.color
                |> Maybe.map
                    (\c ->
                        [ attribute "style" ("background-color:" ++ c ++ "; color:" ++ colorToTextColor c ++ ";") ]
                    )
                |> withDefault []
    in
    span ([ class ("tag is-rounded " ++ cls) ] ++ color) [ text label.name ]


viewUsers : List User -> Html msg
viewUsers users =
    span [ class "usersList" ] (List.map (\u -> viewUser True u.username) users)


viewUser : Bool -> String -> Html msg
viewUser isLinked username =
    if isLinked then
        span [ class "mr-2" ]
            [ a [ href (uriFromUsername UsersBaseUri username) ]
                [ getAvatar1 username ]
            ]

    else
        span [ class "mr-2" ] [ getAvatar1 username ]


viewUser2 : String -> Html msg
viewUser2 username =
    span [ class "mr-2" ]
        [ a [ href (uriFromUsername UsersBaseUri username) ]
            [ getAvatar2 username ]
        ]


viewUserFull : Int -> Bool -> Bool -> User -> Html msg
viewUserFull size isLinked isBoxed user =
    let
        ( pad, avatar ) =
            case size of
                0 ->
                    ( "p-1", getAvatar0 )

                1 ->
                    ( "p-1", getAvatar1 )

                2 ->
                    ( "", getAvatar2 )

                3 ->
                    ( "", getAvatar3 )

                _ ->
                    ( "p-1", getAvatar1 )
    in
    span (ternary isBoxed [ class ("box is-light field " ++ pad), attribute "style" "display:inline;" ] [])
        [ span [ class "mr-2", attribute "style" (ternary isBoxed "position:relative;top:6px;" "") ]
            [ if isLinked then
                a [ href (uriFromUsername UsersBaseUri user.username) ] [ avatar user.username ]

              else
                avatar user.username
            ]
        , span [ attribute "style" (ternary isBoxed "" "position:relative;top:-4px;") ]
            [ Maybe.map (\name -> span [ class "is-name" ] [ text name ]) user.name |> withDefault (text "")
            , span [ class "is-username" ] [ text ("@" ++ user.username) ]
            ]
        ]


viewUsernameLink : String -> Html msg
viewUsernameLink username =
    a [ href (uriFromUsername UsersBaseUri username) ] [ "@" ++ username |> text ]


viewOpenedDate : Time.Posix -> String -> Html msg
viewOpenedDate now date =
    span [] <|
        List.intersperse (text " ") <|
            [ span [] [ text T.opened ]
            , text (formatDate now date)
            ]


viewUpdated : Time.Posix -> String -> Html msg
viewUpdated now date =
    span [ class "is-grey-light" ] <|
        List.intersperse (text " ") <|
            [ text "·"
            , span [] [ text T.edited ]
            , text (formatDate now date)
            ]


viewCommentedDate : Time.Posix -> String -> Html msg
viewCommentedDate now date =
    span [ class "is-grey-light" ] <|
        List.intersperse (text " ") <|
            [ span [ class "is-itali" ] [ text T.commented ]
            , text (formatDate now date)
            ]


viewTensionDateAndUser : Time.Posix -> String -> String -> Username -> Html msg
viewTensionDateAndUser now cls createdAt createdBy =
    span [ class cls ] <|
        List.intersperse (text " ") <|
            [ viewOpenedDate now createdAt
            , text T.by
            , viewUsernameLink createdBy.username
            ]


viewTensionDateAndUserC : Time.Posix -> String -> Username -> Html msg
viewTensionDateAndUserC now createdAt createdBy =
    span [] <|
        List.intersperse (text " ") <|
            [ viewUsernameLink createdBy.username
            , viewCommentedDate now createdAt
            ]


byAt : Time.Posix -> Username -> String -> Html msg
byAt now createdBy createdAt =
    span [] <|
        List.intersperse (text " ") <|
            [ text "by"
            , viewUsernameLink createdBy.username
            , text (formatDate now createdAt)
            ]


atBy : Time.Posix -> String -> String -> Username -> Html msg
atBy now cls createdAt createdBy =
    span [ class cls ] <|
        List.intersperse (text " ") <|
            [ text (formatDate now createdAt)
            , text "by"
            , viewUsernameLink createdBy.username
            ]


statusColor : TensionStatus.TensionStatus -> String
statusColor s =
    case s of
        TensionStatus.Open ->
            "success"

        TensionStatus.Closed ->
            "danger"


tensionTypeColor : String -> TensionType.TensionType -> String
tensionTypeColor elt tt =
    case tt of
        TensionType.Operational ->
            "has-" ++ elt ++ "-success"

        TensionType.Governance ->
            "has-" ++ elt ++ "-info"

        TensionType.Help ->
            "has-" ++ elt ++ "-warning"



{-
   Node
-}


viewNodeRef : FractalBaseRoute -> EmitterOrReceiver -> Html msg
viewNodeRef baseUri n =
    let
        ref =
            if n.role_type == Just RoleType.Member then
                "#"

            else
                uriFromNameid baseUri n.nameid
    in
    a [ href ref ] [ n.name |> text ]


viewNodeRefShort : FractalBaseRoute -> String -> Html msg
viewNodeRefShort baseUri nid =
    let
        ref =
            uriFromNameid baseUri nid

        name =
            nid |> String.split "#" |> List.reverse |> List.head |> withDefault nid
    in
    a [ href ref ] [ name |> text ]


viewOrgaMedia : UserState -> NodeExt -> Html msg
viewOrgaMedia user root =
    let
        n_members =
            root.orga_agg |> Maybe.map (\agg -> withDefault 0 agg.n_members) |> withDefault 0

        n_guests =
            root.orga_agg |> Maybe.map (\agg -> withDefault 0 agg.n_guests) |> withDefault 0
    in
    div [ class "media box mediaBox" ]
        [ div [ class "media-left" ]
            [ a
                [ class "image circleBase circle2"
                , href (uriFromNameid OverviewBaseUri root.nameid)
                ]
                [ getAvatarOrga root.name ]
            ]
        , div [ class "media-content" ]
            ([ div [ class "columns" ]
                [ div [ class "column is-8" ]
                    [ a [ href (uriFromNameid OverviewBaseUri root.nameid) ] [ text root.name ]
                    , case root.about of
                        Just ab ->
                            p [ class "is-italic pt-1" ] [ text ab ]

                        Nothing ->
                            text ""
                    ]
                , span [ class "column is-4" ]
                    [ div [ class "field is-grouped is-grouped-multiline is-pulled-right" ]
                        [ div [ class "control" ]
                            [ div [ class "tags has-addons" ]
                                [ span [ class "tag is-light" ] [ text "member" ]
                                , span [ class "tag is-white" ] [ text (String.fromInt n_members) ]
                                ]
                            ]
                        , div [ class "control" ]
                            [ div [ class "tags has-addons" ]
                                [ span [ class "tag is-light" ] [ text "guest" ]
                                , span [ class "tag is-white" ] [ text (String.fromInt n_guests) ]
                                ]
                            ]
                        ]
                    ]
                ]
             , div [ id "icons", class "level is-mobile" ]
                [ div [ class "level-left" ]
                    [ if root.visibility == NodeVisibility.Private then
                        span [ class "level-item" ] [ I.icon "icon-lock" ]

                      else
                        text ""
                    ]
                ]
             ]
                ++ (case user of
                        LoggedIn uctx ->
                            [ hr [] []
                            , div [ class "buttons" ] <|
                                (uctx.roles
                                    |> List.filter (\r -> r.role_type /= RoleType.Member && nid2rootid r.nameid == root.nameid)
                                    |> List.map
                                        (\r ->
                                            a
                                                [ class ("button buttonRole is-small has-text-weight-semibold tooltip has-tooltip-arrow has-tooltip-bottom is-" ++ roleColor r.role_type)
                                                , attribute "data-tooltip" (r.name ++ " of " ++ getParentFragmentFromRole r)
                                                , href <| uriFromNameid OverviewBaseUri r.nameid
                                                ]
                                                [ text r.name ]
                                        )
                                )
                            ]

                        LoggedOut ->
                            []
                   )
            )
        ]


roleColor : RoleType.RoleType -> String
roleColor rt =
    case rt of
        RoleType.Owner ->
            "orange"

        RoleType.Member ->
            "primary"

        RoleType.Coordinator ->
            "orange"

        RoleType.Peer ->
            "primary"

        RoleType.Bot ->
            "link"

        RoleType.Guest ->
            "primary"

        RoleType.Retired ->
            "primary"

        RoleType.Pending ->
            "primary"



{-
   Avatar
-}


getAvatar0 : String -> Html msg
getAvatar0 username =
    span [ class "image circleBaseInline circle00" ] [ Identicon.identicon "14px" username ]


getAvatar1 : String -> Html msg
getAvatar1 username =
    span [ class "image circleBaseInline circle0" ] [ Identicon.identicon "18px" username ]


getAvatar2 : String -> Html msg
getAvatar2 username =
    span [ class "image circleBaseInline circle1" ] [ Identicon.identicon "22px" username ]


getAvatar3 : String -> Html msg
getAvatar3 username =
    span [ class "image circleBaseInline circle3" ] [ Identicon.identicon "108px" username ]


getAvatarOrga : String -> Html msg
getAvatarOrga name =
    let
        initial =
            name
                |> String.slice 0 1
                |> String.toUpper
    in
    span []
        [ text initial
        , name
            |> String.slice 1 3
            |> String.toLower
            |> text
        ]



{-
   Action
-}


actionNameStr : TensionAction.TensionAction -> String
actionNameStr action =
    case action of
        TensionAction.NewCircle ->
            upH T.circle

        TensionAction.EditCircle ->
            upH T.circle

        TensionAction.ArchivedCircle ->
            upH T.circle

        TensionAction.NewRole ->
            upH T.role

        TensionAction.EditRole ->
            upH T.role

        TensionAction.ArchivedRole ->
            upH T.role

        TensionAction.NewMd ->
            upH T.document

        TensionAction.EditMd ->
            upH T.document

        TensionAction.ArchivedMd ->
            upH T.document


viewActionIconLink : TensionAction.TensionAction -> String -> String -> String -> String -> Html msg
viewActionIconLink action org tid words cls =
    let
        charac =
            getTensionCharac action
    in
    a
        [ class "actionLink tooltip has-tooltip-arrow"
        , classList [ ( "has-text-warning", charac.action_type == ARCHIVE ) ]
        , attribute "data-tooltip" ("1 " ++ actionNameStr action ++ " attached")
        , href (Route.Tension_Dynamic_Dynamic_Action { param1 = org, param2 = tid } |> toHref)
        ]
        [ span [ class cls ] [ viewActionIcon action ]
        , text words
        ]


viewActionIcon : TensionAction.TensionAction -> Html msg
viewActionIcon action =
    case action of
        TensionAction.NewRole ->
            I.icon0 "icon-leaf"

        TensionAction.NewCircle ->
            I.icon0 "icon-git-branch"

        TensionAction.NewMd ->
            I.icon0 "icon-markdown"

        TensionAction.EditRole ->
            I.icon0 "icon-leaf"

        TensionAction.EditCircle ->
            I.icon0 "icon-git-branch"

        TensionAction.EditMd ->
            I.icon0 "icon-markdown"

        TensionAction.ArchivedCircle ->
            I.icon0 "icon-archive"

        TensionAction.ArchivedRole ->
            I.icon0 "icon-archive"

        TensionAction.ArchivedMd ->
            I.icon0 "icon-archive"


action2SourceStr : Maybe TensionAction.TensionAction -> String
action2SourceStr action_m =
    case action_m of
        Nothing ->
            "create this Tension"

        Just action ->
            case action of
                TensionAction.NewCircle ->
                    "create this circle"

                TensionAction.EditCircle ->
                    "edit this circle"

                TensionAction.ArchivedCircle ->
                    "archived this role"

                TensionAction.NewRole ->
                    "create this role"

                TensionAction.EditRole ->
                    "edit this role"

                TensionAction.ArchivedRole ->
                    "archived this role"

                TensionAction.NewMd ->
                    "create this document"

                TensionAction.EditMd ->
                    "edit this document"

                TensionAction.ArchivedMd ->
                    "archived this document"


archiveActionToggle : Maybe TensionAction.TensionAction -> Maybe TensionAction.TensionAction
archiveActionToggle action_m =
    action_m
        |> Maybe.map
            (\action ->
                case action of
                    TensionAction.EditCircle ->
                        Just TensionAction.ArchivedCircle

                    TensionAction.ArchivedCircle ->
                        Just TensionAction.EditCircle

                    TensionAction.EditRole ->
                        Just TensionAction.ArchivedRole

                    TensionAction.ArchivedRole ->
                        Just TensionAction.EditRole

                    TensionAction.EditMd ->
                        Just TensionAction.ArchivedMd

                    TensionAction.ArchivedMd ->
                        Just TensionAction.EditMd

                    TensionAction.NewCircle ->
                        Nothing

                    TensionAction.NewRole ->
                        Nothing

                    TensionAction.NewMd ->
                        Nothing
            )
        |> withDefault Nothing



{-
   Blob
-}


blobTypeStr : BlobType.BlobType -> String
blobTypeStr btype =
    case btype of
        BlobType.OnNode ->
            "Document created"

        BlobType.OnAbout ->
            "Description edited"

        BlobType.OnMandate ->
            "Mandate edited"

        BlobType.OnDoc ->
            "File edited"


type alias FormText =
    { title : String
    , added : String
    , name_help : String
    , about_help : String
    , message_help : String
    , ph_purpose : String
    , ph_responsabilities : String
    , ph_domains : String
    , ph_policies : String
    , submit : String
    , close_submit : String
    , firstLink_help : String
    , tension_added : String
    , noFirstLinks : String
    }


emptyFormText : FormText
emptyFormText =
    FormText "" "" "" "" "" "" "" "" "" "" "" "" "" ""


getTensionText : FormText
getTensionText =
    FormText T.newTension T.tensionAdded T.tensionTitleHelp "" T.tensionMessageHelp "" "" "" "" T.tensionSubmit "" "" "" ""


getNodeTextFromNodeType : NodeType.NodeType -> FormText
getNodeTextFromNodeType type_ =
    case type_ of
        NodeType.Circle ->
            FormText T.newCircle T.circleAdded T.circleNameHelp T.circleAboutHelp T.circleMessageHelp T.phCirclePurpose T.phCircleResponsabilities T.phCircleDomains T.phCirclePolicies T.tensionSubmit T.tensionCircleCloseSubmit T.firstLinkCircleMessageHelp T.tensionCircleAdded T.noFirstLinksCircle

        NodeType.Role ->
            FormText T.newRole T.roleAdded T.roleNameHelp T.roleAboutHelp T.roleMessageHelp T.phRolePurpose T.phRoleResponsabilities T.phRoleDomains T.phRolePolicies T.tensionSubmit T.tensionRoleCloseSubmit T.firstLinkRoleMessageHelp T.tensionRoleAdded T.noFirstLinksRole



{-
   Contract
-}


contractTypeToText : ContractType.ContractType -> String
contractTypeToText c =
    case c of
        ContractType.AnyCoordoDual ->
            "dual coordinators"

        ContractType.AnyCandidates ->
            "poll"

        ContractType.AnyCoordoTarget ->
            "receiver coordinator"

        ContractType.AnyCoordoSource ->
            "emitter coordinator"


contractEventToText : TensionEvent.TensionEvent -> String
contractEventToText c =
    case c of
        TensionEvent.Moved ->
            "move tension"

        _ ->
            "@TODO text"
