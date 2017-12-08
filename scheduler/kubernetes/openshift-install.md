---
layout: page
title: "Deploy Portworx on Openshift"
keywords: portworx, container, kubernetes, storage, docker, k8s, pv, persistent disk, openshift
sidebar: home_sidebar

meta-description: "Find out how to install PX within a Openshift cluster and have PX provide highly available volumes to any application deployed via Kubernetes."
---

* TOC
{:toc}

## Deploy

1. Ensure you have followed the general [Portworx prerequisites for Kubernetes](/scheduler/kubernetes/install.html#prereqs-section)

2. Add Portworx service accounts to the privileged security context

	```bash
	$ oc adm policy add-scc-to-user privileged system:serviceaccount:kube-system:px-account
	$ oc adm policy add-scc-to-user privileged system:serviceaccount:kube-system:portworx-pvc-controller-account
	```

3. Generate px spec using [instructions given here](/scheduler/kubernetes/install.html#install-section). Make sure you give `osft=true` as part of the parameters while generating the spec.

4. Install px
	
	```bash
	$ oc apply -f px-spec.yaml
	```

## Test

We will test if the installation was successful using a persistent mysql deployment.

* Create a Portworx StorageClass

```bash
cat <<EOF | oc create -f -
kind: StorageClass
apiVersion: storage.k8s.io/v1beta1
metadata:
    name: px-demo-sc
provisioner: kubernetes.io/portworx-volume
parameters:
   repl: "1"
EOF
```
* Log into Openshift console: https://MASTER-IP:8443/console

* Create a new project "hello-world".

* Import and deploy [this mysql application template](/k8s-samples/px-mysql-openshift.json?raw=true)
    * For `STORAGE_CLASS_NAME`, we use the storage class `px-demo-sc` created in step before.

* Verify mysql deployment is active.

If you are experiencing issues, please refer to [Troubleshooting PX on Kubernetes](support.html) and [General FAQs](/knowledgebase/faqs.html).