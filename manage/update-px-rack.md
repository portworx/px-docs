---
layout: page
title: "Updating Portworx Rack and Zone Info"
keywords: portworx, pxctl, command-line tool, cli, reference
sidebar: home_sidebar
redirect_from: "/px-rack.html"
meta-description: "Learn how to inform your Portworx nodes where they are placed in order to influence replication decisions and performance."
---

Portworx nodes can be made aware of the rack on which they are a placed as well as the zone in which they are present. Portworx can use this information to influence the volume replica placement decisions. The way PX reacts to zone and rack information is different and is explained below.

#### Rack

If PX nodes are provided with the information about their racks then they can use this information to honor the rack placement strategy provided during volume creation. If PX nodes are aware of their racks, and a volume is instructed to be created on specific racks, PX will make a best effort to place the replicas on those racks. The placement is user driven and has to be provided during volume creation.

#### Zone
  If PX nodes are provided with the information about their zones then they can influence the `default` replica placement. In case of replicated volumes PX will always try to keep the replicas of a volume in different zones. This placement is not `striclty` user driven and if zones are provided PX will automatically default to placing replicas in different zones for a volume


There are different ways in which you can provide this information to PX nodes based on your scheduler.

## Providing rack info to PX

### Updating rack info in a Kubernetes cluster.

Using kubernetes node labels Portworx nodes can be informed about the rack on which they are running. The specific node label to use is ``px/rack=rack1``, where ``px/rack`` is the key, while ``rack1`` is the value identifying the rack of which the node is a part of.
Please make sure the label is a string not starting with a special character or a number.

#### Requirements
Before updating kubernetes node labels double check the permissions listed on Portworx's ClusterRole `node-get-put-list-role`:

```
$ kubectl describe clusterrole node-get-put-list-role
Name:                node-get-put-list-role
Labels:                <none>
Annotations:        <none>
PolicyRule:
  Resources        Non-Resource URLs        Resource Names        Verbs
  ---------        -----------------        --------------        -----
  nodes                []                        []                [get update list]
  pods                 []                        []                [get list]
```
As seen above the permissions on the node object are [get update list]. In order for Portworx nodes to dynamically update its rack information from node labels it needs an additional ``watch`` permission. Update the ClusterRole using

```
$ kubectl edit clusterrole node-get-put-list-role
```
Add the ``watch`` permission and save the edit window.

#### Steps to update kubernetes node labels.

Run the following command to list the existing nodes and their labels.

```
$ kubectl get nodes --show-labels
NAME      STATUS    AGE       VERSION   LABELS
vm-1      Ready     14d       v1.7.4    beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/hostname=vm-1,node-role.kubernetes.io/master=
vm-2      Ready     14d       v1.7.4    beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/hostname=vm-2
vm-3      Ready     14d       v1.7.4    beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/hostname=vm-3
```

To indicate node ``vm-2`` is placed on ``rack1`` update the node label in the following way:

```
$ kubectl label nodes vm-2 px/rack=rack1
node "vm-2" labeled

$ kubectl get nodes --show-labels
NAME      STATUS    AGE       VERSION   LABELS
vm-1      Ready     14d       v1.7.4    beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/hostname=vm-1,node-role.kubernetes.io/master=
vm-2      Ready     14d       v1.7.4    beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/hostname=vm-2,px/rack=rack1
vm-3      Ready     14d       v1.7.4    beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/hostname=vm-3
[root@vm-1 ~]#

```
kubectl will show the node vm-2 with the new ``px/rack`` label.

Double check  if the rack information is reflected in the PX cluster.

```
$ /opt/pwx/bin/pxctl cluster provision-status
NODE        NODE STATUS        POOL        POOL STATUS .....   ZONE           REGION        RACK
vm-2        Online                0        Online      .....   default        default       rack1
vm-3        Online                0        Online      .....   default        default       default

```
The node vm-2 which was labelled ``rack1`` is reflected on the PX node while the unlabelled node vm-3 is still using the ``default`` rack info.

All the subsequent updates to the node labels will be automatically picked up by the PX nodes. A deletion of a ``px/rack`` label will also be reflected.

If kubernetes node labels is not the preferred way of updating rack information then environment variables could be used as explained in the next section.

### Updating rack information through environment variables

Portworx can be made aware of its rack information through ``PWX_RACK`` environment variable. These environment variables can be provided through
the ```/etc/pwx/px_env``` file. A sample file looks like this

```
# PX Environment File
# Add variables in the following format to export into PX container
# export PWX_EXAMPLE_VAR=foobar
PWX_RACK=rack3
```

Add the ```PWX_RACK=<rack-id>``` entry to the end of this file and bounce the PX container. On every PX restart, all the variables defined in ``/etc/pwx/px_env`` will be exported as environment variables in the PX container. Please make sure the label is a string not starting with a special character or a number.

>**Note:** this method requires a reboot of the PX container.

### Specifying rack placement for volumes in the storage class

Once the nodes are updated with rack info you can specify how the volume data can spread across your different racks. Following is an example of a storage class that replicates its volume data across racks `rack1` and `rack2`

```yaml
##### Portworx storage class
kind: StorageClass
apiVersion: storage.k8s.io/v1beta1
metadata:
    name: px-postgres-sc
provisioner: kubernetes.io/portworx-volume
parameters:
   repl: "2"
   shared: "true"
   racks: "rack1,rack2"
```

Any PVC created using the above storage class will have a replication factor of 2 and will have one copy of its data on `rack1` and the other copy on `rack2`

## Providing zone info to PX

### Updating zone information through environment variables

Portworx can be made aware of its zone information through ``PWX_ZONE`` environment variable. These environment variables can be provided through
the ```/etc/pwx/px_env``` file. A sample file looks like this

```
# PX Environment File
# Add variables in the following format to export into PX container
# export PWX_EXAMPLE_VAR=foobar
PWX_ZONE=zone1
```

Add the ```PWX_ZONE=<zone-id>``` entry to the end of this file and bounce the PX container. On every PX restart, all the variables defined in ``/etc/pwx/px_env`` will be exported as environment variables in the PX container. Please make sure the label is a string not starting with a special character or a number.

>**Note:** this method requires a reboot of the PX container.
