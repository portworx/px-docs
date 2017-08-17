---
layout: page
title: "Start PX via 'systemd' and templates"
keywords: systemd automate
sidebar: home_sidebar
redirect_from:
  - /run-with-systemd.html
---

If you are creating a template image - be it an AWS AMI or a Virtual Machine Image - This reference outlines the best practices to automate the provisioning of a multinode PX cluster by creating a base image via `systemd`:

Create a file called

```bash
/lib/systemd/system/portworx.service
```

Add the following as the contents of that file:

```bash
[Unit]
Description=Portworx Container
Wants=docker.service
After=docker.service
[Service]
TimeoutStartSec=0
Restart=always
ExecStartPre=/usr/bin/bash -c "/usr/bin/systemctl set-environment HOSTDIR=`if uname -r | grep -i coreos > /dev/null; then echo /lib/modules; else echo /usr/src; fi`"
ExecStartPre=-/usr/bin/docker stop %n
ExecStartPre=-/usr/bin/docker rm -f %n
ExecStart=/usr/bin/docker run --net=host --privileged=true \
      --cgroup-parent=/system.slice/px-enterprise.service \
      -v /run/docker/plugins:/run/docker/plugins     \
      -v /var/lib/osd:/var/lib/osd:shared            \
      -v /dev:/dev                                   \
      -v /etc/pwx:/etc/pwx                           \
      -v /opt/pwx/bin:/export_bin:shared             \
      -v /var/run/docker.sock:/var/run/docker.sock   \
      -v /var/cores:/var/cores                       \
      -v ${HOSTDIR}:${HOSTDIR}                       \
      --name=%n \
      portworx/px-enterprise -c MY_CLUSTER_ID -k etcd://myetc.company.com:2379  -s /dev/xvdN
KillMode=control-group
ExecStop=/usr/bin/docker stop -t 10 %n
[Install]
WantedBy=multi-user.target
```

You must edit the above template to provide the cluster and node initialization options.  Provide one of the following examples as command line arguments positioned after “px-enterprise”:

```bash
-t <token> token that was provided in email (or arbitrary clusterID)
-c <cluster_id> cluster ID is required if token is not specified
-s <device> of the form /dev/sdN, repeat for multiple devices
-d <data_network_interface> of the form eth0 - (optional)
-m <management_network_interface> of the form eth0 - (optional)
-k <key_value_store> of the form [etcd|consul]://<IP>:<port> - (Not required if Portworx Management portal, Lighthouse is used)
-a will attempt to use all available devices
-f when combined with -a will use all available devices even those with a filesystem
```

For example, you can provide this after the `-d px-enterprise` line in the above `systemd` unit file:

```bash
   -t 06670ede-70af-11e6-beb9-0242fc110003 -s /dev/sdd -s /dev/sde -d eth0 -m eth1
   -t 06670ede-70af-11e6-beb9-0242fc110003 -s /dev/sdd -s /dev/sde
   -t 06670ede-70af-11e6-beb9-0242fc110003 -a -k etcd://10.0.0.123:2379
   -t 06670ede-70af-11e6-beb9-0242fc110003 -a -f
   -t 06670ede-70af-11e6-beb9-0242fc110003 -a -f"
   -c my_cluster_id -k etcd://my_etcd.domain.com:2379 -a -f"
   -c my_cluster_id -k etcd://etcd1:2379,etcd://etcd2:2379 -a -f"
   -c my_cluster_id -k consul://consul1:2379,consul://consul2:2379 -a -f"
```

Once you create systemd unit file, be sure to enable this unit by running:

```
# systemctl daemon-reload
# systemctl enable portworx
```

At this point your machine image is ready to be saved and cloned.  You can launch a multiple of these images and each initial execution of the machine will cause PX to initialize the node and join the provided cluster.  Subsequent boots will simply cause PX to join as an existing node.

>**Note:** Do NOT start PX on your master image.  If you do that, then PX will create a configuration file which will permanently become part of your master image and not portable to the clones.

>**Note:** If other systemd service contain "Wants=portworx.service", then those services will be restarted anytime that a restart is done on the portworx.service.   In order to avoid this, any dependent services should be launched through a scheduler such as Mesos or Kubernetes.
