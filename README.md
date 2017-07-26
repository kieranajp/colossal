# Colossal

A base image based on Alpine that utilizes the autopilot pattern with client side load balancing.

## Why

Missing gap between packing "Docker image" and service orchestration. Autopilot pattern is concerned about application life cycle. Colossal is an opinionated implementation that uses container pilot.

## Overview

* Full power of PID 1: with full reaping powers
* Application life cycle: You can run custom scripts on events.
* Announce the running application to consul.
* Client side load balancing & Service discovery for your external dependencies
* Templates for application configuration.
* Secrets injected into your application configuration (currently support vault).
* Aggregation of stdout and stderr logs.
* Telemetry support.

## Example Docker file

```Dockerfile
FROM quay.io/ahelal/colossal:latest

# Application will be announced to consul as "pilot-app
ENV APP_NAME          "pilot-app"
ENV APP_PORT          8080
# Tags to be announced in consul
ENV APP_TAGS          "pilot-app,v1.1.1"
# Command to run our application. We will run it as app user
ENV APP_EXEC          resu app:app -- /app
# Health check config for consul
ENV APP_HEALTH_EXEC   "curl -fsSo /dev/null http://127.0.0.1:8080"
# Attempts to restart the process if it exists
ENV APP_RESTARTS      10

# Our Application
COPY app /
# Add prestart hook (Run this script before running our application)
COPY prestart.sh /hooks/prestart

# First service dependency (watcher) Redis
ENV SERVICE_NAME_1   "pilot-redis"
ENV SERVICE_PORT_1   "6379"
ENV SERVICE_MODE_1   "tcp"

# Second service dependency (watcher) HTTP application
ENV SERVICE_NAME_2   "pilot-cabincrew"
ENV SERVICE_PORT_2   "8000"

# HAproxy expose stats page and use prometheus haproxy exporter
ENV HAPROXY_STATS     True
ENV HAPROXY_EXPORTER  True
```

```sh
docker run -d -t -e CONSUL=consul.example.com -e CONSUL_ENCRYPT=cg8StVXbQJ0gPvMd9o7yrg myapp
```

