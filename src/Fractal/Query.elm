-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Fractal.Query exposing (..)

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
import Json.Decode as Decode exposing (Decoder)


type alias GetNodeOptionalArguments =
    { id : OptionalArgument Fractal.ScalarCodecs.Id
    , nameid : OptionalArgument String
    }


getNode :
    (GetNodeOptionalArguments -> GetNodeOptionalArguments)
    -> SelectionSet decodesTo Fractal.Object.Node
    -> SelectionSet (Maybe decodesTo) RootQuery
getNode fillInOptionals object_ =
    let
        filledInOptionals =
            fillInOptionals { id = Absent, nameid = Absent }

        optionalArgs =
            [ Argument.optional "id" filledInOptionals.id (Fractal.ScalarCodecs.codecs |> Fractal.Scalar.unwrapEncoder .codecId), Argument.optional "nameid" filledInOptionals.nameid Encode.string ]
                |> List.filterMap identity
    in
    Object.selectionForCompositeField "getNode" optionalArgs object_ (identity >> Decode.nullable)


type alias QueryNodeOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.NodeFilter
    , order : OptionalArgument Fractal.InputObject.NodeOrder
    , first : OptionalArgument Int
    , offset : OptionalArgument Int
    }


queryNode :
    (QueryNodeOptionalArguments -> QueryNodeOptionalArguments)
    -> SelectionSet decodesTo Fractal.Object.Node
    -> SelectionSet (Maybe (List (Maybe decodesTo))) RootQuery
queryNode fillInOptionals object_ =
    let
        filledInOptionals =
            fillInOptionals { filter = Absent, order = Absent, first = Absent, offset = Absent }

        optionalArgs =
            [ Argument.optional "filter" filledInOptionals.filter Fractal.InputObject.encodeNodeFilter, Argument.optional "order" filledInOptionals.order Fractal.InputObject.encodeNodeOrder, Argument.optional "first" filledInOptionals.first Encode.int, Argument.optional "offset" filledInOptionals.offset Encode.int ]
                |> List.filterMap identity
    in
    Object.selectionForCompositeField "queryNode" optionalArgs object_ (identity >> Decode.nullable >> Decode.list >> Decode.nullable)


type alias AggregateNodeOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.NodeFilter }


aggregateNode :
    (AggregateNodeOptionalArguments -> AggregateNodeOptionalArguments)
    -> SelectionSet decodesTo Fractal.Object.NodeAggregateResult
    -> SelectionSet (Maybe decodesTo) RootQuery
aggregateNode fillInOptionals object_ =
    let
        filledInOptionals =
            fillInOptionals { filter = Absent }

        optionalArgs =
            [ Argument.optional "filter" filledInOptionals.filter Fractal.InputObject.encodeNodeFilter ]
                |> List.filterMap identity
    in
    Object.selectionForCompositeField "aggregateNode" optionalArgs object_ (identity >> Decode.nullable)


type alias GetNodeFragmentRequiredArguments =
    { id : Fractal.ScalarCodecs.Id }


getNodeFragment :
    GetNodeFragmentRequiredArguments
    -> SelectionSet decodesTo Fractal.Object.NodeFragment
    -> SelectionSet (Maybe decodesTo) RootQuery
getNodeFragment requiredArgs object_ =
    Object.selectionForCompositeField "getNodeFragment" [ Argument.required "id" requiredArgs.id (Fractal.ScalarCodecs.codecs |> Fractal.Scalar.unwrapEncoder .codecId) ] object_ (identity >> Decode.nullable)


type alias QueryNodeFragmentOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.NodeFragmentFilter
    , order : OptionalArgument Fractal.InputObject.NodeFragmentOrder
    , first : OptionalArgument Int
    , offset : OptionalArgument Int
    }


queryNodeFragment :
    (QueryNodeFragmentOptionalArguments -> QueryNodeFragmentOptionalArguments)
    -> SelectionSet decodesTo Fractal.Object.NodeFragment
    -> SelectionSet (Maybe (List (Maybe decodesTo))) RootQuery
queryNodeFragment fillInOptionals object_ =
    let
        filledInOptionals =
            fillInOptionals { filter = Absent, order = Absent, first = Absent, offset = Absent }

        optionalArgs =
            [ Argument.optional "filter" filledInOptionals.filter Fractal.InputObject.encodeNodeFragmentFilter, Argument.optional "order" filledInOptionals.order Fractal.InputObject.encodeNodeFragmentOrder, Argument.optional "first" filledInOptionals.first Encode.int, Argument.optional "offset" filledInOptionals.offset Encode.int ]
                |> List.filterMap identity
    in
    Object.selectionForCompositeField "queryNodeFragment" optionalArgs object_ (identity >> Decode.nullable >> Decode.list >> Decode.nullable)


