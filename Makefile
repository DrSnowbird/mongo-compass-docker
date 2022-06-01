# -------------------------------------------------------------------------------------------------------
# login first (Registry: e.g., hub.docker.io, registry.localhost:5000, etc.)
# a.)  docker login
# or
# b.) sudo docker login -p FpXM6Qy9vVL5kPeoefzxwA-oaYb-Wpej2iXTwV7UHYs -e unused -u unused docker-registry-default.openkbs.org
# e.g. (using Openshift)
#    oc process -f ./files/deployments/template.yml -v API_NAME=$(REGISTRY_IMAGE) > template.active
#
# to run:
# make <verb> [ APP_VERSION=<...> DOCKER_NAME=<...> REGISTRY_HOST=<...> ]
# example:
#   make build
#   make up
#   make down
# -------------------------------------------------------------------------------------------------------

SHELL := /bin/bash

BASE_IMAGE := $(BASE_IMAGE)

## -- To Check syntax:
#  cat -e -t -v Makefile

# The name of the container (default is current directory name)
#DOCKER_NAME := $(shell echo $${PWD\#\#*/})
DOCKER_NAME := $(shell echo $${PWD\#\#*/}|tr '[:upper:]' '[:lower:]'|tr "/: " "_" )

ORGANIZATION=$(shell echo $${ORGANIZATION:-openkbs})
APP_VERSION=$(shell echo $${APP_VERSION:-latest})
imageTag=$(ORGANIZATION)/$(DOCKER_NAME)

## Docker Registry (Private Server)
REGISTRY_HOST=
#REGISTRY_HOST=$(shell echo $${REGISTRY_HOST:-localhost:5000})
REGISTRY_IMAGE=$(REGISTRY_HOST)/$(ORGANIZATION)/$(DOCKER_NAME)

#VERSION?="$(APP_VERSION)-$$(date +%Y%m%d)"
VERSION?="$(APP_VERSION)"

## -- Uncomment this to use local Registry Host --
DOCKER_IMAGE := $(ORGANIZATION)/$(DOCKER_NAME)

## -- To Check syntax:
#  cat -e -t -v Makefile

# -- example --
#VOLUME_MAP := "-v $${PWD}/data:/home/developer/data -v $${PWD}/workspace:/home/developer/workspace"
VOLUME_MAP := 

# -- Local SAVE of image --
IMAGE_EXPORT_PATH := "$${PWD}/archive"

# { no, on-failure, unless-stopped, always }
RESTART_OPTION := always

SHA := $(shell git describe --match=NeVeRmAtCh --always --abbrev=40 --dirty=*)

TIME_START := $(shell date +%s)

.PHONY: clean rmi build push pull up down run stop exec

clean:
	$(DOCKER_NAME) $(DOCKER_IMAGE):$(VERSION) 

default: build

build-time:
	docker build \
	--build-arg BASE_IMAGE="$(BASE_IMAGE)" \
	--build-arg CIRCLE_SHA1="$(SHA)" \
	--build-arg version=$(VERSION) \
	--build-arg VCS_REF=`git rev-parse --short HEAD` \
	--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
	-t $(DOCKER_IMAGE):$(VERSION) .

build-rm:
	docker build --force-rm --no-cache \
		-t $(DOCKER_IMAGE):$(VERSION) .

build:
	docker build \
	    -t $(DOCKER_IMAGE):$(VERSION) .
	docker images | grep $(DOCKER_IMAGE)
	@echo ">>> Total Dockder images Build using time in seconds: $$(($$(date +%s)-$(TIME_START))) seconds"

push:
	docker commit -m "$comment" ${containerID} ${imageTag}:$(VERSION)
	docker push $(DOCKER_IMAGE):$(VERSION)

	docker tag $(imageTag):$(VERSION) $(REGISTRY_IMAGE):$(VERSION)
	#docker tag $(imageTag):latest $(REGISTRY_IMAGE):latest
	docker push $(REGISTRY_IMAGE):$(VERSION)
	#docker push $(REGISTRY_IMAGE):latest
	@if [ ! "$(IMAGE_EXPORT_PATH)" = "" ]; then \
		mkdir -p $(IMAGE_EXPORT_PATH); \
		docker save $(REGISTRY_IMAGE):$(VERSION) | gzip > $(IMAGE_EXPORT_PATH)/$(DOCKER_NAME)_$(VERSION).tar.gz; \
	fi
	
pull:
	@if [ "$(REGISTRY_HOST)" = "" ]; then \
		docker pull $(DOCKER_IMAGE):$(VERSION) ; \
	else \
		docker pull $(REGISTRY_IMAGE):$(VERSION) ; \
	fi

## -- deployment mode (daemon service): -- ##
up:
	bin/auto-config-all.sh
	docker-compose up -d
	docker ps | grep $(DOCKER_IMAGE)
	@echo ">>> Total Dockder images Build using time in seconds: $$(($$(date +%s)-$(TIME_START))) seconds"

down:
	docker-compose down
	docker ps | grep $(DOCKER_IMAGE)
	@echo ">>> Total Dockder images Build using time in seconds: $$(($$(date +%s)-$(TIME_START))) seconds"

down-rm:
	docker-compose down -v --rmi all --remove-orphans
	docker ps | grep $(DOCKER_IMAGE)
	@echo ">>> Total Dockder images Build using time in seconds: $$(($$(date +%s)-$(TIME_START))) seconds"

## -- dev/debug -- ##
run:
	bin/auto-config-all.sh
	./run.sh
	docker ps | grep $(DOCKER_IMAGE)
	
#docker run --name=$(DOCKER_NAME) --restart=$(RESTART_OPTION) $(VOLUME_MAP) $(DOCKER_IMAGE):$(VERSION)

stop:
	docker stop --name=$(DOCKER_NAME)

status:
	docker ps | grep $(DOCKER_NAME)

rmi:
	docker rmi $$(docker images -f dangling=true -q)

exec:
	docker-compose exec $(DOCKER_NAME) /bin/bash
