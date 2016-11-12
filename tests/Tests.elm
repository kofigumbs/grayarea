module Tests exposing (..)

import Test exposing (..)
import Tests.Story


all : Test
all =
    describe "Geomic"
        [ Tests.Story.all
        ]
