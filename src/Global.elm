port module Global exposing
    ( Flags
    , Model
    , Msg(..)
    , init
    , navigate
    , send
    , sendSleep
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
import ModelCommon.Uri exposing (NodeFocus)
import ModelSchema exposing (..)
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
                            --let
                            --    d =
                            --        Debug.log "error" err
                            --in
                            LoggedOut

                Nothing ->
                    LoggedOut

        session =
            { referer = url
            , user = userState
            , token_data = RemoteData.NotAsked
            , orga_data = Nothing
            , path_data = Nothing
            , node_focus = Nothing
            , tensions_circle = Nothing
            , mandate = Nothing
            , node_action = Nothing
            , node_quickSearch = Nothing
            }
    in
    ( Model flags url key session
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
    | UpdateUserSession UserCtx -- user is logged In !
    | UpdateUserTokenAck (WebData UserCtx)
    | UpdateUserToken
    | LoggedOutUser
    | LoggedOutUserOk
    | RedirectOnLoggedIn -- user is logged In !
    | UpdateSessionFocus (Maybe NodeFocus)
    | UpdateSessionPath (Maybe LocalGraph)
    | UpdateSessionOrga (Maybe NodesData)
    | UpdateSessionTensions (Maybe TensionsData)
    | UpdateSessionMandate (Maybe Mandate)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Navigate route ->
            ( model, Nav.pushUrl model.key (Route.toHref route) )

        UpdateReferer url ->
            let
                session =
                    model.session

                referer =
                    case url.path of
                        "/logout" ->
                            session.referer

                        _ ->
                            url
            in
            ( { model | session = { session | referer = referer } }, Cmd.none )

        RedirectOnLoggedIn ->
            let
                cmd =
                    case model.session.user of
                        LoggedIn uctx ->
                            model.session.referer
                                |> Route.fromUrl
                                |> Maybe.withDefault (Route.User_Dynamic { param1 = uctx.username })
                                |> navigate

                        LoggedOut ->
                            sendSleep RedirectOnLoggedIn 300
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
            ( { model | session = { session | node_focus = data } }, Cmd.none )

        UpdateSessionPath data ->
            let
                session =
                    model.session
            in
            ( { model | session = { session | path_data = data } }, Cmd.none )

        UpdateSessionOrga data ->
            let
                session =
                    model.session
            in
            ( { model | session = { session | orga_data = data } }, Cmd.none )

        UpdateSessionTensions data ->
            let
                session =
                    model.session
            in
            ( { model | session = { session | tensions_circle = data } }, Cmd.none )

        UpdateSessionMandate data ->
            let
                session =
                    model.session
            in
            ( { model | session = { session | mandate = data } }, Cmd.none )

        UpdateUserSession uctx ->
            let
                maybeNewMemberid =
                    case model.session.user of
                        LoggedIn uctxOld ->
                            if List.length uctxOld.roles == 1 && List.length uctx.roles > 1 then
                                List.head uctxOld.roles |> Maybe.map (\r -> r.nameid)

                            else
                                Nothing

                        LoggedOut ->
                            Nothing

                cmds =
                    case model.session.orga_data of
                        Just ndata ->
                            case maybeNewMemberid of
                                Just nid ->
                                    [ Ports.saveUserCtx uctx
                                    , Ports.removeRedrawGraphPack ndata nid
                                    ]

                                Nothing ->
                                    [ Ports.saveUserCtx uctx
                                    , Ports.redrawGraphPack ndata
                                    ]

                        Nothing ->
                            [ Ports.saveUserCtx uctx ]

                session =
                    model.session
            in
            ( { model | session = { session | user = LoggedIn uctx } }
            , Cmd.batch cmds
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


view : { page : Document msg, global : Model, toMsg : Msg -> msg } -> Document msg
view { page, global, toMsg } =
    Components.layout
        { page = page
        , session = global.session
        }



-- COMMANDS


send : msg -> Cmd msg
send =
    Task.succeed >> Task.perform identity


sendSleep : msg -> Float -> Cmd msg
sendSleep msg time =
    Task.perform (\_ -> msg) (Process.sleep time)


navigate : Route -> Cmd Msg
navigate route =
    send (Navigate route)
