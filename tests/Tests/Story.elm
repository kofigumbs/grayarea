module Tests.Story exposing (all)

import Expect
import Test exposing (..)
import Domain exposing (..)
import Geomic.Story as Story


type Content
    = One
    | Two
    | Three
    | Four


chapterOne : Chapter Content
chapterOne =
    { title = "Great Beginnings"
    , length = 1
    , next =
        [ { place = "Denver"
          , description = "Crunchy Granola"
          , latitude = 39.7642548
          , longitude = -104.9951952
          , content = Two
          }
        ]
    }


chapterTwo : Chapter Content
chapterTwo =
    { title = "Single Ladies"
    , length = 0
    , next = []
    }


chapterThree : Chapter Content
chapterThree =
    { title = "Champagne Papi"
    , length = 0
    , next =
        [ { place = "Boulder"
          , description = "staying small"
          , latitude = 40.0292889
          , longitude = -105.3100173
          , content = Two
          }
        ]
    }


chapterFour : Chapter Content
chapterFour =
    { title = "Final-Chapter"
    , length = 3
    , next = []
    }


story : Chapter Content -> Story Content
story chapter =
    { name = "Test Story"
    , rootUrl = "google.com"
    , imageFormat = "png"
    , current = chapter
    , table =
        \content ->
            case content of
                One ->
                    chapterOne

                Two ->
                    chapterTwo

                Three ->
                    chapterThree

                Four ->
                    chapterFour
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
                            Title (story chapterOne)

                        updated =
                            Story.update NextPage model
                    in
                        case fst updated of
                            Page no updatedStory ->
                                Expect.equal
                                    ( 1, chapterOne )
                                    ( no, updatedStory.current )

                            _ ->
                                Expect.fail "should have matched Page"
            , test
                "PreviousPage -> Page 1 -> Title"
              <|
                \() ->
                    let
                        model =
                            Page 1 (story chapterOne)

                        updated =
                            Story.update PreviousPage model
                    in
                        case fst updated of
                            Title updatedStory ->
                                Expect.equal chapterOne updatedStory.current

                            _ ->
                                Expect.fail "should have matched Title"
            , test
                "NextPage -> Title (chapter.length == 0, chapter.next == [ ]) -> End"
              <|
                \() ->
                    let
                        model =
                            Title (story chapterTwo)

                        updated =
                            Story.update NextPage model
                    in
                        case fst updated of
                            End updatedStory ->
                                Expect.equal chapterTwo updatedStory.current

                            _ ->
                                Expect.fail "should have matched End"
            , test
                "NextPage -> Title (chapter.length == 0, chapter.next == [ _ ]) -> Decision"
              <|
                \() ->
                    let
                        model =
                            Title (story chapterThree)

                        updated =
                            Story.update NextPage model
                    in
                        case fst updated of
                            Decision updatedStory ->
                                Expect.equal chapterThree updatedStory.current

                            _ ->
                                Expect.fail "should have matched Decision"
            , test
                "PreviousPage -> Page (n > 1) -> Page (n - 1)"
              <|
                \() ->
                    let
                        model =
                            Page 2 (story chapterTwo)

                        updated =
                            Story.update PreviousPage model
                    in
                        case fst updated of
                            Page no updatedStory ->
                                Expect.equal
                                    ( 1, chapterTwo )
                                    ( no, updatedStory.current )

                            _ ->
                                Expect.fail "should have matched Page"
            , test
                "NextPage -> Page n -> Page (n + 1)"
              <|
                \() ->
                    let
                        model =
                            Page 1 (story chapterFour)

                        updated =
                            Story.update NextPage model
                    in
                        case fst updated of
                            Page no updatedStory ->
                                Expect.equal
                                    ( 2, chapterFour )
                                    ( no, updatedStory.current )

                            _ ->
                                Expect.fail "should have matched Page"
            , test
                "PreviousPage -> Decision -> Page chapter.length"
              <|
                \() ->
                    let
                        model =
                            Decision (story chapterOne)

                        updated =
                            Story.update PreviousPage model
                    in
                        case fst updated of
                            Page no updatedStory ->
                                Expect.equal
                                    ( 1, chapterOne )
                                    ( no, updatedStory.current )

                            _ ->
                                Expect.fail "should have matched Page"
            , test
                "PreviousPage -> Decision (chapter.length == 0) -> Title"
              <|
                \() ->
                    let
                        model =
                            Decision (story chapterTwo)

                        updated =
                            Story.update PreviousPage model
                    in
                        case fst updated of
                            Title updatedStory ->
                                Expect.equal chapterTwo updatedStory.current

                            _ ->
                                Expect.fail "should have matched Title"
            , test
                "NextPage -> Page (n == chapter.length) -> Decision"
              <|
                \() ->
                    let
                        model =
                            Page 1 (story chapterOne)

                        updated =
                            Story.update NextPage model
                    in
                        case fst updated of
                            Decision updatedStory ->
                                Expect.equal chapterOne updatedStory.current

                            _ ->
                                Expect.fail "should have matched Decision"
            , test
                "NextPage -> Page (n == chapter.length, next.length == 0) -> End"
              <|
                \() ->
                    let
                        model =
                            Page 3 (story chapterFour)

                        updated =
                            Story.update NextPage model
                    in
                        case fst updated of
                            End updatedStory ->
                                Expect.equal chapterFour updatedStory.current

                            _ ->
                                Expect.fail "should have matched End"
            , test
                "PreviousPage -> End -> Page"
              <|
                \() ->
                    let
                        model =
                            End (story chapterTwo)

                        updated =
                            Story.update PreviousPage model
                    in
                        case fst updated of
                            Title updatedStory ->
                                Expect.equal chapterTwo updatedStory.current

                            _ ->
                                Expect.fail "should have matched Title"
            , test
                "PreviousPage -> End (chapter.length == 0) -> Title"
              <|
                \() ->
                    let
                        model =
                            End (story chapterFour)

                        updated =
                            Story.update PreviousPage model
                    in
                        case fst updated of
                            Page no updatedStory ->
                                Expect.equal ( 3, chapterFour ) ( no, updatedStory.current )

                            _ ->
                                Expect.fail "should have matched Page"
            ]
        , describe "source"
            [ test "converts 1 on chapterOne" <|
                \() ->
                    Expect.equal
                        "google.com/Great%20Beginnings/001.png"
                        (Story.source 1 (story chapterOne))
            , test "converts 2 on chapterFour" <|
                \() ->
                    Expect.equal
                        "google.com/Final-Chapter/002.png"
                        (Story.source 2 (story chapterFour))
            ]
        ]
