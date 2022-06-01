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
#available services:
#	bitcoind
#	lnd
#	tor
#	thunderhub
#	rtl
#	notebook
#	dashboard
#	lndg
#	docs
ifeq ($(services),)
services                                :=bitcoind,lnd,cln,rtl,thunderhub,docs
else
services                                :=$(services)
endif
export services
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
ifeq ($(reset),true)
RESET:=true
else
RESET:=false
endif
export RESET

PYTHON                                  := $(shell which python)
export PYTHON
PYTHON2                                 := $(shell which python2)
export PYTHON2
PYTHON3                                 := $(shell which python3)
export PYTHON3

PIP                                     := $(shell which pip)
export PIP
PIP2                                    := $(shell which pip2)
export PIP2
PIP3                                    := $(shell which pip3)
export PIP3

python_version_full := $(wordlist 2,4,$(subst ., ,$(shell python3 --version 2>&1)))
python_version_major := $(word 1,${python_version_full})
python_version_minor := $(word 2,${python_version_full})
python_version_patch := $(word 3,${python_version_full})

my_cmd.python.3 := $(PYTHON3) some_script.py3
my_cmd := ${my_cmd.python.${python_version_major}}

PYTHON_VERSION                         := ${python_version_major}.${python_version_minor}.${python_version_patch}
PYTHON_VERSION_MAJOR                   := ${python_version_major}
PYTHON_VERSION_MINOR                   := ${python_version_minor}

export python_version_major
export python_version_minor
export python_version_patch
export PYTHON_VERSION

#PROJECT_NAME defaults to name of the current directory.
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
GIT_PROFILE								:= $(GIT_USER_NAME)
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
GIT_PREVIOUS_HASH						:= $(shell git rev-parse --short HEAD^1)
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
ifeq ($(parallel),true)
PARALLEL                                := --parallel
endif
ifeq ($(para),true)
PARALLEL                                := --parallel
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
.PHONY: - all
-:
	#NOTE: 2 hashes are detected as 1st column output with color
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?##/ {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.PHONY: help
help:## 	print verbose help
	@echo 'make [COMMAND] [EXTRA_ARGUMENTS]	'
	@echo ''
	#@echo ''
	@echo 'make '
	@echo '	 make all                        install and run playground and cluster'
	@echo '	 make help                       print help'
	@echo '	 make report                     print environment variables'
	@echo '	 make initialize                 install dependencies - ubuntu/macOS'
	@echo '	 make init                       initialize basic dependencies'
	@echo '	 make build'
	@echo '	 make build para=true            parallelized build'
	@echo '	 make install'
	@echo '	 make install-cluster'
	@echo '	                                 services=bitcoind,lnd,lndg,rtl,thunderhub,docs,tor,dashboard,notebook'
	@echo '	 make run'
	@echo '	                                 nocache=true verbose=true'
	@echo ''
	@echo '	[DEV ENVIRONMENT]:	'
	@echo ''
#	@echo '	 make shell            compiling environment on host machine'
	@echo '	 make signin profile=gh-user     ~/GH_TOKEN.txt required from github.com'
#	@echo '	 make header package-header'
	@echo '	 make build'
#	@echo '	 make build package-statoshi'
	@echo '	 make package-all'
	@echo ''
	@echo '	 make install-python38-sh'
	@echo '	 make install-python39-sh'
	@echo ''
#	@echo '	[EXTRA_ARGUMENTS]:	set build variables	'
#	@echo ''
#	@echo '	nocache=true'
#	@echo '	            	add --no-cache to docker command and apk add $(NOCACHE)'
#	@echo '	port=integer'
#	@echo '	            	set PUBLIC_PORT default 80'
#	@echo ''
#	@echo '	nodeport=integer'
#	@echo '	            	set NODE_PORT default 8333'
#	@echo ''
#	@echo '	            	TODO'
#	@echo ''
#	@echo '	[DOCKER COMMANDS]:	push a command to the container	'
#	@echo ''
#	@echo '	cmd=command 	'
#	@echo '	cmd="command"	'
#	@echo '	             	send CMD_ARGUMENTS to the [TARGET]'
	@echo ''
	@echo '	[EXAMPLES]:'
	@echo ''
	@echo '	make run nocache=true verbose=true'
	@echo ''
	@echo '	make init && play help'
	@echo ''
	@sed -n 's/^# //p' ${MAKEFILE_LIST} | column -t -s ':' |  sed -e 's/^/# /'
	@sed -n 's/^## //p' ${MAKEFILE_LIST} | column -t -s ':' |  sed -e 's/^/## /'
	@sed -n 's/^### //p' ${MAKEFILE_LIST} | column -t -s ':' |  sed -e 's/^/### /'

