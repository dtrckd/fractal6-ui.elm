-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Fractal.Enum.UserEventFragmentHasFilter exposing (..)

import Json.Decode as Decode exposing (Decoder)


type UserEventFragmentHasFilter
    = CreatedAt
    | IsRead
    | Event


list : List UserEventFragmentHasFilter
list =
    [ CreatedAt, IsRead, Event ]


decoder : Decoder UserEventFragmentHasFilter
decoder =
    Decode.string
        |> Decode.andThen
            (\string ->
                case string of
                    "createdAt" ->
                        Decode.succeed CreatedAt

                    "isRead" ->
                        Decode.succeed IsRead

                    "event" ->
                        Decode.succeed Event

                    _ ->
                        Decode.fail ("Invalid UserEventFragmentHasFilter type, " ++ string ++ " try re-running the @dillonkearns/elm-graphql CLI ")
            )


{-| Convert from the union type representing the Enum to a string that the GraphQL server will recognize.
-}
toString : UserEventFragmentHasFilter -> String
toString enum____ =
    case enum____ of
        CreatedAt ->
            "createdAt"

        IsRead ->
            "isRead"

        Event ->
            "event"


{-| Convert from a String representation to an elm representation enum.
This is the inverse of the Enum `toString` function. So you can call `toString` and then convert back `fromString` safely.

    Swapi.Enum.Episode.NewHope
        |> Swapi.Enum.Episode.toString
        |> Swapi.Enum.Episode.fromString
        == Just NewHope

This can be useful for generating Strings to use for <select> menus to check which item was selected.

-}
fromString : String -> Maybe UserEventFragmentHasFilter
fromString enumString____ =
    case enumString____ of
        "createdAt" ->
            Just CreatedAt

        "isRead" ->
            Just IsRead

        "event" ->
            Just Event

        _ ->
            Nothing
