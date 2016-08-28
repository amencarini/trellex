module Main exposing (..)

import CardList exposing (CardList)
import Card exposing (Card)
import Decoder
import Channel
import Html.App
import Html exposing (Html, div, text, button, input, textarea, p)
import Html.Attributes exposing (class, draggable, value)
import Html.Events exposing (onClick, onInput)
import ExtraEvents exposing (..)
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
    { cards : CardRepo
    , cardLists : Dict Int CardList
    , boardName : String
    , dragged : Int
    , phxSocket : Phoenix.Socket.Socket Msg
    }


type alias CardRepo =
    Dict Int Card


type alias CardUpdateFn =
    Card -> Card


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
                0
                initPhxSocket
    in
        join model



-- UPDATE


type Msg
    = NoOp
    | PhoenixMsg (Phoenix.Socket.Msg Msg)
    | CardEdit Int
    | CardNameUpdate Int String
    | CardDescriptionUpdate Int String
    | CardSave Int
    | DragStarted Int
    | DragEnded Int
    | Dropped Int
      -- CardMsg Int Card.Msg
    | ReceiveCardChange Json.Encode.Value
    | ShowJoinedMessage String
    | ShowLeftMessage String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case Debug.log "got msg" msg of
        NoOp ->
            ( model, Cmd.none )

        PhoenixMsg msg ->
            let
                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.update msg model.phxSocket
            in
                ( { model | phxSocket = phxSocket }
                , Cmd.map PhoenixMsg phxCmd
                )

        CardEdit cardId ->
            let
                updateFn card =
                    { card | isEditable = True }

                cards' =
                    updateCard updateFn cardId model.cards
            in
                ( { model | cards = cards' }, Cmd.none )

        CardNameUpdate cardId name ->
            let
                updateFn card =
                    { card | name = name }

                cards' =
                    updateCard updateFn cardId model.cards
            in
                ( { model | cards = cards' }, Cmd.none )

        CardDescriptionUpdate cardId description ->
            let
                updateFn card =
                    { card | description = description }

                cards' =
                    updateCard updateFn cardId model.cards
            in
                ( { model | cards = cards' }, Cmd.none )

        CardSave cardId ->
            let
                updateFn card =
                    { card | isEditable = False }

                cards' =
                    updateCard updateFn cardId model.cards

                ( phxSocket, phxCmd ) =
                    pushCardToChannel model.phxSocket cardId cards'
            in
                ( { model | cards = cards' }, Cmd.map PhoenixMsg phxCmd )

        DragStarted cardId ->
            let
                updateFn card =
                    { card | isDragged = True }

                cards' =
                    updateCard updateFn cardId model.cards
            in
                ( { model | cards = cards', dragged = cardId }, Cmd.none )

        DragEnded cardId ->
            let
                updateFn card =
                    { card | isDragged = False }

                cards' =
                    updateCard updateFn cardId model.cards
            in
                ( { model | cards = cards', dragged = 0 }, Cmd.none )

        Dropped cardListId ->
            let
                updateFn card =
                    { card | listId = cardListId, isDragged = False }

                cards' =
                    updateCard updateFn model.dragged model.cards

                ( phxSocket, phxCmd ) =
                    pushCardToChannel model.phxSocket model.dragged cards'
            in
                ( { model | cards = cards', dragged = 0 }, Cmd.map PhoenixMsg phxCmd )

        ReceiveCardChange cardJson ->
            let
                card =
                    Decoder.newCard cardJson

                cards' =
                    commitCardUpdate card model.cards
            in
                ( { model | cards = cards' }, Cmd.none )

        ShowJoinedMessage channelName ->
            let
                channelName' =
                    Debug.log "Joined" channelName
            in
                ( model, Cmd.none )

        ShowLeftMessage channelName ->
            let
                channelName' =
                    Debug.log "Left" channelName
            in
                ( model, Cmd.none )


pushCardToChannel : Phoenix.Socket.Socket Msg -> Int -> CardRepo -> ( Phoenix.Socket.Socket Msg, Cmd (Phoenix.Socket.Msg Msg) )
pushCardToChannel phxSocket cardId cards =
    let
        card =
            Dict.get cardId cards
    in
        case card of
            Nothing ->
                ( phxSocket, Cmd.none )

            Just card ->
                Channel.push phxSocket (Channel.send "card_change" (Card.encode card))


updateCard : CardUpdateFn -> Int -> CardRepo -> CardRepo
updateCard updateFn cardId cards =
    let
        card =
            Dict.get cardId cards

        card' =
            case card of
                Nothing ->
                    Card.none

                Just newCard ->
                    updateFn newCard
    in
        commitCardUpdate card' cards


commitCardUpdate : Card -> CardRepo -> CardRepo
commitCardUpdate newCard cards =
    let
        update maybeCard =
            case maybeCard of
                Nothing ->
                    Nothing

                Just maybeCard ->
                    Just newCard
    in
        Dict.update newCard.id update cards


changeCardList : Int -> Maybe Card -> Card
changeCardList cardListId card =
    case card of
        Nothing ->
            Card.none

        Just card ->
            { card | listId = cardListId }



-- CHANNEL


join : Model -> ( Model, Cmd Msg )
join model =
    let
        channel =
            Phoenix.Channel.init "board:lobby"
                -- |> Phoenix.Channel.withPayload userParams
                |>
                    Phoenix.Channel.onJoin (always (ShowJoinedMessage "board:lobby"))
                |> Phoenix.Channel.onClose (always (ShowLeftMessage "board:lobby"))

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


viewCardList : Dict Int Card -> ( Int, CardList ) -> Html Msg
viewCardList cards ( cardListId, cardList ) =
    let
        belongsToList cardList cardId card =
            cardList.id == card.listId

        cards' =
            Dict.filter (belongsToList cardList) cards
    in
        div
            [ class "card-list"
            , onDrop (Dropped cardList.id)
            , onDragOver NoOp
            ]
            [ div [ class "title" ] [ text cardList.name ]
            , div [ class "cards" ] (List.map viewCard (Dict.toList cards'))
            ]


viewCard : ( Int, Card ) -> Html Msg
viewCard ( cardId, card ) =
    if card.isDragged then
        nullCardView card
    else if card.isEditable then
        editCardView card
    else
        normalCardView card


nullCardView : Card -> Html Msg
nullCardView card =
    div [ onDragEnd (DragEnded card.id) ] []


editCardView : Card -> Html Msg
editCardView card =
    div
        [ class "card" ]
        [ input [ class "title", value card.name, onInput (CardNameUpdate card.id) ] []
        , textarea [ class "description", onInput (CardDescriptionUpdate card.id) ] [ text card.description ]
        , button [ onClick (CardSave card.id) ] [ text "Save" ]
        ]


normalCardView : Card -> Html Msg
normalCardView card =
    div
        [ class "card"
        , draggable "true"
        , onClick (CardEdit card.id)
        , onDragStart (DragStarted card.id)
        ]
        [ div [ class "title" ] [ text card.name ]
        , p [ class "description" ] [ text card.description ]
        ]
