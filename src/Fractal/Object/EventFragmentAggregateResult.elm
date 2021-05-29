-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Fractal.Object.EventFragmentAggregateResult exposing (..)

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


count : SelectionSet (Maybe Int) Fractal.Object.EventFragmentAggregateResult
count =
    Object.selectionForField "(Maybe Int)" "count" [] (Decode.int |> Decode.nullable)


oldMin : SelectionSet (Maybe String) Fractal.Object.EventFragmentAggregateResult
oldMin =
    Object.selectionForField "(Maybe String)" "oldMin" [] (Decode.string |> Decode.nullable)


oldMax : SelectionSet (Maybe String) Fractal.Object.EventFragmentAggregateResult
oldMax =
    Object.selectionForField "(Maybe String)" "oldMax" [] (Decode.string |> Decode.nullable)


newMin : SelectionSet (Maybe String) Fractal.Object.EventFragmentAggregateResult
newMin =
    Object.selectionForField "(Maybe String)" "newMin" [] (Decode.string |> Decode.nullable)


newMax : SelectionSet (Maybe String) Fractal.Object.EventFragmentAggregateResult
newMax =
    Object.selectionForField "(Maybe String)" "newMax" [] (Decode.string |> Decode.nullable)
