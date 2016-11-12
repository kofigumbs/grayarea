module Domain exposing (..)


type Msg
    = NextPage
    | PreviousPage


type Story a
    = Story Options (a -> Chapter)


type Chapter
    = Chapter
        { title : String
        , description : String
        , length : Int
        , next : List ( Location, Chapter )
        }


type Location
    = Location ( Float, Float )


type alias Options =
    { name : String
    , root : String
    , format : String
    }
