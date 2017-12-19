---
layout: page
title: "Dynamic Portworx Volume Creation by Kubernetes Operations(KOPS)"
keywords: portworx, container, Kubernetes, storage, Docker, k8s, KOPS, pv, persistent disk, aws, EBS
sidebar: home_sidebar
redirect_from: "/cloud/aws/kops_asg.html"
---

* TOC
{:toc}


The purpose of this below steps to guide and setting up a production ready dynamic provisioning of Portworx volumes using Kubernetes(KOPS) environment on AWS.

## Prerequisites:
Prepare your AWS environment for KOPS.  You will have to perform the following steps:

•	Install KOPS

•	Install aws cli

•	Create and Setup IAM user permission for KOPS

•	Create a hosted DNS zone for KOPS

•	Create S3 bucket for KOPS to store cluster state.

Detailed instructions on these steps are documented [here](https://github.com/kubernetes/KOPS/blob/master/docs/aws.md).

## Create a kubernetes cluster using KOPS:
```
$ export NAME=sen.k8s-demo.com
$ export KOPS_STATE_STORE=s3://KOPS-demo-state-store

$ KOPS create cluster \
>     --channel alpha \
>     --node-count 3 \
>     --zones us-west-2a \
>     --master-zones us-west-2a \
>     --dns-zone k8s-demo.com \
>     --node-size t2.medium \
>     --master-size t2.medium \
>     --ssh-public-key ~/.ssh/id_rsa.pub \
>     --cloud-labels "Team=Portworx,Owner=SenS" \
>     ${NAME}
```

## Prepare the key-value database (etcd):
Portworx requires a key-value database such as etcd for configuring storage. Either point to your external etcd or Follow this steps to set up new [etcd](https://docs.portworx.com/maintain/etcd.html#tuning-etcd) Cluster. we are starting our own etcd.

## Create EBS volume templates
Create atleast one EBS volume. This volume will serve as a template EBS volume. On every node where PX is brought up as a storage node, a new EBS volume identical to the template volume will be created. 

Ensure that these EBS volumes are created in the same region as the auto scaling group (KOPS cluster).

Record the EBS volume ID (e.g. `vol-04e2283f1925ec9ee`), this will be passed in to PX as a parameter.

## Prepare a Portworx Spec for KOPS auto scaling group (ASG):
Once your KOPS cluster is online, install Portworx by customizing and executing the commands below.  Make sure you change the custom parameters (cluster, kvdb , aws environment variables and volume template name) to match your environment.

Example:
```
$ curl -o px-spec.yaml "http://install.portworx.com/?cluster=mycluster&kvdb=etcd://172.20.60.36:2379&drives=vol-04e2283f1925ec9ee&env=AWS_ACCESS_KEY_ID=<enter your details>,AWS_SECRET_ACCESS_KEY=<enter your details>”
$ kubectl apply -f px-spec.yaml
daemonset "portworx" created
```

>**Note:**<br/>There are 2 env variables passed into the px-spec.yaml. These are the KOPS IAM user AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY used for authentication.

>**Note:**<br/>The volume template is passed in as drives=vol-04e2283f1925ec9ee.

The complete PX installation documentation for Kubernetes can be found at the [Kubernetes install guide](/scheduler/kubernetes/install.html).

Once PX has been installed, list the pods and verify that the PX daemonset is running:
```
$ admin@ip-172-20-60-36:~$ kubectl get pods --all-namespaces | grep portworx
kube-system   portworx-2kst8                                                       1/1       Running   0          32m
kube-system   portworx-b8b2n                                                       1/1       Running   0          32m
kube-system   portworx-sxl59                                                       1/1       Running   0          32m
```

Kubernetes may take a few minutes to download the Portworx container images and start the cluster.

Portworx will dynamically create it's local EBS volumes based on the template.  Check the status of Portworx with the following command:

```
$ admin@ip-172-20-33-196:~$ /opt/pwx/bin/pxctl status
Status: PX is operational
License: Trial (expires in 30 days)
Node ID: ip-172-20-33-196.us-west-2.compute.internal
	IP: 172.20.33.196
 	Local Storage Pool: 1 pool
	POOL	IO_PRIORITY	RAID_LEVEL	USABLE	USED	STATUS	ZONE	REGION
	0	LOW		raid0		300 GiB	1.0 GiB	Online	a	us-west-2
	Local Storage Devices: 1 device
	Device	Path		Media Type		Size		Last-Scan
	0:1	/dev/xvdf	STORAGE_MEDIUM_MAGNETIC	300 GiB		14 Nov 17 03:28 UTC
	total			-			300 GiB
Cluster Summary
	Cluster ID: mycluster
	Cluster UUID: a6705624-c41a-4011-95ca-060a19fecd18
	IP		ID						Used	Capacity	Status	StorageStatus
	172.20.34.122	ip-172-20-34-122.us-west-2.compute.internal	1.0 GiB	300 GiB		Online	Up
	172.20.56.123	ip-172-20-56-123.us-west-2.compute.internal	0 B	300 GiB		Online	Up
	172.20.33.196	ip-172-20-33-196.us-west-2.compute.internal	0 B	300 GiB		Online	Up (This node)
Global Storage Pool
	Total Used    	:  1.0 GiB
	Total Capacity	:  900 GiB
```
