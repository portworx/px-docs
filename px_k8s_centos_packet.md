# Portworx with Kubernetes on CentOS with Packet.net

## Deploy Cluster via Terraform to Packet
Use the [Terraporx Repo](https://github.com/portworx/terraporx/tree/master/packet)

## Install Ansible
Think of Ansible as the "easy button" for installing Kubernetes.
There are so many details that installing by hand is most un-advised.

## Copy the Kubernetes Contrib Repo

```
git clone https://github.com/kubernetes/contrib
```

## Proliferate Keys and /etc/hosts

Update your /etc/hosts file with all the IPaddrs and hostnames from your cluster.   To Find:

```
grep network.0.address terraform.tfstate | awk '{print $2}' | sed -e 's/[",]//g'
147.75.A.B
147.75.C.D
147.75.E.F
147.75.G.H
```

Make sure you can login to all hosts without password prompting.   Run something like this:

```
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

Run this for all hosts in the cluster.

Then append `/etc/hosts` with hostname/IPs for all hosts in the cluster. 

```

## Adjust docker config on all hosts
Terraporx automatically installs docker on all hosts, which runs in conflict with the contrib/ansible.
For all the hosts run: `yum -y remove docker-engine docker-engine-selinux`

## Install Kubernetes via Ansible

```
cd contrib/ansible/scripts
 ./deploy-cluster.sh
 
[...]
PLAY RECAP *********************************************************************
kube-master-1              : ok=180  changed=20   unreachable=0    failed=0
kube-node-1                : ok=94   changed=26   unreachable=0    failed=0
kube-node-2                : ok=91   changed=26   unreachable=0    failed=0
kube-node-3                : ok=91   changed=26   unreachable=0    failed=0
```
 
 




