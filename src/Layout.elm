module Layout exposing (view)

import Generated.Routes as Routes exposing (Route, routes)
import Html exposing (..)
import Html.Attributes exposing (..)
import Utils.Spa as Spa


view : Spa.LayoutContext msg -> Html msg
view { page, route } =
    div [ class "app" ]
        [ viewHeader route
        , page
        ]



{-
   # Issues
   * FIX-NAV:  class "is-fixed-top in bavbar dont work yet. class on body ?
-}


viewHeader : Route -> Html msg
viewHeader currentRoute =
    header [ class "hero is-light" ]
        [ nav [ class "navbar has-shadow", attribute "role" "navigation", attribute "aria-label" "main navigation" ]
            [ div [ class "container is-fluid" ]
                [ div [ class "navbar-brand" ]
                    [ a [ class "navbar-item" ] [ img [ alt "Fractal", attribute "height" "28", src "https://bulma.io/images/bulma-logo.png", attribute "width" "112" ] [] ]
                    , a [ attribute "aria-expanded" "false", attribute "aria-label" "menu", class "navbar-burger burger", attribute "data-target" "navMenu", attribute "role" "button" ]
                        [ span [ attribute "aria-hidden" "true" ] []
                        , span [ attribute "aria-hidden" "true" ] []
                        , span [ attribute "aria-hidden" "true" ] []
                        ]
                    ]
                , div [ id "navMenu", class "navbar-menu" ]
                    [ div [ class "navbar-start" ]
                        [ viewLink currentRoute ( "home", routes.top )
                        , viewLink currentRoute ( "nowhere", routes.notFound )
                        , viewLink currentRoute ( "sdkustat", routes.skuStatic )
                        ]
                    , div [ class "navbar-end" ]
                        [ a [ class "navbar-item" ] [ text "Report an issue" ]
                        , div [ class "navbar-item has-dropdown is-hoverable" ]
                            [ div [ class "navbar-link" ] [ text "SkuID" ]
                            , div [ class "navbar-dropdown" ]
                                [ a [ class "navbar-item" ] [ text "Profile" ]
                                , a [ class "navbar-item" ] [ text "Settings" ]
                                , hr [ class "navbar-divider" ] []
                                , a [ class "navbar-item" ] [ text "Sign Out" ]
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        ]


viewLink : Route -> ( String, Route ) -> Html msg
viewLink currentRoute ( label, route ) =
    if currentRoute == route then
        a
            --[ class "link link--active" ]
            [ class "navbar-item is-active is-tab" ]
            [ text label ]

    else
        a
            --[ class "link"
            [ class "navbar-item"
            , href (Routes.toPath route)
            ]
            [ text label ]