type alias AggregateNodeFragmentOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.NodeFragmentFilter }


aggregateNodeFragment :
    (AggregateNodeFragmentOptionalArguments -> AggregateNodeFragmentOptionalArguments)
    -> SelectionSet decodesTo Fractal.Object.NodeFragmentAggregateResult
    -> SelectionSet (Maybe decodesTo) RootQuery
aggregateNodeFragment fillInOptionals object_ =
    let
        filledInOptionals =
            fillInOptionals { filter = Absent }

        optionalArgs =
            [ Argument.optional "filter" filledInOptionals.filter Fractal.InputObject.encodeNodeFragmentFilter ]
                |> List.filterMap identity
    in
    Object.selectionForCompositeField "aggregateNodeFragment" optionalArgs object_ (identity >> Decode.nullable)


type alias GetMandateRequiredArguments =
    { id : Fractal.ScalarCodecs.Id }


getMandate :
    GetMandateRequiredArguments
    -> SelectionSet decodesTo Fractal.Object.Mandate
    -> SelectionSet (Maybe decodesTo) RootQuery
getMandate requiredArgs object_ =
    Object.selectionForCompositeField "getMandate" [ Argument.required "id" requiredArgs.id (Fractal.ScalarCodecs.codecs |> Fractal.Scalar.unwrapEncoder .codecId) ] object_ (identity >> Decode.nullable)


type alias QueryMandateOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.MandateFilter
    , order : OptionalArgument Fractal.InputObject.MandateOrder
    , first : OptionalArgument Int
    , offset : OptionalArgument Int
    }


queryMandate :
    (QueryMandateOptionalArguments -> QueryMandateOptionalArguments)
    -> SelectionSet decodesTo Fractal.Object.Mandate
    -> SelectionSet (Maybe (List (Maybe decodesTo))) RootQuery
queryMandate fillInOptionals object_ =
    let
        filledInOptionals =
            fillInOptionals { filter = Absent, order = Absent, first = Absent, offset = Absent }

        optionalArgs =
            [ Argument.optional "filter" filledInOptionals.filter Fractal.InputObject.encodeMandateFilter, Argument.optional "order" filledInOptionals.order Fractal.InputObject.encodeMandateOrder, Argument.optional "first" filledInOptionals.first Encode.int, Argument.optional "offset" filledInOptionals.offset Encode.int ]
                |> List.filterMap identity
    in
    Object.selectionForCompositeField "queryMandate" optionalArgs object_ (identity >> Decode.nullable >> Decode.list >> Decode.nullable)


type alias AggregateMandateOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.MandateFilter }


aggregateMandate :
    (AggregateMandateOptionalArguments -> AggregateMandateOptionalArguments)
    -> SelectionSet decodesTo Fractal.Object.MandateAggregateResult
    -> SelectionSet (Maybe decodesTo) RootQuery
aggregateMandate fillInOptionals object_ =
    let
        filledInOptionals =
            fillInOptionals { filter = Absent }

        optionalArgs =
            [ Argument.optional "filter" filledInOptionals.filter Fractal.InputObject.encodeMandateFilter ]
                |> List.filterMap identity
    in
    Object.selectionForCompositeField "aggregateMandate" optionalArgs object_ (identity >> Decode.nullable)


type alias GetNodeCharacRequiredArguments =
    { id : Fractal.ScalarCodecs.Id }


getNodeCharac :
    GetNodeCharacRequiredArguments
    -> SelectionSet decodesTo Fractal.Object.NodeCharac
    -> SelectionSet (Maybe decodesTo) RootQuery
getNodeCharac requiredArgs object_ =
    Object.selectionForCompositeField "getNodeCharac" [ Argument.required "id" requiredArgs.id (Fractal.ScalarCodecs.codecs |> Fractal.Scalar.unwrapEncoder .codecId) ] object_ (identity >> Decode.nullable)


type alias QueryNodeCharacOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.NodeCharacFilter
    , first : OptionalArgument Int
    , offset : OptionalArgument Int
    }


queryNodeCharac :
    (QueryNodeCharacOptionalArguments -> QueryNodeCharacOptionalArguments)
    -> SelectionSet decodesTo Fractal.Object.NodeCharac
    -> SelectionSet (Maybe (List (Maybe decodesTo))) RootQuery
queryNodeCharac fillInOptionals object_ =
    let
        filledInOptionals =
            fillInOptionals { filter = Absent, first = Absent, offset = Absent }

        optionalArgs =
            [ Argument.optional "filter" filledInOptionals.filter Fractal.InputObject.encodeNodeCharacFilter, Argument.optional "first" filledInOptionals.first Encode.int, Argument.optional "offset" filledInOptionals.offset Encode.int ]
                |> List.filterMap identity
    in
    Object.selectionForCompositeField "queryNodeCharac" optionalArgs object_ (identity >> Decode.nullable >> Decode.list >> Decode.nullable)


