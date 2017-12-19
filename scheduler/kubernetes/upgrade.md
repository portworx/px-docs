---
layout: page
title: "Upgrade Portworx on Kubernetes"
keywords: portworx, container, Kubernetes, storage, Docker, k8s, flexvol, pv, persistent disk
sidebar: home_sidebar
---

* TOC
{:toc}

This guide walks through upgrading Portworx deployed as a DaemonSet in a Kubernetes cluster.

In the current version, Portworx recommends following an update strategy of 'OnDelete'. With 'OnDelete' update strategy, after you update a DaemonSet template, new DaemonSet pods will only be created when you manually delete old DaemonSet pods. Doing so gives end users more control on when they are ready to upgrade Portworx on a particular node.

Users are expected to migrate application pods using Portworx volumes to another node before deleting the old Portworx pod.

Follow the below sequence to upgrade Portworx in your cluster.

### 1. Ensure that the DaemonSet update strategy is "OnDelete"

* Check current update strategy using command: `$ kubectl get ds portworx -n kube-system -o yaml | grep -A 3 updateStrategy:`
* If the updateStrategy type is `RollingUpdate`, change it to the `OnDelete`
    * Edit the spec using command: `$ kubectl edit ds portworx -n kube-system`
    * This will open the spec in an editor. Change updateStrategy to `OnDelete` and save the file. This section in your spec should look like below:
        ```yaml
        updateStrategy:
            type: OnDelete
        ```

### 2. Upgrade the Portworx spec

* Change the image of the Portworx Daemonset
    * Set the image with command: `$ kubectl set image ds portworx portworx=portworx/px-enterprise:1.2.10 -n kube-system`
    * Alternately, you can also change the image in the DaemonSet spec file and apply it using `$ kubectl apply -f <px-spec.yaml>`.
* Update the `ClusterRole` permissions in Portworx spec using below:

    ```
    cat <<EOF | kubectl apply -f -
    kind: ClusterRole
    apiVersion: rbac.authorization.k8s.io/v1alpha1
    metadata:
       name: node-get-put-list-role
    rules:
    - apiGroups: [""]
      resources: ["nodes"]
      verbs: ["get", "update", "list"]
    - apiGroups: [""]
      resources: ["pods"]
      verbs: ["get", "list"]
    EOF
    ```

### 3. Upgrade Portworx pods

It is not recommended to delete the Portworx pod while an application is actively issuing I/O. This can induce race conditions in docker causing it to hang. 

The following procedure should be followed:
1. Cordon the node where you want to upgrade Portworx: `$ kubectl cordon <node-name>`
2. Delete application pods running on this node that are using Portworx volumes: `$ kubectl delete pod <pod-name>`
    * Since application pods are expected to be managed by a controller like `Deployement` or `StatefulSet`, Kubernetes will spin up a new replacement pod on another node.
3. Delete Portworx pod running on this node. This will start a new Portworx pod on this node with the new version you set above. (Note: Cordoning a kubernetes node doesn't affect DaemonSet pods)
4. A new Portworx pod with the new version will be initiated on this node. This pod will stay in initializing state.
5. Reboot the node. (This step is needed only if your current Portworx version is 1.2.9 since it requires a reboot of the host to perform upgrade of our kernel driver.)
6. Uncordon the node once it comes up.
