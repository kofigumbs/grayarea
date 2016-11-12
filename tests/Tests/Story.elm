module Tests.Story exposing (all)

import Expect
import Test exposing (..)
import Domain exposing (..)
import Geomic.Story as Story


type alias Content =
    Maybe ( String, String )


table : Content -> Chapter Content
table =
    Maybe.withDefault ( "Existential", "Crisis" )
        >> (\( title, description ) ->
                { title = title
                , description = description
                , length = 1
                , next = []
                }
           )


story =
    Story
        { name = "Test Story"
        , rootUrl = "google.com"
        , format = "png"
        , table = table
        }


all : Test
all =
    describe "Geomic.Story"
        [ describe "init"
            []
        , describe "update"
            [ test
                "goes to chapter title when decrementing page 1"
              <|
                \() ->
                    let
                        model =
                            (Page 1 (table Nothing) story)

                        updated =
                            Story.update PreviousPage model
                    in
                        case fst updated of
                            Title chapter _ ->
                                Expect.equal (table Nothing) chapter

                            _ ->
                                Expect.fail "Expexcted Title"
            ]
        ]
