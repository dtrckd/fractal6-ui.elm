-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Fractal.Enum.MandateOrderable exposing (..)

import Json.Decode as Decode exposing (Decoder)


{-|

  - CreatedAt -
  - Message -
  - Purpose -
  - Responsabilities -
  - Domains -

-}
type MandateOrderable
    = CreatedAt
    | Message
    | Purpose
    | Responsabilities
    | Domains


list : List MandateOrderable
list =
    [ CreatedAt, Message, Purpose, Responsabilities, Domains ]


decoder : Decoder MandateOrderable
decoder =
    Decode.string
        |> Decode.andThen
            (\string ->
                case string of
                    "createdAt" ->
                        Decode.succeed CreatedAt

                    "message" ->
                        Decode.succeed Message

                    "purpose" ->
                        Decode.succeed Purpose

                    "responsabilities" ->
                        Decode.succeed Responsabilities

                    "domains" ->
                        Decode.succeed Domains

                    _ ->
                        Decode.fail ("Invalid MandateOrderable type, " ++ string ++ " try re-running the @dillonkearns/elm-graphql CLI ")
            )


{-| Convert from the union type representating the Enum to a string that the GraphQL server will recognize.
-}
toString : MandateOrderable -> String
toString enum =
    case enum of
        CreatedAt ->
            "createdAt"

        Message ->
            "message"

        Purpose ->
            "purpose"

        Responsabilities ->
            "responsabilities"

        Domains ->
            "domains"


{-| Convert from a String representation to an elm representation enum.
This is the inverse of the Enum `toString` function. So you can call `toString` and then convert back `fromString` safely.

    Swapi.Enum.Episode.NewHope
        |> Swapi.Enum.Episode.toString
        |> Swapi.Enum.Episode.fromString
        == Just NewHope

This can be useful for generating Strings to use for <select> menus to check which item was selected.

-}
fromString : String -> Maybe MandateOrderable
fromString enumString =
    case enumString of
        "createdAt" ->
            Just CreatedAt

        "message" ->
            Just Message

        "purpose" ->
            Just Purpose

        "responsabilities" ->
            Just Responsabilities

        "domains" ->
            Just Domains

        _ ->
            Nothing
