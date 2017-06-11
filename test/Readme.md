# Tests

In order to test we spin up a Consul server first then spin _nginx_, _redis_  and python web _app_

* _nginx container_ is consumer of _pilot-app_
* _app container_ is producer of service _pilot-app_ and a consumer of _pilot-redis_
* redis container_ is producer of service _pilot-redis_

## Run

On the root of source run

```
make build
make tests
```

## details
For more info dig into
.kitchen.yml
tests in integration