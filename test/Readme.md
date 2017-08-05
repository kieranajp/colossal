# Tests

In order to test we spin up a Consul server first then spin _nginx_, _redis_  and python web _app_

* _nginx container_ is consumer of _pilot-app_
* _app container_ is producer of service _pilot-app_ and a consumer of _pilot-redis_
* redis container_ is producer of service _pilot-redis_

## Run

You need ruby > 2.0 and bundler installed and on the root of source run.

```sh
# Install required gems
bundle
# build image and spin the cluster and run the tests and tear down the cluster
bundle exec rake tests
# minor clean up
bundle exec rake clean
# clean every thing including image
bundle exec rake clean-all

# To list all tasks
bundle exec rake --tasks
```

## Details

For more info dig into [rake](rake) [docker-compose](test/docker-compose.yml) and the [test dir](test)
