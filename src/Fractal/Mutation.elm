-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Fractal.Mutation exposing (..)

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


type alias UpdateNodeRequiredArguments =
    { input : Fractal.InputObject.UpdateNodeInput }


{-|

  - input -

-}
updateNode : UpdateNodeRequiredArguments -> SelectionSet decodesTo Fractal.Object.UpdateNodePayload -> SelectionSet (Maybe decodesTo) RootMutation
updateNode requiredArgs object_ =
    Object.selectionForCompositeField "updateNode" [ Argument.required "input" requiredArgs.input Fractal.InputObject.encodeUpdateNodeInput ] object_ (identity >> Decode.nullable)


type alias DeleteNodeRequiredArguments =
    { filter : Fractal.InputObject.NodeFilter }


{-|

  - filter -

-}
deleteNode : DeleteNodeRequiredArguments -> SelectionSet decodesTo Fractal.Object.DeleteNodePayload -> SelectionSet (Maybe decodesTo) RootMutation
deleteNode requiredArgs object_ =
    Object.selectionForCompositeField "deleteNode" [ Argument.required "filter" requiredArgs.filter Fractal.InputObject.encodeNodeFilter ] object_ (identity >> Decode.nullable)


type alias AddCircleRequiredArguments =
    { input : List Fractal.InputObject.AddCircleInput }


{-|

  - input -

-}
addCircle : AddCircleRequiredArguments -> SelectionSet decodesTo Fractal.Object.AddCirclePayload -> SelectionSet (Maybe decodesTo) RootMutation
addCircle requiredArgs object_ =
    Object.selectionForCompositeField "addCircle" [ Argument.required "input" requiredArgs.input (Fractal.InputObject.encodeAddCircleInput |> Encode.list) ] object_ (identity >> Decode.nullable)


type alias UpdateCircleRequiredArguments =
    { input : Fractal.InputObject.UpdateCircleInput }


{-|

  - input -

-}
updateCircle : UpdateCircleRequiredArguments -> SelectionSet decodesTo Fractal.Object.UpdateCirclePayload -> SelectionSet (Maybe decodesTo) RootMutation
updateCircle requiredArgs object_ =
    Object.selectionForCompositeField "updateCircle" [ Argument.required "input" requiredArgs.input Fractal.InputObject.encodeUpdateCircleInput ] object_ (identity >> Decode.nullable)


type alias DeleteCircleRequiredArguments =
    { filter : Fractal.InputObject.CircleFilter }


{-|

  - filter -

-}
deleteCircle : DeleteCircleRequiredArguments -> SelectionSet decodesTo Fractal.Object.DeleteCirclePayload -> SelectionSet (Maybe decodesTo) RootMutation
deleteCircle requiredArgs object_ =
    Object.selectionForCompositeField "deleteCircle" [ Argument.required "filter" requiredArgs.filter Fractal.InputObject.encodeCircleFilter ] object_ (identity >> Decode.nullable)


type alias AddRoleRequiredArguments =
    { input : List Fractal.InputObject.AddRoleInput }


{-|

  - input -

-}
addRole : AddRoleRequiredArguments -> SelectionSet decodesTo Fractal.Object.AddRolePayload -> SelectionSet (Maybe decodesTo) RootMutation
addRole requiredArgs object_ =
    Object.selectionForCompositeField "addRole" [ Argument.required "input" requiredArgs.input (Fractal.InputObject.encodeAddRoleInput |> Encode.list) ] object_ (identity >> Decode.nullable)


type alias UpdateRoleRequiredArguments =
    { input : Fractal.InputObject.UpdateRoleInput }


{-|

  - input -

-}
updateRole : UpdateRoleRequiredArguments -> SelectionSet decodesTo Fractal.Object.UpdateRolePayload -> SelectionSet (Maybe decodesTo) RootMutation
updateRole requiredArgs object_ =
    Object.selectionForCompositeField "updateRole" [ Argument.required "input" requiredArgs.input Fractal.InputObject.encodeUpdateRoleInput ] object_ (identity >> Decode.nullable)


type alias DeleteRoleRequiredArguments =
    { filter : Fractal.InputObject.RoleFilter }


{-|

  - filter -

-}
deleteRole : DeleteRoleRequiredArguments -> SelectionSet decodesTo Fractal.Object.DeleteRolePayload -> SelectionSet (Maybe decodesTo) RootMutation
deleteRole requiredArgs object_ =
    Object.selectionForCompositeField "deleteRole" [ Argument.required "filter" requiredArgs.filter Fractal.InputObject.encodeRoleFilter ] object_ (identity >> Decode.nullable)


type alias UpdatePostRequiredArguments =
    { input : Fractal.InputObject.UpdatePostInput }


{-|

  - input -

-}
updatePost : UpdatePostRequiredArguments -> SelectionSet decodesTo Fractal.Object.UpdatePostPayload -> SelectionSet (Maybe decodesTo) RootMutation
updatePost requiredArgs object_ =
    Object.selectionForCompositeField "updatePost" [ Argument.required "input" requiredArgs.input Fractal.InputObject.encodeUpdatePostInput ] object_ (identity >> Decode.nullable)


type alias DeletePostRequiredArguments =
    { filter : Fractal.InputObject.PostFilter }


