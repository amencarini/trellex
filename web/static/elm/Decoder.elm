module Decoder exposing (..)

import CardList exposing (CardList)
import Card exposing (Card)
import Dict exposing (Dict)
import Json.Decode exposing (Decoder, Value, (:=), succeed, int, string, list, bool, oneOf, decodeValue, map)
import Json.Decode.Extra exposing ((|:))


initialCards : Value -> Dict Int Card
initialCards payload =
    case decodeValue (list card |> map listToDict) payload of
        Ok val ->
            val

        Err message ->
            Debug.crash message


newCard : Value -> Card
newCard payload =
    case decodeValue card payload of
        Ok val ->
            val

        Err message ->
            Debug.crash message


initialCardLists : Value -> Dict Int CardList
initialCardLists payload =
    case decodeValue (list cardList |> map listToDict) payload of
        Ok val ->
            val

        Err message ->
            Debug.crash message


cardList : Decoder CardList
cardList =
    succeed CardList
        |: ("id" := int)
        |: ("name" := string)


listToDict : List { idable | id : Int } -> Dict Int { idable | id : Int }
listToDict idables =
    idables
        |> List.map (\idable -> ( idable.id, idable ))
        |> Dict.fromList


card : Decoder Card
card =
    succeed Card
        |: ("id" := int)
        |: ("listId" := int)
        |: ("name" := string)
        |: ("description" := string)
        |: (succeed False)
        |: (succeed False)
