module Story
    exposing
        ( Msg(..)
        , Model
        , Chapter
        , init
        , update
        , present
        , threshold
        , subscriptions
        )

import String
import Geolocation
import Http
import Task


type Msg content
    = Move Float Float
    | LocationError
    | Choose content


type Model content
    = Model (Story content)


type alias Story content =
    { name : String
    , rootUrl : String
    , imageFormat : String
    , current : Chapter content
    , location : Location
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


type Location
    = NotRequired
    | Loading
    | Error
    | Coordinates Float Float


init :
    { config
        | name : String
        , rootUrl : String
        , imageFormat : String
        , start : a
        , table : a -> Chapter a
    }
    -> String
    -> ( Model a, Cmd (Msg a) )
init config flags =
    let
        locate =
            Result.map (\current -> Move current.latitude current.longitude)
                >> Result.withDefault LocationError

        ( location, cmd ) =
            if String.contains "cheat" flags then
                ( NotRequired, Cmd.none )
            else
                ( Loading, Task.attempt locate Geolocation.now )
    in
        ( Model
            { name = config.name
            , rootUrl = config.rootUrl
            , imageFormat = config.imageFormat
            , current = config.table config.start
            , location = location
            }
        , cmd
        )


update :
    { config | table : a -> Chapter a, scroll : Cmd (Msg a) }
    -> Msg a
    -> Model a
    -> ( Model a, Cmd (Msg a) )
update config msg (Model story) =
    case msg of
        LocationError ->
            ( Model { story | location = Error }
            , Cmd.none
            )

        Move latitude longitude ->
            ( Model { story | location = Coordinates latitude longitude }
            , Cmd.none
            )

        Choose content ->
            ( Model { story | current = config.table content }
            , config.scroll
            )


present :
    { config
        | loading : b
        , error : b
        , chapter :
            { name : String
            , chapterTitle : String
            , panelUrls : List String
            , decisions :
                List
                    { place : String
                    , description : String
                    , action : Maybe (Msg a)
                    }
            }
            -> b
    }
    -> Model a
    -> b
present config (Model story) =
    let
        present_ f =
            { name = story.name
            , chapterTitle = story.current.title
            , panelUrls = panelUrls story
            , decisions = decisions f story
            }
    in
        case story.location of
            Loading ->
                config.loading

            Error ->
                config.error

            Coordinates latitude longitude ->
                config.chapter (present_ (curry nearby latitude longitude))

            NotRequired ->
                config.chapter (present_ (always True))


panelUrls : Story a -> List String
panelUrls story =
    let
        url num =
            String.join ""
                [ story.rootUrl
                , "/"
                , Http.encodeUri story.current.title
                , "/"
                , String.padLeft 3 '0' (toString num)
                , "."
                , story.imageFormat
                ]
    in
        List.map url (List.range 1 story.current.length)


decisions :
    (( Float, Float ) -> Bool)
    -> Story b
    -> List { place : String, description : String, action : Maybe (Msg b) }
decisions eligible story =
    let
        decision next =
            { place = next.place
            , description = next.description
            , action =
                if eligible ( next.latitude, next.longitude ) then
                    Just (Choose next.content)
                else
                    Nothing
            }
    in
        List.map decision story.current.next


nearby : ( Float, Float ) -> ( Float, Float ) -> Bool
nearby ( lat1, long1 ) ( lat2, long2 ) =
    abs (lat1 - lat2) <= threshold && abs (long1 - long2) <= threshold


threshold : Float
threshold =
    0.0005


subscriptions : Model content -> Sub (Msg content)
subscriptions (Model story) =
    if story.location == NotRequired || story.location == Loading then
        Sub.none
    else
        Geolocation.changes
            (\current -> Move current.latitude current.longitude)
