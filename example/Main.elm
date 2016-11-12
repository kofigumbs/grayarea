module Main exposing (..)

import Geomic


type Content
    = Introduction
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


table : Content -> Geomic.Chapter Content
table content =
    case content of
        Introduction ->
            { title = "Introduction"
            , description = ""
            , length = 19
            , next =
                [ ( 0, 0, One )
                ]
            }

        One ->
            { title = ""
            , description = ""
            , length = 0
            , next =
                [ ( 0, 0, Introduction )
                ]
            }

        Two ->
            { title = ""
            , description = ""
            , length = 0
            , next =
                [ ( 0, 0, Introduction )
                ]
            }

        Three ->
            { title = ""
            , description = ""
            , length = 0
            , next =
                [ ( 0, 0, Introduction )
                ]
            }

        Four ->
            { title = ""
            , description = ""
            , length = 0
            , next =
                [ ( 0, 0, Introduction )
                ]
            }

        Five ->
            { title = ""
            , description = ""
            , length = 0
            , next =
                [ ( 0, 0, Introduction )
                ]
            }

        Six ->
            { title = ""
            , description = ""
            , length = 0
            , next =
                [ ( 0, 0, Introduction )
                ]
            }

        Seven ->
            { title = ""
            , description = ""
            , length = 0
            , next =
                [ ( 0, 0, Introduction )
                ]
            }

        Eight ->
            { title = ""
            , description = ""
            , length = 0
            , next =
                [ ( 0, 0, Introduction )
                ]
            }

        Nine ->
            { title = ""
            , description = ""
            , length = 0
            , next =
                [ ( 0, 0, Introduction )
                ]
            }

        Ten ->
            { title = ""
            , description = ""
            , length = 0
            , next =
                [ ( 0, 0, Introduction )
                ]
            }

        Eleven ->
            { title = ""
            , description = ""
            , length = 0
            , next =
                [ ( 0, 0, Introduction )
                ]
            }

        Twelve ->
            { title = ""
            , description = ""
            , length = 0
            , next =
                [ ( 0, 0, Introduction )
                ]
            }

        Thirteen ->
            { title = ""
            , description = ""
            , length = 0
            , next =
                [ ( 0, 0, Introduction )
                ]
            }

        Fourteen ->
            { title = ""
            , description = ""
            , length = 0
            , next =
                [ ( 0, 0, Introduction )
                ]
            }

        Fifteen ->
            { title = ""
            , description = ""
            , length = 0
            , next =
                [ ( 0, 0, Introduction )
                ]
            }


main : Program Never
main =
    Geomic.program
        { name = "Gray Area"
        , rootUrl = "https://kofi.sexy/grayarea"
        , format = "png"
        , table = table
        , start = Introduction
        }
