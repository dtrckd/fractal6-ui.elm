-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Fractal.Enum.NodeHasFilter exposing (..)

import Json.Decode as Decode exposing (Decoder)


type NodeHasFilter
    = CreatedBy
    | CreatedAt
    | UpdatedAt
    | Name
    | Nameid
    | Rootnameid
    | IsRoot
    | Parent
    | Type_
    | Tensions_out
    | Tensions_in
    | About
    | Mandate
    | Source
    | Visibility
    | Mode
    | Rights
    | IsArchived
    | IsPersonal
    | UserCanJoin
    | GuestCanCreateTension
    | Children
    | Docs
    | Labels
    | Roles
    | Role_ext
    | Role_type
    | Color
    | First_link
    | Second_link
    | Skills
    | Contracts
    | Watchers
    | Orga_agg
    | Events_history


list : List NodeHasFilter
list =
    [ CreatedBy, CreatedAt, UpdatedAt, Name, Nameid, Rootnameid, IsRoot, Parent, Type_, Tensions_out, Tensions_in, About, Mandate, Source, Visibility, Mode, Rights, IsArchived, IsPersonal, UserCanJoin, GuestCanCreateTension, Children, Docs, Labels, Roles, Role_ext, Role_type, Color, First_link, Second_link, Skills, Contracts, Watchers, Orga_agg, Events_history ]


decoder : Decoder NodeHasFilter
decoder =
    Decode.string
        |> Decode.andThen
            (\string ->
                case string of
                    "createdBy" ->
                        Decode.succeed CreatedBy

                    "createdAt" ->
                        Decode.succeed CreatedAt

                    "updatedAt" ->
                        Decode.succeed UpdatedAt

                    "name" ->
                        Decode.succeed Name

                    "nameid" ->
                        Decode.succeed Nameid

                    "rootnameid" ->
                        Decode.succeed Rootnameid

                    "isRoot" ->
                        Decode.succeed IsRoot

                    "parent" ->
                        Decode.succeed Parent

                    "type_" ->
                        Decode.succeed Type_

                    "tensions_out" ->
                        Decode.succeed Tensions_out

                    "tensions_in" ->
                        Decode.succeed Tensions_in

                    "about" ->
                        Decode.succeed About

                    "mandate" ->
                        Decode.succeed Mandate

                    "source" ->
                        Decode.succeed Source

                    "visibility" ->
                        Decode.succeed Visibility

                    "mode" ->
                        Decode.succeed Mode

                    "rights" ->
                        Decode.succeed Rights

                    "isArchived" ->
                        Decode.succeed IsArchived

                    "isPersonal" ->
                        Decode.succeed IsPersonal

                    "userCanJoin" ->
                        Decode.succeed UserCanJoin

                    "guestCanCreateTension" ->
                        Decode.succeed GuestCanCreateTension

                    "children" ->
                        Decode.succeed Children

                    "docs" ->
                        Decode.succeed Docs

                    "labels" ->
                        Decode.succeed Labels

                    "roles" ->
                        Decode.succeed Roles

                    "role_ext" ->
                        Decode.succeed Role_ext

                    "role_type" ->
                        Decode.succeed Role_type

                    "color" ->
                        Decode.succeed Color

                    "first_link" ->
                        Decode.succeed First_link

                    "second_link" ->
                        Decode.succeed Second_link

                    "skills" ->
                        Decode.succeed Skills

                    "contracts" ->
                        Decode.succeed Contracts

                    "watchers" ->
                        Decode.succeed Watchers

                    "orga_agg" ->
                        Decode.succeed Orga_agg

                    "events_history" ->
                        Decode.succeed Events_history

                    _ ->
                        Decode.fail ("Invalid NodeHasFilter type, " ++ string ++ " try re-running the @dillonkearns/elm-graphql CLI ")
            )


{-| Convert from the union type representing the Enum to a string that the GraphQL server will recognize.
-}
toString : NodeHasFilter -> String
toString enum____ =
    case enum____ of
        CreatedBy ->
            "createdBy"

        CreatedAt ->
            "createdAt"

        UpdatedAt ->
            "updatedAt"

        Name ->
            "name"

        Nameid ->
            "nameid"

        Rootnameid ->
            "rootnameid"

        IsRoot ->
            "isRoot"

        Parent ->
            "parent"

        Type_ ->
            "type_"

        Tensions_out ->
            "tensions_out"

        Tensions_in ->
            "tensions_in"

        About ->
            "about"

        Mandate ->
            "mandate"

        Source ->
            "source"

        Visibility ->
            "visibility"

        Mode ->
            "mode"

        Rights ->
            "rights"

        IsArchived ->
            "isArchived"

        IsPersonal ->
            "isPersonal"

        UserCanJoin ->
            "userCanJoin"

        GuestCanCreateTension ->
            "guestCanCreateTension"

        Children ->
            "children"

        Docs ->
            "docs"

        Labels ->
            "labels"

        Roles ->
            "roles"

        Role_ext ->
            "role_ext"

        Role_type ->
            "role_type"

        Color ->
            "color"

        First_link ->
            "first_link"

        Second_link ->
            "second_link"

        Skills ->
            "skills"

        Contracts ->
            "contracts"

        Watchers ->
            "watchers"

        Orga_agg ->
            "orga_agg"

        Events_history ->
            "events_history"


{-| Convert from a String representation to an elm representation enum.
This is the inverse of the Enum `toString` function. So you can call `toString` and then convert back `fromString` safely.

    Swapi.Enum.Episode.NewHope
        |> Swapi.Enum.Episode.toString
        |> Swapi.Enum.Episode.fromString
        == Just NewHope

This can be useful for generating Strings to use for <select> menus to check which item was selected.

-}
fromString : String -> Maybe NodeHasFilter
fromString enumString____ =
    case enumString____ of
        "createdBy" ->
            Just CreatedBy

        "createdAt" ->
            Just CreatedAt

        "updatedAt" ->
            Just UpdatedAt

        "name" ->
            Just Name

        "nameid" ->
            Just Nameid

        "rootnameid" ->
            Just Rootnameid

        "isRoot" ->
            Just IsRoot

        "parent" ->
            Just Parent

        "type_" ->
            Just Type_

        "tensions_out" ->
            Just Tensions_out

        "tensions_in" ->
            Just Tensions_in

        "about" ->
            Just About

        "mandate" ->
            Just Mandate

        "source" ->
            Just Source

        "visibility" ->
            Just Visibility

        "mode" ->
            Just Mode

        "rights" ->
            Just Rights

        "isArchived" ->
            Just IsArchived

        "isPersonal" ->
            Just IsPersonal

        "userCanJoin" ->
            Just UserCanJoin

        "guestCanCreateTension" ->
            Just GuestCanCreateTension

        "children" ->
            Just Children

        "docs" ->
            Just Docs

        "labels" ->
            Just Labels

        "roles" ->
            Just Roles

        "role_ext" ->
            Just Role_ext

        "role_type" ->
            Just Role_type

        "color" ->
            Just Color

        "first_link" ->
            Just First_link

        "second_link" ->
            Just Second_link

        "skills" ->
            Just Skills

        "contracts" ->
            Just Contracts

        "watchers" ->
            Just Watchers

        "orga_agg" ->
            Just Orga_agg

        "events_history" ->
            Just Events_history

        _ ->
            Nothing
