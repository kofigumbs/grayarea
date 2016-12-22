module Story.Test exposing (all)

import Expect
import Fuzz
import Test exposing (..)
import Story


type Content
    = One
    | Two


type View
    = Error
    | Loading (Story.Msg Content) (List String)
    | Chapter
        { name : String
        , chapterTitle : String
        , panelUrls : List String
        , decisions :
            List
                { place : String
                , description : String
                , action : Maybe (Story.Msg Content)
                }
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
                  , latitude = 0
                  , longitude = 0
                  , content = Two
                  }
                ]
            }

        Two ->
            { title = "Single Ladies"
            , length = 2
            , next = []
            }


scroll : Cmd (Story.Msg Content)
scroll =
    Cmd.none
        |> Cmd.map (always Debug.crash "this won't evaluate")


config =
    { name = "Test Story"
    , rootUrl = "google.com"
    , imageFormat = "png"
    , start = One
    , table = table
    , scroll = scroll
    , loading = Loading
    , error = Error
    , chapter = Chapter
    }


do :
    String
    -> List (Story.Msg Content)
    -> ( Story.Model Content, Cmd (Story.Msg Content) )
do =
    Story.init config
        >> List.foldl (\msg ( model, _ ) -> Story.update config msg model)


present : String -> List (Story.Msg Content) -> View
present cheat =
    Story.present config << Tuple.first << do cheat


withoutCheat =
    ""


withCheat =
    "#cheat"


cheatFuzzer =
    Fuzz.frequencyOrCrash
        [ ( 1, Fuzz.constant withCheat )
        , ( 1, Fuzz.constant withoutCheat )
        ]


withinThresholdFuzzer =
    Fuzz.floatRange (negate Story.threshold) Story.threshold


invert =
    Fuzz.map (flip (/) Story.threshold)