type alias AggregateNodeCharacOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.NodeCharacFilter }


aggregateNodeCharac :
    (AggregateNodeCharacOptionalArguments -> AggregateNodeCharacOptionalArguments)
    -> SelectionSet decodesTo Fractal.Object.NodeCharacAggregateResult
    -> SelectionSet (Maybe decodesTo) RootQuery
aggregateNodeCharac fillInOptionals object_ =
    let
        filledInOptionals =
            fillInOptionals { filter = Absent }

        optionalArgs =
            [ Argument.optional "filter" filledInOptionals.filter Fractal.InputObject.encodeNodeCharacFilter ]
                |> List.filterMap identity
    in
    Object.selectionForCompositeField "aggregateNodeCharac" optionalArgs object_ (identity >> Decode.nullable)


type alias QueryOrgaAggOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.OrgaAggFilter
    , order : OptionalArgument Fractal.InputObject.OrgaAggOrder
    , first : OptionalArgument Int
    , offset : OptionalArgument Int
    }


queryOrgaAgg :
    (QueryOrgaAggOptionalArguments -> QueryOrgaAggOptionalArguments)
    -> SelectionSet decodesTo Fractal.Object.OrgaAgg
    -> SelectionSet (Maybe (List (Maybe decodesTo))) RootQuery
queryOrgaAgg fillInOptionals object_ =
    let
        filledInOptionals =
            fillInOptionals { filter = Absent, order = Absent, first = Absent, offset = Absent }

        optionalArgs =
            [ Argument.optional "filter" filledInOptionals.filter Fractal.InputObject.encodeOrgaAggFilter, Argument.optional "order" filledInOptionals.order Fractal.InputObject.encodeOrgaAggOrder, Argument.optional "first" filledInOptionals.first Encode.int, Argument.optional "offset" filledInOptionals.offset Encode.int ]
                |> List.filterMap identity
    in
    Object.selectionForCompositeField "queryOrgaAgg" optionalArgs object_ (identity >> Decode.nullable >> Decode.list >> Decode.nullable)


type alias AggregateOrgaAggOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.OrgaAggFilter }


aggregateOrgaAgg :
    (AggregateOrgaAggOptionalArguments -> AggregateOrgaAggOptionalArguments)
    -> SelectionSet decodesTo Fractal.Object.OrgaAggAggregateResult
    -> SelectionSet (Maybe decodesTo) RootQuery
aggregateOrgaAgg fillInOptionals object_ =
    let
        filledInOptionals =
            fillInOptionals { filter = Absent }

        optionalArgs =
            [ Argument.optional "filter" filledInOptionals.filter Fractal.InputObject.encodeOrgaAggFilter ]
                |> List.filterMap identity
    in
    Object.selectionForCompositeField "aggregateOrgaAgg" optionalArgs object_ (identity >> Decode.nullable)


type alias GetPostRequiredArguments =
    { id : Fractal.ScalarCodecs.Id }


getPost :
    GetPostRequiredArguments
    -> SelectionSet decodesTo Fractal.Object.Post
    -> SelectionSet (Maybe decodesTo) RootQuery
getPost requiredArgs object_ =
    Object.selectionForCompositeField "getPost" [ Argument.required "id" requiredArgs.id (Fractal.ScalarCodecs.codecs |> Fractal.Scalar.unwrapEncoder .codecId) ] object_ (identity >> Decode.nullable)


type alias QueryPostOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.PostFilter
    , order : OptionalArgument Fractal.InputObject.PostOrder
    , first : OptionalArgument Int
    , offset : OptionalArgument Int
    }


queryPost :
    (QueryPostOptionalArguments -> QueryPostOptionalArguments)
    -> SelectionSet decodesTo Fractal.Object.Post
    -> SelectionSet (Maybe (List (Maybe decodesTo))) RootQuery
queryPost fillInOptionals object_ =
    let
        filledInOptionals =
            fillInOptionals { filter = Absent, order = Absent, first = Absent, offset = Absent }

        optionalArgs =
            [ Argument.optional "filter" filledInOptionals.filter Fractal.InputObject.encodePostFilter, Argument.optional "order" filledInOptionals.order Fractal.InputObject.encodePostOrder, Argument.optional "first" filledInOptionals.first Encode.int, Argument.optional "offset" filledInOptionals.offset Encode.int ]
                |> List.filterMap identity
    in
    Object.selectionForCompositeField "queryPost" optionalArgs object_ (identity >> Decode.nullable >> Decode.list >> Decode.nullable)


type alias AggregatePostOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.PostFilter }


aggregatePost :
    (AggregatePostOptionalArguments -> AggregatePostOptionalArguments)
    -> SelectionSet decodesTo Fractal.Object.PostAggregateResult
    -> SelectionSet (Maybe decodesTo) RootQuery
