-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Fractal.Object.Contract exposing (..)

import Fractal.Enum.ContractStatus
import Fractal.Enum.ContractType
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
    -> SelectionSet decodesTo Fractal.Object.Contract
tension fillInOptionals object_ =
    let
        filledInOptionals =
            fillInOptionals { filter = Absent }

        optionalArgs =
            [ Argument.optional "filter" filledInOptionals.filter Fractal.InputObject.encodeTensionFilter ]
                |> List.filterMap identity
    in
    Object.selectionForCompositeField "tension" optionalArgs object_ identity


status : SelectionSet Fractal.Enum.ContractStatus.ContractStatus Fractal.Object.Contract
status =
    Object.selectionForField "Enum.ContractStatus.ContractStatus" "status" [] Fractal.Enum.ContractStatus.decoder


contract_type : SelectionSet Fractal.Enum.ContractType.ContractType Fractal.Object.Contract
contract_type =
    Object.selectionForField "Enum.ContractType.ContractType" "contract_type" [] Fractal.Enum.ContractType.decoder


closedAt : SelectionSet (Maybe Fractal.ScalarCodecs.DateTime) Fractal.Object.Contract
closedAt =
    Object.selectionForField "(Maybe ScalarCodecs.DateTime)" "closedAt" [] (Fractal.ScalarCodecs.codecs |> Fractal.Scalar.unwrapCodecs |> .codecDateTime |> .decoder |> Decode.nullable)


type alias EventOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.EventFragmentFilter }


event :
    (EventOptionalArguments -> EventOptionalArguments)
    -> SelectionSet decodesTo Fractal.Object.EventFragment
    -> SelectionSet decodesTo Fractal.Object.Contract
event fillInOptionals object_ =
    let
        filledInOptionals =
            fillInOptionals { filter = Absent }

        optionalArgs =
            [ Argument.optional "filter" filledInOptionals.filter Fractal.InputObject.encodeEventFragmentFilter ]
                |> List.filterMap identity
    in
    Object.selectionForCompositeField "event" optionalArgs object_ identity


type alias CandidatesOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.UserFilter
    , order : OptionalArgument Fractal.InputObject.UserOrder
    , first : OptionalArgument Int
    , offset : OptionalArgument Int
    }


candidates :
    (CandidatesOptionalArguments -> CandidatesOptionalArguments)
    -> SelectionSet decodesTo Fractal.Object.User
    -> SelectionSet (Maybe (List decodesTo)) Fractal.Object.Contract
candidates fillInOptionals object_ =
    let
        filledInOptionals =
            fillInOptionals { filter = Absent, order = Absent, first = Absent, offset = Absent }

        optionalArgs =
            [ Argument.optional "filter" filledInOptionals.filter Fractal.InputObject.encodeUserFilter, Argument.optional "order" filledInOptionals.order Fractal.InputObject.encodeUserOrder, Argument.optional "first" filledInOptionals.first Encode.int, Argument.optional "offset" filledInOptionals.offset Encode.int ]
                |> List.filterMap identity
    in
    Object.selectionForCompositeField "candidates" optionalArgs object_ (identity >> Decode.list >> Decode.nullable)


type alias ParticipantsOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.VoteFilter
    , first : OptionalArgument Int
    , offset : OptionalArgument Int
    }


participants :
    (ParticipantsOptionalArguments -> ParticipantsOptionalArguments)
    -> SelectionSet decodesTo Fractal.Object.Vote
    -> SelectionSet (Maybe (List decodesTo)) Fractal.Object.Contract
participants fillInOptionals object_ =
    let
        filledInOptionals =
            fillInOptionals { filter = Absent, first = Absent, offset = Absent }

        optionalArgs =
            [ Argument.optional "filter" filledInOptionals.filter Fractal.InputObject.encodeVoteFilter, Argument.optional "first" filledInOptionals.first Encode.int, Argument.optional "offset" filledInOptionals.offset Encode.int ]
                |> List.filterMap identity
    in
    Object.selectionForCompositeField "participants" optionalArgs object_ (identity >> Decode.list >> Decode.nullable)


type alias CommentsOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.CommentFilter
    , order : OptionalArgument Fractal.InputObject.CommentOrder
    , first : OptionalArgument Int
    , offset : OptionalArgument Int
    }


comments :
    (CommentsOptionalArguments -> CommentsOptionalArguments)
    -> SelectionSet decodesTo Fractal.Object.Comment
    -> SelectionSet (Maybe (List decodesTo)) Fractal.Object.Contract
comments fillInOptionals object_ =
    let
        filledInOptionals =
            fillInOptionals { filter = Absent, order = Absent, first = Absent, offset = Absent }

        optionalArgs =
            [ Argument.optional "filter" filledInOptionals.filter Fractal.InputObject.encodeCommentFilter, Argument.optional "order" filledInOptionals.order Fractal.InputObject.encodeCommentOrder, Argument.optional "first" filledInOptionals.first Encode.int, Argument.optional "offset" filledInOptionals.offset Encode.int ]
                |> List.filterMap identity
    in
    Object.selectionForCompositeField "comments" optionalArgs object_ (identity >> Decode.list >> Decode.nullable)


id : SelectionSet Fractal.ScalarCodecs.Id Fractal.Object.Contract
id =
    Object.selectionForField "ScalarCodecs.Id" "id" [] (Fractal.ScalarCodecs.codecs |> Fractal.Scalar.unwrapCodecs |> .codecId |> .decoder)


type alias CreatedByOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.UserFilter }


createdBy :
    (CreatedByOptionalArguments -> CreatedByOptionalArguments)
    -> SelectionSet decodesTo Fractal.Object.User
    -> SelectionSet decodesTo Fractal.Object.Contract
createdBy fillInOptionals object_ =
    let
        filledInOptionals =
            fillInOptionals { filter = Absent }

        optionalArgs =
            [ Argument.optional "filter" filledInOptionals.filter Fractal.InputObject.encodeUserFilter ]
                |> List.filterMap identity
    in
    Object.selectionForCompositeField "createdBy" optionalArgs object_ identity


createdAt : SelectionSet Fractal.ScalarCodecs.DateTime Fractal.Object.Contract
createdAt =
    Object.selectionForField "ScalarCodecs.DateTime" "createdAt" [] (Fractal.ScalarCodecs.codecs |> Fractal.Scalar.unwrapCodecs |> .codecDateTime |> .decoder)


updatedAt : SelectionSet (Maybe Fractal.ScalarCodecs.DateTime) Fractal.Object.Contract
updatedAt =
    Object.selectionForField "(Maybe ScalarCodecs.DateTime)" "updatedAt" [] (Fractal.ScalarCodecs.codecs |> Fractal.Scalar.unwrapCodecs |> .codecDateTime |> .decoder |> Decode.nullable)


message : SelectionSet (Maybe String) Fractal.Object.Contract
message =
    Object.selectionForField "(Maybe String)" "message" [] (Decode.string |> Decode.nullable)
