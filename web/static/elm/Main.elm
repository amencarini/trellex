module Trellex exposing (..)

import Board
import Decoder
import Channel
import Html exposing (Html, div, text, button)
import Html.App
import Json.Encode


--import Json.Encode as Encode
--import Json.Decode as Decode exposing ((:=))

import Phoenix.Socket
import Phoenix.Channel


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


socketServer : String
socketServer =
    "ws://localhost:4000/socket/websocket"



-- MODEL


type alias Flags =
    { value : Json.Encode.Value
    }


type alias Model =
    { board : Board.Model
    , phxSocket : Phoenix.Socket.Socket Msg
    }


initPhxSocket : Phoenix.Socket.Socket Msg
initPhxSocket =
    Phoenix.Socket.init socketServer
        |> Phoenix.Socket.withDebug
        |> Phoenix.Socket.on "card_change" "board:lobby" ReceiveCardChange



-- |> Phoenix.Socket.on "new_msg" "board:lobby" ReceiveMessage


init : Flags -> ( Model, Cmd Msg )
init initial =
    let
        model =
            Model (Decoder.decodeState initial.value) initPhxSocket
    in
        join model



-- UPDATE


type Msg
    = MainMsg Board.Msg
    | PhoenixMsg (Phoenix.Socket.Msg Msg)
    | ReceiveCardChange Json.Encode.Value



-- | ReceiveMessage Encode.Value
-- | SendChange
-- | JoinChannel
-- | ShowJoinedMessage String
-- | ShowLeftMessage String
-- type alias ChatMessage =
--   { body : String
--   }
-- chatMessageDecoder : Decode.Decoder ChatMessage
-- chatMessageDecoder =
--  Decode.object1 ChatMessage
--    ("body" := Decode.string)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MainMsg boardMsg ->
            let
                ( updatedBoard, cmd, outMsg ) =
                    Board.update boardMsg model.board

                ( phxSocket, phxCmd ) =
                    Channel.push model.phxSocket outMsg
            in
                -- TODO: combine with incoming message from Board? (Cmd.map MainMsg cmd)
                ( { model | board = updatedBoard }, Cmd.map PhoenixMsg phxCmd )

        PhoenixMsg msg ->
            let
                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.update msg model.phxSocket
            in
                ( { model | phxSocket = phxSocket }
                , Cmd.map PhoenixMsg phxCmd
                )

        ReceiveCardChange msg ->
            let
                msg' = Debug.log "msg in card received change" msg
            in
                ( Model (Decoder.decodeState msg) model.phxSocket, Cmd.none )




-- ReceiveMessage raw ->
--   case Decode.decodeValue chatMessageDecoder raw of
--     Ok chatMessage ->
--       ({ model | state = chatMessage.body }, Cmd.none)
--     Err error ->
--       ( model, Cmd.none )
-- SendChange ->
--   let
--     payload = (Encode.object [ ("body", Encode.string "New Message") ])
--     push' =
--       Phoenix.Push.init "new_msg" "board:lobby"
--       |> Phoenix.Push.withPayload payload
--     (phxSocket, phxCmd) = Phoenix.Socket.push push' model.phxSocket
--     model = {model | phxSocket = phxSocket}
--   in
--     (model, Cmd.map PhoenixMsg phxCmd)
-- ShowJoinedMessage channelName ->
--   let
--     channelName' = Debug.log "Joined" channelName
--   in
--     ( model, Cmd.none )
-- ShowLeftMessage channelName ->
--   let
--     channelName' = Debug.log "Left" channelName
--   in
--     ( model, Cmd.none )
-- CHANNEL


join : Model -> ( Model, Cmd Msg )
join model =
    let
        channel =
            Phoenix.Channel.init "board:lobby"

        -- |> Phoenix.Channel.withPayload userParams
        -- |> Phoenix.Channel.onJoin (always (ShowJoinedMessage "board:lobby"))
        -- |> Phoenix.Channel.onClose (always (ShowLeftMessage "board:lobby"))
        ( phxSocket, phxCmd ) =
            Phoenix.Socket.join channel model.phxSocket
    in
        ( { model | phxSocket = phxSocket }, Cmd.map PhoenixMsg phxCmd )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Phoenix.Socket.listen model.phxSocket PhoenixMsg



-- VIEW


view : Model -> Html Msg
view model =
    Html.App.map MainMsg (Board.view model.board)
