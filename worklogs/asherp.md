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
