module Tests.Story exposing (all)

import Expect
import Test exposing (..)
import Domain exposing (..)
import Geomic.Story as Story


type Content
    = One
    | Two
    | Three


chapterOne =
    { title = "Great Beginnings"
    , description = "and small heroes"
    , length = 1
    , next = [ ( 1, 2, Two ) ]
    }


chapterTwo =
    { title = "All the single ladies"
    , description = "put your hands up"
    , length = 0
    , next = []
    }


chapterThree =
    { title = "All the single ladies"
    , description = "put your hands up"
    , length = 0
    , next = [ ( 3, 4, Two ) ]
    }


table : Content -> Chapter Content
table content =
    case content of
        One ->
            chapterOne

        Two ->
            chapterTwo

        Three ->
            chapterThree


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
        [ describe "update"
            [ test
                "NextPage -> Title -> Page 1"
              <|
                \() ->
                    let
                        model =
                            Title chapterOne story

                        updated =
                            Story.update NextPage model
                    in
                        case fst updated of
                            Page no chapter _ ->
                                Expect.equal ( 1, chapterOne ) ( no, chapter )

                            _ ->
                                Expect.fail "should have matched Page"
            , test
                "PreviousPage -> Page 1 -> Title"
              <|
                \() ->
                    let
                        model =
                            Page 1 chapterOne story

                        updated =
                            Story.update PreviousPage model
                    in
                        case fst updated of
                            Title chapter _ ->
                                Expect.equal chapterOne chapter

                            _ ->
                                Expect.fail "should have matched Title"
            , test
                "NextPage -> Title (chapter.length == 0, chapter.next == [ ]) -> End"
              <|
                \() ->
                    let
                        model =
                            Title chapterTwo story

                        updated =
                            Story.update NextPage model
                    in
                        case fst updated of
                            End _ ->
                                Expect.pass

                            _ ->
                                Expect.fail "should have matched End"
            , test
                "NextPage -> Title (chapter.length == 0, chapter.next == [ _ ]) -> Decision"
              <|
                \() ->
                    let
                        model =
                            Title chapterThree story

                        updated =
                            Story.update NextPage model
                    in
                        case fst updated of
                            Decision chapter _ ->
                                Expect.equal chapterThree chapter

                            _ ->
                                Expect.fail "should have matched Decision"
            , test
                "PreviousPage -> Page (n > 1) -> Page (n - 1)"
              <|
                \() ->
                    let
                        model =
                            Page 2 chapterTwo story

                        updated =
                            Story.update PreviousPage model
                    in
                        case fst updated of
                            Page no chapter _ ->
                                Expect.equal ( 1, chapterTwo ) ( no, chapter )

                            _ ->
                                Expect.fail "should have matched Page"
            , test
                "PreviousPage -> Decision -> Page chapter.length"
              <|
                \() ->
                    let
                        model =
                            Decision chapterOne story

                        updated =
                            Story.update PreviousPage model
                    in
                        case fst updated of
                            Page no chapter _ ->
                                Expect.equal ( chapterOne.length, chapterOne ) ( no, chapter )

                            _ ->
                                Expect.fail "should have matched Page"
            , test
                "PreviousPage -> Decision (chapter.length == 0) -> Title"
              <|
                \() ->
                    let
                        model =
                            Decision chapterTwo story

                        updated =
                            Story.update PreviousPage model
                    in
                        case fst updated of
                            Title chapter _ ->
                                Expect.equal chapterTwo chapter

                            _ ->
                                Expect.fail "should have matched Title"
            ]
        ]
