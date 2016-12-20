module View exposing (view)

import Html exposing (Html)
import Html.Attributes as Html
import Html.Events as Html


view :
    { name : String
    , chapterTitle : String
    , panelUrls : List String
    , decisions :
        List
            { place : String
            , description : String
            , action : Maybe a
            }
    }
    -> Html a
view { name, chapterTitle, panelUrls, decisions } =
    List.map panel panelUrls
        |> (::) (header name chapterTitle)
        |> flip (++) (footer decisions)
        |> List.intersperse (Html.br [] [])
        |> Html.div
            [ Html.style
                [ ( "text-align", "center" )
                , ( "line-height", "1" )
                , ( "margin", "1em" )
                ]
            ]


panel : String -> Html a
panel url =
    Html.img
        [ Html.src url
        , Html.style
            [ ( "width", "100%" )
            , ( "margin", "0 auto" )
            , ( "display", "block" )
            , ( "max-width", maxWidth )
            ]
        ]
        []


header : String -> String -> Html a
header name chapterTitle =
    Html.div
        [ Html.style
            [ ( "text-align", "left" )
            , ( "background-color", "#333333" )
            , ( "margin", "0 auto" )
            , ( "max-width", maxWidth )
            ]
        ]
        [ Html.div
            [ Html.style
                [ ( "padding", "4em" )
                ]
            ]
            [ Html.h1 [ monospace ] [ Html.text name ]
            , Html.h2 [ monospace ] [ Html.text chapterTitle ]
            ]
        ]


footer :
    List { place : String, description : String, action : Maybe a }
    -> List (Html a)
footer =
    let
        wrap action =
            case action of
                Just msg ->
                    Html.a
                        [ monospace
                        , Html.style
                            [ ( "background-color", "#009688" )
                            , ( "text-decoration", "underline" )
                            , ( "cursor", "pointer" )
                            , ( "margin", "0 auto" )
                            , ( "padding", "1em 0" )
                            , ( "display", "block" )
                            , ( "max-width", maxWidth )
                            ]
                        , Html.onClick msg
                        ]

                Nothing ->
                    Html.div
                        [ monospace
                        , Html.style
                            [ ( "background-color", "#B71C1C" )
                            , ( "margin", "0 auto" )
                            , ( "padding", "1em 0" )
                            , ( "max-width", maxWidth )
                            ]
                        ]
                        << flip (++) [ Html.text "You are too far away!" ]

        option { place, description, action } =
            wrap action
                [ Html.h3 [] [ Html.text place ]
                , Html.h4 [] [ Html.text description ]
                ]
    in
        List.map option


monospace : Html.Attribute a
monospace =
    Html.style
        [ ( "font-family", "monospace" )
        , ( "color", "#FFFFFF" )
        ]


maxWidth : String
maxWidth =
    "720px"