aggregatePost fillInOptionals object_ =
    let
        filledInOptionals =
            fillInOptionals { filter = Absent }

        optionalArgs =
            [ Argument.optional "filter" filledInOptionals.filter Fractal.InputObject.encodePostFilter ]
                |> List.filterMap identity
    in
    Object.selectionForCompositeField "aggregatePost" optionalArgs object_ (identity >> Decode.nullable)


type alias GetTensionRequiredArguments =
    { id : Fractal.ScalarCodecs.Id }


getTension :
    GetTensionRequiredArguments
    -> SelectionSet decodesTo Fractal.Object.Tension
    -> SelectionSet (Maybe decodesTo) RootQuery
getTension requiredArgs object_ =
    Object.selectionForCompositeField "getTension" [ Argument.required "id" requiredArgs.id (Fractal.ScalarCodecs.codecs |> Fractal.Scalar.unwrapEncoder .codecId) ] object_ (identity >> Decode.nullable)


type alias QueryTensionOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.TensionFilter
    , order : OptionalArgument Fractal.InputObject.TensionOrder
    , first : OptionalArgument Int
    , offset : OptionalArgument Int
    }


queryTension :
    (QueryTensionOptionalArguments -> QueryTensionOptionalArguments)
    -> SelectionSet decodesTo Fractal.Object.Tension
    -> SelectionSet (Maybe (List (Maybe decodesTo))) RootQuery
queryTension fillInOptionals object_ =
    let
        filledInOptionals =
            fillInOptionals { filter = Absent, order = Absent, first = Absent, offset = Absent }

        optionalArgs =
            [ Argument.optional "filter" filledInOptionals.filter Fractal.InputObject.encodeTensionFilter, Argument.optional "order" filledInOptionals.order Fractal.InputObject.encodeTensionOrder, Argument.optional "first" filledInOptionals.first Encode.int, Argument.optional "offset" filledInOptionals.offset Encode.int ]
                |> List.filterMap identity
    in
    Object.selectionForCompositeField "queryTension" optionalArgs object_ (identity >> Decode.nullable >> Decode.list >> Decode.nullable)


type alias AggregateTensionOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.TensionFilter }


aggregateTension :
    (AggregateTensionOptionalArguments -> AggregateTensionOptionalArguments)
    -> SelectionSet decodesTo Fractal.Object.TensionAggregateResult
    -> SelectionSet (Maybe decodesTo) RootQuery
aggregateTension fillInOptionals object_ =
    let
        filledInOptionals =
            fillInOptionals { filter = Absent }

        optionalArgs =
            [ Argument.optional "filter" filledInOptionals.filter Fractal.InputObject.encodeTensionFilter ]
                |> List.filterMap identity
    in
    Object.selectionForCompositeField "aggregateTension" optionalArgs object_ (identity >> Decode.nullable)


type alias GetLabelRequiredArguments =
    { id : Fractal.ScalarCodecs.Id }


getLabel :
    GetLabelRequiredArguments
    -> SelectionSet decodesTo Fractal.Object.Label
    -> SelectionSet (Maybe decodesTo) RootQuery
getLabel requiredArgs object_ =
    Object.selectionForCompositeField "getLabel" [ Argument.required "id" requiredArgs.id (Fractal.ScalarCodecs.codecs |> Fractal.Scalar.unwrapEncoder .codecId) ] object_ (identity >> Decode.nullable)


type alias QueryLabelOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.LabelFilter
    , order : OptionalArgument Fractal.InputObject.LabelOrder
    , first : OptionalArgument Int
    , offset : OptionalArgument Int
    }


queryLabel :
    (QueryLabelOptionalArguments -> QueryLabelOptionalArguments)
    -> SelectionSet decodesTo Fractal.Object.Label
    -> SelectionSet (Maybe (List (Maybe decodesTo))) RootQuery
queryLabel fillInOptionals object_ =
    let
        filledInOptionals =
            fillInOptionals { filter = Absent, order = Absent, first = Absent, offset = Absent }

        optionalArgs =
            [ Argument.optional "filter" filledInOptionals.filter Fractal.InputObject.encodeLabelFilter, Argument.optional "order" filledInOptionals.order Fractal.InputObject.encodeLabelOrder, Argument.optional "first" filledInOptionals.first Encode.int, Argument.optional "offset" filledInOptionals.offset Encode.int ]
                |> List.filterMap identity
    in
    Object.selectionForCompositeField "queryLabel" optionalArgs object_ (identity >> Decode.nullable >> Decode.list >> Decode.nullable)


type alias AggregateLabelOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.LabelFilter }


