-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Fractal.Object.UpdateEventFragmentPayload exposing (..)

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


type alias EventFragmentOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.EventFragmentFilter
    , order : OptionalArgument Fractal.InputObject.EventFragmentOrder
    , first : OptionalArgument Int
    , offset : OptionalArgument Int
    }


eventFragment :
    (EventFragmentOptionalArguments -> EventFragmentOptionalArguments)
    -> SelectionSet decodesTo Fractal.Object.EventFragment
    -> SelectionSet (Maybe (List (Maybe decodesTo))) Fractal.Object.UpdateEventFragmentPayload
eventFragment fillInOptionals object_ =
    let
        filledInOptionals =
            fillInOptionals { filter = Absent, order = Absent, first = Absent, offset = Absent }

        optionalArgs =
            [ Argument.optional "filter" filledInOptionals.filter Fractal.InputObject.encodeEventFragmentFilter, Argument.optional "order" filledInOptionals.order Fractal.InputObject.encodeEventFragmentOrder, Argument.optional "first" filledInOptionals.first Encode.int, Argument.optional "offset" filledInOptionals.offset Encode.int ]
                |> List.filterMap identity
    in
    Object.selectionForCompositeField "eventFragment" optionalArgs object_ (identity >> Decode.nullable >> Decode.list >> Decode.nullable)


numUids : SelectionSet (Maybe Int) Fractal.Object.UpdateEventFragmentPayload
numUids =
    Object.selectionForField "(Maybe Int)" "numUids" [] (Decode.int |> Decode.nullable)
