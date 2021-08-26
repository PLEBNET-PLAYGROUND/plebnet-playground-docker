* updated bos alias

* getting the following error when running `bos peers`

```console
err: 
  message: 400,ExpectedLndWithKnownChain
  stack: 
    - Error: 400,ExpectedLndWithKnownChain
    -     at /app/node_modules/async/asyncify.js:105:61
    -     at processTicksAndRejections (node:internal/process/task_queues:96:5)
```

* Keeping credentials.json fixed in the repo so user updates have no effect:

```console
git update-index --assume-unchanged bos/node/credentials.json
```

To continue tracking changes, use the following:

```console
git update-index --no-assume-unchanged bos/node/credentials.json
```

* verbose output
* bos prototype install

* building install script for bos

bos instructions do not work https://github.com/alexbosworth/balanceofsatoshis
```console
!base64 volumes/lnd_datadir/tls.cert | tr -d '\n'
```

Above command does not actually strip the newline character. When I decode in python, the line is still there.


### 2021-08-26 14:06:43.311135: clock-in

### 2021-08-25 23:24:46.982492: clock-out

* mounting volumes/bos_datadir for bos container
* removing volume README.md

### 2021-08-25 22:43:15.162846: clock-in

### 2021-08-25 18:21:40.161252: clock-out

* fixed up arch table
* `ARCH=aarch64-linux-gnu` works on my mac. bitcoind starts up
* docker-compose was not stoping containers on my mac, but restarting docker desktop from tray icon worked
* docker-compose up sometimes fails with tor still running: `docker system prune` resolved my issue
* ignore data volumes and any dev-dependent hourly configs
* added worklogs directory for dev time tracking
* mounting data volumes from repo

### 2021-08-25 16:37:02.531165: clock-in: T-20m 