aggregateLabel :
    (AggregateLabelOptionalArguments -> AggregateLabelOptionalArguments)
    -> SelectionSet decodesTo Fractal.Object.LabelAggregateResult
    -> SelectionSet (Maybe decodesTo) RootQuery
aggregateLabel fillInOptionals object_ =
    let
        filledInOptionals =
            fillInOptionals { filter = Absent }

        optionalArgs =
            [ Argument.optional "filter" filledInOptionals.filter Fractal.InputObject.encodeLabelFilter ]
                |> List.filterMap identity
    in
    Object.selectionForCompositeField "aggregateLabel" optionalArgs object_ (identity >> Decode.nullable)


type alias GetCommentRequiredArguments =
    { id : Fractal.ScalarCodecs.Id }


getComment :
    GetCommentRequiredArguments
    -> SelectionSet decodesTo Fractal.Object.Comment
    -> SelectionSet (Maybe decodesTo) RootQuery
getComment requiredArgs object_ =
    Object.selectionForCompositeField "getComment" [ Argument.required "id" requiredArgs.id (Fractal.ScalarCodecs.codecs |> Fractal.Scalar.unwrapEncoder .codecId) ] object_ (identity >> Decode.nullable)


type alias QueryCommentOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.CommentFilter
    , order : OptionalArgument Fractal.InputObject.CommentOrder
    , first : OptionalArgument Int
    , offset : OptionalArgument Int
    }


queryComment :
    (QueryCommentOptionalArguments -> QueryCommentOptionalArguments)
    -> SelectionSet decodesTo Fractal.Object.Comment
    -> SelectionSet (Maybe (List (Maybe decodesTo))) RootQuery
queryComment fillInOptionals object_ =
    let
        filledInOptionals =
            fillInOptionals { filter = Absent, order = Absent, first = Absent, offset = Absent }

        optionalArgs =
            [ Argument.optional "filter" filledInOptionals.filter Fractal.InputObject.encodeCommentFilter, Argument.optional "order" filledInOptionals.order Fractal.InputObject.encodeCommentOrder, Argument.optional "first" filledInOptionals.first Encode.int, Argument.optional "offset" filledInOptionals.offset Encode.int ]
                |> List.filterMap identity
    in
    Object.selectionForCompositeField "queryComment" optionalArgs object_ (identity >> Decode.nullable >> Decode.list >> Decode.nullable)


type alias AggregateCommentOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.CommentFilter }


aggregateComment :
    (AggregateCommentOptionalArguments -> AggregateCommentOptionalArguments)
    -> SelectionSet decodesTo Fractal.Object.CommentAggregateResult
    -> SelectionSet (Maybe decodesTo) RootQuery
aggregateComment fillInOptionals object_ =
    let
        filledInOptionals =
            fillInOptionals { filter = Absent }

        optionalArgs =
            [ Argument.optional "filter" filledInOptionals.filter Fractal.InputObject.encodeCommentFilter ]
                |> List.filterMap identity
    in
    Object.selectionForCompositeField "aggregateComment" optionalArgs object_ (identity >> Decode.nullable)


type alias GetBlobRequiredArguments =
    { id : Fractal.ScalarCodecs.Id }


getBlob :
    GetBlobRequiredArguments
    -> SelectionSet decodesTo Fractal.Object.Blob
    -> SelectionSet (Maybe decodesTo) RootQuery
getBlob requiredArgs object_ =
    Object.selectionForCompositeField "getBlob" [ Argument.required "id" requiredArgs.id (Fractal.ScalarCodecs.codecs |> Fractal.Scalar.unwrapEncoder .codecId) ] object_ (identity >> Decode.nullable)


type alias QueryBlobOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.BlobFilter
    , order : OptionalArgument Fractal.InputObject.BlobOrder
    , first : OptionalArgument Int
    , offset : OptionalArgument Int
    }


queryBlob :
    (QueryBlobOptionalArguments -> QueryBlobOptionalArguments)
    -> SelectionSet decodesTo Fractal.Object.Blob
    -> SelectionSet (Maybe (List (Maybe decodesTo))) RootQuery
queryBlob fillInOptionals object_ =
    let
        filledInOptionals =
            fillInOptionals { filter = Absent, order = Absent, first = Absent, offset = Absent }

        optionalArgs =
            [ Argument.optional "filter" filledInOptionals.filter Fractal.InputObject.encodeBlobFilter, Argument.optional "order" filledInOptionals.order Fractal.InputObject.encodeBlobOrder, Argument.optional "first" filledInOptionals.first Encode.int, Argument.optional "offset" filledInOptionals.offset Encode.int ]
                |> List.filterMap identity
    in
    Object.selectionForCompositeField "queryBlob" optionalArgs object_ (identity >> Decode.nullable >> Decode.list >> Decode.nullable)


type alias AggregateBlobOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.BlobFilter }


