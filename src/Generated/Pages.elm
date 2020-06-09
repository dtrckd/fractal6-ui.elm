module Generated.Pages exposing
    ( Model
    , Msg
    , init
    , subscriptions
    , update
    , view
    )

import Generated.Route as Route exposing (Route)
import Global
import Page exposing (Bundle, Document)
import Pages.Top
import Pages.Login
import Pages.Logout
import Pages.NotFound
import Pages.Signup
import Pages.O.Dynamic
import Pages.User.Dynamic
import Pages.O.Dynamic.Dynamic
import Pages.O.Dynamic.Dynamic.Dynamic



-- TYPES


type Model
    = Top_Model Pages.Top.Model
    | Login_Model Pages.Login.Model
    | Logout_Model Pages.Logout.Model
    | NotFound_Model Pages.NotFound.Model
    | Signup_Model Pages.Signup.Model
    | O_Dynamic_Model Pages.O.Dynamic.Model
    | User_Dynamic_Model Pages.User.Dynamic.Model
    | O_Dynamic_Dynamic_Model Pages.O.Dynamic.Dynamic.Model
    | O_Dynamic_Dynamic_Dynamic_Model Pages.O.Dynamic.Dynamic.Dynamic.Model


type Msg
    = Top_Msg Pages.Top.Msg
    | Login_Msg Pages.Login.Msg
    | Logout_Msg Pages.Logout.Msg
    | NotFound_Msg Pages.NotFound.Msg
    | Signup_Msg Pages.Signup.Msg
    | O_Dynamic_Msg Pages.O.Dynamic.Msg
    | User_Dynamic_Msg Pages.User.Dynamic.Msg
    | O_Dynamic_Dynamic_Msg Pages.O.Dynamic.Dynamic.Msg
    | O_Dynamic_Dynamic_Dynamic_Msg Pages.O.Dynamic.Dynamic.Dynamic.Msg



-- PAGES


type alias UpgradedPage flags model msg =
    { init : flags -> Global.Model -> ( Model, Cmd Msg, Cmd Global.Msg )
    , update : msg -> model -> Global.Model -> ( Model, Cmd Msg, Cmd Global.Msg )
    , bundle : model -> Global.Model -> Bundle Msg
    }


type alias UpgradedPages =
    { top : UpgradedPage Pages.Top.Flags Pages.Top.Model Pages.Top.Msg
    , login : UpgradedPage Pages.Login.Flags Pages.Login.Model Pages.Login.Msg
    , logout : UpgradedPage Pages.Logout.Flags Pages.Logout.Model Pages.Logout.Msg
    , notFound : UpgradedPage Pages.NotFound.Flags Pages.NotFound.Model Pages.NotFound.Msg
    , signup : UpgradedPage Pages.Signup.Flags Pages.Signup.Model Pages.Signup.Msg
    , o_dynamic : UpgradedPage Pages.O.Dynamic.Flags Pages.O.Dynamic.Model Pages.O.Dynamic.Msg
    , user_dynamic : UpgradedPage Pages.User.Dynamic.Flags Pages.User.Dynamic.Model Pages.User.Dynamic.Msg
    , o_dynamic_dynamic : UpgradedPage Pages.O.Dynamic.Dynamic.Flags Pages.O.Dynamic.Dynamic.Model Pages.O.Dynamic.Dynamic.Msg
    , o_dynamic_dynamic_dynamic : UpgradedPage Pages.O.Dynamic.Dynamic.Dynamic.Flags Pages.O.Dynamic.Dynamic.Dynamic.Model Pages.O.Dynamic.Dynamic.Dynamic.Msg
    }


