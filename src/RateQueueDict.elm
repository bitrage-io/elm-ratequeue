module RateQueueDict
    exposing
        ( RateQueueDict
        , empty
        , pop
        , add
        , length
        , isEmpty
        , isQueueEmpty
        )

{-|
@docs RateQueueDict, empty, pop, add, length, isEmpty, isQueueEmpty
-}

import Dict
import RateQueue
import Time


{-| -}
type RateQueueDict comparable item
    = RateQueueDict (Dict.Dict comparable (RateQueue.RateQueue item))


{-| -}
empty : RateQueueDict comparable item
empty =
    RateQueueDict Dict.empty


{-| -}
pop : Time.Time -> RateQueueDict comparable item -> ( RateQueueDict comparable item, List item )
pop now (RateQueueDict queueDict) =
    queueDict
        |> Dict.toList
        |> List.map (\( id, queue ) -> ( id, RateQueue.pop now queue ))
        |> List.map (\( id, ( queue, item ) ) -> ( ( id, queue ), item ))
        |> List.unzip
        |> (\( queues, items ) -> ( RateQueueDict <| Dict.fromList queues, List.filterMap identity items ))


{-| Add items to the end of a RateQueue. If no RateQueue exists with the specified
id then one will be created with the rate limit provided.
-}
add : Time.Time -> comparable -> List item -> RateQueueDict comparable item -> RateQueueDict comparable item
add rateLimit id items (RateQueueDict queueDict) =
    queueDict
        |> Dict.get id
        |> Maybe.withDefault (RateQueue.new rateLimit)
        |> (\queue -> Dict.insert id (RateQueue.add items queue) queueDict)
        |> RateQueueDict


{-| -}
length : comparable -> RateQueueDict comparable item -> Int
length id (RateQueueDict queueDict) =
    queueDict
        |> Dict.get id
        |> Maybe.withDefault (RateQueue.new 0)
        |> RateQueue.length


{-| -}
isQueueEmpty : comparable -> RateQueueDict comparable item -> Bool
isQueueEmpty id (RateQueueDict queueDict) =
    queueDict
        |> Dict.get id
        |> Maybe.andThen (Just << RateQueue.isEmpty)
        |> Maybe.withDefault True


{-| -}
isEmpty : RateQueueDict comparable item -> Bool
isEmpty (RateQueueDict queueDict) =
    queueDict
        |> Dict.toList
        |> List.all (RateQueue.isEmpty << Tuple.second)
