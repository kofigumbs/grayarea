module Geomic.View exposing (..)

import Html exposing (Html)
import Html.Attributes as Html
import Html.Events as Html


page : String -> msg -> msg -> Html msg
page url previous next =
    Html.div
        [ Html.style [ ( "display", "flex" ) ] ]
        [ button [ Html.onClick previous ] [ Html.text "Previous" ]
        , Html.img [ Html.src url ] []
        , button [ Html.onClick next ] [ Html.text "Next" ]
        ]


decision _ =
    Debug.crash


end _ =
    Debug.crash


button : List (Html.Attribute msg) -> List (Html msg) -> Html msg
button attributes innerHtml =
    let
        styles : Html.Attribute msg
        styles =
            Html.style
                [ ( "padding", "1.05rem 2.75rem" )
                , ( "color", "#333333" )
                , ( "background-color", "#fff" )
                , ( "font-size", "1.2rem" )
                , ( "font-weight", "300" )
                , ( "text-transform", "uppercase" )
                , ( "border-radius", "12rem" )
                , ( "border", ".2rem solid #333333" )
                , ( "transition", "color .3s,border .3s" )
                ]
    in
        Html.button (styles :: attributes) innerHtml
