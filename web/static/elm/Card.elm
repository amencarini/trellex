module Card exposing (Model, Msg, view, update)

import Html exposing (Html, div, text, p, button, input, textarea)
import Html.Attributes exposing (class, value)
import Html.Events exposing (onClick, onInput)
import Channel
import Json.Encode as JE


-- MODEL


type alias Model =
    { id : Int
    , name : String
    , description : String
    , isEditable : Bool
    }



-- UPDATE


type Msg
    = Edit
    | UpdateName String
    | UpdateDescription String
    | Save


update : Msg -> Model -> ( Model, Cmd Msg, Channel.OutMsg )
update msg model =
    case msg of
        Edit ->
            ( { model | isEditable = True }, Cmd.none, Channel.noMessage )

        UpdateName name ->
            ( { model | name = name }, Cmd.none, Channel.noMessage )

        UpdateDescription description ->
            ( { model | description = description }, Cmd.none, Channel.noMessage )

        Save ->
            ( { model | isEditable = False }, Cmd.none, Channel.send "card_change" (encode model) )



-- VIEW


view : Model -> Html Msg
view model =
    if model.isEditable then
        editView model
    else
        normalView model


editView : Model -> Html Msg
editView model =
    div
        [ class "card" ]
        [ input [ class "title", value model.name, onInput UpdateName ] []
        , textarea [ class "description", onInput UpdateDescription ] [ text model.description ]
        , button [ onClick Save ] [ text "Save" ]
        ]


normalView : Model -> Html Msg
normalView model =
    div
        [ class "card", onClick Edit ]
        [ div [ class "title" ] [ text model.name ]
        , p [ class "description" ] [ text model.description ]
        ]


encode : Model -> JE.Value
encode record =
    JE.object
        [ ( "id", JE.int <| record.id )
        , ( "name", JE.string <| record.name )
        , ( "description", JE.string <| record.description )
        ]
