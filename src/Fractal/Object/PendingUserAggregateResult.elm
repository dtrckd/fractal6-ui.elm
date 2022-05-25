-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Fractal.Object.PendingUserAggregateResult exposing (..)

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


count : SelectionSet (Maybe Int) Fractal.Object.PendingUserAggregateResult
count =
    Object.selectionForField "(Maybe Int)" "count" [] (Decode.int |> Decode.nullable)


updatedAtMin : SelectionSet (Maybe Fractal.ScalarCodecs.DateTime) Fractal.Object.PendingUserAggregateResult
updatedAtMin =
    Object.selectionForField "(Maybe ScalarCodecs.DateTime)" "updatedAtMin" [] (Fractal.ScalarCodecs.codecs |> Fractal.Scalar.unwrapCodecs |> .codecDateTime |> .decoder |> Decode.nullable)


updatedAtMax : SelectionSet (Maybe Fractal.ScalarCodecs.DateTime) Fractal.Object.PendingUserAggregateResult
updatedAtMax =
    Object.selectionForField "(Maybe ScalarCodecs.DateTime)" "updatedAtMax" [] (Fractal.ScalarCodecs.codecs |> Fractal.Scalar.unwrapCodecs |> .codecDateTime |> .decoder |> Decode.nullable)


usernameMin : SelectionSet (Maybe String) Fractal.Object.PendingUserAggregateResult
usernameMin =
    Object.selectionForField "(Maybe String)" "usernameMin" [] (Decode.string |> Decode.nullable)


usernameMax : SelectionSet (Maybe String) Fractal.Object.PendingUserAggregateResult
usernameMax =
    Object.selectionForField "(Maybe String)" "usernameMax" [] (Decode.string |> Decode.nullable)


passwordMin : SelectionSet (Maybe String) Fractal.Object.PendingUserAggregateResult
passwordMin =
    Object.selectionForField "(Maybe String)" "passwordMin" [] (Decode.string |> Decode.nullable)


passwordMax : SelectionSet (Maybe String) Fractal.Object.PendingUserAggregateResult
passwordMax =
    Object.selectionForField "(Maybe String)" "passwordMax" [] (Decode.string |> Decode.nullable)


emailMin : SelectionSet (Maybe String) Fractal.Object.PendingUserAggregateResult
emailMin =
    Object.selectionForField "(Maybe String)" "emailMin" [] (Decode.string |> Decode.nullable)


emailMax : SelectionSet (Maybe String) Fractal.Object.PendingUserAggregateResult
emailMax =
    Object.selectionForField "(Maybe String)" "emailMax" [] (Decode.string |> Decode.nullable)


email_tokenMin : SelectionSet (Maybe String) Fractal.Object.PendingUserAggregateResult
email_tokenMin =
    Object.selectionForField "(Maybe String)" "email_tokenMin" [] (Decode.string |> Decode.nullable)


email_tokenMax : SelectionSet (Maybe String) Fractal.Object.PendingUserAggregateResult
email_tokenMax =
    Object.selectionForField "(Maybe String)" "email_tokenMax" [] (Decode.string |> Decode.nullable)


tokenMin : SelectionSet (Maybe String) Fractal.Object.PendingUserAggregateResult
tokenMin =
    Object.selectionForField "(Maybe String)" "tokenMin" [] (Decode.string |> Decode.nullable)


tokenMax : SelectionSet (Maybe String) Fractal.Object.PendingUserAggregateResult
tokenMax =
    Object.selectionForField "(Maybe String)" "tokenMax" [] (Decode.string |> Decode.nullable)
