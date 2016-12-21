module Story.Test exposing (all)

import Expect
import Fuzz
import Test exposing (..)
import Story


type Content
    = One
    | Two


type View
    = Loading
    | Error
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
            , length = 5
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


update =
    Story.update config


present =
    Story.present config


withoutCheating =
    Story.init config ""


withCheating =
    Story.init config "#cheat"


model =
    Tuple.first


cmd =
    Tuple.second


all : Test
all =
    describe "Story"
        [ test
            "presents error after updated with location error"
          <|
            \_ ->
                withoutCheating
                    |> model
                    >> update Story.LocationError
                    >> model
                    >> present
                    >> Expect.equal Error
        , test
            "presents loading after initialize without cheat"
          <|
            \_ ->
                withoutCheating
                    |> model
                    >> present
                    >> Expect.equal Loading
        , test
            "presents simple chapter after initialize with cheat"
          <|
            \_ ->
                withCheating
                    |> model
                    >> update (Story.Choose Two)
                    >> model
                    >> present
                    >> Expect.equal
                        (Chapter
                            { name = "Test Story"
                            , chapterTitle = "Single Ladies"
                            , panelUrls =
                                [ "google.com/Single%20Ladies/001.png"
                                , "google.com/Single%20Ladies/002.png"
                                , "google.com/Single%20Ladies/003.png"
                                , "google.com/Single%20Ladies/004.png"
                                , "google.com/Single%20Ladies/005.png"
                                ]
                            , decisions =
                                []
                            }
                        )
        , fuzz3
            (Fuzz.frequencyOrCrash
                [ ( 1, Fuzz.constant withCheating )
                , ( 1, Fuzz.constant withoutCheating )
                ]
            )
            (Fuzz.floatRange (negate Story.threshold) Story.threshold)
            (Fuzz.floatRange (negate Story.threshold) Story.threshold)
            "presents complex chapter after initialize and move is in range"
          <|
            \precondition latitude longitude ->
                precondition
                    |> model
                    >> update (Story.Move latitude longitude)
                    >> model
                    >> present
                    >> Expect.equal
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
                                  , action = Just (Story.Choose Two)
                                  }
                                ]
                            }
                        )
        , fuzz2
            (Fuzz.map
                (flip (/) Story.threshold)
                (Fuzz.floatRange (negate Story.threshold) Story.threshold)
            )
            (Fuzz.map
                (flip (/) Story.threshold)
                (Fuzz.floatRange (negate Story.threshold) Story.threshold)
            )
            "presents complex chapter after move is not in range without cheat"
          <|
            \latitude longitude ->
                withoutCheating
                    |> model
                    >> update (Story.Move latitude longitude)
                    >> model
                    >> present
                    >> Expect.equal
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
                withoutCheating
                    |> model
                    >> update (Story.Choose Two)
                    >> cmd
                    >> Expect.equal scroll
        , test
            "does not send geolocation task with cheat"
          <|
            \_ ->
                withCheating
                    |> cmd
                    >> Expect.equal Cmd.none
        , test
            "does not subscribe to geolocation with cheat"
          <|
            \_ ->
                withCheating
                    |> model
                    >> Story.subscriptions
                    >> Expect.equal Sub.none
        , test
            "sends geolocation task without cheat"
          <|
            \_ ->
                withoutCheating
                    |> cmd
                    >> Expect.notEqual Cmd.none
        , test
            "does not subscribe to geolocation when loading without cheat"
          <|
            \_ ->
                withoutCheating
                    |> model
                    >> Story.subscriptions
                    >> Expect.equal Sub.none
        , test
            "subscribes to geolocation when loading without cheat after move"
          <|
            \_ ->
                withoutCheating
                    |> model
                    >> update (Story.Move 1 1)
                    >> model
                    >> Story.subscriptions
                    >> Expect.notEqual Sub.none
        , test
            "subscribes to geolocation when loading without cheat after error"
          <|
            \_ ->
                withoutCheating
                    |> model
                    >> update Story.LocationError
                    >> model
                    >> Story.subscriptions
                    >> Expect.notEqual Sub.none
        ]
