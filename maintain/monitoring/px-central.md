---
layout: page
title: "Portworx Monitoring Stack"
keywords: portworx, container, Kubernetes, storage, Docker, k8s, prometheus, grafana, lighthouse, alertmanager, manager, central, multi-cluster

meta-description: "Find out how to install the full monitoring stack including, prometheus, grafana, alertmanager and lighthouse."
---

- TOC
  {:toc}

## Pre-requisites

- This page assumes you have a running etcd cluster or will be using the `internal-etcd` feature. If not, return to [Installing etcd](/scheduler/kubernetes/install-pks.html#step-2-install-etcd).
- It also assumes that you have a K8S cluster running

## Single Cluster Installation

If your cluster has less than 20 nodes we recommend using this setup. Otherwise please refer to [this guide](/maintain/monitoring/px-central.html#multi-cluster).

1. Create a secret using [this template](https://gist.github.com/pault84/3a79f6f981ad25c422fdbe81df9f4fbb). Replace the values corresponding to your email settings.

   `create secret generic alertmanager-portworx --from-file=alertmanager.yaml -n kube-system`

2. Download the single-cluster [spec](https://gist.github.com/pault84/0f7e81dc7d95b46d5c54a3885bd9b795).

   2a. replace `<clusterid>` with the desired clustername

   2b. replace `<cluster uuid>` with the given uuid from your portworx cluster

   2c. replace the `<grafana nodeport>` and <prometheus nodeport> with the correct values.

3. `kubectl apply -f single-cluster.yaml`

You will now have the following:

- 3 Node Portworx Cluster
- 1 `Grafana` Instance
- 1 `Prometheus` Instance
- 1 `Lighthouse` Instance
- 1 `AlertManager` instance

`Prometheus` will scrape the nodes

`AlertManager` will report issues based on our given rules

`Grafana` will use `Prometheus` as it’s datasource and has pre-baked dashboards

`Lighthouse` will watch the portworx cluster and has `Grafana` and `Prometheus` available out-of-the-box as links on the overview page.

Finally go to `Lighthouse`, login with `admin/Password1` and the cluster should be visible.

`Grafana` won’t show any volume metrics until a volume has been created and mounted and/or attached.

## Multi Cluster Installation

If your cluster has more than 20 nodes or is resource intensive we recommend using this installation to create a dedicated monitoring cluster, and let this cluster monitor the others.
If not consider using the [single cluster installation](/maintain/monitoring/px-central.html#single-cluster-installation)

1. Create a secret using [this template](https://gist.github.com/pault84/3a79f6f981ad25c422fdbe81df9f4fbb). Replace the values corresponding to your email settings.

   `create secret generic alertmanager-portworx --from-file=alertmanager.yaml -n kube-system`

2. Create a secret using [this template](https://gist.github.com/pault84/aa7eb60a75255d67f576719024961755). Replace the values corresponding to your other K8S clusters.

   `kubectl create secret generic additional-scrape-configs --from-file=prometheus-additional.yaml -n kube-system`

3. Download the multi-cluster [spec](https://gist.github.com/pault84/13b034ec63bc4647093f4d77b5bb4a5c).

   a. replace `<clusterid>` with the desired clustername

   b. replace `<cluster uuid>` with the given uuid from your portworx cluster

   c. replace the `<grafana nodeport>` and `<prometheus nodeport>` with the correct values.

4. `kubectl apply -f multi-cluster.yaml`

You will now have the following:

- 3 Node `Portworx` Cluster
- 1 `Grafana` Instance
- 1 `Prometheus` Instance
- 1 `Lighthouse` Instance
- 1 `AlertManager` instance

`Prometheus` will scrape the prometheus nodes configured in `prometheus-additional.yaml`

`AlertManager` will report issues based on our given rules

`Grafana` will use `Prometheus` as it’s datasource and has pre-baked dashboards

`Lighthouse` will watch the portworx cluster and has `Grafana` and `Prometheus` available out-of-the-box as links on the overview page.

Finally go to `Lighthouse`, login with `admin/Password1` and the cluster should be visible.

In order to have `Lighthouse` manage more than 1 cluster, add them with the `add cluster` option
Provide an external ip and nodeport for the other cluster.

`Grafana` won’t show any volume metrics until a volume has been created and mounted and/or attached.
