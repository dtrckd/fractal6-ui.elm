module Pages.T.Dynamic.Dynamic exposing (Flags, Model, Msg, page)

import Components.Org.Tensions as T exposing (Model, Msg, init, subscriptions, update, view)
import Global
import Html
import Page exposing (Document, Page)


type alias Flags =
    { param1 : String, param2 : String }


type alias Model =
    T.Model


type alias Msg =
    T.Msg


page : Page Flags Model Msg
page =
    Page.component
        { init = init
        , update = T.update
        , subscriptions = T.subscriptions
        , view = T.view
        }


init : Global.Model -> Flags -> ( Model, Cmd Msg, Cmd Global.Msg )
init global { param1, param2 } =
    T.init global
        { param1 = param1
        , param2 = Just param2
        , param3 = Nothing
        }
