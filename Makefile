MAKEFLAGS += --warn-undefined-variables
.DEFAULT_GOAL := build
PHONY: all build test push push-latest clean
include ./packages.mk

NAME	   := quay.io/ahelal/colossal
VERSION    := $(shell cat VERSION)
BUILD_ARGS :=  	--build-arg VERSION=${VERSION} \
				--build-arg CONTAINERPILOT_VERSION=${CONTAINERPILOT_VERSION} --build-arg CONTAINERPILOT_CHECKSUM=${CONTAINERPILOT_CHECKSUM} \
				--build-arg CONSUL_VERSION=${CONSUL_VERSION} --build-arg CONSUL_CHECKSUM=${CONSUL_CHECKSUM} \
				--build-arg CONSUL_TEMPLATE_VERSION=${CONSUL_TEMPLATE_VERSION} --build-arg CONSUL_TEMPLATE_CHECKSUM=${CONSUL_TEMPLATE_CHECKSUM} \
				--build-arg RESU_VERSION=${RESU_VERSION} --build-arg RESU_CHECKSUM=${RESU_CHECKSUM} \
				--build-arg PROMETHEUS_HAPROXY_VERSION=${PROMETHEUS_HAPROXY_VERSION} --build-arg PROMETHEUS_HAPROXY_CHECKSUM=${PROMETHEUS_HAPROXY_CHECKSUM} \
				--build-arg CONSUL_TEMPLATE_PLUGIN_SSM_VERSION=${CONSUL_TEMPLATE_PLUGIN_SSM_VERSION} \
				--build-arg CONSUL_TEMPLATE_PLUGIN_SSM_CHECKSUM=${CONSUL_TEMPLATE_PLUGIN_SSM_CHECKSUM}

M = $(shell printf "\033[34;1m▶\033[0m")
# Default to PR  can be overwriten from command line
CI_LABEL = pr

all: build

start-consul:
ifneq ($(shell docker ps | grep "pilot-consul" | awk '{ print $$15 }'), pilot-consul)
	$(info $(M) Running consul)
	@docker run -d --rm -p 8500:8500 -e CONSUL_BIND_INTERFACE=eth0 --name pilot-consul consul:latest
endif

build:
	$(info $(M) Building ${NAME}:${VERSION}, ${NAME}:${CI_LABEL} and ${NAME}:dev …)
	@docker build ${BUILD_ARGS} -t ${NAME}:${CI_LABEL} -t ${NAME}:${VERSION} -t ${NAME}:dev -f Dockerfile .

squash:
	# requires docker-squash https://github.com/goldmann/docker-squash
	$(info $(M) Squashing ${NAME}:${VERSION} and ${NAME}:dev …)
	@docker-squash -t ${NAME}:${VERSION} ${NAME}:${VERSION}
	@docker tag $(NAME):$(VERSION) $(NAME):dev
	@docker tag $(NAME):$(VERSION) $(NAME):${CI_LABEL}

check-build:
ifeq ($(docker images $(NAME) | awk '{print $$2 }' | grep $(VERSION)), "$(VERSION)")
	$(info $(M) $(NAME) $(VERSION) is not yet built. Please run 'make build')
	false
endif

tests: start-consul check-build
	$(info $(M) Running tests for $(NAME):dev)
	@bundle exec kitchen destroy
	@bundle exec kitchen converge
	@echo "Sleeping for 30 seconds .."
	@/bin/sleep 30
	@bundle exec kitchen verify
	@bundle exec kitchen destroy
	@./test/functions.sh stop-container pilot-consul

tests-debug: start-consul check-build
	@docker tag $(NAME):$(VERSION) $(NAME):dev
	$(info $(M) Running tests for $(NAME) $(VERSION))
	@bundle exec kitchen converge
	$(info $(M) Sleeping for 30)
	@/bin/sleep 30
	@bundle exec kitchen verify
	@bundle exec kitchen destroy
	@./test/functions.sh stop-container pilot-consul

push:
	$(info $(M) Pushing $(NAME):$(VERSION) )
	@docker tag $(NAME):dev $(NAME):$(VERSION)
	@docker push "${NAME}:${VERSION}"

push-label:
	$(info $(M) Pushing $(NAME):${CI_LABEL} )
	@docker push "${NAME}:${CI_LABEL}"

push-latest:
	$(info $(M) Linking latest to $(NAME):$(VERSION) and pushing tag latest )
	docker tag $(NAME):$(VERSION) $(NAME):latest
	docker push "${NAME}:latest"

clean:
	$(info $(M) Cleaning)
	@bundle exec kitchen destroy
	@./test/functions.sh stop-container pilot-consul

clean-all: clean
	$(info $(M) Cleaning all)
	@./test/functions.sh remove-image ${NAME} ${VERSION}
	@./test/functions.sh remove-image ${NAME} dev
	@./test/functions.sh remove-image ${NAME} latest
	@./test/functions.sh remove-image ${NAME} pr
	@./test/functions.sh remove-image consul latest
#docker rmi docker images -f "dangling=true" -q
