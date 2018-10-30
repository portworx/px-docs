---
layout: page
title: "Portworx Monitoring Stack"
keywords: portworx, container, Kubernetes, storage, Docker, k8s, Prometheus, Grafana, Lighthouse, Alertmanager, manager, central, multi-cluster

meta-description: "Find out how to install the full monitoring stack including, Prometheus, Grafana, AlertManager and Lighthouse."
---

- TOC
  {:toc}

## Pre-requisites

- This page assumes you will be using the `internal-etcd` feature.
- It also assumes that you have a K8S cluster running
- Have the Prometheus Operator [spec](/k8s-samples/pxm/operator.yaml) installed.
  `kubectl apply -f operator.yaml`

## Single Cluster Installation

If your cluster has less than 20 nodes we recommend using this setup. Otherwise please refer to [this guide](/maintain/monitoring/px-central.html#multi-cluster-installation).

1. Create a secret using [this template](/k8s-samples/pxm/alertmanager.yaml).
   Replace the values corresponding to your email settings.

   `kubectl create secret generic alertmanager-portworx --from-file=alertmanager.yaml -n kube-system`

2. Download the single-cluster [spec](/k8s-samples/pxm/singlecluster.yaml).

3. Replace `<unique id>` in the command given below
   
   `CLUSTER_ID=<unique id> envsubst < singlecluster.yaml | kubectl apply -f -`

You will now have the following:

- a `Portworx` Cluster
- 1 `Grafana` Instance
- 1 `Prometheus` Instance
- 1 `Lighthouse` Instance
- 1 `AlertManager` instance

Visit `Lighthouse` on `http://<master_ip>:32678`, login with `admin/Password1` and the cluster should be visible.

- `Lighthouse` will watch the portworx cluster and has `Grafana` and `Prometheus` available out-of-the-box as links on the overview page.
- `Prometheus` will scrape the nodes
- `AlertManager` will report issues based on our given rules
- `Grafana` will use `Prometheus` as it’s datasource and has pre-baked dashboards

## Multi Cluster Installation

The below steps are in PREVIEW mode and are in active development.

If your cluster has more than 20 nodes or is resource intensive we recommend using this installation to create a dedicated monitoring cluster, and let this cluster monitor the others.
If not consider using the [single cluster installation](/maintain/monitoring/px-central.html#single-cluster-installation)

1. Create a secret using [this template](/k8s-samples/pxm/alertmanager.yaml). Replace the values corresponding to your email settings.

   `kubectl create secret generic alertmanager-portworx --from-file=alertmanager.yaml -n kube-system`

2. Create a secret using [this template](/k8s-samples/pxm/prometheus-additional.yaml). Replace the values corresponding to your other K8S clusters.

   `kubectl create secret generic additional-scrape-configs --from-file=prometheus-additional.yaml -n kube-system`

3. Download the multi-cluster [spec](/k8s-samples/pxm/multicluster.yaml).
   a. replace `<clusterid>` with the desired clustername

4. Replace `<unique id>` in the command given below
   
   `CLUSTER_ID=<unique id> envsubst < multicluster.yaml | kubectl apply -f -`

You will now have the following:

- 3 Node `Portworx` Cluster
- 1 `Grafana` Instance
- 1 `Prometheus` Instance
- 1 `Lighthouse` Instance
- 1 `AlertManager` instance

- `Lighthouse` will watch the portworx cluster and has `Grafana` and `Prometheus` available out-of-the-box as links on the overview page.
- `Prometheus` will scrape the nodes
- `AlertManager` will report issues based on our given rules
- `Grafana` will use `Prometheus` as it’s datasource and has pre-baked dashboards

In order to have `Lighthouse` manage more than 1 cluster, add them with the `add cluster` option
Provide an external ip and nodeport for the other cluster.
