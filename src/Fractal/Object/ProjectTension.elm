-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Fractal.Object.ProjectTension exposing (..)

import Fractal.InputObject
import Fractal.Interface
import Fractal.Object
import Fractal.Scalar
import Fractal.ScalarCodecs
import Fractal.Union
import Graphql.Internal.Builder.Argument as Argument exposing (Argument)
import Graphql.Internal.Builder.Object as Object
import Graphql.Internal.Encode as Encode exposing (Value)
import Graphql.Operation exposing (RootMutation, RootQuery, RootSubscription)
import Graphql.OptionalArgument exposing (OptionalArgument(..))
import Graphql.SelectionSet exposing (SelectionSet)
import Json.Decode as Decode


id : SelectionSet Fractal.ScalarCodecs.Id Fractal.Object.ProjectTension
id =
    Object.selectionForField "ScalarCodecs.Id" "id" [] (Fractal.ScalarCodecs.codecs |> Fractal.Scalar.unwrapCodecs |> .codecId |> .decoder)


type alias TensionOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.TensionFilter }


tension :
    (TensionOptionalArguments -> TensionOptionalArguments)
    -> SelectionSet decodesTo Fractal.Object.Tension
    -> SelectionSet decodesTo Fractal.Object.ProjectTension
tension fillInOptionals____ object____ =
    let
        filledInOptionals____ =
            fillInOptionals____ { filter = Absent }

        optionalArgs____ =
            [ Argument.optional "filter" filledInOptionals____.filter Fractal.InputObject.encodeTensionFilter ]
                |> List.filterMap Basics.identity
    in
    Object.selectionForCompositeField "tension" optionalArgs____ object____ Basics.identity


pos : SelectionSet Int Fractal.Object.ProjectTension
pos =
    Object.selectionForField "Int" "pos" [] Decode.int


type alias PcOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.ProjectColumnFilter }


pc :
    (PcOptionalArguments -> PcOptionalArguments)
    -> SelectionSet decodesTo Fractal.Object.ProjectColumn
    -> SelectionSet decodesTo Fractal.Object.ProjectTension
pc fillInOptionals____ object____ =
    let
        filledInOptionals____ =
            fillInOptionals____ { filter = Absent }

        optionalArgs____ =
            [ Argument.optional "filter" filledInOptionals____.filter Fractal.InputObject.encodeProjectColumnFilter ]
                |> List.filterMap Basics.identity
    in
    Object.selectionForCompositeField "pc" optionalArgs____ object____ Basics.identity