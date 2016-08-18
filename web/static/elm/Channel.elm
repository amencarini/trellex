module Channel exposing (OutMsg, send, noMessage)

import Json.Encode exposing (Value)

type OutMsg
  = Send String Value
  | None

send : String -> Value -> OutMsg
send channel obj =
  Send channel obj

noMessage : OutMsg
noMessage = None
