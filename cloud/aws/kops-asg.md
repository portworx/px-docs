---
layout: page
title: "Dynamic Portworx Volume Creation by Kubernetes Operations(KOPS)"
keywords: portworx, container, Kubernetes, storage, Docker, k8s, KOPS, pv, persistent disk, aws, EBS
sidebar: home_sidebar
redirect_from: "/cloud/aws/kops_asg.html"
---

![k8s porx Logo](/images/k8s-porx.png){:height="188px" width="188px"}

* TOC
{:toc}

This is a guide to setup a production ready Portworx cluster using Kubernetes (KOPS) environment that allows you to dynamically provision persistent volumes.

## Prerequisites

{% include k8s-prereqs.md %}

## Create a Kubernetes cluster using KOPS

To prepare your KOPS cluster, you will need to perform the following steps:
* Install KOPS
* Install AWS cli
* Create and Setup IAM user permission for KOPS
* Create a hosted DNS zone for KOPS
* Create S3 bucket for KOPS to store cluster state.

Detailed instructions on these steps are documented [here](https://github.com/kubernetes/KOPS/blob/master/docs/aws.md).

Following is an example command to create the KOPS cluster:
```
$ export NAME=sen.k8s-demo.com
$ export KOPS_STATE_STORE=s3://KOPS-demo-state-store

$ kops create cluster \
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

## Install

Portworx gets deployed as a [Kubernetes DaemonSet](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/). Following sections describe how to generate the spec files and apply them.

### Create EBS volume template

Create atleast one EBS volume. This volume will serve as a template EBS volume. On every node where PX is brought up as a storage node, a new EBS volume identical to the template volume will be created. 

Ensure that these EBS volumes are created in the same region as the auto scaling group (KOPS cluster).

Record the EBS volume ID (e.g. _vol-04e2283f1925ec9ee_), this will be passed in to PX as a parameter.

### Generate the Portworx Spec

When generating the spec, following parameters are important for KOPS:
1. __AWS environment variables__: In the environment variables option (_e_), specify _AWS\_ACCESS\_KEY\_ID_ and _AWS\_SECRET\_ACCESS\_KEY_ for the KOPS IAM user. Example: AWS_ACCESS_KEY_ID=\<id>,AWS_SECRET_ACCESS_KEY=\<key>
2. __Volume template__: In the drives option (_s_), specific the EBS volume template ID that you created in previous step. Portworx will dynamically create EBS volumes based on this template.

{% include k8s-spec-generate.md %}

### Apply the spec

Once you have generated the spec file, deploy Portworx.	
```bash
kubect apply -f px-spec.yaml
```

{% include k8s-monitor-install.md %}

## Deploy a sample application

Now that you have Portworx installed, checkout various examples of [applications using Portworx on Kubernetes](/scheduler/kubernetes/k8s-px-app-samples.html).