module Footbar exposing (view)

import Assets as A
import Html exposing (Html, a, div, header, hr, i, nav, span, text)
import Html.Attributes as Attr exposing (attribute, class, href, id, style, target)


view : Html msg
view =
    div [ id "footBar", class "footer" ]
        [ div [ class "columns is-centered" ]
            [ div [ class "column is-2" ]
                [ div [ class "contacts" ]
                    [ span [] [ a [ href "mailto:contact@fractale.co" ] [ text "Contact us" ] ]
                    , span [] [ text "-" ]
                    , span [] [ a [ href "https://gitlab.com/fractal6", target "_blank" ] [ A.icon "icon-gitlab" ] ]

                    --, span [] [ a [ href "https://github.com/fractal6", target "_blank" ] [ A.icon "icon-github"  ] ]
                    ]
                ]
            ]
        ]