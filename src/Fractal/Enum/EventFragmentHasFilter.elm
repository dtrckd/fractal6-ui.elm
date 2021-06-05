-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Fractal.Enum.EventFragmentHasFilter exposing (..)

import Json.Decode as Decode exposing (Decoder)


type EventFragmentHasFilter
    = Event_type
    | Old
    | New


list : List EventFragmentHasFilter
list =
    [ Event_type, Old, New ]


decoder : Decoder EventFragmentHasFilter
decoder =
    Decode.string
        |> Decode.andThen
            (\string ->
                case string of
                    "event_type" ->
                        Decode.succeed Event_type

                    "old" ->
                        Decode.succeed Old

                    "new" ->
                        Decode.succeed New

                    _ ->
                        Decode.fail ("Invalid EventFragmentHasFilter type, " ++ string ++ " try re-running the @dillonkearns/elm-graphql CLI ")
            )


{-| Convert from the union type representing the Enum to a string that the GraphQL server will recognize.
-}
toString : EventFragmentHasFilter -> String
toString enum =
    case enum of
        Event_type ->
            "event_type"

        Old ->
            "old"

        New ->
            "new"


{-| Convert from a String representation to an elm representation enum.
This is the inverse of the Enum `toString` function. So you can call `toString` and then convert back `fromString` safely.

    Swapi.Enum.Episode.NewHope
        |> Swapi.Enum.Episode.toString
        |> Swapi.Enum.Episode.fromString
        == Just NewHope

This can be useful for generating Strings to use for <select> menus to check which item was selected.

-}
fromString : String -> Maybe EventFragmentHasFilter
fromString enumString =
    case enumString of
        "event_type" ->
            Just Event_type

        "old" ->
            Just Old

        "new" ->
            Just New

        _ ->
            Nothing