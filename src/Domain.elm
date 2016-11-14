module Domain exposing (..)


type Msg content
    = NextPage
    | PreviousPage
    | NextChapter content
    | PreviousChapter content


type Model content
    = Title (Chapter content) (Story content)
    | Page ( Int, String ) (Chapter content) (Story content)
    | Decision (Chapter content) (Story content)
    | End (Story content)


type alias Story content =
    { name : String
    , rootUrl : String
    , format : String
    , table : content -> Chapter content
    }


type alias Chapter content =
    { title : String
    , description : String
    , length : Int
    , next : List ( Float, Float, content )
    }
