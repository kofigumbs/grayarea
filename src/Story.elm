module Story
    exposing
        ( Msg(..)
        , Model
        , Chapter
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
    = Choose content
    | Move Float Float


type alias Model content =
    { name : String
    , rootUrl : String
    , imageFormat : String
    , current : Chapter content
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


update : (a -> Chapter a) -> Msg a -> Model a -> Model a
update table msg model =
    case msg of
        Choose content ->
            { model | current = table content }

        Move latitude longitude ->
            { model | position = Just ( latitude, longitude ) }


present :
    Model a
    -> { name : String
       , chapterTitle : String
       , panelUrls : List String
       , decisions :
            List
                { place : String
                , description : String
                , action : Maybe (Msg a)
                }
       }
present model =
    { name = model.name
    , chapterTitle = model.current.title
    , panelUrls = panelUrls model
    , decisions = decisions model
    }


panelUrls : Model a -> List String
panelUrls model =
    let
        dir =
            Http.encodeUri model.current.title

        file num =
            String.padLeft 3 '0' (toString num)

        url num =
            model.rootUrl ++ "/" ++ dir ++ "/" ++ file num ++ "." ++ model.imageFormat
    in
        List.map url (List.range 1 model.current.length)


decisions :
    Model a
    -> List { place : String, description : String, action : Maybe (Msg a) }
decisions model =
    let
        isNearby next ( latitude, longitude ) =
            (&&)
                (abs (next.latitude - latitude) <= threshold)
                (abs (next.longitude - longitude) <= threshold)

        action content nearby =
            if nearby then
                Just (Choose content)
            else
                Nothing

        decision next =
            { place = next.place
            , description = next.description
            , action =
                model.position
                    |> Maybe.map (isNearby next)
                    |> Maybe.andThen (action next.content)
            }
    in
        List.map decision model.current.next


threshold : Float
threshold =
    0.0005


subscriptions : a -> Sub (Msg b)
subscriptions _ =
    Geolocation.changes <|
        \location -> Move location.latitude location.longitude
