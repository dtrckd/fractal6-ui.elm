-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Fractal.Enum.NodeVisibility exposing (..)

import Json.Decode as Decode exposing (Decoder)


type NodeVisibility
    = Public
    | Private
    | Secret


list : List NodeVisibility
list =
    [ Public, Private, Secret ]


decoder : Decoder NodeVisibility
decoder =
    Decode.string
        |> Decode.andThen
            (\string ->
                case string of
                    "Public" ->
                        Decode.succeed Public

                    "Private" ->
                        Decode.succeed Private

                    "Secret" ->
                        Decode.succeed Secret

                    _ ->
                        Decode.fail ("Invalid NodeVisibility type, " ++ string ++ " try re-running the @dillonkearns/elm-graphql CLI ")
            )


{-| Convert from the union type representing the Enum to a string that the GraphQL server will recognize.
-}
toString : NodeVisibility -> String
toString enum____ =
    case enum____ of
        Public ->
            "Public"

        Private ->
            "Private"

        Secret ->
            "Secret"


{-| Convert from a String representation to an elm representation enum.
This is the inverse of the Enum `toString` function. So you can call `toString` and then convert back `fromString` safely.

    Swapi.Enum.Episode.NewHope
        |> Swapi.Enum.Episode.toString
        |> Swapi.Enum.Episode.fromString
        == Just NewHope

This can be useful for generating Strings to use for <select> menus to check which item was selected.

-}
fromString : String -> Maybe NodeVisibility
fromString enumString____ =
    case enumString____ of
        "Public" ->
            Just Public

        "Private" ->
            Just Private

        "Secret" ->
            Just Secret

        _ ->
            Nothing
