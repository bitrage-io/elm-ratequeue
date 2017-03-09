# elm-ratequeue

Rate-limited queues for arbitrary data types. Currently the primary use-case for
this is to release batched HTTP requests slowly to avoid hitting rate limit caps
in third-party APIs.

## Install

```sh
elm-package install bitrage-io/elm-ratequeue
```

## Usage

```elm
import Dict
import RateQueue
import Time

emptyQueue : RateQueue.RateQueue String
emptyQueue =
    RateQueue.new Time.second

queueWithItems : RateQueue.RateQueue String
queueWithItems =
    RateQueue.enqueue ["a", "b", "c"] emptyQueue

queueAndReleasedItem : ( RateQueue String, Maybe String )
queueAndReleasedItem =
    RateQueue.release 0 queueWithItems

queueDict : Dict.Dict String (RateQueue.RateQueue String)
queueDict =
    RateQueue.enqueueDict Time.second "queue-id" ["a", "b", "c"] Dict.empty

queueDictAndReleasedItems : (Dict.Dict String (RateQueue.RateQueue String), List String)
queueDictAndReleasedItems =
    RateQueue.releaseDict 0 queueDict
```