{-|

  - filter -

-}
deletePost : DeletePostRequiredArguments -> SelectionSet decodesTo Fractal.Object.DeletePostPayload -> SelectionSet (Maybe decodesTo) RootMutation
deletePost requiredArgs object_ =
    Object.selectionForCompositeField "deletePost" [ Argument.required "filter" requiredArgs.filter Fractal.InputObject.encodePostFilter ] object_ (identity >> Decode.nullable)


type alias AddTensionRequiredArguments =
    { input : List Fractal.InputObject.AddTensionInput }


{-|

  - input -

-}
addTension : AddTensionRequiredArguments -> SelectionSet decodesTo Fractal.Object.AddTensionPayload -> SelectionSet (Maybe decodesTo) RootMutation
addTension requiredArgs object_ =
    Object.selectionForCompositeField "addTension" [ Argument.required "input" requiredArgs.input (Fractal.InputObject.encodeAddTensionInput |> Encode.list) ] object_ (identity >> Decode.nullable)


type alias UpdateTensionRequiredArguments =
    { input : Fractal.InputObject.UpdateTensionInput }


{-|

  - input -

-}
updateTension : UpdateTensionRequiredArguments -> SelectionSet decodesTo Fractal.Object.UpdateTensionPayload -> SelectionSet (Maybe decodesTo) RootMutation
updateTension requiredArgs object_ =
    Object.selectionForCompositeField "updateTension" [ Argument.required "input" requiredArgs.input Fractal.InputObject.encodeUpdateTensionInput ] object_ (identity >> Decode.nullable)


type alias DeleteTensionRequiredArguments =
    { filter : Fractal.InputObject.TensionFilter }


{-|

  - filter -

-}
deleteTension : DeleteTensionRequiredArguments -> SelectionSet decodesTo Fractal.Object.DeleteTensionPayload -> SelectionSet (Maybe decodesTo) RootMutation
deleteTension requiredArgs object_ =
    Object.selectionForCompositeField "deleteTension" [ Argument.required "filter" requiredArgs.filter Fractal.InputObject.encodeTensionFilter ] object_ (identity >> Decode.nullable)


type alias AddMandateRequiredArguments =
    { input : List Fractal.InputObject.AddMandateInput }


{-|

  - input -

-}
addMandate : AddMandateRequiredArguments -> SelectionSet decodesTo Fractal.Object.AddMandatePayload -> SelectionSet (Maybe decodesTo) RootMutation
addMandate requiredArgs object_ =
    Object.selectionForCompositeField "addMandate" [ Argument.required "input" requiredArgs.input (Fractal.InputObject.encodeAddMandateInput |> Encode.list) ] object_ (identity >> Decode.nullable)


type alias UpdateMandateRequiredArguments =
    { input : Fractal.InputObject.UpdateMandateInput }


{-|

  - input -

-}
updateMandate : UpdateMandateRequiredArguments -> SelectionSet decodesTo Fractal.Object.UpdateMandatePayload -> SelectionSet (Maybe decodesTo) RootMutation
updateMandate requiredArgs object_ =
    Object.selectionForCompositeField "updateMandate" [ Argument.required "input" requiredArgs.input Fractal.InputObject.encodeUpdateMandateInput ] object_ (identity >> Decode.nullable)


type alias DeleteMandateRequiredArguments =
    { filter : Fractal.InputObject.MandateFilter }


{-|

  - filter -

-}
deleteMandate : DeleteMandateRequiredArguments -> SelectionSet decodesTo Fractal.Object.DeleteMandatePayload -> SelectionSet (Maybe decodesTo) RootMutation
deleteMandate requiredArgs object_ =
    Object.selectionForCompositeField "deleteMandate" [ Argument.required "filter" requiredArgs.filter Fractal.InputObject.encodeMandateFilter ] object_ (identity >> Decode.nullable)


type alias AddUserRequiredArguments =
    { input : List Fractal.InputObject.AddUserInput }


{-|

  - input -

-}
addUser : AddUserRequiredArguments -> SelectionSet decodesTo Fractal.Object.AddUserPayload -> SelectionSet (Maybe decodesTo) RootMutation
addUser requiredArgs object_ =
    Object.selectionForCompositeField "addUser" [ Argument.required "input" requiredArgs.input (Fractal.InputObject.encodeAddUserInput |> Encode.list) ] object_ (identity >> Decode.nullable)


type alias UpdateUserRequiredArguments =
    { input : Fractal.InputObject.UpdateUserInput }


{-|

  - input -

-}
updateUser : UpdateUserRequiredArguments -> SelectionSet decodesTo Fractal.Object.UpdateUserPayload -> SelectionSet (Maybe decodesTo) RootMutation
updateUser requiredArgs object_ =
    Object.selectionForCompositeField "updateUser" [ Argument.required "input" requiredArgs.input Fractal.InputObject.encodeUpdateUserInput ] object_ (identity >> Decode.nullable)


type alias DeleteUserRequiredArguments =
    { filter : Fractal.InputObject.UserFilter }


{-|

  - filter -

-}
deleteUser : DeleteUserRequiredArguments -> SelectionSet decodesTo Fractal.Object.DeleteUserPayload -> SelectionSet (Maybe decodesTo) RootMutation
deleteUser requiredArgs object_ =
    Object.selectionForCompositeField "deleteUser" [ Argument.required "filter" requiredArgs.filter Fractal.InputObject.encodeUserFilter ] object_ (identity >> Decode.nullable)
