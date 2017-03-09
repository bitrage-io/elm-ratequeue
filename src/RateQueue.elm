module RateQueue
    exposing
        ( RateQueue
        , new
        , release
        , enqueue
        , length
        , isEmpty
        , rateLimit
        , nextRelease
        , canRelease
        , items
        , enqueueDict
        , releaseDict
        )

{-|

A queue of items that are released at regular intervals. Primarily used to rate limit batches of
outgoing HTTP requests, but it will work for any arbitrary types.

## RateQueue

@docs RateQueue

## Build

@docs new, enqueue, release

## Query

@docs isEmpty, length, rateLimit, nextRelease, canRelease, items

## Dict

Helpers for enqueing and releasing items from a dictionary of queues.

@docs enqueueDict, releaseDict

-}

import Dict
import Time


{-| A list of items that should be released at regular intervals.
-}
type RateQueue item
    = RateQueue
        { rateLimit : Time.Time
        , items : List item
        , nextRelease : Time.Time
        }


{-| Create a new queue with a rate limit.

```elm
rateQueue =
    RateQueue.new Time.second  -- Items can be released every second
```

-}
new : Time.Time -> RateQueue item
new rateLimit =
    RateQueue
        { rateLimit = rateLimit
        , items = []
        , nextRelease = 0
        }


{-| Add items to the end of the queue.

```elm
RateQueue.enqueue [ "a", "b", "c" ] rateQueue
```
-}
enqueue : List item -> RateQueue item -> RateQueue item
enqueue items (RateQueue queue) =
    RateQueue { queue | items = List.concat [ queue.items, items ] }


{-| Get the first item from the queue if enough time has passed,.

```elm
RateQueue.release now rateQueue
```

-}
release : Time.Time -> RateQueue item -> ( RateQueue item, Maybe item )
release now queue =
    if canRelease now queue then
        ( RateQueue
            { rateLimit = rateLimit queue
            , items = Maybe.withDefault [] <| List.tail <| items queue
            , nextRelease = now + (rateLimit queue)
            }
        , List.head <| items queue
        )
    else
        ( queue, Nothing )


{-| Adds items to the end of a queue in a dictionary. If a queue doesn't exist
for the key, then a new one is created with the rate limit.

```elm
RateQueue.enqueueDict Time.second "a-unique-id" ["a", "b", "c"] Dict.empty
```
-}
enqueueDict : Time.Time -> comparable -> List item -> Dict.Dict comparable (RateQueue item) -> Dict.Dict comparable (RateQueue item)
enqueueDict rateLimit key items dict =
    dict
        |> Dict.get key
        |> Maybe.withDefault (new rateLimit)
        |> (\queue -> Dict.insert key (enqueue items queue) dict)


{-| Releases items from all the queues in a dictionary.


```elm
Dict.empty
    |> RateQueue.enqueueDict Time.second "a-unique-id" ["a", "b", "c"]
    |> RateQueue.enqueueDict Time.second "another-id" ["d", "e", "f"]
    |> RateQueue.releaseDict now
    -- ["a", "d"]
```
-}
releaseDict : Time.Time -> Dict.Dict comparable (RateQueue item) -> ( Dict.Dict comparable (RateQueue item), List item )
releaseDict now dict =
    dict
        |> Dict.toList
        |> List.map (\( id, queue ) -> ( id, release now queue ))
        |> List.map (\( id, ( queue, item ) ) -> ( ( id, queue ), item ))
        |> List.unzip
        |> (\( queues, items ) -> ( Dict.fromList queues, List.filterMap identity items ))


{-| Determine if the queue is empty.

```elm
RateQueue.isEmpty rateQueue == True
```

-}
isEmpty : RateQueue item -> Bool
isEmpty queue =
    List.isEmpty <| items queue


{-| Determine the number of items in the queue.

```elm
RateQueue.length rateQueue == 2
```
-}
length : RateQueue item -> Int
length queue =
    List.length <| items queue


{-| Determine the rate of the queue.

```elm
RateQueue.rateLimit (Queue.new 1000) -- 1000
```

-}
rateLimit : RateQueue item -> Time.Time
rateLimit (RateQueue queue) =
    queue.rateLimit


{-| Determine the items in the queue.

```elm
(Queue.new 1000)
    |> Queue.enqueue ["a", "b", "c"]
    |> Queue.items
    -- ["a", "b", "c"]
```
-}
items : RateQueue item -> List item
items (RateQueue queue) =
    queue.items


{-| Determine the next release time of the queue.
```elm
(Queue.new 1000)
    |> Queue.release 1500
    |> Tuple.first
    |> Queue.nextRelease
    --  2500
```
-}
nextRelease : RateQueue item -> Time.Time
nextRelease (RateQueue queue) =
    queue.nextRelease


{-| Determine if enough time has passed to release an item from the queue.
```elm
Queue.canRelease now <| Queue.new 1000 -- True
```
-}
canRelease : Time.Time -> RateQueue item -> Bool
canRelease now queue =
    (nextRelease queue) <= now