all : Test
all =
    describe "Story"
        [ test
            "presents error after updated with location error"
          <|
            \_ ->
                present withoutCheat [ Story.LocationError ]
                    |> Expect.equal Error
        , fuzz cheatFuzzer
            "presents loading after initialize"
          <|
            \cheat ->
                present cheat []
                    |> Expect.equal
                        (Loading
                            Story.PanelLoaded
                            [ "google.com/Great%20Beginnings/001.png"
                            , "google.com/Great%20Beginnings/002.png"
                            , "google.com/Great%20Beginnings/003.png"
                            ]
                        )
        , fuzz (Fuzz.intRange 0 99)
            "presents loading until location granted without cheat"
          <|
            \count ->
                present withoutCheat (List.repeat count Story.PanelLoaded)
                    |> Expect.equal
                        (Loading
                            Story.PanelLoaded
                            [ "google.com/Great%20Beginnings/001.png"
                            , "google.com/Great%20Beginnings/002.png"
                            , "google.com/Great%20Beginnings/003.png"
                            ]
                        )
        , test
            "presents chapter once panels are loaded with cheat"
          <|
            \_ ->
                present withCheat
                    [ Story.PanelLoaded
                    , Story.PanelLoaded
                    , Story.PanelLoaded
                    ]
                    |> Expect.equal
                        (Chapter
                            { name = "Test Story"
                            , chapterTitle = "Great Beginnings"
                            , panelUrls =
                                [ "google.com/Great%20Beginnings/001.png"
                                , "google.com/Great%20Beginnings/002.png"
                                , "google.com/Great%20Beginnings/003.png"
                                ]
                            , decisions =
                                [ { place = "Chicago"
                                  , description = "windy city"
                                  , action = Just (Story.Chosen Two)
                                  }
                                ]
                            }
                        )
        , test
            "presents loading on each new chapter"
          <|
            \_ ->
                present withCheat
                    [ Story.PanelLoaded
                    , Story.PanelLoaded
                    , Story.Chosen Two
                    ]
                    |> Expect.equal
                        (Loading
                            Story.PanelLoaded
                            [ "google.com/Single%20Ladies/001.png"
                            , "google.com/Single%20Ladies/002.png"
                            ]
                        )
        , test
            "presents loading until location granted without cheat"
          <|
            \_ ->
                present withoutCheat
                    [ Story.PanelLoaded
                    , Story.PanelLoaded
                    , Story.PanelLoaded
                    ]
                    |> Expect.equal
                        (Loading
                            Story.PanelLoaded
                            [ "google.com/Great%20Beginnings/001.png"
                            , "google.com/Great%20Beginnings/002.png"
                            , "google.com/Great%20Beginnings/003.png"
                            ]
                        )
        , fuzz3
            cheatFuzzer
            withinThresholdFuzzer
            withinThresholdFuzzer
            "presents chapter after loaded and move is in range"
          <|
            \cheat latitude longitude ->
                present cheat
                    [ Story.Moved latitude longitude
                    , Story.PanelLoaded
                    , Story.PanelLoaded
                    , Story.PanelLoaded
                    , Story.PanelLoaded
                    ]
                    |> Expect.equal
                        (Chapter
                            { name = "Test Story"
                            , chapterTitle = "Great Beginnings"
                            , panelUrls =
                                [ "google.com/Great%20Beginnings/001.png"
                                , "google.com/Great%20Beginnings/002.png"
                                , "google.com/Great%20Beginnings/003.png"
                                ]
                            , decisions =
                                [ { place = "Chicago"
                                  , description = "windy city"
                                  , action = Just (Story.Chosen Two)
                                  }
                                ]
                            }
                        )
        , fuzz2
            (invert withinThresholdFuzzer)
            (invert withinThresholdFuzzer)
            "presents complex chapter after move is not in range without cheat"
          <|
            \latitude longitude ->
                present withoutCheat
                    [ Story.Moved latitude longitude
                    , Story.PanelLoaded
                    , Story.PanelLoaded
                    , Story.PanelLoaded
                    ]
                    |> Expect.equal
                        (Chapter
                            { name = "Test Story"
                            , chapterTitle = "Great Beginnings"
                            , panelUrls =
                                [ "google.com/Great%20Beginnings/001.png"
                                , "google.com/Great%20Beginnings/002.png"
                                , "google.com/Great%20Beginnings/003.png"
                                ]
                            , decisions =
                                [ { place = "Chicago"
                                  , description = "windy city"
                                  , action = Nothing
                                  }
                                ]
                            }
                        )
        , test
            "scrolls on new chapter"
          <|
            \_ ->
                do withoutCheat [ Story.Chosen Two ]
                    |> Tuple.second
                    |> Expect.equal scroll
        , test
            "does not send geolocation task with cheat"
          <|
            \_ ->
                do withCheat []
                    |> Tuple.second
                    |> Expect.equal Cmd.none
        , test
            "does not subscribe to geolocation with cheat"
          <|
            \_ ->
                do withCheat []
                    |> Tuple.first
                    |> Story.subscriptions
                    |> Expect.equal Sub.none
        , test
            "sends geolocation task without cheat"
          <|
            \_ ->
                do withoutCheat []
                    |> Tuple.second
                    |> Expect.notEqual Cmd.none
        , test
            "does not subscribe to geolocation when loading without cheat"
          <|
            \_ ->
                do withoutCheat []
                    |> Tuple.first
                    |> Story.subscriptions
                    |> Expect.equal Sub.none
        , test
            "subscribes to geolocation when loading without cheat after move"
          <|
            \_ ->
                do withoutCheat [ (Story.Moved 1 1) ]
                    |> Tuple.first
                    |> Story.subscriptions
                    |> Expect.notEqual Sub.none
        , test
            "subscribes to geolocation when loading without cheat after error"
          <|
            \_ ->
                do withoutCheat [ Story.LocationError ]
                    |> Tuple.first
                    |> Story.subscriptions
                    |> Expect.notEqual Sub.none
        ]
