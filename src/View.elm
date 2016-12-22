module View exposing (loading, error, chapter)

import Json.Decode
import Html exposing (Html)
import Html.Attributes as Html
import Html.Events as Html


error : Html a
error =
    wrap
        [ header
            "I couldn't access your location"
            """
            Gray Area uses your location to track progress.
            Please let me access your location to continue.
            """
            palette.red
        ]


loading : a -> List String -> Html a
loading msg urls =
    let
        img url =
            Html.img
                [ Html.src url
                , Html.on "load" (Json.Decode.succeed msg)
                ]
                []
    in
        wrap
            [ header "loading..." "" palette.gray
            , List.map img urls
                |> Html.div [ Html.hidden True ]
            ]


chapter :
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
chapter { name, chapterTitle, panelUrls, decisions } =
    let
        panel url =
            Html.img [ expand, Html.src url ] []
    in
        List.map panel panelUrls
            |> (::) (header name chapterTitle palette.gray)
            >> flip (++) (footer decisions)
            >> List.intersperse (Html.br [ expand ] [])
            >> wrap


header : String -> String -> String -> Html a
header name chapterTitle color =
    Html.div
        [ expand
        , Html.style
            [ ( "text-align", "left" )
            , ( "background-color", color )
            ]
        ]
        [ Html.div
            [ Html.style
                [ ( "padding", "4em" )
                ]
            ]
            [ Html.h1 [ font ] [ Html.text name ]
            , Html.h2 [ font ] [ Html.text chapterTitle ]
            ]
        ]


footer :
    List { place : String, description : String, action : Maybe a }
    -> List (Html a)
footer =
    let
        active msg =
            Html.a
                [ font
                , expand
                , Html.style
                    [ ( "background-color", palette.green )
                    , ( "text-decoration", "underline" )
                    , ( "cursor", "pointer" )
                    , ( "padding", "1em 0" )
                    ]
                , Html.onClick msg
                ]

        inactive =
            Html.div
                [ font
                , expand
                , Html.style
                    [ ( "background-color", palette.red )
                    , ( "padding", "1em 0" )
                    ]
                ]
                << flip (++)
                    [ Html.p
                        [ Html.style [ ( "font-style", "italic" ) ]
                        ]
                        [ Html.text "You are too far away!"
                        ]
                    ]

        option { place, description, action } =
            [ Html.h3 [] [ Html.text place ]
            , Html.h4 [] [ Html.text description ]
            ]
                |> Maybe.withDefault inactive (Maybe.map active action)
    in
        List.map option


wrap : List (Html a) -> Html a
wrap =
    Html.div
        [ Html.style
            [ ( "text-align", "center" )
            , ( "line-height", "1em" )
            , ( "margin", "1em auto" )
            , ( "max-width", "720px" )
            ]
        ]


expand : Html.Attribute a
expand =
    Html.style
        [ ( "display", "block" )
        , ( "width", "100%" )
        ]


font : Html.Attribute a
font =
    Html.style
        [ ( "font-family", "monospace" )
        , ( "color", "#FFFFFF" )
        ]


palette =
    { gray = "#333333"
    , red = "#B71C1C"
    , green = "#009688"
    }
