module Geomic.Story exposing (init, update, view, subscriptions)

import Html exposing (Html)
import Domain exposing (..)
import Geomic.View


init : a -> Story a -> ( Model a, Cmd (Msg a) )
init start (Story config) =
    ( Title (config.table start) (Story config), Cmd.none )


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
                        Page 1 chapter story

            ( PreviousPage, Page no chapter story ) ->
                case no of
                    1 ->
                        Title chapter story

                    _ ->
                        Page (no - 1) chapter story

            ( PreviousPage, Decision chapter story ) ->
                case chapter.length of
                    0 ->
                        Title chapter story

                    _ ->
                        Page chapter.length chapter story

            _ ->
                model


view : Model a -> Html (Msg a)
view model =
    case model of
        _ ->
            Debug.crash "view"



-- Page no content story ->
--     View.page (source no content story)
-- Decision content (Story { _, _, _, table }) ->
--     View.decision (plot content story)
-- End story ->
--     View.end story


subscriptions : Model a -> Sub (Msg a)
subscriptions model =
    Sub.none
