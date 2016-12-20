module Tests exposing (..)

import Expect
import Fuzz
import Test exposing (..)
import Story


type Content
    = One
    | Two


story : Content -> Story.Model Content
story chapter =
    { name = "Test Story"
    , rootUrl = "google.com"
    , imageFormat = "png"
    , current = table chapter
    , position = Nothing
    , cheat = False
    }


table : Content -> Story.Chapter Content
table content =
    case content of
        One ->
            { title = "Great Beginnings"
            , length = 3
            , next =
                [ { place = "Chicago"
                  , description = "windy city"
                  , latitude = 0.025
                  , longitude = 0.025
                  , content = Two
                  }
                ]
            }

        Two ->
            { title = "Single Ladies"
            , length = 5
            , next = []
            }


all : Test
all =
    describe "Geomic.Story"
        [ describe "update"
            [ test
                "Choose Msg moves model to that chapter"
              <|
                \() ->
                    let
                        msg =
                            Story.Choose Two

                        model =
                            story One |> Story.update table msg
                    in
                        Expect.equal (story Two) model
            , fuzz2
                Fuzz.float
                Fuzz.float
                "Move Msg updates model position"
              <|
                \a b ->
                    let
                        msg =
                            Story.Move a b

                        model =
                            story One |> Story.update table msg
                    in
                        Just ( a, b )
                            |> Expect.equal model.position
            ]
        , describe "present"
            [ test "maps story name" <|
                \() ->
                    story One
                        |> Story.present
                        |> .name
                        |> Expect.equal "Test Story"
            , test "maps chapter title -- Chapter One" <|
                \() ->
                    story One
                        |> Story.present
                        |> .chapterTitle
                        |> Expect.equal "Great Beginnings"
            , test "maps chapter title -- Chapter Two" <|
                \() ->
                    story Two
                        |> Story.present
                        |> .chapterTitle
                        |> Expect.equal "Single Ladies"
            , test "formats panel urls -- Chapter One" <|
                \() ->
                    story One
                        |> Story.present
                        |> .panelUrls
                        |> Expect.equal
                            [ "google.com/Great%20Beginnings/001.png"
                            , "google.com/Great%20Beginnings/002.png"
                            , "google.com/Great%20Beginnings/003.png"
                            ]
            , test "formats panel urls -- Chapter Two" <|
                \() ->
                    story Two
                        |> Story.present
                        |> .panelUrls
                        |> Expect.equal
                            [ "google.com/Single%20Ladies/001.png"
                            , "google.com/Single%20Ladies/002.png"
                            , "google.com/Single%20Ladies/003.png"
                            , "google.com/Single%20Ladies/004.png"
                            , "google.com/Single%20Ladies/005.png"
                            ]
            , fuzz2
                (Fuzz.floatRange 0.001 0.005)
                (Fuzz.floatRange 0.001 0.005)
                "When cheat is enabled, everything is nearby"
              <|
                \a b ->
                    story One
                        |> (\s -> { s | cheat = True })
                        |> Story.update table (Story.Move a b)
                        |> Story.present
                        |> .decisions
                        |> Expect.equal
                            [ { place = "Chicago"
                              , description = "windy city"
                              , action = Just (Story.Choose Two)
                              }
                            ]
            , fuzz2
                (Fuzz.floatRange 0.001 0.005)
                (Fuzz.floatRange 0.001 0.005)
                "Small latitude and longitude deltas considered nearby"
              <|
                \a b ->
                    story One
                        |> Story.update table (Story.Move a b)
                        |> Story.present
                        |> .decisions
                        |> Expect.equal
                            [ { place = "Chicago"
                              , description = "windy city"
                              , action =
                                    if
                                        (&&)
                                            (abs (a - 0.025) <= Story.threshold)
                                            (abs (b - 0.025) <= Story.threshold)
                                    then
                                        Just (Story.Choose Two)
                                    else
                                        Nothing
                              }
                            ]
            ]
        ]
