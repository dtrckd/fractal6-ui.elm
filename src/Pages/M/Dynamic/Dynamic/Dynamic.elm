module Pages.M.Dynamic.Dynamic.Dynamic exposing (Flags, Model, Msg, page)

import Components.Org.Members as M
import Global
import Html
import Page exposing (Document, Page)


type alias Flags =
    { param1 : String, param2 : String, param3 : String }


type alias Model =
    M.Model


type alias Msg =
    M.Msg


page : Page Flags Model Msg
page =
    Page.component
        { init = init
        , update = M.update
        , subscriptions = M.subscriptions
        , view = M.view
        }


init : Global.Model -> Flags -> ( Model, Cmd Msg, Cmd Global.Msg )
init global { param1, param2, param3 } =
    M.init global
        { param1 = param1
        , param2 = Just param2
        , param3 = Just param3
        }