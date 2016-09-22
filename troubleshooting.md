---
layout: page
title: "Troubleshooting"
keywords: portworx, troubleshooting, logs, issue
sidebar: home_sidebar
---
For troubleshooting help, get logs for PX-Enterprise or PX-Developer, just as you do for any other Docker container. For example:

* `docker ps` and get the CONTAINER ID for PX-Developer
* `docker logs [CONTAINER_ID]`

#### "No such file or directory" message when running on SELinux

 If you have `SELinux` enabled, you may get the following error message:
 
 ```
 # docker run --name mysql -e MYSQL_ROOT_PASSWORD=my-secret-pw  --volume-driver=pxd -v sql_vol:/var/lib/mysql -d mysql
 docker: Error response from daemon: no such file or directory.
 See 'docker run --help'.
 ```
To resolve the issue:

 ```
 # docker run  --security-opt=label:disable  --name mysql -e MYSQL_ROOT_PASSWORD=my-secret-pw  --volume-driver=pxd -v  sql_vol:/var/lib/mysql -d mysql
 ```

 You will not need to workaround this after [20834](https://github.com/docker/docker/pull/20834) is merged.

#### "permission denied" message in `pxctl`

 ```
 pxctl cluster list
 show cluster: Get http://unix.sock/v1/cluster/enumerate: dial unix /var/lib/osd/cluster/osd.sock: connect: permission denied
  ```
 To resolve the issue:

 Run as `root` to use the `pxctl` tools. To enable root, run `sudo su`.

#### "invalid value... bad mode specified" message when running PX-Developer

 The following error occurs when your Docker version is not 1.10 or greater. For example, running with v1.9.1 will report this error:

  ```
 invalid value "/var/lib/osd:/var/lib/osd:shared" for flag -v: bad mode specified: shared
  ```

#### "Not enough free space in /dev/shm" message

  ```
"Invalid PX configuration: Configuration check failed: Not enough free space in /dev/shm, needs 258MB, available 224MB"
```

  To resolve the issue:

  ```
mount -o remount,size=1GB /dev/shm
```

#### Duplicate NodeID
PX Cluster tries to start, but all nodes are reporting the same NodeID.
You probably tried to bring up multiple nodes from a cloned image that already had PX running.
The NodeID is generated on the fly as new nodes join the cluster and is stored in the /etc/pwx directory.
The act of removing the /etc/pwx directory will cause a new ID to be generated. The config.json tells us what cluster to join and the storage devices to use.   For the proper way to clone system images with Portworx via **systemd**, please see [this](/systemd.html)
