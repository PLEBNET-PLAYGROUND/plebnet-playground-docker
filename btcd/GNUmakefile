SHELL := /bin/bash

PWD 									?= pwd_unknown

THIS_FILE								:= $(lastword $(MAKEFILE_LIST))
export THIS_FILE
TIME									:= $(shell date +%s)
export TIME

ARCH                                    :=$(shell uname -m)
export ARCH
ifeq ($(ARCH),x86_64)
ARCH                                    :=x86_64-linux-gnu
export ARCH
endif
ifeq ($(ARCH),arm64)
ARCH                                    :=aarch64-linux-gnu
export ARCH
endif

ifeq ($(user),)
HOST_USER								:= root
HOST_UID								:= $(strip $(if $(uid),$(uid),0))
else
HOST_USER								:=  $(strip $(if $(USER),$(USER),nodummy))
HOST_UID								:=  $(strip $(if $(shell id -u),$(shell id -u),4000))
endif
export HOST_USER
export HOST_UID

ifeq ($(target),)
SERVICE_TARGET							?= shell
else
SERVICE_TARGET							:= $(target)
endif
export SERVICE_TARGET

ifeq ($(docker),)
DOCKER							        := $(shell which docker)
else
DOCKER   							    := $(docker)
endif
export DOCKER

ifeq ($(compose),)
DOCKER_COMPOSE						    := $(shell which docker-compose)
else
DOCKER_COMPOSE							:= $(compose)
endif
export DOCKER_COMPOSE

# PROJECT_NAME defaults to name of the current directory.
ifeq ($(project),)
PROJECT_NAME							:= $(notdir $(PWD))
else
PROJECT_NAME							:= $(project)
endif
export PROJECT_NAME

ifeq ($(nocache),true)
NOCACHE					     			:= --no-cache
else
NOCACHE						    		:=	
endif
export NOCACHE

ifeq ($(verbose),true)
VERBOSE									:= --verbose
else
VERBOSE									:=	
endif
export VERBOSE

#TODO more umbrel config testing
ifeq ($(port),)
PUBLIC_PORT								:= 80
else
PUBLIC_PORT								:= $(port)
endif
export PUBLIC_PORT

ifeq ($(nodeport),)
NODE_PORT								:= 8333
else
NODE_PORT								:= $(nodeport)
endif
export NODE_PORT

ifeq ($(cmd),)
CMD_ARGUMENTS							:= 	
else
CMD_ARGUMENTS							:= $(cmd)
endif
export CMD_ARGUMENTS

.PHONY: help
help:
	@echo ''
	@echo '	[USAGE]: make [COMMAND] [EXTRA_ARGUMENTS]	'
	@echo ''
	@echo '		 make btcd'
	@echo ''
	@echo '	[DOCKER COMMANDS]:	push a command to the container	'
	@echo ''
	@echo '		cmd=command 	'
	@echo '		cmd="command"	'
	@echo '		             	send CMD_ARGUMENTS to the [TARGET]'
	@echo ''
	@echo '	[EXAMPLES]:'
	@echo ''
	@echo '		make btcd no-cache=true verbose=true'
	@echo '	'

.PHONY: report
report:
	@echo ''
	@echo '	[ARGUMENTS]	'
	@echo '      args:'
	@echo '        - HOME=${HOME}'
	@echo '        - PWD=${PWD}'
	@echo '        - ARCH=${ARCH}'
	@echo '        - HOST_USER=${HOST_USER}'
	@echo '        - HOST_UID=${HOST_UID}'
	@echo '        - PUBLIC_PORT=${PUBLIC_PORT}'
	@echo '        - NODE_PORT=${NODE_PORT}'
	@echo '        - SERVICE_TARGET=${SERVICE_TARGET}'
	@echo '        - PROJECT_NAME=${PROJECT_NAME}'
	@echo '        - BITCOIN_CONF=${BITCOIN_CONF}'
	@echo '        - BITCOIN_DATA_DIR=${BITCOIN_DATA_DIR}'
	@echo '        - PUBLIC_PORT=${PUBLIC_PORT}'
	@echo '        - NODE_PORT=${NODE_PORT}'
	@echo '        - PASSWORD=${PASSWORD}'
	@echo '        - CMD_ARGUMENTS=${CMD_ARGUMENTS}'

#######################

BTCD_DATADIR:=$(PWD)/volumes/btcd_datadir
export BTCD_DATADIR

.PHONY: btcd
btcd:
	bash -c "mkdir -p $(PWD)/volumes/btcd_datadir"
	bash -c "cat btcd.conf > $(PWD)/volumes/btcd_datadir/btcd.conf"
	docker build --no-cache --build-arg BTCD_DATADIR=$(BTCD_DATADIR) .
ifeq ($(CMD_ARGUMENTS),)
	$(DOCKER_COMPOSE) $(VERBOSE) -p $(PROJECT_NAME)_$(HOST_UID) run --rm btcd &
else
	$(DOCKER_COMPOSE) $(VERBOSE) -p $(PROJECT_NAME)_$(HOST_UID) run --rm btcd sh -c "$(CMD_ARGUMENTS)"
endif

