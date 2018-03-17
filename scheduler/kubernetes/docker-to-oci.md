---
layout: page
title: "Migrating Portworx installation from docker to OCI"
keywords: portworx, container, Kubernetes, storage, Docker, k8s, flexvol, pv, persistent disk
sidebar: home_sidebar
---

* TOC
{:toc}

This page describes the procedue to migrate your current Portworx installation to use OCI/runc containers.

## Step 1: Get your current Portworx arguments

Use the following command to get arguments supplied to your current Portworx DaemonSet. We will use that to generate the new DaemonSet spec that uses OCI later in this guide.

```
$ kubectl get ds/portworx -n kube-system -o jsonpath='{.spec.template.spec.containers[*].args}'

[-k etcd:http://etcd1.acme.net:2379,etcd:http://etcd2.acme.net:2379 -c cluster123 \
 -s /dev/sdb1 -s /dev/sdc -x kubernetes]
 ```

## Step 2: Get the Daemonset spec that uses OCI

While generating the spec using below procedure, specify the parameters from step 1.

{% include k8s-spec-generate.md %}

## Step 3: Verify the generated spec for migration

In the generated spec file, make sure the image for the Portworx DaemonSet is portworx/oci-monitor:__\<your-current-version\>__.

This ensures that you simply migrate to Portworx using OCI and don't end up upgrading to a new Portworx version.

If you have custom changes to the DaemonSet spec apart from the arguments, go ahead and make those too.

## Step 4: Apply and migrate

Apply the spec using `kubectl apply -f <spec-file>`.

As the DaemonSet upgrade strategy in _RollingUpgrade_, each node will migrate to Portworx using OCI one by one.

To monitor the migration process: `kubectl rollout status ds/portworx -n kube-system`

To monitor the Portworx pods: `kubectl get pods -o wide -n kube-system -l name=portworx`






