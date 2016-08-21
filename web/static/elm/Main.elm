module Trellex exposing (..)

import CardList
import Card
import Decoder
import Channel
import Html exposing (Html, div, text, button)
import Html.Attributes exposing (class)
import Html.App
import Json.Encode
import Dict exposing (Dict)
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
    { cards : Json.Encode.Value
    , cardLists : Json.Encode.Value
    , boardName : String
    }


type alias Model =
    { cards : Dict Int Card.Model
    , cardLists : Dict Int CardList.Model
    , boardName : String
    , phxSocket : Phoenix.Socket.Socket Msg
    }


initPhxSocket : Phoenix.Socket.Socket Msg
initPhxSocket =
    Phoenix.Socket.init socketServer
        |> Phoenix.Socket.withDebug
        |> Phoenix.Socket.on "card_change" "board:lobby" ReceiveCardChange


init : Flags -> ( Model, Cmd Msg )
init initial =
    let
        model =
            Model
                (Decoder.initialCards initial.cards)
                (Decoder.initialCardLists initial.cardLists)
                initial.boardName
                initPhxSocket
    in
        join model



-- UPDATE


type Msg
    = CardMsg Int Card.Msg
    | PhoenixMsg (Phoenix.Socket.Msg Msg)
    | ReceiveCardChange Json.Encode.Value



-- | ShowJoinedMessage String
-- | ShowLeftMessage String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case Debug.log "got msg" msg of
        CardMsg cardId cardMsg ->
            let
                card =
                    Dict.get cardId model.cards

                ( updatedCard, cmd, outMsg ) =
                    updateCard cardMsg card

                ( phxSocket, phxCmd ) =
                    Channel.push model.phxSocket (Debug.log "outMsg" outMsg)

                updatedCards =
                    Dict.insert cardId updatedCard model.cards
            in
                -- TODO: combine with incoming message from Board? (Cmd.map MainMsg cmd)
                ( { model | cards = updatedCards }, Cmd.map PhoenixMsg phxCmd )

        PhoenixMsg msg ->
            let
                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.update msg model.phxSocket
            in
                ( { model | phxSocket = phxSocket }
                , Cmd.map PhoenixMsg phxCmd
                )

        ReceiveCardChange cardJson ->
            let
                card =
                    Decoder.newCard cardJson

                cards' =
                    updateCards card model.cards
            in
                ( { model | cards = cards' }, Cmd.none )



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


updateCards : Card.Model -> Dict Int Card.Model -> Dict Int Card.Model
updateCards newCard cards =
    let
        update maybeCard =
            case maybeCard of
                Nothing ->
                    Nothing

                Just maybeCard ->
                    Just newCard
    in
        Dict.update newCard.id update cards


updateCard : Card.Msg -> Maybe Card.Model -> ( Card.Model, Cmd Card.Msg, Channel.OutMsg )
updateCard cardMsg card =
    case card of
        Nothing ->
            ( Card.none, Cmd.none, Channel.noMessage )

        Just card ->
            Card.update cardMsg card



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
    div [ class "board" ]
        [ div [ class "title" ] [ text model.boardName ]
        , div [ class "cards" ] (List.map (viewCardList model.cards) (Dict.toList model.cardLists))
        , div [ class "clear" ] []
        ]


viewCardList : Dict Int Card.Model -> ( Int, CardList.Model ) -> Html Msg
viewCardList cards ( cardListId, cardList ) =
    let
        belongsToList cardList cardId card =
            cardList.id == card.listId

        cards' =
            Dict.filter (belongsToList cardList) cards
    in
        div [ class "card-list" ]
            [ div [ class "title" ] [ text cardList.name ]
            , div [ class "cards" ] (List.map viewCard (Dict.toList cards'))
            ]


viewCard : ( Int, Card.Model ) -> Html Msg
viewCard ( cardId, card ) =
    Html.App.map (CardMsg cardId) (Card.view card)