aggregateBlob :
    (AggregateBlobOptionalArguments -> AggregateBlobOptionalArguments)
    -> SelectionSet decodesTo Fractal.Object.BlobAggregateResult
    -> SelectionSet (Maybe decodesTo) RootQuery
aggregateBlob fillInOptionals object_ =
    let
        filledInOptionals =
            fillInOptionals { filter = Absent }

        optionalArgs =
            [ Argument.optional "filter" filledInOptionals.filter Fractal.InputObject.encodeBlobFilter ]
                |> List.filterMap identity
    in
    Object.selectionForCompositeField "aggregateBlob" optionalArgs object_ (identity >> Decode.nullable)


type alias GetEventRequiredArguments =
    { id : Fractal.ScalarCodecs.Id }


getEvent :
    GetEventRequiredArguments
    -> SelectionSet decodesTo Fractal.Object.Event
    -> SelectionSet (Maybe decodesTo) RootQuery
getEvent requiredArgs object_ =
    Object.selectionForCompositeField "getEvent" [ Argument.required "id" requiredArgs.id (Fractal.ScalarCodecs.codecs |> Fractal.Scalar.unwrapEncoder .codecId) ] object_ (identity >> Decode.nullable)


type alias QueryEventOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.EventFilter
    , order : OptionalArgument Fractal.InputObject.EventOrder
    , first : OptionalArgument Int
    , offset : OptionalArgument Int
    }


queryEvent :
    (QueryEventOptionalArguments -> QueryEventOptionalArguments)
    -> SelectionSet decodesTo Fractal.Object.Event
    -> SelectionSet (Maybe (List (Maybe decodesTo))) RootQuery
queryEvent fillInOptionals object_ =
    let
        filledInOptionals =
            fillInOptionals { filter = Absent, order = Absent, first = Absent, offset = Absent }

        optionalArgs =
            [ Argument.optional "filter" filledInOptionals.filter Fractal.InputObject.encodeEventFilter, Argument.optional "order" filledInOptionals.order Fractal.InputObject.encodeEventOrder, Argument.optional "first" filledInOptionals.first Encode.int, Argument.optional "offset" filledInOptionals.offset Encode.int ]
                |> List.filterMap identity
    in
    Object.selectionForCompositeField "queryEvent" optionalArgs object_ (identity >> Decode.nullable >> Decode.list >> Decode.nullable)


type alias AggregateEventOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.EventFilter }


aggregateEvent :
    (AggregateEventOptionalArguments -> AggregateEventOptionalArguments)
    -> SelectionSet decodesTo Fractal.Object.EventAggregateResult
    -> SelectionSet (Maybe decodesTo) RootQuery
aggregateEvent fillInOptionals object_ =
    let
        filledInOptionals =
            fillInOptionals { filter = Absent }

        optionalArgs =
            [ Argument.optional "filter" filledInOptionals.filter Fractal.InputObject.encodeEventFilter ]
                |> List.filterMap identity
    in
    Object.selectionForCompositeField "aggregateEvent" optionalArgs object_ (identity >> Decode.nullable)


type alias QueryEventFragmentOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.EventFragmentFilter
    , order : OptionalArgument Fractal.InputObject.EventFragmentOrder
    , first : OptionalArgument Int
    , offset : OptionalArgument Int
    }


queryEventFragment :
    (QueryEventFragmentOptionalArguments -> QueryEventFragmentOptionalArguments)
    -> SelectionSet decodesTo Fractal.Object.EventFragment
    -> SelectionSet (Maybe (List (Maybe decodesTo))) RootQuery
queryEventFragment fillInOptionals object_ =
    let
        filledInOptionals =
            fillInOptionals { filter = Absent, order = Absent, first = Absent, offset = Absent }

        optionalArgs =
            [ Argument.optional "filter" filledInOptionals.filter Fractal.InputObject.encodeEventFragmentFilter, Argument.optional "order" filledInOptionals.order Fractal.InputObject.encodeEventFragmentOrder, Argument.optional "first" filledInOptionals.first Encode.int, Argument.optional "offset" filledInOptionals.offset Encode.int ]
                |> List.filterMap identity
    in
    Object.selectionForCompositeField "queryEventFragment" optionalArgs object_ (identity >> Decode.nullable >> Decode.list >> Decode.nullable)


type alias AggregateEventFragmentOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.EventFragmentFilter }


aggregateEventFragment :
    (AggregateEventFragmentOptionalArguments -> AggregateEventFragmentOptionalArguments)
    -> SelectionSet decodesTo Fractal.Object.EventFragmentAggregateResult
    -> SelectionSet (Maybe decodesTo) RootQuery