.PHONY: report
report:## 	print environment arguments
	@echo ''
	@echo '	[ARGUMENTS]	'
	@echo '      args:'
	@echo '        - PROJECT_NAME=${PROJECT_NAME}'
	@echo '        - HOME=${HOME}'
	@echo '        - PWD=${PWD}'
	@echo '        - PYTHON=${PYTHON}'
	# @echo '        - PYTHON2=${PYTHON2}'
	@echo '        - PYTHON3=${PYTHON3}'
	@echo '        - PYTHON_VERSION=${PYTHON_VERSION}'
	@echo '        - PYTHON_VERSION_MAJOR=${PYTHON_VERSION_MAJOR}'
	@echo '        - PYTHON_VERSION_MINOR=${PYTHON_VERSION_MINOR}'
	@echo '        - PIP=${PIP}'
	# @echo '        - PIP2=${PIP2}'
	@echo '        - PIP3=${PIP3}'
	# @echo '        - UMBREL=${UMBREL}'
	# @echo '        - THIS_FILE=${THIS_FILE}'
	@echo '        - TIME=${TIME}'
	@echo '        - PACKAGE_PREFIX=${PACKAGE_PREFIX}'
	@echo '        - ARCH=${ARCH}'
	@echo '        - TRIPLET=${TRIPLET}'
	@echo '        - services=${services}'
	@echo '        - HOST_USER=${HOST_USER}'
	@echo '        - HOST_UID=${HOST_UID}'
	@echo '        - PUBLIC_PORT=${PUBLIC_PORT}'
	@echo '        - NODE_PORT=${NODE_PORT}'
	# @echo '        - SERVICE_TARGET=${SERVICE_TARGET}'
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
	@echo '        - NOCACHE=${NOCACHE}'
	# @echo '        - VERBOSE=${VERBOSE}'
	# @echo '        - PASSWORD=${PASSWORD}'
	# @echo '        - CMD_ARGUMENTS=${CMD_ARGUMENTS}'

#######################

ORIGIN_DIR:=$(PWD)
MACOS_TARGET_DIR:=/var/root/$(PROJECT_NAME)
LINUX_TARGET_DIR:=/root/$(PROJECT_NAME)
export ORIGIN_DIR
export TARGET_DIR

all: initialize init install-cluster install## 	all
.PHONY: venv
venv:## 	create python3 virtualenv .venv
	test -d .venv || $(PYTHON3) -m virtualenv .venv
	( \
	   source .venv/bin/activate; pip install -r requirements.txt; \
	);
	@echo "To activate (venv)"
	@echo "try:"
	@echo ". .venv/bin/activate"
	@echo "or:"
	@echo "make test-venv"
##:	test-venv            source .venv/bin/activate; pip install -r requirements.txt;
test-venv:## 	test virutalenv .venv
	# insert test commands here
	test -d .venv || $(PYTHON3) -m virtualenv .venv
	( \
	   source .venv/bin/activate; pip install -r requirements.txt; \
	);
.PHONY: init setup
.SILENT:
setup: init venv## 	basic setup
init:## 	basic setup

ifneq ($(shell id -u),0)
	@echo
	@echo $(shell id -u -n) 'try:'
	@echo 'make super'
	@echo 'If permissions issue...'
	@echo
