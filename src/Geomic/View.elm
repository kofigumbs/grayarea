module View exposing (..)

import Html exposing (Html)
import Html.Attributes as Html
import Html.Events as Html
import Domain exposing (..)


page : String -> ( Bool, Bool ) -> Html Msg
page url ( disablePrevious, disableNext ) =
    Html.div
        [ Html.style
            [ ( "display", "flex" )
            ]
        ]
        [ button
            [ Html.onClick PreviousPage
            , Html.disabled disablePrevious
            ]
            [ Html.text "Previous"
            ]
        , Html.img
            [ Html.src url
            ]
            []
        , button
            [ Html.onClick NextPage
            , Html.disabled disableNext
            ]
            [ Html.text "Next"
            ]
        ]


button : List (Html.Attribute Msg) -> List (Html Msg) -> Html Msg
button attributes innerHtml =
    let
        styles : Html.Attribute Msg
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
