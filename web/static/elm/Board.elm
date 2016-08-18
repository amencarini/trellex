module Board exposing (Model, view, Msg, update)

import Html exposing (Html, div, text)
import Html.App
import Html.Attributes exposing (class)
import CardList
import Dict exposing (Dict)
import Channel


-- MODEL


type alias Model =
    { name : String
    , cardLists : Dict Int CardList.Model
    }


nullCardList : CardList.Model
nullCardList =
    CardList.Model 0 "" Dict.empty



-- UPDATE


type Msg
    = BoardMsg Int CardList.Msg


update : Msg -> Model -> ( Model, Cmd Msg, Channel.OutMsg )
update msg model =
    case msg of
        BoardMsg cardListId cardListMsg ->
            let
                cardList =
                    Dict.get cardListId model.cardLists

                ( updatedCardList, cmd, outMsg ) =
                    updateCardList cardListMsg cardList

                updatedCardLists =
                    Dict.insert cardListId updatedCardList model.cardLists

                updatedModel =
                    { model | cardLists = updatedCardLists }
            in
                ( updatedModel, Cmd.map (BoardMsg cardListId) cmd, outMsg )


updateCardList : CardList.Msg -> Maybe CardList.Model -> ( CardList.Model, Cmd CardList.Msg, Channel.OutMsg )
updateCardList cardListMsg cardList =
    case cardList of
        Nothing ->
            ( nullCardList, Cmd.none, Channel.noMessage )

        Just cardList ->
            let
                ( updatedCardList, cmd, outMsg ) =
                    CardList.update cardListMsg cardList
            in
                ( updatedCardList, cmd, outMsg )



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "board" ]
        [ div [ class "title" ] [ text model.name ]
        , div [ class "lists" ] (List.map viewCardList (Dict.toList model.cardLists))
        , div [ class "clear" ] []
        ]


viewCardList : ( Int, CardList.Model ) -> Html Msg
viewCardList ( id, model ) =
    Html.App.map (BoardMsg id) (CardList.view model)
