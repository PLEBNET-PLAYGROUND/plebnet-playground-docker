* refactoring to dashboard library

### 2021-09-06 15:35:37.593682: clock-in

### 2021-09-06 14:14:45.488795: clock-out

* interpolating positions from base path

### 2021-09-06 12:38:29.198835: clock-in

### 2021-09-05 22:31:50.256312: clock-out

* python 3.7 for networkx compatibility
* containerizing dashboard

### 2021-09-05 21:08:35.199569: clock-in

### 2021-09-05 13:24:24.791297: clock-out

* shortest path vis looking better

### 2021-09-05 11:31:17.028480: clock-in: T-10m 

### 2021-09-04 18:34:24.628271: clock-out

* multipath vis
* adding grpc defs

### 2021-09-04 17:06:16.103299: clock-in: T-15m 

### 2021-09-01 16:23:47.698346: clock-out

* multipath vis

### 2021-09-01 13:49:54.103872: clock-in

### 2021-08-31 22:30:33.124519: clock-out

* simple path visualization

### 2021-08-31 20:25:59.032072: clock-in

### 2021-08-30 19:41:07.202459: clock-out

* meeting with Richard/Randy
* testing docker volume permissions

### 2021-08-30 17:22:19.733165: clock-in

### 2021-08-30 16:04:33.359857: clock-out

* look at generating macaroons from command line
* firecracker vm setup?

### 2021-08-30 14:54:58.062615: clock-in

### 2021-08-29 15:19:51.728227: clock-out

* degree histogram
* looking at k-componts

### 2021-08-29 14:51:03.558541: clock-in

### 2021-08-29 14:22:39.600142: clock-out: T-1h30m 

* calculating weights for minimum spanning tree

### 2021-08-29 12:18:35.208999: clock-in

### 2021-08-29 12:18:32.450252: clock-out: T-3h 


### 2021-08-29 07:47:31.354669: clock-in

### 2021-08-28 21:53:50.692778: clock-out: T-1h 


### 2021-08-28 20:32:21.015838: clock-in

### 2021-08-28 18:49:44.214159: clock-out

* https://github.com/andrerfneves/lightning-address/blob/master/README.md

### 2021-08-28 17:56:44.676004: clock-in

### 2021-08-28 17:01:25.899171: clock-out

* trying minimum spanning tree, shortest path algorithms

### 2021-08-28 16:18:02.400093: clock-in

### 2021-08-28 11:40:17.494006: clock-out

* added colors, starting to create channels, visualized global network

### 2021-08-28 09:43:10.421124: clock-in

### 2021-08-27 22:34:51.923450: clock-out: T-15m 

* converting to undirected graph

### 2021-08-27 22:07:57.449360: clock-in

### 2021-08-27 13:21:37.244392: clock-out

* got first node/edge graph to render

### 2021-08-27 10:26:15.392487: clock-in

### 2021-08-26 21:20:12.717150: clock-out

* got describegraph in grpc to pull nodes/edges

### 2021-08-26 20:17:20.601943: clock-in

### 2021-08-26 14:06:28.635993: clock-out

* merging multi-platform install


### 2021-08-26 14:02:13.394526: clock-in

### 2021-08-25 22:05:30.948513: clock-out

* dashboard passwords, meeting with Richard

### 2021-08-25 20:28:27.858430: clock-in

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

