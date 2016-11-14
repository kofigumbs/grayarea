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
    , format : String
    , table : a -> Chapter a
    , start : a
    }
    -> Program Never
program { name, rootUrl, format, table, start } =
    Html.App.program
        { init =
            Story.init start
                { name = name
                , rootUrl = rootUrl
                , format = format
                , table = table
                }
        , update = Story.update
        , view = Story.view
        , subscriptions = Story.subscriptions
        }
