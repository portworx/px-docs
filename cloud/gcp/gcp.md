---
layout: page
title: "Dynamic Provisioning on Google Cloud Platform (GCP)"
keywords: portworx, container, Kubernetes, storage, Docker, k8s, pv, persistent disk, gke, gce
sidebar: home_sidebar
meta-description: "This page describes how to setup a production ready Portworx cluster in a Google Cloud Platform (GCP)."
---

* TOC
{:toc}

The steps below will help you enable dynamic provisioning of Portworx volumes in your GCP cluster.

## Prerequisites

{% include px-k8s-prereqs.md %}

## Create a GCP cluster

To manage and auto provision GCP disks, Portworx needs access to the GCP Compute Engine API.   There are two ways to do this.

### Using instance priviledges

Give your instances priviledges to access the GCP API server.  This is the preferred method since it requires the least amount of setup on each instance.

### Using an account file

Alternatively, you can give Portworx access to the GCP API server via an account file and environment variables. First, you will need to create a service account in GCP and download the account file.

1. Create a service account in the "Service Account" section that has the Compute Engine admin role.
2. Go to IAM & admin  -> Service Accounts -> (Instance Service Account) -> Select "Create Key" and download the `.json` file

This json file needs to be made available on any GCP instance that will run Portworx.  Place this file under a `/etc/pwx/` directory on each GCP instance.  For example, `/etc/pwx/gcp.json`.

## Install

If you used an account file above, you will have to configure the PX installation arguments to access this file by way of it's environmnet variables.  In the installation arguments for PX, pass in the location of this file via the environment variable `GOOGLE_APPLICATION_CREDENTIALS`. (See the installation arguments [here](https://docs.portworx.com/runc/options.html#installation-arguments-to-px)).

For example, use `-e GOOGLE_APPLICATION_CREDENTIALS=/etc/pwx/gcp.json`.

If you installing on Kuberentes, you can use a Secret to mount `/etc/pwx/gcp.json` into the Portworx Daemonset and then expose `GOOGLE_APPLICATION_CREDENTIALS` as an env in the Daemonset.

Follow [these instructions](https://docs.portworx.com/#install-with-a-container-orchestrator) to install Portworx based on your container orchestration environment.

### Disk template

Portworx takes in a disk spec which gets used to provision GCP persistent disks dynamically.

{% include asg/gcp-template.md %}
