module Geomic.Story exposing (..)

import String
import Html exposing (Html)
import Http
import Domain exposing (..)
import Geomic.View as View


init : Story a -> ( Model a, Cmd (Msg a) )
init story =
    ( Title story, Cmd.none )


update : Msg a -> Model a -> ( Model a, Cmd (Msg a) )
update msg model =
    flip (,) Cmd.none <|
        case ( msg, model ) of
            ( PreviousPage, Page no story ) ->
                case no of
                    1 ->
                        Title story

                    _ ->
                        Page (no - 1) story

            ( PreviousPage, Decision story ) ->
                case story.current.length of
                    0 ->
                        Title story

                    _ ->
                        Page story.current.length story

            ( PreviousPage, End story ) ->
                case story.current.length of
                    0 ->
                        Title story

                    _ ->
                        Page story.current.length story

            ( NextPage, Title story ) ->
                case ( List.length story.current.next, story.current.length ) of
                    ( 0, 0 ) ->
                        End story

                    ( _, 0 ) ->
                        Decision story

                    ( _, _ ) ->
                        Page 1 story

            ( NextPage, Page no story ) ->
                case ( List.length story.current.next, no == story.current.length ) of
                    ( 0, True ) ->
                        End story

                    ( _, True ) ->
                        Decision story

                    ( _, _ ) ->
                        Page (no + 1) story

            ( _, _ ) ->
                model


view : Model a -> Html (Msg a)
view model =
    case model of
        Title story ->
            View.title story.name story.current.title NextPage

        Page no story ->
            View.page
                (source no story)
                { previous = PreviousPage, next = NextPage }

        Decision story ->
            View.decision (options story) PreviousPage

        End story ->
            View.end story.name PreviousPage


source : Int -> Story a -> String
source no story =
    story.rootUrl
        ++ "/"
        ++ Http.uriEncode story.current.title
        ++ "/"
        ++ String.padLeft 3 '0' (toString no)
        ++ "."
        ++ story.imageFormat


options : Story a -> List ( String, String, View.Distance, Msg a )
options story =
    let
        option next =
            ( next.place
            , next.description
            , View.Here
            , Choose next.content
            )
    in
        List.map option story.current.next


subscriptions : Model a -> Sub (Msg a)
subscriptions model =
    Sub.none
