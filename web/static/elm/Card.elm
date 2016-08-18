module Card exposing (Model, view, Msg, update)

import Html exposing (Html, div, text, p, button, input, textarea)
import Html.Attributes exposing (class, value)
import Html.Events exposing (onClick, onInput)


-- MODEL

type alias Model =
  { id: Int
  , name : String
  , description : String
  , isEditable: Bool
  }


-- UPDATE

type Msg
  = Edit
  | UpdateName String
  | UpdateDescription String
  | Save

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    Edit ->
      ({ model | isEditable = True } , Cmd.none )
    UpdateName name ->
      ({ model | name = name } , Cmd.none )
    UpdateDescription description ->
      ({ model | description = description } , Cmd.none )
    Save ->
      ({ model | isEditable = False } , Cmd.none )
    

-- VIEW

view : Model -> Html Msg
view model =
  if model.isEditable then editView model else normalView model

editView : Model -> Html Msg
editView model =
  div 
    [class "card"] 
    [ input [class "title", value model.name, onInput UpdateName] []
    , textarea [class "description", onInput UpdateDescription] [text model.description]
    , button [onClick Save] [text "Save"]
    ]

normalView : Model -> Html Msg
normalView model =
  div 
    [class "card", onClick Edit] 
    [ div [class "title"] [text model.name]
    , p [class "description"] [text model.description]
    ]
