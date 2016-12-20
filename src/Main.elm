port module Main exposing (..)

import Story
import View
import Html


type Content
    = Prelude
    | One
    | Two
    | Three
    | Four
    | Five
    | Six
    | Seven
    | Eight
    | Nine
    | Ten
    | Eleven
    | Twelve
    | Thirteen
    | Fourteen
    | Fifteen


table : Content -> Story.Chapter Content
table content =
    case content of
        Prelude ->
            { title = "Prelude"
            , length = 19
            , next =
                [ { place = "Stamp Student Union"
                  , description = "Investigate the secret project."
                  , latitude = 38.988081
                  , longitude = -76.944738
                  , content = One
                  }
                ]
            }

        One ->
            { title = "001"
            , length = 9
            , next =
                [ { place = "Computer Science Instructional Center"
                  , description = "George Williams probably knows what's happening."
                  , latitude = 38.989991
                  , longitude = -76.936205
                  , content = Two
                  }
                , { place = "The Diner"
                  , description = "I need to see what my friends think about what's going on."
                  , latitude = 38.992321
                  , longitude = -76.946671
                  , content = Three
                  }
                ]
            }

        Two ->
            { title = "002"
            , length = 16
            , next =
                [ { place = "McKeldin Library"
                  , description = "Start beating the system with Professor Williams."
                  , latitude = 38.986008
                  , longitude = -76.94518
                  , content = Four
                  }
                , { place = "Hornbake Plaza"
                  , description = "I want to explore on my own."
                  , latitude = 38.988035
                  , longitude = -76.942627
                  , content = Five
                  }
                ]
            }

        Three ->
            { title = "003"
            , length = 10
            , next =
                [ { place = "Hornbake Plaza"
                  , description = "They're freaking me out. I'm going to explore on my own."
                  , latitude = 38.988035
                  , longitude = -76.942627
                  , content = Six
                  }
                , { place = "Stamp Student Union"
                  , description = "I'm going to stick with Ali and Tim."
                  , latitude = 38.988081
                  , longitude = -76.944738
                  , content = Seven
                  }
                ]
            }

        Four ->
            { title = "004"
            , length = 16
            , next =
                [ { place = "Hornbake Plaza"
                  , description = "I want to return to reality and never come back."
                  , latitude = 38.988035
                  , longitude = -76.942627
                  , content = Eight
                  }
                , { place = "Stamp Student Union"
                  , description = "I want to try the password on the original portal that disappeared."
                  , latitude = 38.988081
                  , longitude = -76.944738
                  , content = Nine
                  }
                ]
            }

        Five ->
            { title = "005"
            , length = 11
            , next =
                [ { place = "The Diner"
                  , description = "I'm bringing Ali and Tim with me."
                  , latitude = 38.992321
                  , longitude = -76.946671
                  , content = Ten
                  }
                , { place = "Computer Science Instructional Center"
                  , description = "I'm finding Professor Williams in the real world."
                  , latitude = 38.989991
                  , longitude = -76.936205
                  , content = Eleven
                  }
                ]
            }

        Six ->
            { title = "006"
            , length = 11
            , next =
                [ { place = "Computer Science Instructional Center"
                  , description = "I'm finding this Professor Williams."
                  , latitude = 38.989991
                  , longitude = -76.936205
                  , content = Twelve
                  }
                , { place = "The Diner"
                  , description = "I'm getting Ali and Tim."
                  , latitude = 38.992321
                  , longitude = -76.946671
                  , content = Thirteen
                  }
                ]
            }

        Seven ->
            { title = "007"
            , length = 13
            , next =
                [ { place = "Stamp Student Union"
                  , description = "I'm going to use the password on the original doorway."
                  , latitude = 38.988081
                  , longitude = -76.944738
                  , content = Fourteen
                  }
                , { place = "The Diner"
                  , description = "I'm not leaving. I'll stay here."
                  , latitude = 38.992321
                  , longitude = -76.946671
                  , content = Fifteen
                  }
                ]
            }

        Eight ->
            { title = "008"
            , length = 8
            , next = []
            }

        Nine ->
            { title = "009"
            , length = 6
            , next = []
            }

        Ten ->
            { title = "010"
            , length = 7
            , next = []
            }

        Eleven ->
            { title = "011"
            , length = 10
            , next = []
            }

        Twelve ->
            { title = "012"
            , length = 11
            , next = []
            }

        Thirteen ->
            { title = "013"
            , length = 7
            , next = []
            }

        Fourteen ->
            { title = "014"
            , length = 15
            , next = []
            }

        Fifteen ->
            { title = "015"
            , length = 4
            , next = []
            }


story : Story.Model Content
story =
    { name = "Gray Area"
    , rootUrl = "https://kofi.sexy/grayarea"
    , imageFormat = "png"
    , current = table Prelude
    , position = Nothing
    }


port scroll : () -> Cmd a


main =
    let
        wrap update msg model =
            ( update msg model
            , case msg of
                Story.Choose _ ->
                    scroll ()

                Story.Move _ _ ->
                    Cmd.none
            )
    in
        Html.program
            { init = ( story, Cmd.none )
            , update = Story.update table |> wrap
            , view = Story.present >> View.view
            , subscriptions = Story.subscriptions
            }