aggregateEventFragment fillInOptionals object_ =
    let
        filledInOptionals =
            fillInOptionals { filter = Absent }

        optionalArgs =
            [ Argument.optional "filter" filledInOptionals.filter Fractal.InputObject.encodeEventFragmentFilter ]
                |> List.filterMap identity
    in
    Object.selectionForCompositeField "aggregateEventFragment" optionalArgs object_ (identity >> Decode.nullable)


type alias GetContractRequiredArguments =
    { id : Fractal.ScalarCodecs.Id }


getContract :
    GetContractRequiredArguments
    -> SelectionSet decodesTo Fractal.Object.Contract
    -> SelectionSet (Maybe decodesTo) RootQuery
getContract requiredArgs object_ =
    Object.selectionForCompositeField "getContract" [ Argument.required "id" requiredArgs.id (Fractal.ScalarCodecs.codecs |> Fractal.Scalar.unwrapEncoder .codecId) ] object_ (identity >> Decode.nullable)


type alias QueryContractOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.ContractFilter
    , order : OptionalArgument Fractal.InputObject.ContractOrder
    , first : OptionalArgument Int
    , offset : OptionalArgument Int
    }


queryContract :
    (QueryContractOptionalArguments -> QueryContractOptionalArguments)
    -> SelectionSet decodesTo Fractal.Object.Contract
    -> SelectionSet (Maybe (List (Maybe decodesTo))) RootQuery
queryContract fillInOptionals object_ =
    let
        filledInOptionals =
            fillInOptionals { filter = Absent, order = Absent, first = Absent, offset = Absent }

        optionalArgs =
            [ Argument.optional "filter" filledInOptionals.filter Fractal.InputObject.encodeContractFilter, Argument.optional "order" filledInOptionals.order Fractal.InputObject.encodeContractOrder, Argument.optional "first" filledInOptionals.first Encode.int, Argument.optional "offset" filledInOptionals.offset Encode.int ]
                |> List.filterMap identity
    in
    Object.selectionForCompositeField "queryContract" optionalArgs object_ (identity >> Decode.nullable >> Decode.list >> Decode.nullable)


type alias AggregateContractOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.ContractFilter }


aggregateContract :
    (AggregateContractOptionalArguments -> AggregateContractOptionalArguments)
    -> SelectionSet decodesTo Fractal.Object.ContractAggregateResult
    -> SelectionSet (Maybe decodesTo) RootQuery
aggregateContract fillInOptionals object_ =
    let
        filledInOptionals =
            fillInOptionals { filter = Absent }

        optionalArgs =
            [ Argument.optional "filter" filledInOptionals.filter Fractal.InputObject.encodeContractFilter ]
                |> List.filterMap identity
    in
    Object.selectionForCompositeField "aggregateContract" optionalArgs object_ (identity >> Decode.nullable)


type alias GetVoteRequiredArguments =
    { id : Fractal.ScalarCodecs.Id }


getVote :
    GetVoteRequiredArguments
    -> SelectionSet decodesTo Fractal.Object.Vote
    -> SelectionSet (Maybe decodesTo) RootQuery
getVote requiredArgs object_ =
    Object.selectionForCompositeField "getVote" [ Argument.required "id" requiredArgs.id (Fractal.ScalarCodecs.codecs |> Fractal.Scalar.unwrapEncoder .codecId) ] object_ (identity >> Decode.nullable)


type alias QueryVoteOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.VoteFilter
    , first : OptionalArgument Int
    , offset : OptionalArgument Int
    }


queryVote :
    (QueryVoteOptionalArguments -> QueryVoteOptionalArguments)
    -> SelectionSet decodesTo Fractal.Object.Vote
    -> SelectionSet (Maybe (List (Maybe decodesTo))) RootQuery
queryVote fillInOptionals object_ =
    let
        filledInOptionals =
            fillInOptionals { filter = Absent, first = Absent, offset = Absent }

        optionalArgs =
            [ Argument.optional "filter" filledInOptionals.filter Fractal.InputObject.encodeVoteFilter, Argument.optional "first" filledInOptionals.first Encode.int, Argument.optional "offset" filledInOptionals.offset Encode.int ]
                |> List.filterMap identity
    in
    Object.selectionForCompositeField "queryVote" optionalArgs object_ (identity >> Decode.nullable >> Decode.list >> Decode.nullable)


type alias AggregateVoteOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.VoteFilter }


aggregateVote :
    (AggregateVoteOptionalArguments -> AggregateVoteOptionalArguments)
    -> SelectionSet decodesTo Fractal.Object.VoteAggregateResult
    -> SelectionSet (Maybe decodesTo) RootQuery
aggregateVote fillInOptionals object_ =
    let
        filledInOptionals =
            fillInOptionals { filter = Absent }

        optionalArgs =
            [ Argument.optional "filter" filledInOptionals.filter Fractal.InputObject.encodeVoteFilter ]
                |> List.filterMap identity
    in
    Object.selectionForCompositeField "aggregateVote" optionalArgs object_ (identity >> Decode.nullable)


