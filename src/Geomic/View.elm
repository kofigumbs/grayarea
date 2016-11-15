module Geomic.View exposing (..)

import Html exposing (Html)
import Html.Attributes as Html
import Html.Events as Html


type Distance
    = Here
    | Nearby
    | Far


title : String -> String -> msg -> Html msg
title name title next =
    flex
        [ Html.h1 [] [ Html.text name ]
        , Html.h2 [] [ Html.text title ]
        , button [ Html.onClick next ] [ Html.text "Next" ]
        ]


page : String -> { previous : msg, next : msg } -> Html msg
page url msgs =
    flex
        [ button [ Html.onClick msgs.previous ] [ Html.text "Previous" ]
        , Html.img [ Html.src url ] []
        , button [ Html.onClick msgs.next ] [ Html.text "Next" ]
        ]


decision : List ( String, String, Distance, msg ) -> msg -> Html msg
decision options previous =
    flex <|
        (::) (button [ Html.onClick previous ] [ Html.text "Previous" ]) <|
            flip List.map options <|
                \( name, description, distance, msg ) ->
                    Html.div
                        []
                        [ Html.h3 [] [ Html.text name ]
                        , Html.h4 [] [ Html.text description ]
                        , Html.div
                            [ case distance of
                                Here ->
                                    Html.class "here"

                                Nearby ->
                                    Html.class "nearby"

                                Far ->
                                    Html.class "far"
                            , Html.style
                                [ ( "width", "25px" )
                                , ( "height", "25px" )
                                , ( "background-color", "red" )
                                ]
                            ]
                            []
                        ]


end : String -> msg -> Html msg
end name previous =
    flex
        [ button [ Html.onClick previous ] [ Html.text "Previous" ]
        , Html.h1 [] [ Html.text name ]
        ]


flex : List (Html msg) -> Html msg
flex =
    Html.div
        [ Html.style [ ( "display", "flex" ) ]
        ]


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
