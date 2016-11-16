module Geomic exposing (Chapter, program)

import Html exposing (Html)
import Html.App
import Domain exposing (..)
import Geomic.Story as Story


type alias Chapter content =
    Domain.Chapter content


program :
    { name : String
    , rootUrl : String
    , imageFormat : String
    , table : a -> Chapter a
    , start : a
    }
    -> Program Never
program { name, rootUrl, imageFormat, table, start } =
    Html.App.program
        { init =
            Story.init
                { name = name
                , rootUrl = rootUrl
                , imageFormat = imageFormat
                , current = table start
                , table = table
                , position = Nothing
                }
        , update = Story.update
        , view = Story.view
        , subscriptions = Story.subscriptions
        }
