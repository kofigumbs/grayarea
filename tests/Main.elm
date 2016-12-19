port module Main exposing (..)

import Tests
import Test.Runner.Node exposing (run)
import Json.Encode exposing (Value)


port emit : ( String, Value ) -> Cmd msg


main =
    run emit Tests.all
