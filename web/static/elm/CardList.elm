module CardList exposing (Model, Msg)

import Card


-- MODEL


type alias Model =
    { id : Int
    , name : String
    }



-- UPDATE


type Msg
    = CardListMsg Int Card.Msg