pages : UpgradedPages
pages =
    { top = Pages.Top.page |> Page.upgrade Top_Model Top_Msg
    , login = Pages.Login.page |> Page.upgrade Login_Model Login_Msg
    , logout = Pages.Logout.page |> Page.upgrade Logout_Model Logout_Msg
    , notFound = Pages.NotFound.page |> Page.upgrade NotFound_Model NotFound_Msg
    , signup = Pages.Signup.page |> Page.upgrade Signup_Model Signup_Msg
    , o_dynamic = Pages.O.Dynamic.page |> Page.upgrade O_Dynamic_Model O_Dynamic_Msg
    , user_dynamic = Pages.User.Dynamic.page |> Page.upgrade User_Dynamic_Model User_Dynamic_Msg
    , o_dynamic_dynamic = Pages.O.Dynamic.Dynamic.page |> Page.upgrade O_Dynamic_Dynamic_Model O_Dynamic_Dynamic_Msg
    , o_dynamic_dynamic_dynamic = Pages.O.Dynamic.Dynamic.Dynamic.page |> Page.upgrade O_Dynamic_Dynamic_Dynamic_Model O_Dynamic_Dynamic_Dynamic_Msg
    }



-- INIT


init : Route -> Global.Model -> ( Model, Cmd Msg, Cmd Global.Msg )
init route =
    case route of
        Route.Top ->
            pages.top.init ()
        
        Route.Login ->
            pages.login.init ()
        
        Route.Logout ->
            pages.logout.init ()
        
        Route.NotFound ->
            pages.notFound.init ()
        
        Route.Signup ->
            pages.signup.init ()
        
        Route.O_Dynamic params ->
            pages.o_dynamic.init params
        
        Route.User_Dynamic params ->
            pages.user_dynamic.init params
        
        Route.O_Dynamic_Dynamic params ->
            pages.o_dynamic_dynamic.init params
        
        Route.O_Dynamic_Dynamic_Dynamic params ->
            pages.o_dynamic_dynamic_dynamic.init params



-- UPDATE


update : Msg -> Model -> Global.Model -> ( Model, Cmd Msg, Cmd Global.Msg )
update bigMsg bigModel =
    case ( bigMsg, bigModel ) of
        ( Top_Msg msg, Top_Model model ) ->
            pages.top.update msg model
        
        ( Login_Msg msg, Login_Model model ) ->
            pages.login.update msg model
        
        ( Logout_Msg msg, Logout_Model model ) ->
            pages.logout.update msg model
        
        ( NotFound_Msg msg, NotFound_Model model ) ->
            pages.notFound.update msg model
        
        ( Signup_Msg msg, Signup_Model model ) ->
            pages.signup.update msg model
        
        ( O_Dynamic_Msg msg, O_Dynamic_Model model ) ->
            pages.o_dynamic.update msg model
        
        ( User_Dynamic_Msg msg, User_Dynamic_Model model ) ->
            pages.user_dynamic.update msg model
        
        ( O_Dynamic_Dynamic_Msg msg, O_Dynamic_Dynamic_Model model ) ->
            pages.o_dynamic_dynamic.update msg model
        
        ( O_Dynamic_Dynamic_Dynamic_Msg msg, O_Dynamic_Dynamic_Dynamic_Model model ) ->
            pages.o_dynamic_dynamic_dynamic.update msg model
        
        _ ->
            always ( bigModel, Cmd.none, Cmd.none )



-- BUNDLE - (view + subscriptions)


bundle : Model -> Global.Model -> Bundle Msg
bundle bigModel =
    case bigModel of
        Top_Model model ->
            pages.top.bundle model
        
        Login_Model model ->
            pages.login.bundle model
        
        Logout_Model model ->
            pages.logout.bundle model
        
        NotFound_Model model ->
            pages.notFound.bundle model
        
        Signup_Model model ->
            pages.signup.bundle model
        
        O_Dynamic_Model model ->
            pages.o_dynamic.bundle model
        
        User_Dynamic_Model model ->
            pages.user_dynamic.bundle model
        
        O_Dynamic_Dynamic_Model model ->
            pages.o_dynamic_dynamic.bundle model
        
        O_Dynamic_Dynamic_Dynamic_Model model ->
            pages.o_dynamic_dynamic_dynamic.bundle model


view : Model -> Global.Model -> Document Msg
view model =
    bundle model >> .view


subscriptions : Model -> Global.Model -> Sub Msg
subscriptions model =
    bundle model >> .subscriptions