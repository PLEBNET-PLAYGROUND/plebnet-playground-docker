SHELL := /bin/bash

PWD 									?= pwd_unknown

THIS_FILE								:= $(lastword $(MAKEFILE_LIST))
export THIS_FILE
TIME									:= $(shell date +%s)
export TIME

ARCH                                    :=$(shell uname -m)
export ARCH
ifeq ($(ARCH),x86_64)
TRIPLET                                 :=x86_64-linux-gnu
export TRIPLET
endif
ifeq ($(ARCH),arm64)
TRIPLET                                 :=aarch64-linux-gnu
export TRIPLET
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

PYTHON                                  := $(shell which python)
export PYTHON
PYTHON3                                 := $(shell which python3)
export PYTHON3

PIP                                     := $(shell which pip)
export PIP
PIP3                                    := $(shell which pip3)
export PIP3

# PROJECT_NAME defaults to name of the current directory.
ifeq ($(project),)
PROJECT_NAME							:= $(notdir $(PWD))
else
PROJECT_NAME							:= $(project)
endif
export PROJECT_NAME

#GIT CONFIG
GIT_USER_NAME							:= $(shell git config user.name)
export GIT_USER_NAME
GIT_USER_EMAIL							:= $(shell git config user.email)
export GIT_USER_EMAIL
GIT_SERVER								:= https://github.com
export GIT_SERVER

GIT_REPO_NAME							:= $(PROJECT_NAME)
export GIT_REPO_NAME

