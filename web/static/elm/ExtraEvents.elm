module ExtraEvents exposing (..)

import Html.Events exposing (on, Options, onWithOptions)
import Html exposing (Attribute)
import Json.Decode as JD


onDragStart : msg -> Html.Attribute msg
onDragStart msg =
    on "dragstart" (JD.succeed msg)


onDragEnd : msg -> Html.Attribute msg
onDragEnd msg =
    on "dragend" (JD.succeed msg)


onDrop : msg -> Attribute msg
onDrop message =
    onWithOptions
        "drop"
        preventDefaultAndStopPropagation
        (JD.succeed message)


onDragOver : msg -> Attribute msg
onDragOver message =
    onWithOptions
        "dragover"
        preventDefaultAndStopPropagation
        (JD.succeed message)


preventDefaultAndStopPropagation : Options
preventDefaultAndStopPropagation =
    Options True True


preventDefault : Options
preventDefault =
    Html.Events.Options False True