For more info check supported [variables](#variables) and [hooks](#hooks)

## Colossal components

Colossal is based on Alpine linux and is packaged with

* [container-pilot](https://github.com/joyent/containerpilot/)
* [Consul](https://www.consul.io/)
* [Consul-template](https://github.com/hashicorp/consul-template)
* [HA-proxy](http://www.haproxy.org/)
* [resu](https://github.com/ben--/resu/)

List of [components version](packages.mk)

## Users

Yes it is recommended to run as non root user when possible even in docker.
The following users are available for isolation

* **consul**
* **haproxy**
* **app** Recommended to run your application with app user.

## Service discovery and client side load balancing

*Consul server must be setup, before using this feature it is beyond the scope of Colossal. Head to [Consul](https://www.consul.io)

This is an opinionated way to do service discovery inspired by the all mighty SmartStack from AirBnB.

A service is divided into a Consumer and a Producer.

Take the following stack each will run in a container:

* A web HTTP Application "blog"
* A NGinx that acts as a reverse proxy "nginx"
* A PostgreSQL database "db"

let's break it down to consumers and producers.

* *db* requires nothing; then *db* consumes *nothing* and produces *db*
* *blog* requires *db*; then *blog* consumes *db* and produces *blog*
* *nginx* requires *blog*; then *nginx* consumes *blog* and produces *nothing*. since nginx will be our edge server and will not be consumed by internal services.

### Producer

A service that will be announced on a specific Address/TCP port vie consul. In Colossal you can only announce one service per container. off-course you can have multiple instance of that service.

Components of a producer:

* The application i.e. blog
* Consul-agent (packaged with Colossal)

In order to know whether a producer is healthy, The consul agent performs health checks, and if it fail the service is de-registered. The health check is a command that is executed every interval inside the container by consul-agent. The health check could be a simple curl `curl localhost:8080/` or better implement a custom health endpoint that will returns 200 if all  is okay. That part is up to you implement.
You can also write a script that does a simple basic health. it checks connection and get some data and asserts it.
  exits with a non-zero if something is wrong.

```bash
#!/bin/sh
set -e
pg_isready -h localhost -p 5433
psql -c 'SELECT * FROM sometable WHERE SOMETHING = 1'
```

### Consumer

All the magic happens on the consumer. So it is responsible to make your service dependencies "watchers" available to use, transparently to your application.

Components of a consumer:

* You application i.e. nginx
* Consul-agent (packaged with Colossal)
* Consul-template (packaged with Colossal)
* HA-Proxy (packaged with Colossal)

You will define your service dependencies "watchers" consul-agent will read the service meta data information "Address/ports" and passes that to *consul-template* that will re/write HAProxy configuration file and reload HAProxy to reflect the changes. All the heavy lifting is left to HAProxy to handle and we get all the benefits of powerful load balancer plus loads of metrics and statistics. Plus an built-in health checking

Your application will connect to localhost:SERVICE_port and HAProxy will take care of the rest.

### Service discovery overview

This approach to  Service Discovery has the benefit of being de-centralized, orchestrator agonistic, high level of visibility and flexibility.
Doing debugging or maintenance on a backend is as simple as stopping the Consul-agent process on the instance. You can also utilize HAProxy status page it will list all the backends available and aggregate and per-request information.

The infrastructure is completely distributed. The most critical nodes are the Consul and if you require even higher availability you can configure HAProxy not to remove a backends unless they are explicitly de-registered from consul. that means even if Consul server fails you get to keep all backends until you restore consul server and during the downtime HAProxy will remove unhealthy backends if they begin to act odd.

## Events

The entry point is */bin/containerpilot"* this will also acts as PID 1.

### Built in hooks

If you use watchers downstream changes in a service (new services registered, becomes unhealthy or goes away) will trigger HAPorxy to reload and reflect current services.
check [changed-script](changed-script.sh)

### Hooks

You can add custom scripts that will be executed if it exist and is executable when a certain event occurs.

| Location          | Description |
|-------------------|-------------|
| /hooks/preContainerPilot | Runs before container Pilot starting |
| /hooks/preStart   | Runs before app start |
| /hooks/renderConfigFiles| Generate config files |
| /hooks/ConfigENV.ctmpl| A consul-template file formated in KEY=VALUE|
| /hooks/preChange  | Runs after watcher change and before HAproxy reload  |
| /hooks/postChange | Runs after watcher change and after HAproxy reload  |
| /hooks/preStop    | Runs before stopping the app |
| /hooks/stop       | Runs to stop the app if not provided it will be killed by container pilot |
| /hooks/postStop   | Runs after stopping the app |

## Variables

You can configure various knobs using environmental variable

### Application variables

The group of variables that define application configuration.

| Variable          | Required | Default | Description |
|-------------------|----------|---------|-------------|
|APP_NAME           |  YES     | None    | Application name|
|APP_EXEC           |  YES     | None    | Application execution command|
|APP_PORT           |  YES     | None    | Application Port |
|APP_INTERFACES_STATIC|  NO    | None    | Static IP used to advertise on Consul |
|APP_INTERFACES     |  NO      | None    | Comma separated parameters [check container pilot doc](https://github.com/joyent/containerpilot/blob/master/docs/30-configuration/32-configuration-file.md#interfaces)|
|APP_POLL           |  NO      | None    |             |
|APP_TAGS           |  NO      | None    |             |
|APP_RESTARTS       |  NO      | 10      | Number of times the process will be restarted if it exits. This field supports any non-negative numeric value (ex. 0 or 1) or the strings "unlimited" or "never"|
|APP_HEALTH_EXEC    |  NO      | None    |             |
|APP_HEALTH_TTL     |  NO      | 25      |             |
|APP_HEALTH_INTERVAL|  NO      | 10      |             |
|APP_HEALTH_TIMEOUT |  No      | 5       |             |


### Consul variables

| Variable          | Required | Default | Description |
|-------------------|----------|---------|-------------|
| CONSUL            |  No      |127.0.0.1|             |
| CONSUL_ENCRYPT    |  Yes     | None    |Consul encrypt without the '==' at the end|
| CONSUL_DATACENTER |  No      | dc1     |              |

### Service (Service dependency)

| Variable            | Required | Default  | Description |
|---------------------|----------|----------|-------------|
|SERVICE_NAME_$NUM    |  NO      |          |             |
|SERVICE_PORT_$NUM    |  NO      |          |             |
|SERVICE_MODE_$NUM    |  NO      |  http    |             |
|SERVICE_BALANCE_$NUM |  NO      |roundrobin|             |
|SERVICE_OPTIONS_$NUM |  NO      |          |check inter 60s fastinter 5s downinter 8s rise 3 fall 2|
|TAG_CONTAINS_$NUM    |  NO      |          |             |
|TAG_REGEX_$NUM       |  NO      |          |             |

### HAProxy

| Variable        | Required | Default  | Description |
|-----------------|----------|----------|-------------|
|HAPROXY_STATS    |  No      | None     |             |
|HAPROXY_BALANCE  |  No      |roundrobin|             |
|HAPROXY_LOG      |  No      |127.0.0.1 local0|             |
|HAPROXY_EXPORTER |  No      | None     |             |

### Debugging

| Variable          | Required | Default | Description |
|-------------------|----------|---------|-------------|
| LOG_LEVEL         |  No      | INFO    |             |

## Running tests

```bash
# Build image
make build
# Run tests (and try to do clean up)
make tests
# Run tests (leave images in docker and don't do clean up)
make tests-debug
```

## TODO

* Implement CI pipeline
* PR
  * build and push image
  * run test
* Master
  * build and push image
  * run test
  * do api quai.io
* Every day
  * Run Security check

* HAProxy
  * Enable default option for type of backedend TCP/HTTP
  * Draining connection
