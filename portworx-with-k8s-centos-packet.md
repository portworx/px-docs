# Portworx with Kubernetes on CentOS with Packet.net
This guide will get a Kubernetes Cluster installed with Portworx on CentOS using packet.net

## Deploy Cluster via Terraform to Packet
Use this [Terraporx Repo](https://github.com/portworx/terraporx/tree/master/packet) to deploy 
Portworx on CentOS on [Packet.net](https://www.packet.net/)

## Install Ansible
Think of Ansible as the "easy button" for easily installing and deploying Kubernetes.
Steps to deploy are listed below.   Before starting, make sure you have Ansible installed
on your **localmachine** via "yum", "apt-get", "brew", or whatever.


## Copy the Kubernetes Contrib Repo

```
# git clone https://github.com/kubernetes/contrib
```

## Copy Keys and /etc/hosts

Update your /etc/hosts file with all the IPaddrs and hostnames from your cluster.   To Find:

```
# grep network.0.address terraform.tfstate | awk '{print $2}' | sed -e 's/[",]//g'
147.75.A.B
147.75.C.D
147.75.E.F
147.75.G.H
```

If you have not already done so, be sure to run `ssh-keygen` to setup your public/private keys for SSH.

To make sure you can login to all hosts without password prompting, run something like this command, 
which takes as one argument the name of the remote host whose `authorized_keys` file gets appended
with your local public key.

```bash
#!/bin/sh

KEY="$HOME/.ssh/id_rsa.pub"

if [ ! -f ~/.ssh/id_rsa.pub ];then
    echo "private key not found at $KEY"
    echo "* please create it with "ssh-keygen -t rsa" *"
    echo "* to login to the remote host without a password, don't give the key you create with ssh-keygen a password! *"
    exit
fi

if [ -z $1 ];then
    echo "Please specify user@host.tld as the first switch to this script"
    exit
fi

echo "Putting your key on $1... "

KEYCODE=`cat $KEY`
ssh -i your_private.key root@$1 "mkdir ~/.ssh 2>/dev/null; chmod 700 ~/.ssh; echo "$KEYCODE" >> ~/.ssh/authorized_keys; chmod 644 ~/.ssh/authorized_keys"

echo "done!"
```

Be sure to change the value of "your_private.key" (!)
Run the above command in a loop for all hosts in the cluster, to enable `ssh` commands without password prompting.


Then append `/etc/hosts` with hostname/IPs for all hosts in the cluster, and make sure it too is copied to all
hosts in the cluster.

## Adjust docker config on all hosts
Terraporx automatically installs docker on all hosts, which runs in conflict with the contrib/ansible.
For all the hosts run: `yum -y remove docker-engine docker-engine-selinux`

## Adjust for secure API Port
As per the [ansible README.md](https://github.com/kubernetes/contrib/blob/master/ansible/README.md#kubernetes-source-type), 
edit `roles/kubernetes/defaults/main.yml` and set `kube_master_api_port` to `6443`

## Create the Ansible hosts 'inventory'
Create the inventory file on which hosts Kubernetes will be installed, as per the [README](https://github.com/kubernetes/contrib/blob/master/ansible/README.md)

## Install Kubernetes via Ansible

```
# cd contrib/ansible/scripts
# ./deploy-cluster.sh
[...]
PLAY RECAP *********************************************************************
kube-master-1              : ok=180  changed=20   unreachable=0    failed=0
kube-node-1                : ok=94   changed=26   unreachable=0    failed=0
kube-node-2                : ok=91   changed=26   unreachable=0    failed=0
kube-node-3                : ok=91   changed=26   unreachable=0    failed=0
```
 
## Update Docker on all Nodes
On all nodes, edit the file /etc/systemd/system/multi-user.target.wants/docker.service.
Comment out or delete: `MountFlags=slave`
Run the following:

```
# systemctl daemon-reload
# systemctl restart docker
```

## Update Kubernetes binaries with Portworx Patches
 
**NB** : This step is only needed until [this Kubernetes PR](https://github.com/kubernetes/kubernetes/pull/39535) is merged
 
###  Get the Kubernetes / Portworx distro
 
```
# wget http://yum.portworx.com/repo/rpms/kubernetes/kubernetes-portworx.tar.gz && \
tar xvf kubernetes-portworx.tar.gz
```

####  Update the Master

```
# cd kubernetes/server/bin
# ssh root@kube-master-1 "systemctl stop kube-apiserver"
# ssh root@kube-master-1 "systemctl stop kube-controller-manager"
# ssh root@kube-master-1 "systemctl stop kube-scheduler"
# scp kube-apiserver kube-controller-manager kubectl kube-scheduler root@kube-master-1:/usr/bin
```

Make sure the API server is listening on port 6443:

```
# grep KUBE_API_PORT /etc/kubernetes/apiserver
```
should show `KUBE_API_PORT="--secure-port=6443"`

```
# ssh root@kube-master-1 "systemctl start kube-apiserver"
# ssh root@kube-master-1 "systemctl start kube-controller-manager"
# ssh root@kube-master-1 "systemctl start kube-scheduler"
```

#### Update the Minion/Nodes

Go back to kubernetes/server/bin.
Run a script of the following form:

```bash
#!/bin/bash

NODES=3

for i in `seq 1 $NODES`
do
  ssh root@kube-node-$i "systemctl stop kubelet"
  ssh root@kube-node-$i "systemctl stop kube-proxy"
  scp kubectl kubelet kube-proxy root@kube-node-$i:/usr/bin
  ssh root@kube-node-$i "systemctl start kubelet"
  ssh root@kube-node-$i "systemctl start kube-proxy"
done
```

### Verify Kubernetes Cluster

From the master node, run the following to verify the cluster is at the correct version
and that all the nodes are up:

```
# kubectl version
Client Version: version.Info{Major:"1", Minor:"5+", GitVersion:"v1.5.3-beta.0.44+7f2055addfd186-dirty", GitCommit:"7f2055addfd1868a1fb041267c9a02f7ecff071b", GitTreeState:"dirty", BuildDate:"2017-01-25T18:06:46Z", GoVersion:"go1.7.4", Compiler:"gc", Platform:"linux/amd64"}
Server Version: version.Info{Major:"1", Minor:"5+", GitVersion:"v1.5.3-beta.0.44+7f2055addfd186-dirty", GitCommit:"7f2055addfd1868a1fb041267c9a02f7ecff071b", GitTreeState:"dirty", BuildDate:"2017-01-25T18:51:53Z", GoVersion:"go1.7.4", Compiler:"gc", Platform:"linux/amd64"}
[root@px-k8s-centos-0 ~]# kubectl get nodes
NAME          STATUS    AGE
kube-node-1   Ready     22h
kube-node-2   Ready     22h
kube-node-3   Ready     22h
```

## Install Portworx
Since an earlier step required removing `docker`, Portworx will need to be reinstalled.
The `kube-master` node should be running `etcd`.   To verify:

```
curl -XGET http://${KUBE-MASTER}:2379/version
```

Install Portworx on all minion/slave nodes:

```
# docker run --restart=always --name px -d --net=host       \
                 --privileged=true                             \
                 -v /run/docker/plugins:/run/docker/plugins    \
                 -v /var/lib/osd:/var/lib/osd:shared           \
                 -v /dev:/dev                                  \
                 -v /etc/pwx:/etc/pwx                          \
                 -v /opt/pwx/bin:/export_bin:shared            \
                 -v /var/run/docker.sock:/var/run/docker.sock  \
                 -v /var/cores:/var/cores                      \
                  -v /usr/src:/usr/src                         \
                portworx/px-dev -daemon -k etcd://kube-master-1:2379 -c MY_CLUSTER_ID -s /dev/dm-0 -d team0:0 -m team0:0
```
