module Tests exposing (..)

import Test exposing (..)
import Expect
import RateQueue
import RateQueueDict


all : Test
all =
    describe "elm-queue tests"
        [ queueTest
        , queueDictTest
        ]


queueTest : Test
queueTest =
    describe "RateQueue Test Suite"
        [ test "Enqueuing items" <|
            \() ->
                (RateQueue.new 50)
                    |> RateQueue.add [ 1, 2, 3 ]
                    |> RateQueue.length
                    |> Expect.equal 3
        , test "Releasing items" <|
            \() ->
                (RateQueue.new 50)
                    |> RateQueue.add [ "a", "b", "c" ]
                    |> RateQueue.pop 0
                    |> (\( queue, item ) -> ( item, RateQueue.length queue ))
                    |> Expect.equal ( Just "a", 2 )
        , test "Rate limiting item release" <|
            \() ->
                (RateQueue.new 50)
                    |> RateQueue.add [ "a", "b", "c" ]
                    |> RateQueue.pop 0
                    |> Tuple.first
                    |> RateQueue.pop 40
                    |> (\( queue, item ) -> ( item, RateQueue.length queue ))
                    |> Expect.equal ( Nothing, 2 )
        , test "Rate limiting item release" <|
            \() ->
                (RateQueue.new 50)
                    |> RateQueue.add [ "a", "b", "c" ]
                    |> RateQueue.pop 0
                    |> Tuple.first
                    |> RateQueue.pop 55
                    |> (\( queue, item ) -> ( item, RateQueue.length queue ))
                    |> Expect.equal ( Just "b", 1 )
        , test "Queue is empty" <|
            \() ->
                (RateQueue.new 50)
                    |> RateQueue.isEmpty
                    |> Expect.true "Expected queue to be empty"
        , test "Queue is NOT empty" <|
            \() ->
                (RateQueue.new 50)
                    |> RateQueue.add [ "a" ]
                    |> RateQueue.isEmpty
                    |> Expect.false "Expected queue to NOT be empty"
        ]


queueDictTest : Test
queueDictTest =
    describe "RateQueueDict Test Suite"
        [ test "Enqueing items" <|
            \() ->
                RateQueueDict.empty
                    |> RateQueueDict.add 50 "test-id" [ "a", "b", "c" ]
                    |> RateQueueDict.length "test-id"
                    |> Expect.equal 3
        , test "Releasing items from one queue" <|
            \() ->
                RateQueueDict.empty
                    |> RateQueueDict.add 50 "test-id" [ "a", "b", "c" ]
                    |> RateQueueDict.pop 0
                    |> (\( queueDict, items ) -> ( RateQueueDict.length "test-id" queueDict, items ))
                    |> Expect.equal ( 2, [ "a" ] )
        , test "Releasing items from multiple queues" <|
            \() ->
                RateQueueDict.empty
                    |> RateQueueDict.add 50 "test-id-1" [ "a", "b", "c" ]
                    |> RateQueueDict.add 50 "test-id-2" [ "c" ]
                    |> RateQueueDict.pop 0
                    |> (\( queueDict, items ) -> ( RateQueueDict.length "test-id-2" queueDict, items ))
                    |> Expect.equal ( 0, [ "a", "c" ] )
        , test "Rate limiting item release from one queue" <|
            \() ->
                RateQueueDict.empty
                    |> RateQueueDict.add 50 "test-id" [ "a", "b", "c" ]
                    |> RateQueueDict.pop 0
                    |> Tuple.first
                    |> RateQueueDict.pop 40
                    |> (\( queueDict, items ) -> ( RateQueueDict.length "test-id" queueDict, items ))
                    |> Expect.equal ( 2, [] )
        , test "Rate limiting item release from multiple queues" <|
            \() ->
                RateQueueDict.empty
                    |> RateQueueDict.add 50 "test-id-1" [ "a", "b", "c" ]
                    |> RateQueueDict.add 50 "test-id-2" [ "d", "e", "f" ]
                    |> RateQueueDict.add 60 "test-id-3" [ "g", "h", "i" ]
                    |> RateQueueDict.pop 0
                    |> Tuple.first
                    |> RateQueueDict.pop 55
                    |> (\( queueDict, items ) -> ( RateQueueDict.length "test-id-3" queueDict, items ))
                    |> Expect.equal ( 2, [ "b", "e" ] )
        , test "Rate limiting item release from multiple queues" <|
            \() ->
                RateQueueDict.empty
                    |> RateQueueDict.add 50 "test-id-1" [ "a", "b", "c" ]
                    |> RateQueueDict.add 50 "test-id-2" [ "d", "e", "f" ]
                    |> RateQueueDict.add 60 "test-id-3" [ "g", "h", "i" ]
                    |> RateQueueDict.pop 0
                    |> Tuple.first
                    |> RateQueueDict.pop 55
                    |> Tuple.first
                    |> RateQueueDict.pop 110
                    |> (\( queueDict, items ) -> ( RateQueueDict.length "test-id-3" queueDict, items ))
                    |> Expect.equal ( 1, [ "c", "f", "h" ] )
        , test "Uninitialized queue is empty" <|
            \() ->
                RateQueueDict.empty
                    |> RateQueueDict.isQueueEmpty "nothing"
                    |> Expect.true "Expected queue to be empty"
        , test "Initialized queue is empty" <|
            \() ->
                RateQueueDict.empty
                    |> RateQueueDict.add 50 "test-id" []
                    |> RateQueueDict.isQueueEmpty "test-id"
                    |> Expect.true "Expected queue to be empty"
        , test "Initialized queue is NOT empty" <|
            \() ->
                RateQueueDict.empty
                    |> RateQueueDict.add 50 "test-id" [ "test" ]
                    |> RateQueueDict.isQueueEmpty "test-id"
                    |> Expect.false "Expected queue to NOT be empty"
        , test "All queues are empty" <|
            \() ->
                RateQueueDict.empty
                    |> RateQueueDict.add 50 "test-id-1" []
                    |> RateQueueDict.add 50 "test-id-2" []
                    |> RateQueueDict.isEmpty
                    |> Expect.true "Expected queue to be empty"
        ]
