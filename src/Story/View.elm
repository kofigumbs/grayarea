module Story.View exposing (..)


type Model a
    = Loading a a (List String)
    | LocationError
    | LoadError
    | Chapter
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
