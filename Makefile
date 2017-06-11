MAKEFLAGS += --warn-undefined-variables
.DEFAULT_GOAL := build
PHONY: all build test push push_latest clean
include ./packages.mk

NAME	   := quay.io/ahelal/colossal
VERSION    := $(shell cat VERSION)
BUILD_ARGS :=  --build-arg VERSION=${VERSION} \
  			   --build-arg CONTAINERPILOT_VERSION=${CONTAINERPILOT_VERSION} \
			   --build-arg CONTAINERPILOT_CHECKSUM=${CONTAINERPILOT_CHECKSUM} \
			   --build-arg CONSUL_VERSION=${CONSUL_VERSION} \
			   --build-arg CONSUL_CHECKSUM=${CONSUL_CHECKSUM} \
			   --build-arg CONSUL_TEMPLATE_VERSION=${CONSUL_TEMPLATE_VERSION} \
			   --build-arg CONSUL_TEMPLATE_CHECKSUM=${CONSUL_TEMPLATE_CHECKSUM} \
			   --build-arg RESU_VERSION=${RESU_VERSION} \
			   --build-arg RESU_CHECKSUM=${RESU_CHECKSUM} \
			   --build-arg PROMETHEUS_HAPROXY_VERSION=${PROMETHEUS_HAPROXY_VERSION} \
			   --build-arg PROMETHEUS_HAPROXY_CHECKSUM=${PROMETHEUS_HAPROXY_CHECKSUM}
M = $(shell printf "\033[34;1m▶\033[0m")

all: build

build:
	$(info $(M) Building ${NAME}:${VERSION}…)
	@docker build ${BUILD_ARGS} --squash -t ${NAME}:${VERSION} -f Dockerfile .

check_build:

ifeq ($(docker images $(NAME) | awk '{print $$2 }' | grep $(VERSION)), "$(VERSION)")
	$(info $(M) $(NAME) $(VERSION) is not yet built. Please run 'make build')
	false
endif

tests: check_build
	@docker tag $(NAME):$(VERSION) $(NAME):dev
	$(info $(M) Running tests for $(NAME) $(VERSION) )
	@./test/run_tests.sh tests

tests-debug: check_build
	@docker tag $(NAME):$(VERSION) $(NAME):dev
	$(info $(M) Running tests-debug for $(NAME) $(VERSION) )
	@./test/run_tests.sh tests-debug

push:
	$(info $(M) Pushing $(NAME):$(VERSION) )
	@docker push "${NAME}:${VERSION}"

push_latest:
	$(info $(M) Linking latest to $(NAME):$(VERSION) and pushing tag latest )
	docker tag $(NAME):$(VERSION) $(NAME):latest
	docker push "${NAME}:${VERSION}"

clean:
	$(info $(M) Cleaning)
	bundle exec kitchen destroy

clean_all:
	$(info $(M) Cleaning all)
	bundle exec kitchen destroy

ifeq ($(shell docker images $(NAME) | awk '{print $$2 }' | grep "$(VERSION)"), $(VERSION))
	$(info $(M) Removing image $(NAME):$(VERSION) from cache)
	docker rmi "${NAME}:${VERSION}"
endif

ifeq ($(shell docker images $(NAME) | awk '{print $$2 }' | grep "dev"), dev)
	$(info $(M) Removing image $(NAME):dev from cache)
	docker rmi "${NAME}:dev"
endif

ifeq ($(shell docker images $(NAME) | awk '{print $$2 }' | grep "latest"), latest)
	$(info $(M) Removing image $(NAME):latest from cache)
	docker rmi "${NAME}:latest"
endif

#docker rmi $(docker images --filter "dangling=true" -q --no-trunc)
# ifeq ($(shell docker images "consul" | awk '{print $$2 }' | grep "latest"), latest)
# 	$(info $(M) Removing image consul:latest from cache)
# 	docker rmi "consul:latest"
# endif
