module CardList exposing (Model, view, Msg, update)

import Dict exposing (Dict)
import Html exposing (Html, div, text)
import Html.App
import Html.Attributes exposing (class)

import Card
import Channel


-- MODEL

type alias Model =
  { id : Int
  , name : String
  , cards : Dict Int Card.Model
  }

nullCard : Card.Model
nullCard = Card.Model 0 "" "" False


-- UPDATE

type Msg
  = CardListMsg Int Card.Msg

update : Msg -> Model -> (Model, Cmd Msg, Channel.OutMsg)
update msg model =
  case msg of
    CardListMsg cardId cardMsg ->
      let
        card = Dict.get cardId model.cards
        (updatedCard, cmd, outMsg) = updateCard cardMsg card
        updatedCards = Dict.insert cardId updatedCard model.cards
        updatedModel = { model | cards = updatedCards }
      in
        (updatedModel, Cmd.map (CardListMsg cardId) cmd, outMsg)

updateCard : Card.Msg -> Maybe Card.Model -> (Card.Model, Cmd Card.Msg, Channel.OutMsg)
updateCard cardMsg card =
  case card of
    Nothing -> (nullCard, Cmd.none, Channel.noMessage)
    Just card -> 
      let
        (updatedCard, cmd, outMsg) = Card.update cardMsg card
      in
        (updatedCard, cmd, outMsg)


-- VIEW

view : Model -> Html Msg
view model =
  div [class "card-list"]
    [ div [class "title"] [text model.name]
    , div [class "cards"] (List.map viewCard (Dict.toList model.cards))
    ]

viewCard : (Int, Card.Model) -> Html Msg
viewCard (id, model) =
  Html.App.map (CardListMsg id) (Card.view model)
