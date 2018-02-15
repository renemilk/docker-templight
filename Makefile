
THISDIR=$(dir $(lastword $(MAKEFILE_LIST)))

.PHONY: push all $(REPONAMES) readme

check_client:
	@$(DOCKER_SUDO) docker info > /dev/null  || \
	  (echo "cannot connect to docker client. export DOCKER_SUDO=sudo ?" ; exit 1)

build: check_client
	$(eval GITREV=$(shell git describe --tags --dirty --always --long))
	$(eval IMAGE=templight)
	$(eval REPO=renemilk/$(IMAGE))
	$(DOCKER_SUDO) docker build --rm=true --force-rm=true ${DOCKER_QUIET} -t $(REPO):$(GITREV) .
	$(DOCKER_SUDO) docker tag $(REPO):$(GITREV) $(REPO):latest

push:
	$(DOCKER_SUDO) docker push renemilk/templight

all: build

.DEFAULT_GOAL := all
