-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Fractal.Object.Blob exposing (..)

import Fractal.Enum.BlobType
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


type alias TensionOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.TensionFilter }


tension :
    (TensionOptionalArguments -> TensionOptionalArguments)
    -> SelectionSet decodesTo Fractal.Object.Tension
    -> SelectionSet decodesTo Fractal.Object.Blob
tension fillInOptionals____ object____ =
    let
        filledInOptionals____ =
            fillInOptionals____ { filter = Absent }

        optionalArgs____ =
            [ Argument.optional "filter" filledInOptionals____.filter Fractal.InputObject.encodeTensionFilter ]
                |> List.filterMap Basics.identity
    in
    Object.selectionForCompositeField "tension" optionalArgs____ object____ Basics.identity


blob_type : SelectionSet Fractal.Enum.BlobType.BlobType Fractal.Object.Blob
blob_type =
    Object.selectionForField "Enum.BlobType.BlobType" "blob_type" [] Fractal.Enum.BlobType.decoder


pushedFlag : SelectionSet (Maybe Fractal.ScalarCodecs.DateTime) Fractal.Object.Blob
pushedFlag =
    Object.selectionForField "(Maybe ScalarCodecs.DateTime)" "pushedFlag" [] (Fractal.ScalarCodecs.codecs |> Fractal.Scalar.unwrapCodecs |> .codecDateTime |> .decoder |> Decode.nullable)


archivedFlag : SelectionSet (Maybe Fractal.ScalarCodecs.DateTime) Fractal.Object.Blob
archivedFlag =
    Object.selectionForField "(Maybe ScalarCodecs.DateTime)" "archivedFlag" [] (Fractal.ScalarCodecs.codecs |> Fractal.Scalar.unwrapCodecs |> .codecDateTime |> .decoder |> Decode.nullable)


type alias NodeOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.NodeFragmentFilter }


node :
    (NodeOptionalArguments -> NodeOptionalArguments)
    -> SelectionSet decodesTo Fractal.Object.NodeFragment
    -> SelectionSet (Maybe decodesTo) Fractal.Object.Blob
node fillInOptionals____ object____ =
    let
        filledInOptionals____ =
            fillInOptionals____ { filter = Absent }

        optionalArgs____ =
            [ Argument.optional "filter" filledInOptionals____.filter Fractal.InputObject.encodeNodeFragmentFilter ]
                |> List.filterMap Basics.identity
    in
    Object.selectionForCompositeField "node" optionalArgs____ object____ (Basics.identity >> Decode.nullable)


md : SelectionSet (Maybe String) Fractal.Object.Blob
md =
    Object.selectionForField "(Maybe String)" "md" [] (Decode.string |> Decode.nullable)


id : SelectionSet Fractal.ScalarCodecs.Id Fractal.Object.Blob
id =
    Object.selectionForField "ScalarCodecs.Id" "id" [] (Fractal.ScalarCodecs.codecs |> Fractal.Scalar.unwrapCodecs |> .codecId |> .decoder)


type alias CreatedByOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.UserFilter }


createdBy :
    (CreatedByOptionalArguments -> CreatedByOptionalArguments)
    -> SelectionSet decodesTo Fractal.Object.User
    -> SelectionSet decodesTo Fractal.Object.Blob
createdBy fillInOptionals____ object____ =
    let
        filledInOptionals____ =
            fillInOptionals____ { filter = Absent }

        optionalArgs____ =
            [ Argument.optional "filter" filledInOptionals____.filter Fractal.InputObject.encodeUserFilter ]
                |> List.filterMap Basics.identity
    in
    Object.selectionForCompositeField "createdBy" optionalArgs____ object____ Basics.identity


createdAt : SelectionSet Fractal.ScalarCodecs.DateTime Fractal.Object.Blob
createdAt =
    Object.selectionForField "ScalarCodecs.DateTime" "createdAt" [] (Fractal.ScalarCodecs.codecs |> Fractal.Scalar.unwrapCodecs |> .codecDateTime |> .decoder)


updatedAt : SelectionSet (Maybe Fractal.ScalarCodecs.DateTime) Fractal.Object.Blob
updatedAt =
    Object.selectionForField "(Maybe ScalarCodecs.DateTime)" "updatedAt" [] (Fractal.ScalarCodecs.codecs |> Fractal.Scalar.unwrapCodecs |> .codecDateTime |> .decoder |> Decode.nullable)


message : SelectionSet (Maybe String) Fractal.Object.Blob
message =
    Object.selectionForField "(Maybe String)" "message" [] (Decode.string |> Decode.nullable)
