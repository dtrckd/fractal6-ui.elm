-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Fractal.Enum.UserHasFilter exposing (..)

import Json.Decode as Decode exposing (Decoder)


type UserHasFilter
    = CreatedAt
    | LastAck
    | Username
    | Name
    | Email
    | Password
    | Bio
    | Location
    | Utc
    | Links
    | Skills
    | NotifyByEmail
    | Lang
    | Subscriptions
    | Watching
    | Rights
    | Roles
    | Backed_roles
    | Tensions_created
    | Tensions_assigned
    | Contracts
    | Events
    | MarkAllAsRead
    | Event_count


list : List UserHasFilter
list =
    [ CreatedAt, LastAck, Username, Name, Email, Password, Bio, Location, Utc, Links, Skills, NotifyByEmail, Lang, Subscriptions, Watching, Rights, Roles, Backed_roles, Tensions_created, Tensions_assigned, Contracts, Events, MarkAllAsRead, Event_count ]


decoder : Decoder UserHasFilter
decoder =
    Decode.string
        |> Decode.andThen
            (\string ->
                case string of
                    "createdAt" ->
                        Decode.succeed CreatedAt

                    "lastAck" ->
                        Decode.succeed LastAck

                    "username" ->
                        Decode.succeed Username

                    "name" ->
                        Decode.succeed Name

                    "email" ->
                        Decode.succeed Email

                    "password" ->
                        Decode.succeed Password

                    "bio" ->
                        Decode.succeed Bio

                    "location" ->
                        Decode.succeed Location

                    "utc" ->
                        Decode.succeed Utc

                    "links" ->
                        Decode.succeed Links

                    "skills" ->
                        Decode.succeed Skills

                    "notifyByEmail" ->
                        Decode.succeed NotifyByEmail

                    "lang" ->
                        Decode.succeed Lang

                    "subscriptions" ->
                        Decode.succeed Subscriptions

                    "watching" ->
                        Decode.succeed Watching

                    "rights" ->
                        Decode.succeed Rights

                    "roles" ->
                        Decode.succeed Roles

                    "backed_roles" ->
                        Decode.succeed Backed_roles

                    "tensions_created" ->
                        Decode.succeed Tensions_created

                    "tensions_assigned" ->
                        Decode.succeed Tensions_assigned

                    "contracts" ->
                        Decode.succeed Contracts

                    "events" ->
                        Decode.succeed Events

                    "markAllAsRead" ->
                        Decode.succeed MarkAllAsRead

                    "event_count" ->
                        Decode.succeed Event_count

                    _ ->
                        Decode.fail ("Invalid UserHasFilter type, " ++ string ++ " try re-running the @dillonkearns/elm-graphql CLI ")
            )


{-| Convert from the union type representing the Enum to a string that the GraphQL server will recognize.
-}
toString : UserHasFilter -> String
toString enum____ =
    case enum____ of
        CreatedAt ->
            "createdAt"

        LastAck ->
            "lastAck"

        Username ->
            "username"

        Name ->
            "name"

        Email ->
            "email"

        Password ->
            "password"

        Bio ->
            "bio"

        Location ->
            "location"

        Utc ->
            "utc"

        Links ->
            "links"

        Skills ->
            "skills"

        NotifyByEmail ->
            "notifyByEmail"

        Lang ->
            "lang"

        Subscriptions ->
            "subscriptions"

        Watching ->
            "watching"

        Rights ->
            "rights"

        Roles ->
            "roles"

        Backed_roles ->
            "backed_roles"

        Tensions_created ->
            "tensions_created"

        Tensions_assigned ->
            "tensions_assigned"

        Contracts ->
            "contracts"

        Events ->
            "events"

        MarkAllAsRead ->
            "markAllAsRead"

        Event_count ->
            "event_count"


{-| Convert from a String representation to an elm representation enum.
This is the inverse of the Enum `toString` function. So you can call `toString` and then convert back `fromString` safely.

    Swapi.Enum.Episode.NewHope
        |> Swapi.Enum.Episode.toString
        |> Swapi.Enum.Episode.fromString
        == Just NewHope

This can be useful for generating Strings to use for <select> menus to check which item was selected.

-}
fromString : String -> Maybe UserHasFilter
fromString enumString____ =
    case enumString____ of
        "createdAt" ->
            Just CreatedAt

        "lastAck" ->
            Just LastAck

        "username" ->
            Just Username

        "name" ->
            Just Name

        "email" ->
            Just Email

        "password" ->
            Just Password

        "bio" ->
            Just Bio

        "location" ->
            Just Location

        "utc" ->
            Just Utc

        "links" ->
            Just Links

        "skills" ->
            Just Skills

        "notifyByEmail" ->
            Just NotifyByEmail

        "lang" ->
            Just Lang

        "subscriptions" ->
            Just Subscriptions

        "watching" ->
            Just Watching

        "rights" ->
            Just Rights

        "roles" ->
            Just Roles

        "backed_roles" ->
            Just Backed_roles

        "tensions_created" ->
            Just Tensions_created

        "tensions_assigned" ->
            Just Tensions_assigned

        "contracts" ->
            Just Contracts

        "events" ->
            Just Events

        "markAllAsRead" ->
            Just MarkAllAsRead

        "event_count" ->
            Just Event_count

        _ ->
            Nothing