#Usage
#make package-all profile=rsafier
#make package-all profile=asherp
#note on GH_TOKEN.txt file below
ifeq ($(profile),)
ifeq ($(GIT_REPO_ORIGIN),git@github.com:PLEBNET_PLAYGROUND/plebnet-playground-docker.dev.git)
GIT_PROFILE								:= PLEBNET-PLAYGROUND
endif
ifeq ($(GIT_REPO_ORIGIN),https://github.com/PLEBNET_PLAYGROUND/plebnet-playground-docker.dev.git)
GIT_PROFILE								:= PLEBNET-PLAYGROUND
endif
else
GIT_PROFILE								:= $(profile)
endif
export GIT_PROFILE

GIT_BRANCH								:= $(shell git rev-parse --abbrev-ref HEAD)
export GIT_BRANCH
GIT_HASH								:= $(shell git rev-parse --short HEAD)
export GIT_HASH
GIT_PREVIOUS_HASH						:= $(shell git rev-parse --short master@{1})
export GIT_PREVIOUS_HASH
GIT_REPO_ORIGIN							:= $(shell git remote get-url origin)
export GIT_REPO_ORIGIN
GIT_REPO_PATH							:= $(HOME)/$(GIT_REPO_NAME)
export GIT_REPO_PATH

ifneq ($(bitcoin-datadir),)
BITCOIN_DATA_DIR						:= $(bitcoin-datadir)
else
BITCOIN_DATA_DIR						:= $(HOME)/.bitcoin
endif
export BITCOIN_DATA_DIR

ifeq ($(nocache),true)
NOCACHE					     			:= --no-cache
#Force parallel build when --no-cache to speed up build
PARALLEL                                := --parallel
else
NOCACHE						    		:=	
PARALLEL                                :=
endif
export NOCACHE
export PARALLEL

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

ifneq ($(passwd),)
PASSWORD								:= $(passwd)
else 
PASSWORD								:= changeme
endif
export PASSWORD

ifeq ($(cmd),)
CMD_ARGUMENTS							:= 	
else
CMD_ARGUMENTS							:= $(cmd)
endif
export CMD_ARGUMENTS

#ifeq ($(umbrel),true)
##comply with umbrel conventions
#PWD=/home/umbrel/umbrel/apps/$(PROJECT_NAME)
#UMBREL=true
#else
#pwd ?= pwd_unknown
#UMBREL=false
#endif
#export PWD
#export UMBREL
########################

PACKAGE_PREFIX                          := ghcr.io
export PACKAGE_PREFIX

.PHONY: help
help:
	@echo ''
	@echo '	[USAGE]: make [COMMAND] [EXTRA_ARGUMENTS]	'
	@echo ''
	@echo ''
	@echo '		 make '
	@echo '		 make help             print help'
	@echo '		 make init             initialize basic dependencies'
	@echo '		 make report           print environment variables'
	@echo '		 make build'
	@echo '		 make run'
	@echo '		                       user=root uid=0 nocache=false verbose=false'
	@echo ''
	@echo '	[DEV ENVIRONMENT]:	'
	@echo ''
#	@echo '		 make shell            compiling environment on host machine'
	@echo '		 make signin           ~/GH_TOKEN.txt required from github.com'
#	@echo '		 make header package-header'
	@echo '		 make build'
#	@echo '		 make build package-statoshi'
	@echo '		 make package-all'
	@echo ''
#	@echo '	[EXTRA_ARGUMENTS]:	set build variables	'
#	@echo ''
#	@echo '		nocache=true'
#	@echo '		            	add --no-cache to docker command and apk add $(NOCACHE)'
#	@echo '		port=integer'
#	@echo '		            	set PUBLIC_PORT default 80'
#	@echo ''
#	@echo '		nodeport=integer'
#	@echo '		            	set NODE_PORT default 8333'
#	@echo ''
#	@echo '		            	TODO'
#	@echo ''
#	@echo '	[DOCKER COMMANDS]:	push a command to the container	'
#	@echo ''
#	@echo '		cmd=command 	'
#	@echo '		cmd="command"	'
#	@echo '		             	send CMD_ARGUMENTS to the [TARGET]'
	@echo ''
	@echo '	[EXAMPLES]:'
	@echo ''
	@echo '		make all run user=root uid=0 no-cache=true verbose=true'
	@echo '		make report all run user=root uid=0 no-cache=true verbose=true cmd="top"'
	@echo ''
	@echo '		make init && play help'
	@echo '	'

.PHONY: report
report:
	@echo ''
	@echo '	[ARGUMENTS]	'
	@echo '      args:'
	@echo '        - HOME=${HOME}'
	@echo '        - PWD=${PWD}'
	@echo '        - PYTHON=${PYTHON}'
	@echo '        - PYTHON3=${PYTHON3}'
	@echo '        - PIP=${PIP}'
	@echo '        - PIP3=${PIP3}'
	@echo '        - UMBREL=${UMBREL}'
	@echo '        - THIS_FILE=${THIS_FILE}'
	@echo '        - TIME=${TIME}'
	@echo '        - PACKAGE_PREFIX=${PACKAGE_PREFIX}'
	@echo '        - ARCH=${ARCH}'
	@echo '        - TRIPLET=${TRIPLET}'
	@echo '        - HOST_USER=${HOST_USER}'
	@echo '        - HOST_UID=${HOST_UID}'
	@echo '        - PUBLIC_PORT=${PUBLIC_PORT}'
	@echo '        - NODE_PORT=${NODE_PORT}'
	@echo '        - SERVICE_TARGET=${SERVICE_TARGET}'
	@echo '        - PROJECT_NAME=${PROJECT_NAME}'
	@echo '        - DOCKER_BUILD_TYPE=${DOCKER_BUILD_TYPE}'
	@echo '        - DOCKER_COMPOSE=${DOCKER_COMPOSE}'
	@echo '        - GIT_USER_NAME=${GIT_USER_NAME}'
	@echo '        - GIT_USER_EMAIL=${GIT_USER_EMAIL}'
	@echo '        - GIT_SERVER=${GIT_SERVER}'
	@echo '        - GIT_PROFILE=${GIT_PROFILE}'
	@echo '        - GIT_BRANCH=${GIT_BRANCH}'
	@echo '        - GIT_HASH=${GIT_HASH}'
	@echo '        - GIT_PREVIOUS_HASH=${GIT_PREVIOUS_HASH}'
	@echo '        - GIT_REPO_ORIGIN=${GIT_REPO_ORIGIN}'
	@echo '        - GIT_REPO_NAME=${GIT_REPO_NAME}'
	@echo '        - GIT_REPO_PATH=${GIT_REPO_PATH}'
	@echo '        - BITCOIN_CONF=${BITCOIN_CONF}'
	@echo '        - BITCOIN_DATA_DIR=${BITCOIN_DATA_DIR}'
	@echo '        - STATOSHI_DATA_DIR=${STATOSHI_DATA_DIR}'
	@echo '        - NOCACHE=${NOCACHE}'
	@echo '        - VERBOSE=${VERBOSE}'
	@echo '        - PUBLIC_PORT=${PUBLIC_PORT}'
	@echo '        - NODE_PORT=${NODE_PORT}'
	@echo '        - PASSWORD=${PASSWORD}'
	@echo '        - CMD_ARGUMENTS=${CMD_ARGUMENTS}'

#######################

ORIGIN_DIR:=$(PWD)
MACOS_TARGET_DIR:=/var/root/$(PROJECT_NAME)
LINUX_TARGET_DIR:=/root/$(PROJECT_NAME)
export ORIGIN_DIR
export TARGET_DIR

.PHONY: super
super:
ifneq ($(shell id -u),0)
	@echo switch to superuser
	@echo cd $(TARGET_DIR)
	#sudo ln -s $(PWD) $(TARGET_DIR)
#.ONESHELL:
	sudo -s
endif
.PHONY: init
init: report
ifneq ($(shell id -u),0)
	@echo 'sudo make init #try if permissions issue'
endif
	@echo 'init'
ifneq ($(shell id -u),0)
	sudo -s bash -c 'rm -f /usr/local/bin/play'
	sudo -s bash -c 'install -v $(PWD)/scripts/*  /usr/local/bin'
ifneq ($(PIP3),)
	$(PIP3) install -r requirements.txt
	$(PYTHON3) ./plebnet_generate.py TRIPLET=$(TRIPLET)
	pushd docs && $(PIP3) install -r requirements.txt && popd
else
	$(PIP) install -r requirements.txt
	$(PYTHON) ./plebnet_generate.py TRIPLET=$(TRIPLET)
	pushd docs && $(PIP) install -r requirements.txt && popd
endif
	
else
	        bash -c 'install -v $(PWD)/scripts/*  /usr/local/bin'
endif
#######################
.PHONY: install
install: init
	bash -c './install.sh $(TRIPLET)'
	#bash -c 'make btcd'
#######################
.PHONY: uninstall
uninstall:
	bash -c './uninstall.sh $(TRIPLET)'
#######################
.PHONY: run
run: docs init
	$(DOCKER_COMPOSE) $(VERBOSE) $(NOCACHE) up --remove-orphans &
#######################
.PHONY: build
build: init
	$(DOCKER_COMPOSE) $(VERBOSE) build $(PARALLEL) --no-rm $(NOCACHE)
#######################
.PHONY: btcd
btcd:
	bash -c "cd btcd && make btcd && cd .."
.PHONY: docs
docs:
	@echo "Use 'make docs nocache=true' to force docs rebuild..."
	install -v README.md docs/docs/index.md
	sed 's/images/.\/images/' README.md > docs/docs/index.md
	cp -R ./images ./docs/docs
	$(DOCKER_COMPOSE) $(VERBOSE) build $(NOCACHE) docs

#######################
#.PHONY: run
#run: build
#	@echo 'run'
#ifeq ($(CMD_ARGUMENTS),)
#	@echo '$(CMD_ARGUMENTS)'
#	$(DOCKER_COMPOSE) $(VERBOSE) -p $(PROJECT_NAME)_$(HOST_UID) run -d --publish $(PUBLIC_PORT):3000 --publish 8125:8125 --publish 8126:8126 --publish 8333:8333 --publish 8332:8332 statoshi sh
#	@echo ''
#else
#	@echo ''
#	$(DOCKER_COMPOSE) $(VERBOSE) -p $(PROJECT_NAME)_$(HOST_UID) run -d --publish $(PUBLIC_PORT):3000 --publish 8125:8125 --publish 8126:8126 --publish 8333:8333 --publish 8332:8332 statoshi sh -c "$(CMD_ARGUMENTS)"
#	@echo ''
#endif
#	@echo 'Give grafana a few minutes to set up...'
#	@echo 'http://localhost:$(PUBLIC_PORT)'
########################
.PHONY: extract
extract:
	@echo 'extract'
	#extract TODO CREATE PACKAGE for distribution
	sed '$d' $(DOCKERFILE) | sed '$d' | sed '$d' > $(DOCKERFILE_EXTRACT)
	docker build -f $(DOCKERFILE_EXTRACT) --rm -t $(DOCKERFILE_EXTRACT) .
	docker run --name $(DOCKERFILE_EXTRACT) $(DOCKERFILE_EXTRACT) /bin/true
	docker rm $(DOCKERFILE_EXTRACT)
	rm -f  $(DOCKERFILE_EXTRACT)
#######################
.PHONY: torproxy
torproxy:
	@echo ''
	#REF: https://hub.docker.com/r/dperson/torproxy
	#bash -c 'docker run -it -p 8118:8118 -p 9050:9050 -p 9051:9051 -d dperson/torproxy'
	@echo ''
ifneq ($(shell id -u),0)
	bash -c 'sudo make torproxy user=root &'
endif
ifeq ($(CMD_ARGUMENTS),)
	$(DOCKER_COMPOSE) $(VERBOSE) -f docker-compose.yml -p $(PROJECT_NAME)_$(HOST_UID) run --publish 8118:8118 --publish 9050:9050  --publish 9051:9051 --rm torproxy
else
	$(DOCKER_COMPOSE) $(VERBOSE) -f docker-compose.yml -p $(PROJECT_NAME)_$(HOST_UID) run --publish 8118:8118 --publish 9050:9050  --publish 9051:9051 --rm torproxy sh -c "$(CMD_ARGUMENTS)"
endif
	@echo ''
#######################
.PHONY: clean
clean:
	# remove created images
	@$(DOCKER_COMPOSE) -p $(PROJECT_NAME)_$(HOST_UID) down --remove-orphans --rmi all 2>/dev/null \
	&& echo 'Image(s) for "$(PROJECT_NAME):$(HOST_USER)" removed.' \
	|| echo 'Image(s) for "$(PROJECT_NAME):$(HOST_USER)" already removed.'
#######################
.PHONY: prune
prune:
	$(DOCKER_COMPOSE) -p $(PROJECT_NAME)_$(HOST_UID) down
	docker system prune -af
#######################
.PHONY: prune-network
prune-network:
	$(DOCKER_COMPOSE) -p $(PROJECT_NAME)_$(HOST_UID) down
	docker network prune -f
#######################
.PHONY: push
push:
	@echo 'push'
	#bash -c "git reset --soft HEAD~1 || echo failed to add docs..."
	#bash -c "git add README.md docker/README.md docker/DOCKER.md *.md docker/*.md || echo failed to add docs..."
	#bash -c "git commit --amend --no-edit --allow-empty -m '$(GIT_HASH)'          || echo failed to commit --amend --no-edit"
	#bash -c "git commit         --no-edit --allow-empty -m '$(GIT_PREVIOUS_HASH)' || echo failed to commit --amend --no-edit"
	bash -c "git push -f --all git@github.com:$(GIT_PROFILE)/$(PROJECT_NAME).git || echo failed to push docs"
	bash -c "git push -f --all git@github.com:bitcoincore-dev/statoshi.host.git || echo failed to push to statoshi.host"
.PHONY: push-docs
push-docs: statoshi-docs push
	@echo 'push-docs'

SIGNIN=randymcmillan
export SIGNIN

.PHONY: signin
signin:
#Place a file named GH_TOKEN.txt in your $HOME - create in https://github.com/settings/tokens (Personal access tokens)
	bash -c 'cat ~/GH_TOKEN.txt | docker login ghcr.io -u $(GIT_PROFILE) --password-stdin'
#######################
package-plebnet: signin

	#touch TIME && echo $(TIME) > TIME && git add -f TIME
	#legit . -m "make package-header at $(TIME)" -p 00000
	#git commit --amend --no-edit --allow-empty

	bash -c 'docker tag  $(PROJECT_NAME)_thunderhub   $(PACKAGE_PREFIX)/$(GIT_PROFILE)/$(PROJECT_NAME)/thunderhub-$(TRIPLET)/$(HOST_USER):$(TIME)'
	bash -c 'docker tag  $(PROJECT_NAME)_thunderhub   $(PACKAGE_PREFIX)/$(GIT_PROFILE)/$(PROJECT_NAME)/thunderhub-$(TRIPLET)/$(HOST_USER):$(TIME)'
	bash -c 'docker tag  $(PROJECT_NAME)_dashboard    $(PACKAGE_PREFIX)/$(GIT_PROFILE)/$(PROJECT_NAME)/dashboard-$(TRIPLET)/$(HOST_USER):$(TIME)'
	bash -c 'docker push                              $(PACKAGE_PREFIX)/$(GIT_PROFILE)/$(PROJECT_NAME)/dashboard-$(TRIPLET)/$(HOST_USER):$(TIME)'
	#bash -c 'docker tag  $(PROJECT_NAME)_notebook    $(PACKAGE_PREFIX)/$(GIT_PROFILE)/$(PROJECT_NAME)/notebook-$(TRIPLET)/$(HOST_USER):$(TIME)'
	#bash -c 'docker push                             $(PACKAGE_PREFIX)/$(GIT_PROFILE)/$(PROJECT_NAME)/notebook-$(TRIPLET)/$(HOST_USER):$(TIME)'
	bash -c 'docker tag  $(PROJECT_NAME)_bitcoind     $(PACKAGE_PREFIX)/$(GIT_PROFILE)/$(PROJECT_NAME)/bitcoind-$(TRIPLET)/$(HOST_USER):$(TIME)'
	bash -c 'docker push                              $(PACKAGE_PREFIX)/$(GIT_PROFILE)/$(PROJECT_NAME)/bitcoind-$(TRIPLET)/$(HOST_USER):$(TIME)'
	bash -c 'docker tag  $(PROJECT_NAME)_docs         $(PACKAGE_PREFIX)/$(GIT_PROFILE)/$(PROJECT_NAME)/docs-$(TRIPLET)/$(HOST_USER):$(TIME)'
	bash -c 'docker push                              $(PACKAGE_PREFIX)/$(GIT_PROFILE)/$(PROJECT_NAME)/docs-$(TRIPLET)/$(HOST_USER):$(TIME)'
	bash -c 'docker tag  $(PROJECT_NAME)_tor          $(PACKAGE_PREFIX)/$(GIT_PROFILE)/$(PROJECT_NAME)/tor-$(TRIPLET)/$(HOST_USER):$(TIME)'
	bash -c 'docker push                              $(PACKAGE_PREFIX)/$(GIT_PROFILE)/$(PROJECT_NAME)/tor-$(TRIPLET)/$(HOST_USER):$(TIME)'
	bash -c 'docker tag  $(PROJECT_NAME)_lnd          $(PACKAGE_PREFIX)/$(GIT_PROFILE)/$(PROJECT_NAME)/lnd-$(TRIPLET)/$(HOST_USER):$(TIME)'
	bash -c 'docker push                              $(PACKAGE_PREFIX)/$(GIT_PROFILE)/$(PROJECT_NAME)/lnd-$(TRIPLET)/$(HOST_USER):$(TIME)'
	bash -c 'docker tag  shahanafarooqui/rtl:0.11.0   $(PACKAGE_PREFIX)/$(GIT_PROFILE)/$(PROJECT_NAME)/rtl-$(TRIPLET)/$(HOST_USER):$(TIME)'
	bash -c 'docker push                              $(PACKAGE_PREFIX)/$(GIT_PROFILE)/$(PROJECT_NAME)/rtl-$(TRIPLET)/$(HOST_USER):$(TIME)'

########################
.PHONY: package-all
package-all: init package-plebnet
#INSERT other scripting here 
	bash -c "echo"
########################

