# Tests

In order to run our tests we spin up a Consul server then a number of containers first.

* _nginx container_ is consumer of _pilot-app_
* _app container_ is producer of service _pilot-app_ and a consumer of _pilot-redis_
* _redis container_ is producer of service _pilot-redis_
* _hooks container_ is producer of hooks.

## Running

You need ruby > 2.0 and bundler installed. Change your directory to root of Colossal

```sh
# Install required gems
bundle

# build Colossal dev
bundle exec rake build

# Spin the cluster and run the tests and tear down the cluster if all is good
bundle exec rake tests

# minor clean up
bundle exec rake clean

# Clean every thing including removing images
bundle exec rake clean-all

# List all tasks
bundle exec rake --tasks
```

## Details

For more info dig into

* [Rakefile](Rakefile)
* [docker-compose](test/docker-compose.yml)
* [Test specification for all containers](test/spec)
* [test dir](test)
