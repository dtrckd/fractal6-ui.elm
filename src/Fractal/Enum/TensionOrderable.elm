-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Fractal.Enum.TensionOrderable exposing (..)

import Json.Decode as Decode exposing (Decoder)


{-|

  - CreatedAt -
  - Message -
  - Nth -
  - Title -
  - Severity -

-}
type TensionOrderable
    = CreatedAt
    | Message
    | Nth
    | Title
    | Severity


list : List TensionOrderable
list =
    [ CreatedAt, Message, Nth, Title, Severity ]


decoder : Decoder TensionOrderable
decoder =
    Decode.string
        |> Decode.andThen
            (\string ->
                case string of
                    "createdAt" ->
                        Decode.succeed CreatedAt

                    "message" ->
                        Decode.succeed Message

                    "nth" ->
                        Decode.succeed Nth

                    "title" ->
                        Decode.succeed Title

                    "severity" ->
                        Decode.succeed Severity

                    _ ->
                        Decode.fail ("Invalid TensionOrderable type, " ++ string ++ " try re-running the @dillonkearns/elm-graphql CLI ")
            )


{-| Convert from the union type representating the Enum to a string that the GraphQL server will recognize.
-}
toString : TensionOrderable -> String
toString enum =
    case enum of
        CreatedAt ->
            "createdAt"

        Message ->
            "message"

        Nth ->
            "nth"

        Title ->
            "title"

        Severity ->
            "severity"


{-| Convert from a String representation to an elm representation enum.
This is the inverse of the Enum `toString` function. So you can call `toString` and then convert back `fromString` safely.

    Swapi.Enum.Episode.NewHope
        |> Swapi.Enum.Episode.toString
        |> Swapi.Enum.Episode.fromString
        == Just NewHope

This can be useful for generating Strings to use for <select> menus to check which item was selected.

-}
fromString : String -> Maybe TensionOrderable
fromString enumString =
    case enumString of
        "createdAt" ->
            Just CreatedAt

        "message" ->
            Just Message

        "nth" ->
            Just Nth

        "title" ->
            Just Title

        "severity" ->
            Just Severity

        _ ->
            Nothing
