---
layout: page
title: "Installing Etcd using CFCR etcd release"
keywords: portworx, etcd, Kubernetes, bosh, cfcr, storage, pkss
---

* TOC
{:toc}


### 1. Clone the CFCR etcd release repo.

```bash
git clone https://github.com/cloudfoundry-incubator/cfcr-etcd-release.git
cd cfcr-etcd-release
git checkout tags/v1.5.0
```

### 2. Deploy etcd

Download the [etcd deployment manifest](/k8s-samples/bosh-etcd-deployment.yaml) and change availibility zones and networks to match your environment. These are fields in the manifest that have a *CHANGEME* comment.

Now use bosh to deploy it.

```
export BOSH_ENVIRONMENT=pks # CHANGE this to your bosh director environment name
export BOSH_DEPLOYMENT=etcd
bosh deploy bosh-etcd-deployment.yaml
```

If all goes well, you should have 3 etcd instances.

```
 $ bosh vms
```

This should output something like below.
```
Deployment 'etcd'

Instance                                   Process State  AZ    IPs           VM CID                                   VM Type  Active
etcd/087aca88-83ab-4d6a-9889-631f861c1032  running        az-1  70.0.255.241  vm-4f7bc18b-4fc0-4580-aa41-e544ed24f3e5  medium   -
etcd/2da63ebd-cd62-49df-910e-3790b6ebaa86  running        az-1  70.0.255.242  vm-44d83e7c-ae35-469e-89d3-d1e9fea2cdaa  medium   -
etcd/77e56a14-02f7-4f49-80f4-8ccb6ceb769a  running        az-2  70.0.255.243  vm-bbdbc0c3-0513-4eae-a542-1709e668a54e  medium   -

3 vms
```

Let's list the etcd cluster members now.

```
 $ bosh ssh etcd/087aca88-83ab-4d6a-9889-631f861c1032 ETCDCTL_API=3  /var/vcap/jobs/etcd/bin/etcdctl member list

21ce9f1eea115b88, started, 087aca88-83ab-4d6a-9889-631f861c1032, https://087aca88-83ab-4d6a-9889-631f861c1032.etcd.pks-services.etcd.bosh:2380, https://087aca88-83ab-4d6a-9889-631f861c1032.etcd.pks-services.etcd.bosh:2379
3563446b241ac972, started, 2da63ebd-cd62-49df-910e-3790b6ebaa86, https://2da63ebd-cd62-49df-910e-3790b6ebaa86.etcd.pks-services.etcd.bosh:2380, https://2da63ebd-cd62-49df-910e-3790b6ebaa86.etcd.pks-services.etcd.bosh:2379
46829f944246eaa8, started, 77e56a14-02f7-4f49-80f4-8ccb6ceb769a, https://77e56a14-02f7-4f49-80f4-8ccb6ceb769a.etcd.pks-services.etcd.bosh:2380, https://77e56a14-02f7-4f49-80f4-8ccb6ceb769a.etcd.pks-services.etcd.bosh:2379
```

### 3. Copy out the etcd certs

To allow external clients to access the etcd cluster, we will copy out the certs.

```
bosh scp etcd/087aca88-83ab-4d6a-9889-631f861c1032:/var/vcap/jobs/etcd/config/etcd* etcd-certs/
ls etcd-certs/
```