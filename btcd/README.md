btcd
====

```
make btcd
```


```
BTCD_DATADIR:=../volumes/btcd_datadir
export BTCD_DATADIR

.PHONY: btcd
btcd:
	bash -c "mkdir -p ../volumes/btcd_datadir"
	bash -c "cat btcd.conf > ../volumes/btcd_datadir/btcd.conf"
	docker build --no-cache --build-arg BTCD_DATADIR=$(BTCD_DATADIR) .
ifeq ($(CMD_ARGUMENTS),)
	$(DOCKER_COMPOSE) $(VERBOSE) -p $(PROJECT_NAME)_$(HOST_UID) run --rm btcd &
else
	$(DOCKER_COMPOSE) $(VERBOSE) -p $(PROJECT_NAME)_$(HOST_UID) run --rm btcd sh -c "$(CMD_ARGUMENTS)"
endif

```