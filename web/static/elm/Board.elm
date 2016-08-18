module Board exposing (Model, view, Msg, update)

import CardList
import Dict exposing (Dict)

import Html exposing (Html, div, text)
import Html.App
import Html.Attributes exposing (class)


-- MODEL

type alias Model =
  { name : String
  , cardLists : Dict Int CardList.Model
  }


-- UPDATE

type Msg
  = BoardMsg Int CardList.Msg
  | NoOp

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    BoardMsg cardListId cardListMsg ->
      let
        updatedCardLists = Dict.update cardListId (updateCardList cardListMsg) model.cardLists
        updatedModel = { model | cardLists = updatedCardLists }
      in
        (updatedModel, Cmd.none)
    NoOp ->
      (model, Cmd.none)

updateCardList : CardList.Msg -> Maybe CardList.Model -> Maybe CardList.Model
updateCardList cardListMsg cardList =
  case cardList of
    Nothing -> Nothing
    Just cardList -> 
      let
        (updatedCardList, cmd) = CardList.update cardListMsg cardList
      in
        Just updatedCardList


-- VIEW

view : Model -> Html Msg
view model =
  div [class "board"]
    [ div [class "title"] [text model.name]
    , div [class "lists"] (List.map viewCardList (Dict.toList model.cardLists))
    , div [class "clear"] []
    ]

viewCardList : (Int, CardList.Model) -> Html Msg
viewCardList (id, model) =
  Html.App.map (BoardMsg id) (CardList.view model)
