---
layout: page
title: "Portworx with Flannel SDN and User Namespaces"
keywords: portworx, flannel, docker, sdn, userns
sidebar: home_sidebar
---

This reference guide shows how to configure and run Portworx with User Namespaces under a Flannel SDN.

### Introduction
This guide has been qualified under CentOS 7.

This guide further assumes the following:

* The Docker Engine runs with User Namespaces enabled
* The Portworx 'etcd' instance runs with *--net=bridge*
* The Portworx instance runs with *--privileged=true* and *--net=host*
* All commands are run as 'root'

### Install the SDN

The [Flannel SDN](https://coreos.com/flannel/docs/latest) is dependent on 'etcd'.   
Since Docker will be dependant on the Flannel SDN, we setup Flannel's etcd and the Flannel service first.

For this guide, the Flannel 'etcd' will run in a host context.  While Portworx can use this same etcd, in this reference architecture, we additionally show you how you can run a second etcd instance running with the Flannel SDN.

#### Install 'etcdctl'
Install ‘etcdctl’ as a way of easily accessing 'etcd'.
Set the 'ETCDCTL_ENDPOINT' to you appropriate host IP address.

```
wget https://github.com/coreos/etcd/releases/download/v3.0.15/etcd-v3.0.15-linux-amd64.tar.gz
tar xzvf
mv etcdctl /usr/local/bin
chmod +x /usr/local/bin/etcdctl
export ETCDCTL_ENDPOINT=http://10.1.2.3:2379
```

Populate 'etcd' with the definition of the Flannel SDN name and subnet range, 
using appropriate values for the root directory (i.e. “flannelsdn”) and the Network Subnet:

```
etcdctl set /flannelsdn/network/config '{ "Network": "10.1.0.0/16" }'
```

#### Install 'etcd'
Now we deploy etcd at the host level for the Flannel SDN service.  For every node participating a member of the host-level 'etcd' cluster,
install, configure, and deploy ‘etcd’ as follows:

```
yum -y install etcd
```

Configure /etc/etcd/etcd.conf as follows, using IPaddrs appropriate for your environment:

```
ETCD_NAME=default
ETCD_DATA_DIR="/var/lib/etcd/default.etcd"
ETCD_LISTEN_PEER_URLS="http://10.1.2.3:2380"
ETCD_LISTEN_CLIENT_URLS="http://10.1.2.3:2379"
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://10.1.2.3:2380"
ETCD_INITIAL_CLUSTER="default=http://10.1.2.3:2380"
ETCD_INITIAL_CLUSTER_STATE="new"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
```

Enable and start etcd

```
systemctl enable etcd
systemctl restart etcd
systemctl status etcd
```

Verify from the output of 'systemctl status etcd' that 'etcd' has started without errors before proceeding.

#### Install 'flannel'
Install 'flannel'. This guide has been qualified with flannel version 0.5.3

```
yum -y install flannel
```

Configure 'flannel'.    Edit '/etc/sysconfig/flanneld', with values appropriate for your environment.
For FLANNEL_ETCD_KEY, use the corresponding string from the 'etcdctl' command above.
For "FLANNEL_OPTIONS", use the appropriate external facing network interface.

```
[...]
# etcd url location.  Point this to the server where etcd runs
FLANNEL_ETCD="http://10.1.2.3:2379"

# etcd config key.  This is the configuration key that flannel queries
# For address range assignment
FLANNEL_ETCD_KEY="/flannelsdn/network"

# Any additional options that you want to pass
FLANNEL_OPTIONS="-iface=enp0s3"
```

Enable and Start 'flanneld':

```
systemctl enable flanneld
systemctl start flanneld
systemctl status flanneld
```

Verify from the output of 'systemtl status flanneld' that 'flanneld' started with the expected command line options.

### Configure Docker with Userns

On all hosts that will be running Docker, enable **'user_namespaces'** in the kernel

```
grubby --args="user_namespace.enable=1"   \
       --update-kernel=/boot/vmlinuz-`uname -r`
reboot
```

After reboot validate new configuration with:

```
cat /proc/cmdline  
```

Output should be similar to:

```
BOOT_IMAGE=/vmlinuz-3.10.0-327.36.2.el7.x86_64 root=/dev/mapper/centos-root \
    ro crashkernel=auto rd.lvm.lv=centos/root rd.lvm.lv=centos/swap rhgb quiet \
    LANG=en_US.UTF-8 user_namespace.enable=1
```

Configure User Namespaces for Docker.   Create a user called "dockremap"

```
adduser dockremap

# Setup subuid and subgid
echo dockremap:500000:65536 > /etc/subuid
echo dockremap:500000:65536 > /etc/subgid
```

Now we can configure docker to use both user namespaces and the overlay network.  Ensure the docker.service file has the following form:

```
[Service]
Type=notify
# the default is not to use systemd for cgroups because the delegate issues still
# exists and systemd currently does not support the cgroup feature set required
# for containers run by docker
EnvironmentFile=/run/flannel/docker
ExecStart=/usr/bin/dockerd $DOCKER_NETWORK_OPTIONS --userns-remap=default
```

Restart docker:

```
systemctl daemon-reload
systemctl restart docker
systemctl status docker
```

Verify that docker has started properly with the expected arguments to 'dockerd'.   For example:

```
[...]
 CGroup: /system.slice/docker.service
           ├─2849 /usr/bin/dockerd --bip=10.1.78.1/24 --ip-masq=true --mtu=1472 --userns-remap=default
[...]
```

Validate User Namespaces are properly configured.    This command:

```
docker run -it --rm --privileged=true busybox sh
```

Should output:

```
docker: Error response from daemon: Privileged mode is incompatible with user namespaces.
```

### Verify Overlay Network

After all hosts running docker have been configured with 'flanneld' and User Namespaces, 
verify overlay network functionality between hosts.

On each host, run:

```
docker run -itd --name busybox busybox
```

Determine the IP addr of each instance:

```
docker exec -it busybox  ifconfig eth0
```

Ping between the 'busybox' instances each running on separate hosts:

```
docker exec -it busybox ping <otherbox IP>
```

The IP addresses from different busybox instances on different hosts should be on different subnets within
the "Network" defined by the 'flannel' SDN configuration.   In the above example, "/flannelsdn" was defined as "10.1.0.0/16".
Therefore the IPaddr for the busybox instances on different hosts might be "10.1.78.2" and "10.1.19.3".
Verify on each host that the IP address for the busybox instance corresponds to the subnet range found in **'/run/flannel/subnet.env'**

### Start up ‘etcd’ container in bridged mode
This step is optional.  You can either use the etcd that was setup for Flannel, or create a new seperate etcd in bridged mode using the Flannel SDN and deployed as a Docker container.

Use the following format for launching a local containerized 'etcd'.   
To make use of the overlay network, note that ‘etcd’ runs with “--net=bridge”.   
Also note the exposed ports are changed from the default 2379 and 2380 to 12379 and 12380 respectively, 
so as not to conflict with the ‘etcd’ ports being used by the host-level instsance of ‘etcd’.

```
IPADDR=10.1.2.3
docker run -d -p 14001:14001 -p 12379:12379 -p 12380:12380                   \
     --net=bridge							     \
     --restart=always                                                        \
     --name etcd-px quay.io/coreos/etcd:v2.3.7                               \
     -name etcd0                                                             \
     -data-dir /var/lib/etcd/                                                \
     -advertise-client-urls http://${IPADDR}:12379,http://${IPADDR}:14001    \
     -listen-client-urls http://0.0.0.0:12379                                \
     -initial-advertise-peer-urls http://${IPADDR}:12380                     \
     -listen-peer-urls http://0.0.0.0:12380                                  \
     -initial-cluster-token etcd-cluster                                     \
     -initial-cluster etcd0=http://${IPADDR}:12380                           \
     -initial-cluster-state new
```

Only one instance of containerized 'etcd' is needed for the Portworx cluster 
(though the containerized instance of 'etcd' could be configured as a cluster)


### Start Portworx

On each node, launch Portworx with the following format:

```
docker run --restart=always --name px -d --net=host            \
                 --privileged=true                             \
                 --userns=host                                 \
                 -v /run/docker/plugins:/run/docker/plugins    \
                 -v /var/lib/osd:/var/lib/osd:shared           \
                 -v /dev:/dev                                  \
                 -v /etc/pwx:/etc/pwx                          \
                 -v /opt/pwx/bin:/export_bin:shared            \
                 -v /var/run/docker.sock:/var/run/docker.sock  \
                 -v /var/cores:/var/cores                      \
                 -v /lib/modules:/lib/modules                  \
                 --ipc=host                                    \
                portworx/px-enterprise -daemon -k etcd://10.1.2.3:12379 -c mypxcluster -a -f 
```

Note:   The **'kvdb**' parameter refers to the IP:Port of the containerized ‘etcd’, not the host-based 'etcd'.

Verify that the Portworx cluster is running via "/opt/pwx/bin/pxctl status".   
All nodes should be present through the host IP address.
Example the /etc/pwx/config.json file.
The 'kvdb' parameter should be referencing the containerized instance of 'etcd'.



### Reference Links:
                          
[http://chunqi.li/2015/10/10/Flannel-for-Docker-Overlay-Network/](http://chunqi.li/2015/10/10/Flannel-for-Docker-Overlay-Network/)


[http://www.slideshare.net/lorispack/using-coreos-flannel-for-docker-networking](http://www.slideshare.net/lorispack/using-coreos-flannel-for-docker-networking)


[http://cloudgeekz.com/1016/configure-flannel-docker-power.html](http://cloudgeekz.com/1016/configure-flannel-docker-power.html)


[https://coderwall.com/p/s_ydlq/using-user-namespaces-on-docker](https://coderwall.com/p/s_ydlq/using-user-namespaces-on-docker)

