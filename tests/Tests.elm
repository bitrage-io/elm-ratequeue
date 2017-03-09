module Tests exposing (..)

import Dict
import Test exposing (..)
import Expect
import RateQueue


all : Test
all =
    describe "elm-queue tests"
        [ test "Enqueuing items" <|
            \() ->
                (RateQueue.new 50)
                    |> RateQueue.enqueue [ 1, 2, 3 ]
                    |> RateQueue.length
                    |> Expect.equal 3
        , test "Releasing items" <|
            \() ->
                (RateQueue.new 50)
                    |> RateQueue.enqueue [ "a", "b", "c" ]
                    |> RateQueue.release 0
                    |> (\( queue, item ) -> ( item, RateQueue.length queue ))
                    |> Expect.equal ( Just "a", 2 )
        , test "Rate limiting item release" <|
            \() ->
                (RateQueue.new 50)
                    |> RateQueue.enqueue [ "a", "b", "c" ]
                    |> RateQueue.release 0
                    |> Tuple.first
                    |> RateQueue.release 40
                    |> (\( queue, item ) -> ( item, RateQueue.length queue ))
                    |> Expect.equal ( Nothing, 2 )
        , test "Rate limiting item release" <|
            \() ->
                (RateQueue.new 50)
                    |> RateQueue.enqueue [ "a", "b", "c" ]
                    |> RateQueue.release 0
                    |> Tuple.first
                    |> RateQueue.release 55
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
                    |> RateQueue.enqueue [ "a" ]
                    |> RateQueue.isEmpty
                    |> Expect.false "Expected queue to NOT be empty"
        , test "Enqueing items in a dictionary" <|
            \() ->
                Dict.empty
                    |> RateQueue.enqueueDict 50 "test-id" [ "a", "b", "c" ]
                    |> Dict.get "test-id"
                    |> Maybe.andThen (Just << RateQueue.items)
                    |> Expect.equal (Just [ "a", "b", "c" ])
        ]
