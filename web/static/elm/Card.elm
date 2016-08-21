module Card exposing (Model, Msg, view, update, none)

import String
import Html exposing (Html, div, text, p, button, input, textarea)
import Html.Attributes exposing (class, value)
import Html.Events exposing (onClick, onInput)
import Channel
import Json.Encode as JE


-- MODEL


type alias Model =
    { id : Int
    , listId : Int
    , name : String
    , description : String
    , isEditable : Bool
    }


none : Model
none =
    Model 0 0 "" "" False



-- UPDATE


type Msg
    = Edit
    | UpdateName String
    | UpdateDescription String
    | UpdateListId String
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

        UpdateListId listId ->
            let
                toNumber string =
                    case String.toInt string of
                        Ok number ->
                            number

                        Err error ->
                            model.listId
            in
                ( { model | listId = toNumber listId }, Cmd.none, Channel.noMessage )

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
        , input [ class "listId", onInput UpdateListId, value (toString model.listId) ] []
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
        , ( "list_id", JE.int <| record.listId )
        , ( "name", JE.string <| record.name )
        , ( "description", JE.string <| record.description )
        ]
