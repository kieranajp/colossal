#!/bin/sh

## Defines version of resu, CONTAINER PILOT, CONSUL and CONSUL TEMPLATE
## versions are defined packages.json

# Releases at https://github.com/joyent/containerpilot/releases
CONTAINERPILOT_VERSION  := $(shell cat packages.json | grep "CONTAINERPILOT_VERSION" | cut -f2 -d: | cut -d '"' -f2 )
CONTAINERPILOT_CHECKSUM := $(shell cat packages.json | grep "CONTAINERPILOT_CHECKSUM" | cut -f2 -d: | cut -d '"' -f2 )
# Releases at https://releases.hashicorp.com/consul
CONSUL_VERSION  := $(shell cat packages.json | grep "CONSUL_VERSION" | cut -f2 -d: | cut -d '"' -f2 )
CONSUL_CHECKSUM := $(shell cat packages.json | grep "CONSUL_CHECKSUM" | cut -f2 -d: | cut -d '"' -f2 )
# Releases at https://releases.hashicorp.com/consul-template/
CONSUL_TEMPLATE_VERSION  := $(shell cat packages.json | grep "CONSUL_TEMPLATE_VERSION" | cut -f2 -d: | cut -d '"' -f2 )
CONSUL_TEMPLATE_CHECKSUM := $(shell cat packages.json | grep "CONSUL_TEMPLATE_CHECKSUM" | cut -f2 -d: | cut -d '"' -f2 )
# Releases at https://github.com/ben--/resu/releases
RESU_VERSION  := $(shell cat packages.json | grep "RESU_VERSION" | cut -f2 -d: | cut -d '"' -f2 )
RESU_CHECKSUM := $(shell cat packages.json | grep "RESU_CHECKSUM" | cut -f2 -d: | cut -d '"' -f2 )
# Releases at https://github.com/prometheus/haproxy_exporter/releases
PROMETHEUS_HAPROXY_VERSION	:= $(shell cat packages.json | grep "PROMETHEUS_HAPROXY_VERSION" | cut -f2 -d: | cut -d '"' -f2 )
PROMETHEUS_HAPROXY_CHECKSUM := $(shell cat packages.json | grep "PROMETHEUS_HAPROXY_CHECKSUM" | cut -f2 -d: | cut -d '"' -f2 )
