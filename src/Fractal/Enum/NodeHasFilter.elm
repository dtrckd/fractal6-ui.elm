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
    | Parent
    | Children
    | Type_
    | Tensions_out
    | Tensions_in
    | About
    | Mandate
    | Docs
    | Source
    | IsRoot
    | IsPersonal
    | IsPrivate
    | IsArchived
    | Charac
    | Rights
    | Labels
    | First_link
    | Second_link
    | Skills
    | Role_type
    | Contracts
    | Orga_agg


list : List NodeHasFilter
list =
    [ CreatedBy, CreatedAt, UpdatedAt, Name, Nameid, Rootnameid, Parent, Children, Type_, Tensions_out, Tensions_in, About, Mandate, Docs, Source, IsRoot, IsPersonal, IsPrivate, IsArchived, Charac, Rights, Labels, First_link, Second_link, Skills, Role_type, Contracts, Orga_agg ]


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

                    "parent" ->
                        Decode.succeed Parent

                    "children" ->
                        Decode.succeed Children

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

                    "docs" ->
                        Decode.succeed Docs

                    "source" ->
                        Decode.succeed Source

                    "isRoot" ->
                        Decode.succeed IsRoot

                    "isPersonal" ->
                        Decode.succeed IsPersonal

                    "isPrivate" ->
                        Decode.succeed IsPrivate

                    "isArchived" ->
                        Decode.succeed IsArchived

                    "charac" ->
                        Decode.succeed Charac

                    "rights" ->
                        Decode.succeed Rights

                    "labels" ->
                        Decode.succeed Labels

                    "first_link" ->
                        Decode.succeed First_link

                    "second_link" ->
                        Decode.succeed Second_link

                    "skills" ->
                        Decode.succeed Skills

                    "role_type" ->
                        Decode.succeed Role_type

                    "contracts" ->
                        Decode.succeed Contracts

                    "orga_agg" ->
                        Decode.succeed Orga_agg

                    _ ->
                        Decode.fail ("Invalid NodeHasFilter type, " ++ string ++ " try re-running the @dillonkearns/elm-graphql CLI ")
            )


{-| Convert from the union type representing the Enum to a string that the GraphQL server will recognize.
-}
toString : NodeHasFilter -> String
toString enum =
    case enum of
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

        Parent ->
            "parent"

        Children ->
            "children"

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

        Docs ->
            "docs"

        Source ->
            "source"

        IsRoot ->
            "isRoot"

        IsPersonal ->
            "isPersonal"

        IsPrivate ->
            "isPrivate"

        IsArchived ->
            "isArchived"

        Charac ->
            "charac"

        Rights ->
            "rights"

        Labels ->
            "labels"

        First_link ->
            "first_link"

        Second_link ->
            "second_link"

        Skills ->
            "skills"

        Role_type ->
            "role_type"

        Contracts ->
            "contracts"

        Orga_agg ->
            "orga_agg"


{-| Convert from a String representation to an elm representation enum.
This is the inverse of the Enum `toString` function. So you can call `toString` and then convert back `fromString` safely.

    Swapi.Enum.Episode.NewHope
        |> Swapi.Enum.Episode.toString
        |> Swapi.Enum.Episode.fromString
        == Just NewHope

This can be useful for generating Strings to use for <select> menus to check which item was selected.

-}
fromString : String -> Maybe NodeHasFilter
fromString enumString =
    case enumString of
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

        "parent" ->
            Just Parent

        "children" ->
            Just Children

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

        "docs" ->
            Just Docs

        "source" ->
            Just Source

        "isRoot" ->
            Just IsRoot

        "isPersonal" ->
            Just IsPersonal

        "isPrivate" ->
            Just IsPrivate

        "isArchived" ->
            Just IsArchived

        "charac" ->
            Just Charac

        "rights" ->
            Just Rights

        "labels" ->
            Just Labels

        "first_link" ->
            Just First_link

        "second_link" ->
            Just Second_link

        "skills" ->
            Just Skills

        "role_type" ->
            Just Role_type

        "contracts" ->
            Just Contracts

        "orga_agg" ->
            Just Orga_agg

        _ ->
            Nothing
