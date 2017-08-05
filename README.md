[![Docker Repository on Quay](https://quay.io/repository/ahelal/colossal/status "Docker Repository on Quay")](https://quay.io/repository/ahelal/colossal)
# Colossal

A Docker image based on Alpine that utilizes the autopilot pattern with client side load balancing.

## Rationale

We believe there is a gap to be filled between packing a "Docker image" and service orchestration. The Autopilot pattern is concerned with application life cycle. Colossal is an opinionated implementation of all of the above, using container pilot.

## Overview

* Full power of PID 1, with full reaping powers
* Application life cycle: allows hooking custom scripts up to events
* Announce the running application to Consul
* Client-Side Load Balancing & Service Discovery for your external dependencies
* Templates for application configuration
* Secret injection into your application configuration (currently only Vault is supported)
* Aggregation of stdout and stderr logs
* Telemetry support

## Example Docker file

```Dockerfile
FROM quay.io/ahelal/colossal:latest

# Application will be announced to Consul as "pilot-app"
ENV APP_NAME          "pilot-app"
ENV APP_PORT          8080
# Tags to be announced in Consul
ENV APP_TAGS          "pilot-app,v1.1.1"
# Command to run our application. We will run it as app user
ENV APP_EXEC          resu app:app -- /app
# Health check config for Consul
ENV APP_HEALTH_EXEC   "curl -fsSo /dev/null http://127.0.0.1:8080"
# Attempts to restart the process if it exists
ENV APP_RESTARTS      2

# Our Application
COPY app /
# Add pre-start hook (Run this script before running our application)
COPY preStart.sh /hooks/preStart

# First service dependency (watcher) Redis
ENV SERVICE_NAME_1   "pilot-redis"
ENV SERVICE_PORT_1   "6379"
ENV SERVICE_MODE_1   "tcp"

# Second service dependency (watcher) HTTP application
ENV SERVICE_NAME_2   "pilot-cabincrew"
ENV SERVICE_PORT_2   "8000"

# HAproxy expose stats page and use Prometheus HAProxy exporter
ENV HAPROXY_STATS     True
ENV HAPROXY_EXPORTER  True
```

```sh
docker run -d -t -e CONSUL=consul.example.com -e CONSUL_ENCRYPT=cg8StVXbQJ0gPvMd9o7yrg myapp
```

For more info, check the supported [variables](#variables) and [hooks](#hooks).

## Colossal components

Colossal is based on Alpine Linux and is packaged with:

* [container-pilot](https://github.com/joyent/containerpilot/)
* [Consul](https://www.consul.io/)
* [Consul-template](https://github.com/hashicorp/consul-template)
* [HA-proxy](http://www.haproxy.org/)
* [resu](https://github.com/ben--/resu/)

See here for a list of [components' versions](packages.mk).

## Users

It is recommended to run as non root user when possible even in docker.
The following users are available for isolation:

* **consul**
* **haproxy**
* **app** (it's recommended to run your application as this user)

## Service discovery and client side load balancing

> A *Consul* server must be set up before using this feature. This is beyond the scope of Colossal. Head to [Consul](https://www.consul.io) for more information.

This is an opinionated way to do service discovery, inspired by the almighty SmartStack from AirBnB.

Each service is divided into a *Consumer* and a *Producer*.

Take the following stack as an example. Each service will run in its own container.

* A web HTTP Application, `blog`
* NGiNX acting as a reverse proxy, `nginx`
* A PostgreSQL database, `db`

Breaking this down to consumers and producers:

* `db` requires nothing; therefore `db` consumes *nothing* and produces `db`
* `blog` requires `db`; therefore `blog` consumes `db` and produces `blog`
* `nginx` requires `blog`; therefore `nginx` consumes `blog` and produces `nothing` (since nginx will be our edge server and will not be consumed by internal services)

### Producer

A producer is a service that will be announced on a specific Address/TCP port via Consul. In Colossal, you can only announce one service per container. Of course it's possible to have multiple instances of that service.

Components of a producer:

* The application (e.g. blog)
* Consul-agent (packaged with Colossal)

In order to know whether a producer is healthy, the consul agent performs health checks. If these fail the service is de-registered. The health check is a command to be executed every interval inside the container by consul-agent. This could be a simple `curl localhost:8080` or (better) implement a custom health endpoint that will return 200 if all is okay. 

You can also write a script to check connection to a service, and exits with a non-zero exit code if something is wrong.

```bash
#!/bin/sh
set -e
pg_isready -h localhost -p 5433
psql -c 'SELECT * FROM sometable WHERE SOMETHING = 1'
```

### Consumer

All the magic happens on the consumer. Consumers are responsible for making your services' dependencies available to use, transparently to your application.

Components of a consumer:

* You application (e.g. `nginx`)
* Consul-agent (packaged with Colossal)
* Consul-template (packaged with Colossal)
* HAProxy (packaged with Colossal)

Service dependencies ("watchers") are defined declaratively. `consul-agent` then reads the service metadata ("address/ports") and passes that to `consul-template`. This (re)writes the HAProxy configuration file and reloads HAProxy to reflect the changes. All the heavy lifting is left for HAProxy to handle and we get all the benefits of powerful load balancer plus loads of metrics and statistics and built-in health checks.

Your application will connect to `localhost:SERVICE_PORT` and HAProxy will take care of the rest.

### Service discovery overview

This approach to Service Discovery has the benefit of being decentralized and orchestrator agonistic, and offers a high level of visibility and flexibility. Performing debugging or maintenance on a backend is as simple as stopping the `consul-agent` process on the instance. You can also utilize the HAProxy status page, which lists all the backends available along with aggregate and per-request information.

The infrastructure is completely distributed. The most critical nodes are Consul, and if even higher availability is required HAProxy can be configured to avoid removing backends unless they are explicitly de-registered from Consul. This means that even if the Consul server fails, all backends stay up until you restore Consul server. Even during the downtime, HAProxy will remove unhealthy backends if they begin to misbehave.

## Assumptions about your application

* Application is network based and exposes a single TCP port
* Application can handle sigTERM in preparation for a shutdown and performs appropriate cleanup
* Application has circuit breakers for its dependencies, and retries at least a couple of times before giving up

## Events

Colossal is designed with a predefined Application lifecycle. The entry point is `/bin/containerpilot`, which also acts as PID 1.

![Flow](https://user-images.githubusercontent.com/4069495/28960738-1930b26a-7900-11e7-8c60-b5cb1f00e5f2.png)

### Built in hooks

* [`changed-script`](hooks/changed-script.sh): If you use watchers, downstream changes in a service (new services registered, health status change, or simply goes away) will trigger `consul-template` to re-configure HAProxy to reflect the updated services.
* [`consul-leave`](bin/consul-leave.sh): When `consul-agent` is stopping, _before it quits_ this script will run and attempt to de-register the agent, containerpilot, and the service.
* [`term`](bin/term.sh): In the event that `preStart`, `renderConfig`, `configENV` or `Application` fail, `term` will kick in to send a TERM signal to containerpilot to simply kill the container. In some cases that might not be desired, in which case a guard file can be used.

### Hooks

You can add custom scripts to be triggered when a certain event occurs. Like Git hooks, these will be executed if they exist and are marked executable.

| Location                 | Description                                         |
|--------------------------|-----------------------------------------------------|
| /hooks/preStart          | Runs before app start                               |
| /hooks/renderConfigFiles | Generate config files                               |
| /hooks/configENV.ctmpl   | A consul-template file formated in KEY=VALUE        |
| /hooks/preChange         | Runs after watcher change and before HAproxy reload |
| /hooks/postChange        | Runs after watcher change and after HAproxy reload  |
| /hooks/preStop           | Runs before stopping the app                        |
| /hooks/postStop          | Runs after stopping the app                         |

### Application configuration

You can configure your application in various ways depending on your use case. Aside from the obvious (*pre packaged static files* or *environment variables*), Colossal exposes two methods via hooks.

**renderConfigFiles**: Add a script that renders your configuration before application start. For example, let's take a simple NGiNX config:

```sh
#!/bin/sh
/usr/local/bin/consul-template \
    -consul-addr localhost:8500  \
    -once \
    -dedup \
    -template "/etc/nginx_template.conf.ctmpl:/etc/nginx/conf.d/default.conf"
```

```Nginx
server {
        listen 8888 default_server;
        location / {
            proxy_pass http://127.0.0.1:{{ env "SERVICE_PORT_1" }};
        }
}
```

The benefit of this approach is that it allows use of the power of consul-template with Consul key/value store and vault.

**configENV.ctmpl**: If your application does not support configuration files you can use environment variables. Sometimes you don't want to pass the variables via `-e PASSWORD=SUPERSECUREPASSWORD`, so this approach uses configENV.ctmpl in the format of key=value.

```sh
# Static declaration
MYPILOT_ENV_CONF=Production
MYSQL_HOST="localhost:3306"
# USE AWS SSM
MYPILOT_PASSWORD={{ plugin "ssm" "TEST_PARAM_VALUE" }}
# Use KV from consul
MYSQL_DB="{{ key "MYSQL_DB" }}"
MYSQL_DB="{{ key "MYSQL_USERNAME" }}"
# Use vault
{{ with secret "secret/database/" }}
MYSQL_PASSWORD={{ .MYSQL_PASSWORD }}{{ end }}
```

These variables will be injected into container pilot and made available to the application process.

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
|APP_RESTARTS       |  NO      | 0      | Number of times the process will be restarted if it exits. This field supports any non-negative numeric value (ex. 0 or 1) or the strings "unlimited" or "never"|
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
| CONSUL_CONFIG_FILE|  No      |         | Path to optional consul config file |

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
|HAPROXY_LOG      |  No      |127.0.0.1 local0|       |
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
