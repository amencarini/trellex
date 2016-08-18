module CardList exposing (Model, view, Msg, update)

import Card
import Dict exposing (Dict)

import Html exposing (Html, div, text)
import Html.App
import Html.Attributes exposing (class)


-- MODEL

type alias Model =
  { id : Int
  , name : String
  , cards : Dict Int Card.Model
  }


-- UPDATE

type Msg
  = CardListMsg Int Card.Msg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    CardListMsg cardId cardMsg ->
      let
        updatedCards = Dict.update cardId (updateCard cardMsg) model.cards
        updatedModel = { model | cards = updatedCards }
      in
        (updatedModel, Cmd.none)

updateCard : Card.Msg -> Maybe Card.Model -> Maybe Card.Model
updateCard cardMsg card =
  case card of
    Nothing -> Nothing
    Just card -> 
      let
        (updatedCard, cmd) = Card.update cardMsg card
      in
        Just updatedCard


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
