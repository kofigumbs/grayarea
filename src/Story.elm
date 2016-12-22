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
    = Moved Float Float
    | LocationError
    | LoadError
    | LoadSuccess
    | Chosen content


type Model content
    = Model (Story content)


type alias Story content =
    { name : String
    , rootUrl : String
    , imageFormat : String
    , current : Chapter content
    , location : Location
    , panelsRemaining : Result () Int
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
    | Asking
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
            Result.map (\current -> Moved current.latitude current.longitude)
                >> Result.withDefault LocationError

        current =
            config.table config.start

        ( location, cmd ) =
            if String.contains "cheat" flags then
                ( NotRequired, Cmd.none )
            else
                ( Asking, Task.attempt locate Geolocation.now )
    in
        ( Model
            { name = config.name
            , rootUrl = config.rootUrl
            , imageFormat = config.imageFormat
            , current = current
            , location = location
            , panelsRemaining = Ok current.length
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
        Moved latitude longitude ->
            ( Model { story | location = Coordinates latitude longitude }
            , Cmd.none
            )

        LocationError ->
            ( Model { story | location = Error }
            , Cmd.none
            )

        LoadError ->
            ( Model { story | panelsRemaining = Err () }
            , Cmd.none
            )

        LoadSuccess ->
            ( Model
                { story
                    | panelsRemaining =
                        Result.map ((+) -1) story.panelsRemaining
                }
            , Cmd.none
            )

        Chosen content ->
            ( Model
                { story
                    | current = config.table content
                    , panelsRemaining = Ok story.current.length
                }
            , config.scroll
            )


present :
    { config
        | loading : Msg a -> Msg a -> List String -> b
        , locationError : b
        , loadError : b
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
    case ( story.location, story.panelsRemaining ) of
        ( _, Err _ ) ->
            config.loadError

        ( Error, _ ) ->
            config.locationError

        ( Coordinates latitude longitude, Ok 0 ) ->
            config.chapter
                { name = story.name
                , chapterTitle = story.current.title
                , panelUrls = panelUrls story
                , decisions = decisions (curry nearby latitude longitude) story
                }

        ( NotRequired, Ok 0 ) ->
            config.chapter
                { name = story.name
                , chapterTitle = story.current.title
                , panelUrls = panelUrls story
                , decisions = decisions (always True) story
                }

        ( _, Ok _ ) ->
            config.loading LoadError LoadSuccess (panelUrls story)


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
                    Just (Chosen next.content)
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
    if story.location == NotRequired || story.location == Asking then
        Sub.none
    else
        Geolocation.changes
            (\current -> Moved current.latitude current.longitude)
