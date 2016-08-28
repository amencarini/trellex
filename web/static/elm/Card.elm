module Card exposing (Card, none, encode)

import Json.Encode as JE


-- MODEL


type alias Card =
    { id : Int
    , listId : Int
    , name : String
    , description : String
    , isEditable : Bool
    , isDragged : Bool
    }


none : Card
none =
    Card 0 0 "" "" False False


encode : Card -> JE.Value
encode record =
    JE.object
        [ ( "id", JE.int <| record.id )
        , ( "list_id", JE.int <| record.listId )
        , ( "name", JE.string <| record.name )
        , ( "description", JE.string <| record.description )
        ]
