-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Fractal.Object.NodeFragment exposing (..)

import Fractal.Enum.NodeMode
import Fractal.Enum.NodeType
import Fractal.Enum.NodeVisibility
import Fractal.Enum.RoleType
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


id : SelectionSet Fractal.ScalarCodecs.Id Fractal.Object.NodeFragment
id =
    Object.selectionForField "ScalarCodecs.Id" "id" [] (Fractal.ScalarCodecs.codecs |> Fractal.Scalar.unwrapCodecs |> .codecId |> .decoder)


nameid : SelectionSet (Maybe String) Fractal.Object.NodeFragment
nameid =
    Object.selectionForField "(Maybe String)" "nameid" [] (Decode.string |> Decode.nullable)


name : SelectionSet (Maybe String) Fractal.Object.NodeFragment
name =
    Object.selectionForField "(Maybe String)" "name" [] (Decode.string |> Decode.nullable)


about : SelectionSet (Maybe String) Fractal.Object.NodeFragment
about =
    Object.selectionForField "(Maybe String)" "about" [] (Decode.string |> Decode.nullable)


type alias MandateOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.MandateFilter }


mandate :
    (MandateOptionalArguments -> MandateOptionalArguments)
    -> SelectionSet decodesTo Fractal.Object.Mandate
    -> SelectionSet (Maybe decodesTo) Fractal.Object.NodeFragment
mandate fillInOptionals____ object____ =
    let
        filledInOptionals____ =
            fillInOptionals____ { filter = Absent }

        optionalArgs____ =
            [ Argument.optional "filter" filledInOptionals____.filter Fractal.InputObject.encodeMandateFilter ]
                |> List.filterMap Basics.identity
    in
    Object.selectionForCompositeField "mandate" optionalArgs____ object____ (Basics.identity >> Decode.nullable)


skills : SelectionSet (Maybe (List String)) Fractal.Object.NodeFragment
skills =
    Object.selectionForField "(Maybe (List String))" "skills" [] (Decode.string |> Decode.list |> Decode.nullable)


type alias ChildrenOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.NodeFragmentFilter
    , order : OptionalArgument Fractal.InputObject.NodeFragmentOrder
    , first : OptionalArgument Int
    , offset : OptionalArgument Int
    }


children :
    (ChildrenOptionalArguments -> ChildrenOptionalArguments)
    -> SelectionSet decodesTo Fractal.Object.NodeFragment
    -> SelectionSet (Maybe (List decodesTo)) Fractal.Object.NodeFragment
children fillInOptionals____ object____ =
    let
        filledInOptionals____ =
            fillInOptionals____ { filter = Absent, order = Absent, first = Absent, offset = Absent }

        optionalArgs____ =
            [ Argument.optional "filter" filledInOptionals____.filter Fractal.InputObject.encodeNodeFragmentFilter, Argument.optional "order" filledInOptionals____.order Fractal.InputObject.encodeNodeFragmentOrder, Argument.optional "first" filledInOptionals____.first Encode.int, Argument.optional "offset" filledInOptionals____.offset Encode.int ]
                |> List.filterMap Basics.identity
    in
    Object.selectionForCompositeField "children" optionalArgs____ object____ (Basics.identity >> Decode.list >> Decode.nullable)


visibility : SelectionSet (Maybe Fractal.Enum.NodeVisibility.NodeVisibility) Fractal.Object.NodeFragment
visibility =
    Object.selectionForField "(Maybe Enum.NodeVisibility.NodeVisibility)" "visibility" [] (Fractal.Enum.NodeVisibility.decoder |> Decode.nullable)


mode : SelectionSet (Maybe Fractal.Enum.NodeMode.NodeMode) Fractal.Object.NodeFragment
mode =
    Object.selectionForField "(Maybe Enum.NodeMode.NodeMode)" "mode" [] (Fractal.Enum.NodeMode.decoder |> Decode.nullable)


type_ : SelectionSet (Maybe Fractal.Enum.NodeType.NodeType) Fractal.Object.NodeFragment
type_ =
    Object.selectionForField "(Maybe Enum.NodeType.NodeType)" "type_" [] (Fractal.Enum.NodeType.decoder |> Decode.nullable)


first_link : SelectionSet (Maybe String) Fractal.Object.NodeFragment
first_link =
    Object.selectionForField "(Maybe String)" "first_link" [] (Decode.string |> Decode.nullable)


second_link : SelectionSet (Maybe String) Fractal.Object.NodeFragment
second_link =
    Object.selectionForField "(Maybe String)" "second_link" [] (Decode.string |> Decode.nullable)


role_type : SelectionSet (Maybe Fractal.Enum.RoleType.RoleType) Fractal.Object.NodeFragment
role_type =
    Object.selectionForField "(Maybe Enum.RoleType.RoleType)" "role_type" [] (Fractal.Enum.RoleType.decoder |> Decode.nullable)


type alias ChildrenAggregateOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.NodeFragmentFilter }


childrenAggregate :
    (ChildrenAggregateOptionalArguments -> ChildrenAggregateOptionalArguments)
    -> SelectionSet decodesTo Fractal.Object.NodeFragmentAggregateResult
    -> SelectionSet (Maybe decodesTo) Fractal.Object.NodeFragment
childrenAggregate fillInOptionals____ object____ =
    let
        filledInOptionals____ =
            fillInOptionals____ { filter = Absent }

        optionalArgs____ =
            [ Argument.optional "filter" filledInOptionals____.filter Fractal.InputObject.encodeNodeFragmentFilter ]
                |> List.filterMap Basics.identity
    in
    Object.selectionForCompositeField "childrenAggregate" optionalArgs____ object____ (Basics.identity >> Decode.nullable)
