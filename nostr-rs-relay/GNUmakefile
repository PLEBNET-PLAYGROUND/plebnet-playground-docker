DOCKER:=$(shell which docker)
BREW:=$(shell which brew)
GO:=$(which go)
PROJECT_NAME:=plebnet-playground
-: build
	mkdir -p data
build:
	$(DOCKER) build -t $(PROJECT_NAME)-nostr-rs-relay .
run:
	$(DOCKER) run -it -p 7000:7000 \
		--mount src=$(PWD)/config.toml,target=/usr/src/app/config.toml,type=bind \
		--mount src=$(PWD)/data,target=/usr/src/app/db,type=bind \
		$(PROJECT_NAME)-nostr-rs-relay
noscl:
	$(GO)install github.com/fiatjaf/noscl@latest
all: - init build run noscl
init:
	test $(BREW) && $(BREW) install golang || sudo apt-get install golang-go || true
git-remotes:
	@git remote add gheartsfield	git@git.sr.ht:~gheartsfield/nostr-rs-relay
	@git remote add upstream	git@github.com:scsibug/nostr-rs-relay.git
	@git remote add playground	git@github.com:PLEBNET-PLAYGROUND/playground-nostr-rs-relay.git
