module RateQueue
    exposing
        ( RateQueue
        , new
        , pop
        , add
        , length
        , isEmpty
        )

{-|

@docs RateQueue, new, pop, add, length, isEmpty
-}

import Time


{-| -}
type RateQueue item
    = RateQueue
        { rateLimit : Time.Time
        , items : List item
        , nextRelease : Time.Time
        }


{-| -}
new : Time.Time -> RateQueue item
new rateLimit =
    RateQueue
        { rateLimit = rateLimit
        , items = []
        , nextRelease = 0
        }


{-| -}
pop : Time.Time -> RateQueue item -> ( RateQueue item, Maybe item )
pop now (RateQueue queue) =
    if queue.nextRelease <= now then
        ( RateQueue
            { queue
                | items = Maybe.withDefault [] <| List.tail queue.items
                , nextRelease = now + queue.rateLimit
            }
        , List.head queue.items
        )
    else
        ( RateQueue queue, Nothing )


{-| -}
add : List item -> RateQueue item -> RateQueue item
add items (RateQueue queue) =
    RateQueue { queue | items = List.concat [ queue.items, items ] }


{-| -}
length : RateQueue item -> Int
length (RateQueue queue) =
    List.length queue.items


{-| -}
isEmpty : RateQueue item -> Bool
isEmpty (RateQueue queue) =
    List.isEmpty queue.items
