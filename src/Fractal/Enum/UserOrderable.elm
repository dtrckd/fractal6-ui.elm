-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Fractal.Enum.UserOrderable exposing (..)

import Json.Decode as Decode exposing (Decoder)


type UserOrderable
    = CreatedAt
    | Username
    | Name
    | Password
    | Email
    | EmailHash
    | Bio
    | Utc


list : List UserOrderable
list =
    [ CreatedAt, Username, Name, Password, Email, EmailHash, Bio, Utc ]


decoder : Decoder UserOrderable
decoder =
    Decode.string
        |> Decode.andThen
            (\string ->
                case string of
                    "createdAt" ->
                        Decode.succeed CreatedAt

                    "username" ->
                        Decode.succeed Username

                    "name" ->
                        Decode.succeed Name

                    "password" ->
                        Decode.succeed Password

                    "email" ->
                        Decode.succeed Email

                    "emailHash" ->
                        Decode.succeed EmailHash

                    "bio" ->
                        Decode.succeed Bio

                    "utc" ->
                        Decode.succeed Utc

                    _ ->
                        Decode.fail ("Invalid UserOrderable type, " ++ string ++ " try re-running the @dillonkearns/elm-graphql CLI ")
            )


{-| Convert from the union type representating the Enum to a string that the GraphQL server will recognize.
-}
toString : UserOrderable -> String
toString enum =
    case enum of
        CreatedAt ->
            "createdAt"

        Username ->
            "username"

        Name ->
            "name"

        Password ->
            "password"

        Email ->
            "email"

        EmailHash ->
            "emailHash"

        Bio ->
            "bio"

        Utc ->
            "utc"


{-| Convert from a String representation to an elm representation enum.
This is the inverse of the Enum `toString` function. So you can call `toString` and then convert back `fromString` safely.

    Swapi.Enum.Episode.NewHope
        |> Swapi.Enum.Episode.toString
        |> Swapi.Enum.Episode.fromString
        == Just NewHope

This can be useful for generating Strings to use for <select> menus to check which item was selected.

-}
fromString : String -> Maybe UserOrderable
fromString enumString =
    case enumString of
        "createdAt" ->
            Just CreatedAt

        "username" ->
            Just Username

        "name" ->
            Just Name

        "password" ->
            Just Password

        "email" ->
            Just Email

        "emailHash" ->
            Just EmailHash

        "bio" ->
            Just Bio

        "utc" ->
            Just Utc

        _ ->
            Nothing
