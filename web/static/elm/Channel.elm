module Channel exposing (OutMsg, send, push)

import Json.Encode exposing (Value)
import Phoenix.Socket
import Phoenix.Push


type OutMsg
    = Send String Value


send : String -> Value -> OutMsg
send channel obj =
    Send channel obj


push : Phoenix.Socket.Socket mainMsg -> OutMsg -> ( Phoenix.Socket.Socket mainMsg, Cmd (Phoenix.Socket.Msg mainMsg) )
push socket msg =
    case msg of
        Send msgType payload ->
            let
                push' =
                    Phoenix.Push.init msgType "board:lobby"
                        |> Phoenix.Push.withPayload payload
            in
                Phoenix.Socket.push push' socket