endif

	git config --global --add safe.directory $(PWD)
	mkdir -p volumes
	mkdir -p cluster/volumes
	chown -R $(shell id -u) *                 || echo

	install -v -m=o+rwx $(PWD)/scripts/*  /usr/local/bin/
	install -v -m=o+rwx $(PWD)/getcoins.py  /usr/local/bin/play-getcoins

	$(PYTHON3) -m pip install --upgrade pip 2>/dev/null
	$(PYTHON3) -m pip install -q omegaconf 2>/dev/null
	$(PYTHON3) -m pip install -q -r requirements.txt 2>/dev/null
	pushd docs 2>/dev/null && $(PYTHON3) -m pip install -q -r requirements.txt && popd  2>/dev/null
	$(PYTHON3) plebnet_generate.py TRIPLET=$(TRIPLET) services=$(SERVICES)

	pushd scripts > /dev/null; for string in *; do sudo chmod -R o+rwx /usr/local/bin/$$string; done; popd  2>/dev/null || echo


#######################
.PHONY: blocknotify
blocknotify:
	bash -c 'install -v $(PWD)/scripts/blocknotify  /usr/local/bin/blocknotify'
#######################
.PHONY: initialize
initialize:## 	install libs and dependencies
	./scripts/initialize  #>&/dev/null
#######################
.PHONY: install install-cluster
.SILENT:
install: venv## 	create docker-compose.yml and run playground
	bash -c './install.sh $(TRIPLET)'
install-cluster: venv## 	create cluster/docker-compose.yml and run playground-cluster
	bash -c 'pushd cluster && ./up-generic.sh 5 && popd'
#######################
.PHONY: uninstall
uninstall: 	run uninstall.sh script
	bash -c './uninstall.sh $(TRIPLET)'
#######################
.PHONY: run
run: docs init## 	docker-compose up -d
	$(DOCKER_COMPOSE) $(VERBOSE) $(NOCACHE) up -d
#######################
.PHONY: build
build: init
	docker pull  shahanafarooqui/rtl:0.11.0
	$(DOCKER_COMPOSE) $(VERBOSE) build --pull $(PARALLEL) --no-rm $(NOCACHE)
#######################
.PHONY: btcd
btcd:
	bash -c "cd btcd && make btcd && cd .."
.PHONY: docs
docs: init
	@echo "Use 'make docs nocache=true' to force docs rebuild..."

	echo "## MAKE COMMAND" >> MAKE.md
	echo '```' > MAKE.md
	make help >> MAKE.md
	echo '```' >> MAKE.md

	echo "## PLAY COMMAND" > PLAY.md
	echo '```' >> PLAY.md
	play >> PLAY.md
	echo '```' >> PLAY.md
#
	echo "## PLAY-BITCOIN COMMAND" >> PLAY.md
	echo '```' >> PLAY.md
	play-bitcoin >> PLAY.md
	echo '```' >> PLAY.md
#
	echo "## PLAY-LND COMMAND" >> PLAY.md
	echo '```' >> PLAY.md
	play-lnd >> PLAY.md
	echo '```' >> PLAY.md

	install -v README.md docs/docs/index.md
	install -v MAKE.md docs/docs/MAKE.md
	install -v PLAY.md docs/docs/PLAY.md
	sed 's/images/.\/images/' README.md > docs/docs/index.md
	cp -R ./images ./docs/docs
	$(DOCKER_COMPOSE) $(VERBOSE) build $(NOCACHE) docs
#######################
.PHONY: install-python38-sh
install-python38-sh:
	bash -c './scripts/install-python3.8.sh'
	make init
#######################
.PHONY: install-python39-sh
install-python39-sh: init
	bash -c './scripts/install-python3.9.sh'
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
	@$(DOCKER_COMPOSE) -p $(PROJECT_NAME) down --remove-orphans --rmi all 2>/dev/null \
	&& echo 'Image(s) for "$(PROJECT_NAME)" removed.' \
	|| echo 'Image(s) for "$(PROJECT_NAME)" already removed.'
#######################
.PHONY: prune
prune:## 	docker system prune -af (very destructive!)
	$(DOCKER_COMPOSE) -p $(PROJECT_NAME) down
	docker system prune -af &
#######################
.PHONY: prune-network
prune-playground:## 	remove plebnet-playground-docker network
	$(DOCKER_COMPOSE) -p $(PROJECT_NAME) down
	docker network rm plebnet-playground-docker* 2>/dev/null || echo
prune-cluster:## 	remove plebnet-playground-cluster network
	$(DOCKER_COMPOSE) -p plebnet-playground-cluster down
	docker network rm plebnet-playground-cluster* 2>/dev/null || echo
#######################
.PHONY: push
push:
	@echo push
	git checkout -b $(TIME)/$(GIT_PREVIOUS_HASH)/$(GIT_HASH)
	git push --set-upstream origin $(TIME)/$(GIT_PREVIOUS_HASH)/$(GIT_HASH)
	git add docs
	git commit --amend --no-edit --allow-empty || echo failed to commit --amend --no-edit
	git push -f origin $(TIME)/$(GIT_PREVIOUS_HASH)/$(GIT_HASH):$(TIME)/$(GIT_PREVIOUS_HASH)/$(GIT_HASH)

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

	bash -c 'docker tag  $(PROJECT_NAME)_thunderhub   $(PACKAGE_PREFIX)/$(GIT_PROFILE)/$(PROJECT_NAME)/thunderhub-$(TRIPLET)/$(HOST_USER):$(TIME) || echo skip thunderhub'
	bash -c 'docker push                              $(PACKAGE_PREFIX)/$(GIT_PROFILE)/$(PROJECT_NAME)/thunderhub-$(TRIPLET)/$(HOST_USER):$(TIME) || echo skip thunderhub'
	bash -c 'docker tag  $(PROJECT_NAME)_dashboard    $(PACKAGE_PREFIX)/$(GIT_PROFILE)/$(PROJECT_NAME)/dashboard-$(TRIPLET)/$(HOST_USER):$(TIME) || echo skip dashboard'
	bash -c 'docker push                              $(PACKAGE_PREFIX)/$(GIT_PROFILE)/$(PROJECT_NAME)/dashboard-$(TRIPLET)/$(HOST_USER):$(TIME) || echo skip dashboard'
	bash -c 'docker tag  $(PROJECT_NAME)_notebook     $(PACKAGE_PREFIX)/$(GIT_PROFILE)/$(PROJECT_NAME)/notebook-$(TRIPLET)/$(HOST_USER):$(TIME) || echo skip notebook'
	bash -c 'docker push                              $(PACKAGE_PREFIX)/$(GIT_PROFILE)/$(PROJECT_NAME)/notebook-$(TRIPLET)/$(HOST_USER):$(TIME) || echo skip notebook'
	bash -c 'docker tag  $(PROJECT_NAME)_bitcoind     $(PACKAGE_PREFIX)/$(GIT_PROFILE)/$(PROJECT_NAME)/bitcoind-$(TRIPLET)/$(HOST_USER):$(TIME) || echo skip bitcoind'
	bash -c 'docker push                              $(PACKAGE_PREFIX)/$(GIT_PROFILE)/$(PROJECT_NAME)/bitcoind-$(TRIPLET)/$(HOST_USER):$(TIME) || echo skip bitcoind'
	bash -c 'docker tag  $(PROJECT_NAME)_docs         $(PACKAGE_PREFIX)/$(GIT_PROFILE)/$(PROJECT_NAME)/docs-$(TRIPLET)/$(HOST_USER):$(TIME) || echo skip docs'
	bash -c 'docker push                              $(PACKAGE_PREFIX)/$(GIT_PROFILE)/$(PROJECT_NAME)/docs-$(TRIPLET)/$(HOST_USER):$(TIME) || echo skip docs'
	bash -c 'docker tag  $(PROJECT_NAME)_tor          $(PACKAGE_PREFIX)/$(GIT_PROFILE)/$(PROJECT_NAME)/tor-$(TRIPLET)/$(HOST_USER):$(TIME) || echo skip tor'
	bash -c 'docker push                              $(PACKAGE_PREFIX)/$(GIT_PROFILE)/$(PROJECT_NAME)/tor-$(TRIPLET)/$(HOST_USER):$(TIME) || echo skip tor'
	bash -c 'docker tag  $(PROJECT_NAME)_lnd          $(PACKAGE_PREFIX)/$(GIT_PROFILE)/$(PROJECT_NAME)/lnd-$(TRIPLET)/$(HOST_USER):$(TIME) || echo skip lnd'
	bash -c 'docker push                              $(PACKAGE_PREFIX)/$(GIT_PROFILE)/$(PROJECT_NAME)/lnd-$(TRIPLET)/$(HOST_USER):$(TIME) || echo skip lnd'
	bash -c 'docker tag  shahanafarooqui/rtl:0.11.0   $(PACKAGE_PREFIX)/$(GIT_PROFILE)/$(PROJECT_NAME)/rtl-$(TRIPLET)/$(HOST_USER):$(TIME) || echo skip rtl'
	bash -c 'docker push                              $(PACKAGE_PREFIX)/$(GIT_PROFILE)/$(PROJECT_NAME)/rtl-$(TRIPLET)/$(HOST_USER):$(TIME) || echo skip rtl'

########################
.PHONY: package-all
package-all: init package-plebnet
#INSERT other scripting here
	bash -c "echo insert more scripting here..."
########################

