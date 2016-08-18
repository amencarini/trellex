module Trellex exposing (..)

import Board
-- import CardList
-- import Card
import Decoder

import Html exposing (Html, div, text, button)
import Html.App

-- import Phoenix.Socket
-- import Phoenix.Channel
-- import Phoenix.Push

import Json.Encode
--import Json.Encode as Encode
--import Json.Decode as Decode exposing ((:=))

-- MAIN

main : Program Flags
main =
  Html.App.programWithFlags
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }


-- CONSTANTS

-- socketServer : String
-- socketServer = "ws://localhost:4000/socket/websocket"


-- MODEL

type alias Flags =
  { value : Json.Encode.Value
  }

type alias Model =
  { board : Board.Model
  --, phxSocket : Phoenix.Socket.Socket Msg
  }

-- initPhxSocket : Phoenix.Socket.Socket Msg
-- initPhxSocket =
--   Phoenix.Socket.init socketServer
--     |> Phoenix.Socket.withDebug
--     --|> Phoenix.Socket.on "new_msg" "board:lobby" ReceiveMessage

init : Flags -> (Model, Cmd Msg)
init initial =
  let
    --model = Model (Decoder.decodeInitialState initial.value) initPhxSocket
    model = Model (Decoder.decodeInitialState initial.value)
  in
    (model, Cmd.none)


-- UPDATE

type Msg
  = MainMsg Board.Msg
  --= PhoenixMsg (Phoenix.Socket.Msg Msg)
  --| ReceiveMessage Encode.Value
  --| SendChange
  --| JoinChannel

type alias ChatMessage =
  { body : String
  }

--chatMessageDecoder : Decode.Decoder ChatMessage
--chatMessageDecoder =
--  Decode.object1 ChatMessage
--    ("body" := Decode.string)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    MainMsg boardMsg ->
      let
        (updatedBoard, cmd, outMsg) = Board.update boardMsg model.board
        mycmd = Debug.log "cmd in main" cmd
        outMsg' = Debug.log "outMsg in main" outMsg
      in
        -- ({ model | board = updatedBoard }, Cmd.map MainMsg cmd)
        ({ model | board = updatedBoard }, Cmd.map MainMsg cmd)

    --PhoenixMsg msg ->
    --  let
    --    ( phxSocket, phxCmd ) = Phoenix.Socket.update msg model.phxSocket
    --  in
    --    ( { model | phxSocket = phxSocket }
    --    , Cmd.map PhoenixMsg phxCmd
    --    )

    --ReceiveMessage raw ->
    --  case Decode.decodeValue chatMessageDecoder raw of
    --    Ok chatMessage ->
    --      ({ model | state = chatMessage.body }, Cmd.none)
    --    Err error ->
    --      ( model, Cmd.none )

    --SendChange ->
    --  let
    --    payload = (Encode.object [ ("body", Encode.string "New Message") ])
    --    push' =
    --      Phoenix.Push.init "new_msg" "board:lobby"
    --      |> Phoenix.Push.withPayload payload
    --    (phxSocket, phxCmd) = Phoenix.Socket.push push' model.phxSocket
    --    model = {model | phxSocket = phxSocket}
    --  in
    --    (model, Cmd.map PhoenixMsg phxCmd)

    --JoinChannel ->
    --  let
    --    channel =
    --      Phoenix.Channel.init "board:lobby"
    --        --|> Phoenix.Channel.withPayload userParams
    --        --|> Phoenix.Channel.onJoin (always (ShowJoinedMessage "board:lobby"))
    --        --|> Phoenix.Channel.onClose (always (ShowLeftMessage "board:lobby"))

    --    (phxSocket, phxCmd) = Phoenix.Socket.join channel model.phxSocket
    --    model = {model | phxSocket = phxSocket}
    --  in
    --    (model, Cmd.map PhoenixMsg phxCmd)


-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none
  --Phoenix.Socket.listen model.phxSocket PhoenixMsg


-- VIEW

view : Model -> Html Msg
view model =
  Html.App.map MainMsg (Board.view model.board)
