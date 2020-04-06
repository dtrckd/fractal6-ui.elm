-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Fractal.Object.AddMandatePayload exposing (..)

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


type alias MandateOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.MandateFilter
    , order : OptionalArgument Fractal.InputObject.MandateOrder
    , first : OptionalArgument Int
    , offset : OptionalArgument Int
    }


{-|

  - filter -
  - order -
  - first -
  - offset -

-}
mandate : (MandateOptionalArguments -> MandateOptionalArguments) -> SelectionSet decodesTo Fractal.Object.Mandate -> SelectionSet (Maybe (List (Maybe decodesTo))) Fractal.Object.AddMandatePayload
mandate fillInOptionals object_ =
    let
        filledInOptionals =
            fillInOptionals { filter = Absent, order = Absent, first = Absent, offset = Absent }

        optionalArgs =
            [ Argument.optional "filter" filledInOptionals.filter Fractal.InputObject.encodeMandateFilter, Argument.optional "order" filledInOptionals.order Fractal.InputObject.encodeMandateOrder, Argument.optional "first" filledInOptionals.first Encode.int, Argument.optional "offset" filledInOptionals.offset Encode.int ]
                |> List.filterMap identity
    in
    Object.selectionForCompositeField "mandate" optionalArgs object_ (identity >> Decode.nullable >> Decode.list >> Decode.nullable)


{-| -}
numUids : SelectionSet (Maybe Int) Fractal.Object.AddMandatePayload
numUids =
    Object.selectionForField "(Maybe Int)" "numUids" [] (Decode.int |> Decode.nullable)