type alias GetUserOptionalArguments =
    { id : OptionalArgument Fractal.ScalarCodecs.Id
    , username : OptionalArgument String
    }


getUser :
    (GetUserOptionalArguments -> GetUserOptionalArguments)
    -> SelectionSet decodesTo Fractal.Object.User
    -> SelectionSet (Maybe decodesTo) RootQuery
getUser fillInOptionals object_ =
    let
        filledInOptionals =
            fillInOptionals { id = Absent, username = Absent }

        optionalArgs =
            [ Argument.optional "id" filledInOptionals.id (Fractal.ScalarCodecs.codecs |> Fractal.Scalar.unwrapEncoder .codecId), Argument.optional "username" filledInOptionals.username Encode.string ]
                |> List.filterMap identity
    in
    Object.selectionForCompositeField "getUser" optionalArgs object_ (identity >> Decode.nullable)


type alias QueryUserOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.UserFilter
    , order : OptionalArgument Fractal.InputObject.UserOrder
    , first : OptionalArgument Int
    , offset : OptionalArgument Int
    }


queryUser :
    (QueryUserOptionalArguments -> QueryUserOptionalArguments)
    -> SelectionSet decodesTo Fractal.Object.User
    -> SelectionSet (Maybe (List (Maybe decodesTo))) RootQuery
queryUser fillInOptionals object_ =
    let
        filledInOptionals =
            fillInOptionals { filter = Absent, order = Absent, first = Absent, offset = Absent }

        optionalArgs =
            [ Argument.optional "filter" filledInOptionals.filter Fractal.InputObject.encodeUserFilter, Argument.optional "order" filledInOptionals.order Fractal.InputObject.encodeUserOrder, Argument.optional "first" filledInOptionals.first Encode.int, Argument.optional "offset" filledInOptionals.offset Encode.int ]
                |> List.filterMap identity
    in
    Object.selectionForCompositeField "queryUser" optionalArgs object_ (identity >> Decode.nullable >> Decode.list >> Decode.nullable)


type alias AggregateUserOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.UserFilter }


aggregateUser :
    (AggregateUserOptionalArguments -> AggregateUserOptionalArguments)
    -> SelectionSet decodesTo Fractal.Object.UserAggregateResult
    -> SelectionSet (Maybe decodesTo) RootQuery
aggregateUser fillInOptionals object_ =
    let
        filledInOptionals =
            fillInOptionals { filter = Absent }

        optionalArgs =
            [ Argument.optional "filter" filledInOptionals.filter Fractal.InputObject.encodeUserFilter ]
                |> List.filterMap identity
    in
    Object.selectionForCompositeField "aggregateUser" optionalArgs object_ (identity >> Decode.nullable)


type alias QueryUserRightsOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.UserRightsFilter
    , order : OptionalArgument Fractal.InputObject.UserRightsOrder
    , first : OptionalArgument Int
    , offset : OptionalArgument Int
    }


queryUserRights :
    (QueryUserRightsOptionalArguments -> QueryUserRightsOptionalArguments)
    -> SelectionSet decodesTo Fractal.Object.UserRights
    -> SelectionSet (Maybe (List (Maybe decodesTo))) RootQuery
queryUserRights fillInOptionals object_ =
    let
        filledInOptionals =
            fillInOptionals { filter = Absent, order = Absent, first = Absent, offset = Absent }

        optionalArgs =
            [ Argument.optional "filter" filledInOptionals.filter Fractal.InputObject.encodeUserRightsFilter, Argument.optional "order" filledInOptionals.order Fractal.InputObject.encodeUserRightsOrder, Argument.optional "first" filledInOptionals.first Encode.int, Argument.optional "offset" filledInOptionals.offset Encode.int ]
                |> List.filterMap identity
    in
    Object.selectionForCompositeField "queryUserRights" optionalArgs object_ (identity >> Decode.nullable >> Decode.list >> Decode.nullable)


type alias AggregateUserRightsOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.UserRightsFilter }


aggregateUserRights :
    (AggregateUserRightsOptionalArguments -> AggregateUserRightsOptionalArguments)
    -> SelectionSet decodesTo Fractal.Object.UserRightsAggregateResult
    -> SelectionSet (Maybe decodesTo) RootQuery
aggregateUserRights fillInOptionals object_ =
    let
        filledInOptionals =
            fillInOptionals { filter = Absent }

        optionalArgs =
            [ Argument.optional "filter" filledInOptionals.filter Fractal.InputObject.encodeUserRightsFilter ]
                |> List.filterMap identity
    in
    Object.selectionForCompositeField "aggregateUserRights" optionalArgs object_ (identity >> Decode.nullable)
