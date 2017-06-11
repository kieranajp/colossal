# Colossal

A base image based on Alpine that utilizes the autopilot pattern with client side load balancing.

## Why ?
Missing gap between packing "Docker image" and service orchestration. Autopilot pattern is concerned about application life cycle. Colossal is an opinionated implementation of container pilot.

## Colossal components

Colossal is based on Alpine linux and is packaged with
* [container-pilot](https://github.com/joyent/containerpilot/)
* [Consul](https://www.consul.io/)
* [Consul-template](https://github.com/hashicorp/consul-template)
* [HA-proxy](http://www.haproxy.org/)
* [resu](https://github.com/ben--/resu/)

## Events

## Load balancing

Colossal

## Users


### Custom script

You can add custom scripts that will be executed if they exists and are executable.

| Location          | Description |
|-------------------|-------------|
| /hooks/prestart   | Runs before app start |
| /hooks/preChange  | Runs after watcher change and before HAproxy reload  |
| /hooks/postChange | Runs after watcher change and after HAproxy reload  |
| /hooks/prestop    | Runs before stopping the app |
| /hooks/stop       | Runs to stop the app if not provided it will be killed by container pilot |
| /hooks/postStop   | Runs after stopping the app |

## Variables

#### APP variables
| Variable          | Required | Default | Description |
|-------------------|----------|---------|-------------|
|APP_NAME           |  YES     | None    |             |
|APP_EXEC           |  YES     | None    |             |
|APP_PORT           |  YES     | None    |             |
|APP_POLL           |  NO      | None    |             |
|APP_TAGS           |  NO      | None    |             |
|APP_RESTARTS       |  NO      | 10      |             |
|APP_HEALTH_EXEC    |  NO      | None    |             |
|APP_INTERFACES     |  NO      | None    |             |
|APP_HEALTH_TTL     |  NO      | 25      |             |
|APP_HEALTH_INTERVAL|  NO      | 10      |             |
|APP_HEALTH_TIMEOUT |  No      | 5       |             |

#### Consul variables
| Variable          | Required | Default | Description |
|-------------------|----------|---------|-------------|
| CONSUL            |  No      |127.0.0.1|             |
| CONSUL_ENCRYPT    |  Yes     | None    |without the '==' at the end|
| CONSUL_DATACENTER |  No      | dc1     |              |

#### Service dependency
| Variable            | Required | Default  | Description |
|---------------------|----------|----------|-------------|
|SERVICE_NAME_$NUM    |  NO      |          |             |
|SERVICE_PORT_$NUM    |  NO      |          |             |
|SERVICE_MODE_$NUM    |  NO      |  http    |             |
|SERVICE_BALANCE_$NUM |  NO      |roundrobin|             |
|SERVICE_OPTIONS_$NUM |  NO      |          |check inter 60s fastinter 5s downinter 8s rise 3 fall 2|
|TAG_CONTAINS_$NUM    |  NO      |          |             |
|TAG_REGEX_$NUM       |  NO      |          |             |

#### HAProxy
| Variable        | Required | Default  | Description |
|-----------------|----------|----------|-------------|
|HAPROXY_STATS    |  No      | None     |             |
|HAPROXY_BALANCE  |  No      |roundrobin|             |
|HAPROXY_EXPORTER |  No      | None     |             |


#### Debugging
| Variable          | Required | Default | Description |
|-------------------|----------|---------|-------------|
| LOG_LEVEL         |  No      | INFO    |             |


## TODO

Add support for application config consul-template