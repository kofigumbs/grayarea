module Domain exposing (..)


type Msg content
    = NextPage
    | PreviousPage
    | Choose content
    | Moved Float Float


type Model content
    = Title (Story content)
    | Page Int (Story content)
    | Decision (Story content)
    | End (Story content)


type alias Story content =
    { name : String
    , rootUrl : String
    , imageFormat : String
    , current : Chapter content
    , table : content -> Chapter content
    , position : Maybe ( Float, Float )
    }


type alias Chapter content =
    { title : String
    , length : Int
    , next :
        List
            { place : String
            , description : String
            , latitude : Float
            , longitude : Float
            , content : content
            }
    }
