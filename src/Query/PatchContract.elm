module Query.PatchContract exposing (sendVote)

import Dict exposing (Dict)
import Extra exposing (ternary)
import Fractal.Enum.ContractStatus as ContractStatus
import Fractal.Enum.ContractType as ContractType
import Fractal.Enum.TensionEvent as TensionEvent
import Fractal.InputObject as Input
import Fractal.Mutation as Mutation
import Fractal.Object
import Fractal.Object.AddVotePayload
import Fractal.Object.Contract
import Fractal.Object.Vote
import Fractal.Query as Query
import Fractal.Scalar
import Fractal.ScalarCodecs
import GqlClient exposing (..)
import Graphql.OptionalArgument as OptionalArgument exposing (OptionalArgument(..), fromMaybe)
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet, with)
import Maybe exposing (withDefault)
import ModelCommon exposing (TensionForm, UserForm)
import ModelCommon.Codecs exposing (memberIdCodec, nodeIdCodec)
import ModelSchema exposing (..)
import Query.QueryContract exposing (contractPayload)
import Query.QueryNode exposing (tidPayload)
import RemoteData exposing (RemoteData)



{-
   update contract (Add Vote)
-}


type alias VotePayload =
    { vote : Maybe (List (Maybe VoteResult)) }


type alias VoteResult =
    { id : String
    , contract : ContractResult
    }


voteDecoder : Maybe VotePayload -> Maybe ContractResult
voteDecoder data =
    data
        |> Maybe.andThen
            (\d ->
                d.vote
                    |> Maybe.map (\x -> List.head x)
                    |> Maybe.withDefault Nothing
                    |> Maybe.withDefault Nothing
                    |> Maybe.map (\x -> x.contract)
            )


sendVote url form msg =
    makeGQLMutation url
        (Mutation.addVote
            (\q -> { q | upsert = Present True })
            (voteInputDecoder form)
            (SelectionSet.map VotePayload <|
                Fractal.Object.AddVotePayload.vote identity votePayload
            )
        )
        (RemoteData.fromResult >> decodeResponse voteDecoder >> msg)


voteInputDecoder form =
    let
        createdAt =
            Dict.get "createdAt" form.post |> withDefault "" |> Fractal.Scalar.DateTime

        nid =
            memberIdCodec form.rootnameid form.uctx.username

        inputReq =
            { createdAt = createdAt
            , createdBy =
                Input.buildUserRef
                    (\u -> { u | username = Present form.uctx.username })
            , voteid = form.contractid ++ "#" ++ nid
            , contract =
                Input.buildContractRef
                    (\x -> { x | contractid = Present form.contractid })
            , node =
                Input.buildNodeRef
                    (\x -> { x | nameid = Present nid })
            , data = [ form.vote ]
            }
    in
    { input = [ Input.buildAddVoteInput inputReq identity ] }


votePayload : SelectionSet VoteResult Fractal.Object.Vote
votePayload =
    SelectionSet.map2 VoteResult
        (Fractal.Object.Vote.id |> SelectionSet.map decodedId)
        (Fractal.Object.Vote.contract identity <|
            SelectionSet.map2 ContractResult
                (Fractal.Object.Contract.id |> SelectionSet.map decodedId)
                Fractal.Object.Contract.status
        )
