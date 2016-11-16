module Geomic.View exposing (..)

import Html exposing (Html)
import Html.Attributes as Html
import Html.Events as Html
import Http


type alias Option msg =
    { place : String
    , description : String
    , nearby : Bool
    , msg : msg
    }


title : String -> String -> msg -> Html msg
title name title msg =
    flex
        [ card primary
            [ Html.h1 [] [ Html.text name ]
            , Html.h2 [] [ Html.text title ]
            ]
        , button next msg
        ]


page : String -> { previous : msg, next : msg } -> Html msg
page url msgs =
    flex
        [ button previous msgs.previous
        , Html.img
            [ Html.src url
            , Html.alt "I can't find the image for this page of the story."
            , Html.style
                [ ( "border-radius", "0.2rem" )
                ]
            ]
            []
        , button next msgs.next
        ]


decision : List (Option msg) -> msg -> Html msg
decision options msg =
    let
        theme nearby =
            if nearby then
                ( next, primary )
            else
                ( unavailable, secondary )
    in
        flex <|
            (::) (button previous msg) <|
                flip List.map options <|
                    \{ place, description, nearby, msg } ->
                        let
                            ( text, color ) =
                                theme nearby
                        in
                            card color
                                [ Html.h3 [] [ Html.text place ]
                                , Html.h4 [] [ Html.text description ]
                                , Html.button
                                    [ Html.onClick msg
                                    , Html.disabled (not nearby)
                                    , Html.style
                                        [ ( "width", "100%" )
                                        , ( "height", "3rem" )
                                        , ( "border", "none" )
                                        , ( "shadow", "none" )
                                        , ( "cursor", "pointer" )
                                        , ( "background-color", color )
                                        , ( "color", "white" )
                                        , ( "font-size", "1rem" )
                                        , ( "position", "absolute" )
                                        , ( "bottom", "0" )
                                        , ( "left", "0" )
                                        , ( "font-family", "monspace" )
                                        , ( "text-transform", "uppercase" )
                                        ]
                                    ]
                                    [ Html.text text ]
                                ]


end : String -> msg -> Html msg
end name msg =
    flex
        [ button previous msg
        , card primary
            [ Html.h1 [] [ Html.text name ]
            , Html.h2 [] [ Html.text "THE END." ]
            ]
        ]


flex : List (Html msg) -> Html msg
flex =
    Html.div
        [ Html.style
            [ ( "display", "flex" )
            , ( "align-items", "center" )
            , ( "justify-content", "center" )
            , ( "height", "100%" )
            , ( "width", "100%" )
            ]
        ]


card : String -> List (Html msg) -> Html msg
card color =
    Html.div
        [ Html.style
            [ ( "text-align", "center" )
            , ( "position", "relative" )
            , ( "width", "12rem" )
            , ( "height", "16rem" )
            , ( "padding", "5rem 2.5rem" )
            , ( "margin", "1.5rem" )
            , ( "border", "0.1rem solid " ++ color )
            , ( "border-radius", "0.2rem" )
            , ( "overflow", "hidden" )
            ]
        ]


previous : String
previous =
    "◀️"


next : String
next =
    "▶️"


unavailable : String
unavailable =
    "✖️"


primary : String
primary =
    "#34495E"


secondary : String
secondary =
    "#333333"


button : String -> msg -> Html msg
button text msg =
    Html.button
        [ Html.style
            [ ( "width", "4rem" )
            , ( "height", "4rem" )
            , ( "margin", "1rem" )
            , ( "border-radius", "2rem" )
            , ( "font-size", "1rem" )
            , ( "color", "white" )
            , ( "border", "none" )
            , ( "shadow", "none" )
            , ( "background-color", primary )
            , ( "cursor", "pointer" )
            ]
        , Html.onClick msg
        ]
        [ Html.text text
        ]
