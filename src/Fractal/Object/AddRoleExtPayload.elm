-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Fractal.Object.AddRoleExtPayload exposing (..)

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


type alias RoleExtOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.RoleExtFilter
    , order : OptionalArgument Fractal.InputObject.RoleExtOrder
    , first : OptionalArgument Int
    , offset : OptionalArgument Int
    }


roleExt :
    (RoleExtOptionalArguments -> RoleExtOptionalArguments)
    -> SelectionSet decodesTo Fractal.Object.RoleExt
    -> SelectionSet (Maybe (List (Maybe decodesTo))) Fractal.Object.AddRoleExtPayload
roleExt fillInOptionals____ object____ =
    let
        filledInOptionals____ =
            fillInOptionals____ { filter = Absent, order = Absent, first = Absent, offset = Absent }

        optionalArgs____ =
            [ Argument.optional "filter" filledInOptionals____.filter Fractal.InputObject.encodeRoleExtFilter, Argument.optional "order" filledInOptionals____.order Fractal.InputObject.encodeRoleExtOrder, Argument.optional "first" filledInOptionals____.first Encode.int, Argument.optional "offset" filledInOptionals____.offset Encode.int ]
                |> List.filterMap Basics.identity
    in
    Object.selectionForCompositeField "roleExt" optionalArgs____ object____ (Basics.identity >> Decode.nullable >> Decode.list >> Decode.nullable)


numUids : SelectionSet (Maybe Int) Fractal.Object.AddRoleExtPayload
numUids =
    Object.selectionForField "(Maybe Int)" "numUids" [] (Decode.int |> Decode.nullable)
