{-
   Fractale - Self-organisation for humans.
   Copyright (C) 2022 Fractale Co

   This file is part of Fractale.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU Affero General Public License as
   published by the Free Software Foundation, either version 3 of the
   License, or (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU Affero General Public License for more details.

   You should have received a copy of the GNU Affero General Public License
   along with Fractale.  If not, see <http://www.gnu.org/licenses/>.
-}


module Pages.T.Dynamic exposing (Flags, Model, Msg, page)

import Global
import Html
import Org.Tensions as T
import Page exposing (Document, Page)


type alias Flags =
    { param1 : String }


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
init global { param1 } =
    T.init global
        { param1 = param1
        , param2 = Nothing
        , param3 = Nothing
        }
