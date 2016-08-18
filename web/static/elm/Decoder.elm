module Decoder exposing (..)

import Board
import CardList
import Card

import Dict exposing (Dict)

import Json.Decode exposing (Decoder, Value, (:=), succeed, int, string, list, bool, oneOf, decodeValue, map)
import Json.Decode.Extra exposing ((|:))

decodeInitialState : Value -> Board.Model
decodeInitialState payload =
  case decodeValue board payload of
    Ok val -> val
    Err message -> Debug.crash message

board : Decoder Board.Model
board =
  succeed Board.Model
  |: ("name" := string)
  |: ("lists" := list cardList |> map listToDict)

cardList : Decoder CardList.Model
cardList =
  succeed CardList.Model
  |: ("id" := int)
  |: ("name" := string)
  |: ("cards" := list card |> map listToDict)

listToDict : List { idable | id : Int } -> Dict Int { idable | id : Int }
listToDict idables =
  idables
  |> List.map (\idable -> (idable.id, idable))
  |> Dict.fromList

card : Decoder Card.Model
card =
  succeed Card.Model
  |: ("id" := int)
  |: ("name" := string)
  |: ("description" := string)
  |: (oneOf [ "isEditable" := bool, succeed False ])


  
-- job =
    -- object3 Card.Model
    --   ("name" := Json.Decode.string)
    --   ("description" := Json.Decode.string)
    --   ("completed" := bool)

--encodeSomething : Something -> Json.Encode.Value
--encodeSomething record =
--    Json.Encode.object
--        [ ("name",  Json.Encode.string <| record.name)
--        , ("lists",  Json.Encode.list <| List.map encodeComplexType <| record.lists)
--        ]
