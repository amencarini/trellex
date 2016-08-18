module Channel exposing (OutMsg, noMessage, send, push)

import Json.Encode exposing (Value)
import Phoenix.Socket


-- import Phoenix.Channel

import Phoenix.Push


type OutMsg
    = Send String Value
    | None


send : String -> Value -> OutMsg
send channel obj =
    Send channel obj


noMessage : OutMsg
noMessage =
    None


push : Phoenix.Socket.Socket mainMsg -> OutMsg -> ( Phoenix.Socket.Socket mainMsg, Cmd (Phoenix.Socket.Msg mainMsg) )
push socket msg =
    case msg of
        None ->
            ( socket, Cmd.none )

        Send msgType payload ->
            let
                push' =
                    Phoenix.Push.init msgType "board:lobby"
                        |> Phoenix.Push.withPayload payload
            in
                Phoenix.Socket.push push' socket
