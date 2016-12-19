module View exposing (view)

import Geolocation
import Html exposing (Html)
import Html.Attributes as Html
import Html.Events as Html
import Http


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
view data =
    Html.text "Test"
