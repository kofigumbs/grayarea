module Geomic.Story exposing (init, update, view, subscriptions)

import String
import Html exposing (Html)
import Http
import Domain exposing (..)
import Geomic.View


init : a -> Story a -> ( Model a, Cmd (Msg a) )
init start story =
    ( Title (story.table start) story, Cmd.none )


update : Msg a -> Model a -> ( Model a, Cmd (Msg a) )
update msg model =
    flip (,) Cmd.none <|
        case ( msg, model ) of
            ( NextPage, Title chapter story ) ->
                case ( List.length chapter.next, chapter.length ) of
                    ( 0, 0 ) ->
                        End story

                    ( _, 0 ) ->
                        Decision chapter story

                    _ ->
                        Page (source 1 chapter story) chapter story

            ( NextPage, Page ( no, _ ) chapter story ) ->
                Page (source (no + 1) chapter story) chapter story

            ( PreviousPage, Page ( no, _ ) chapter story ) ->
                case no of
                    1 ->
                        Title chapter story

                    _ ->
                        Page (source (no - 1) chapter story) chapter story

            ( PreviousPage, Decision chapter story ) ->
                case chapter.length of
                    0 ->
                        Title chapter story

                    _ ->
                        Page (source chapter.length chapter story) chapter story

            _ ->
                model


source : Int -> Chapter a -> Story a -> ( Int, String )
source no chapter story =
    ( no
    , story.rootUrl
        ++ "/"
        ++ Http.uriEncode chapter.title
        ++ "/"
        ++ String.padLeft 3 '0' (toString no)
        ++ "."
        ++ story.imageFormat
    )


view : Model a -> Html (Msg a)
view model =
    case model of
        _ ->
            Debug.crash "view"



-- Page (_, src) chapter (Story name, _, _, _) ->
--     View.page src name
-- Decision chapter (Story { name, _, _, _ }) ->
--     View.decision
-- End story ->
--     View.end story


subscriptions : Model a -> Sub (Msg a)
subscriptions model =
    Sub.none
