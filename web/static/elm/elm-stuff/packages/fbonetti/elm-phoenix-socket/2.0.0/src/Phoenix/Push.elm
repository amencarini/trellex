module Phoenix.Push exposing (Push, init, withPayload, onError, onOk)

{-|

@docs Push, init, withPayload, onError, onOk

-}

import Phoenix.Helpers exposing (emptyPayload)
import Json.Encode as JE


{-| Represents a message being pushed to the server
-}
type alias Push msg =
  { event : String
  , channel : String
  , payload : JE.Value
  , onOk : Maybe (JE.Value -> msg)
  , onError : Maybe (JE.Value -> msg)
  }


{-| Initializes a push with the given event and channel

    init "new:msg" "rooms:lobby"

-}
init : String -> String -> Push msg
init event channel =
  Push event channel emptyPayload Nothing Nothing


{-| Attaches a payload

    payload = JE.object [ ("body", JE.string "Hello World!") ]
    init "new:msg" "rooms:lobby"
      |> withPayload payload

-}
withPayload : JE.Value -> Push msg -> Push msg
withPayload payload push =
  { push | payload = payload }


{-| Attaches a success handler

    init "new:msg" "rooms:lobby"
      |> onOk HandlePushOk

-}
onOk : (JE.Value -> msg) -> Push msg -> Push msg
onOk valueToMsg push =
  { push | onOk = Just valueToMsg }


{-| Attaches an error handler

    init "new:msg" "rooms:lobby"
      |> onError HandlePushError

-}
onError : (JE.Value -> msg) -> Push msg -> Push msg
onError valueToMsg push =
  { push | onError = Just valueToMsg }
