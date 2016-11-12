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
            ( PreviousPage, Page no chapter (Story config) ) ->
                Title chapter (Story config)

            _ ->
                Debug.crash "update"


view : Model a -> Html (Msg a)
view model =
    case model of
        _ ->
            Debug.crash "view"



-- Page no content story ->
--     View.page (source no content story)
-- Decision content story ->
--     View.decision (plot content story)
-- End story ->
--     View.end story


subscriptions : Model a -> Sub (Msg a)
subscriptions model =
    Sub.none
