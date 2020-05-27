port module Global exposing
    ( Flags
    , Model
    , Msg(..)
    , init
    , navigate
    , send
    , subscriptions
    , update
    , view
    )

import Browser exposing (Document)
import Browser.Navigation as Nav
import Components
import Components.Loading as Loading exposing (WebData, expectJson, toErrorData)
import Dict
import Generated.Route as Route exposing (Route)
import Http
import Json.Decode as JD
import ModelCommon exposing (..)
import ModelCommon.Uri exposing (NodeFocus, NodePath)
import ModelOrg exposing (..)
import Ports
import Process
import QuickSearch as Qsearch
import RemoteData exposing (RemoteData)
import Task
import Url exposing (Url)



-- INIT


type alias Flags =
    Maybe JD.Value



-- Model


type alias Model =
    { flags : Flags
    , url : Url
    , referer : Url
    , key : Nav.Key
    , session : Session
    }


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        userState =
            case flags of
                Just userCtxRaw ->
                    case JD.decodeValue userDecoder userCtxRaw of
                        Ok uctx ->
                            LoggedIn uctx

                        Err err ->
                            let
                                d =
                                    Debug.log "error" err
                            in
                            LoggedOut

                Nothing ->
                    LoggedOut

        session =
            { user = userState
            , node_focus = Nothing
            , node_path = Nothing
            , orga_data = Nothing
            , circle_tensions = Nothing
            , node_action = Nothing
            , lut = Nothing
            , token_data = RemoteData.NotAsked
            }
    in
    ( Model flags url url key session
    , Cmd.batch
        [ Ports.log "Hello!"
        , Ports.toggle_theme
        , Ports.bulma_driver ""
        ]
    )



-- UPDATE


type Msg
    = Navigate Route
    | UpdateReferer Url
    | UpdateSessionFocus NodeFocus
    | UpdateSessionPath NodePath
    | UpdateSessionOrga NodesData
    | UpdateSessionTensions TensionsData
    | UpdateUserSession UserCtx -- user is logged In !
    | UpdateUserToken
    | UpdateUserTokenAck (WebData UserCtx)
    | LoggedOutUser
    | LoggedOutUserOk
    | RedirectOnLoggedIn -- user is logged In !


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Navigate route ->
            ( model
            , Nav.pushUrl model.key (Route.toHref route)
            )

        UpdateReferer url ->
            ( { model | referer = url }, Cmd.none )

        RedirectOnLoggedIn ->
            let
                cmd =
                    case model.session.user of
                        LoggedIn uctx ->
                            navigate <| Route.User_Dynamic { param1 = uctx.username }

                        --Nav.replaceUrl global.key (String.join "/" [ "/user", uctx.username ])
                        LoggedOut ->
                            Task.perform (\_ -> RedirectOnLoggedIn) (Process.sleep 300)
            in
            ( model, cmd )

        LoggedOutUser ->
            case model.session.user of
                LoggedIn uctx ->
                    let
                        session =
                            model.session
                    in
                    ( { model | session = { session | user = LoggedOut } }, Ports.removeUserCtx uctx )

                LoggedOut ->
                    ( model, Cmd.none )

        LoggedOutUserOk ->
            ( model, navigate Route.Top )

        UpdateSessionFocus data ->
            let
                session =
                    model.session
            in
            ( { model | session = { session | node_focus = Just data } }
            , Cmd.none
            )

        UpdateSessionPath data ->
            let
                session =
                    model.session
            in
            ( { model | session = { session | node_path = Just data } }
            , Cmd.none
            )

        UpdateSessionOrga data ->
            let
                session =
                    model.session

                lutList =
                    data
                        |> Dict.values
                        |> List.map (\n -> n.name)
            in
            ( { model
                | session =
                    { session
                        | orga_data = Just data
                        , lut = Qsearch.makeTable 4 List.singleton |> Qsearch.insertList lutList |> Just
                    }
              }
            , Cmd.none
            )

        UpdateSessionTensions data ->
            let
                session =
                    model.session
            in
            ( { model | session = { session | circle_tensions = Just data } }
            , Cmd.none
            )

        UpdateUserSession userCtx ->
            let
                session =
                    model.session
            in
            ( { model | session = { session | user = LoggedIn userCtx } }
            , Ports.saveUserCtx userCtx
            )

        UpdateUserToken ->
            let
                session =
                    model.session
            in
            ( model
            , Http.riskyRequest
                -- This method is needed to set cookies on the client through CORS.
                { method = "POST"
                , headers = []
                , url = "http://localhost:8888/tokenack"
                , body = Http.emptyBody
                , expect = expectJson (RemoteData.fromResult >> UpdateUserTokenAck) userDecoder
                , timeout = Nothing
                , tracker = Nothing
                }
            )

        UpdateUserTokenAck result ->
            let
                session =
                    model.session

                newModel =
                    { model | session = { session | token_data = result } }
            in
            case result of
                RemoteData.Success uctx ->
                    ( newModel
                    , send <| UpdateUserSession uctx
                    )

                default ->
                    ( newModel, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ loggedOutOkFromJs (always LoggedOutUserOk)
        ]


port loggedOutOkFromJs : (() -> msg) -> Sub msg



-- VIEW


view :
    { page : Document msg
    , global : Model
    , toMsg : Msg -> msg
    }
    -> Document msg
view { page, global, toMsg } =
    Components.layout
        { page = page
        , session = global.session
        }



-- COMMANDS


send : msg -> Cmd msg
send =
    Task.succeed >> Task.perform identity


navigate : Route -> Cmd Msg
navigate route =
    send (Navigate route)
