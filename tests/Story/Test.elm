module Story.Test exposing (all)

import Expect
import Story
import Story.View
import Test exposing (..)


type Content
    = One
    | Two


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
        |> Cmd.map (always Debug.crash "this is just for comparison")


config =
    { name = "Test Story"
    , rootUrl = "google.com"
    , imageFormat = "png"
    , start = One
    , table = table
    , scroll = scroll
    }


{-| "bind" for tuples. Useful for piping update functions!
-}
(|=) : ( a, b ) -> (a -> c) -> c
(|=) ( a, _ ) f =
    f a
infixl 0 |=


all : Test
all =
    describe "Story"
        [ test
            "presents location access after updated with location error"
          <|
            \_ ->
                Story.init config ""
                    |= Story.update config Story.LocationError
                    |= Story.present
                    |> Expect.equal Story.View.LocationError
        , test
            "presents error after updated with load error"
          <|
            \_ ->
                Story.init config ""
                    |= Story.update config Story.LoadError
                    |= Story.present
                    |> Expect.equal Story.View.LoadError
        , test
            "presents loading after initialize"
          <|
            \_ ->
                Story.init config ""
                    |= Story.present
                    |> Expect.equal
                        (Story.View.Loading
                            Story.LoadError
                            Story.LoadSuccess
                            [ "google.com/Great%20Beginnings/001.png"
                            , "google.com/Great%20Beginnings/002.png"
                            , "google.com/Great%20Beginnings/003.png"
                            ]
                        )
        , test
            "presents chapter once panels are loaded with cheat"
          <|
            \_ ->
                Story.init config "#cheat"
                    |= Story.update config Story.LoadSuccess
                    |= Story.update config Story.LoadSuccess
                    |= Story.update config Story.LoadSuccess
                    |= Story.present
                    |> Expect.equal
                        (Story.View.Chapter
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
                Story.init config "#cheat"
                    |= Story.update config Story.LoadSuccess
                    |= Story.update config Story.LoadSuccess
                    |= Story.update config (Story.Chosen Two)
                    |= Story.present
                    |> Expect.equal
                        (Story.View.Loading
                            Story.LoadError
                            Story.LoadSuccess
                            [ "google.com/Single%20Ladies/001.png"
                            , "google.com/Single%20Ladies/002.png"
                            ]
                        )
        , test
            "presents next chapter after loading all the panels"
          <|
            \_ ->
                Story.init config "#cheat"
                    |= Story.update config (Story.Chosen Two)
                    |= Story.update config Story.LoadSuccess
                    |= Story.update config Story.LoadSuccess
                    |= Story.present
                    |> Expect.equal
                        (Story.View.Chapter
                            { name = "Test Story"
                            , chapterTitle = "Single Ladies"
                            , panelUrls =
                                [ "google.com/Single%20Ladies/001.png"
                                , "google.com/Single%20Ladies/002.png"
                                ]
                            , decisions = []
                            }
                        )
        , test
            "presents loading until location granted without cheat"
          <|
            \_ ->
                Story.init config ""
                    |= Story.update config Story.LoadSuccess
                    |= Story.update config Story.LoadSuccess
                    |= Story.update config Story.LoadSuccess
                    |= Story.present
                    |> Expect.equal
                        (Story.View.Loading
                            Story.LoadError
                            Story.LoadSuccess
                            [ "google.com/Great%20Beginnings/001.png"
                            , "google.com/Great%20Beginnings/002.png"
                            , "google.com/Great%20Beginnings/003.png"
                            ]
                        )
        , test
            "presents chapter after loaded and move is in range"
          <|
            \_ ->
                Story.init config ""
                    |= Story.update config (Story.Moved 0 0)
                    |= Story.update config Story.LoadSuccess
                    |= Story.update config Story.LoadSuccess
                    |= Story.update config Story.LoadSuccess
                    |= Story.present
                    |> Expect.equal
                        (Story.View.Chapter
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
            "presents complex chapter after move is not in range without cheat"
          <|
            \_ ->
                Story.init config ""
                    |= Story.update config (Story.Moved 99 99)
                    |= Story.update config Story.LoadSuccess
                    |= Story.update config Story.LoadSuccess
                    |= Story.update config Story.LoadSuccess
                    |= Story.present
                    |> Expect.equal
                        (Story.View.Chapter
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
                Story.init config ""
                    |= Story.update config (Story.Chosen Two)
                    |> Tuple.second
                    |> Expect.equal scroll
        , test
            "does not send geolocation task with cheat"
          <|
            \_ ->
                Story.init config "#cheat"
                    |> Tuple.second
                    |> Expect.equal Cmd.none
        , test
            "does not subscribe to geolocation with cheat"
          <|
            \_ ->
                Story.init config "#cheat"
                    |> Tuple.first
                    |> Story.subscriptions
                    |> Expect.equal Sub.none
        , test
            "sends geolocation task without cheat"
          <|
            \_ ->
                Story.init config ""
                    |> Tuple.second
                    |> Expect.notEqual Cmd.none
        , test
            "does not subscribe to geolocation when loading without cheat"
          <|
            \_ ->
                Story.init config ""
                    |> Tuple.first
                    |> Story.subscriptions
                    |> Expect.equal Sub.none
        , test
            "subscribes to geolocation when loading without cheat after move"
          <|
            \_ ->
                Story.init config ""
                    |= Story.update config (Story.Moved 1 1)
                    |> Tuple.first
                    |> Story.subscriptions
                    |> Expect.notEqual Sub.none
        , test
            "subscribes to geolocation when loading without cheat after error"
          <|
            \_ ->
                Story.init config ""
                    |= Story.update config Story.LocationError
                    |> Tuple.first
                    |> Story.subscriptions
                    |> Expect.notEqual Sub.none
        ]
