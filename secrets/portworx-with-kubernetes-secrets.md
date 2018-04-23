---
layout: page
title: "Portworx with Kubernetes Secrets"
sidebar: home_sidebar
meta-description: "Portworx can integrate with Kubernetes Secrets to store your encryption keys/secrets. This guide will get a Portworx cluster connected to Kubernetes Secrets"
---

* TOC
{:toc}

Portworx can integrate with Kubernetes Secrets to store your encryption keys/secrets and credentials. This guide will help configure Portworx with Kubernetes Secrets. Kubernetes Secrets can then be used to store Portworx secrets for Volume Encryption and Cloud Credentials.
>**Note:**<br/>Supported from PX Enterprise 1.4 onwards

### Configuring Kubernetes Secrets with Portworx

#### New installation
When generating the [Portworx Kubernetes spec file](https://install.portworx.com/), select `Kubernetes` from the "Secrets type" list. For more details on how to generate Portworx spec for Kubernetes, refer instructions on [Deploy Portworx on Kubernetes](/scheduler/kubernetes).

#### Existing installation

##### Permissions to access secrets
Portworx stores credentials/secrets in a Kubernetes namespace called `portworx`. It needs permissions to access secrets under this namespace. If you have upgraded Portworx using the [recommended method](/scheduler/kubernetes/upgrade-1.3.html), then you will not have to create the namespace and roles given below. If the following objects are missing, then create it using `kubectl`:
```yaml
cat <<EOF | kubectl apply -f -
# Namespace to store credentials
apiVersion: v1
kind: Namespace
metadata:
  name: portworx
---
# Role to access secrets under portworx namespace only
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: px-role
  namespace: portworx
rules:
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get", "list", "create", "update", "patch"]
---
# Allow portworx service account to access the secrets under the portworx namespace
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: px-role-binding
  namespace: portworx
subjects:
- kind: ServiceAccount
  name: px-account
  namespace: kube-system
roleRef:
  kind: Role
  name: px-role
  apiGroup: rbac.authorization.k8s.io
EOF
```

##### Update config.json
After ensuring the `portworx` namespace and the required permissions are present, you will have to update the `/etc/pwx/config.json` to start using Kubernetes secrets by default. Add the `secret_type` and `cluster_secret_key` fields in the `secret` section to the `/etc/pwx/config.json` on each node in the cluster:
```json
{
    "clusterid": "",
    "secret": {
        "secret_type": "k8s",
        "cluster_secret_key": "cluster-wide-secret-key"
    },
    ...
}
```

##### Edit the Portworx Daemonset
You will have to edit the Portworx daemonset to use Kubernetes secrets, so that all the new Portworx nodes will start using Kubernetes secrets. You will not have to change the *config.json* for the new nodes if you edit the daemonset.
```
# kubectl edit daemonset portworx -n kube-system
```
Add the `"-secret_type", "k8s"` arguments to the `portworx` container in the daemonset. It should look something like this:
```yaml
  containers:
  - args:
    - -c
    - testclusterid
    - -s
    - /dev/sdb
    - -x
    - kubernetes
    - -secret_type
    - k8s
    name: portworx
```
Editing the daemonset will also restart all the Portworx pods, which will consume the modified *config.json*.

### Creating secrets with Kubernetes

The following section describes the key generation process with Portworx and Kubernetes which can be used for encrypting volumes. More details about encryption can be found on [Encrypted Volumes](/manage/encrypted-volumes.html) and [Encryption using PVC](/scheduler/kubernetes/encrypted-volumes.html) page.

#### Setting cluster wide secret key

A cluster wide secret key is a common key that can be used to encrypt all your volumes. First, let us create a cluster wide secret in Kubernetes using `kubectl`:
```
# kubectl -n portworx create secret generic px-vol-encryption \
  --from-literal=cluster-wide-secret-key=<value>
```
Note that the cluster wide secret has to reside in the `px-vol-encryption` secret under the `portworx` namespace.

Now you have to give Portworx the cluster wide secret key, that acts as the default encryption key for all volumes.
```
# PX_POD=$(kubectl get pods -l name=portworx -n kube-system -o jsonpath='{.items[0].metadata.name}')
# kubectl exec $PX_POD -n kube-system -- /opt/pwx/bin/pxctl secrets set-cluster-key \
  --secret pwx/secrets/cluster-wide-secret-key
Successfully set cluster secret key
```
This command needs to be run just once for the cluster. If you have added the [cluster secret key through the *config.json*](#update-configjson), the above command will overwrite it. Even on subsequent Portworx restarts, the cluster secret key in *config.json* will be ignored for the one set through the CLI.

#### (Optional) Authenticating with Kubernetes Secrets using Portworx CLI

If you wish to quickly try Kubernetes secrets, you can authenticate Portworx with Kubernetes Secrets using Portworx CLI. Run the following command:
```
# PX_POD=$(kubectl get pods -l name=portworx -n kube-system -o jsonpath='{.items[0].metadata.name}')
# kubectl exec $PX_POD -n kube-system -- /opt/pwx/bin/pxctl secrets k8s login
Successfully authenticated with Kubernetes Secrets.
** WARNING, this is probably not what you want to do. This login will not be persisted across PX or node reboots. Please put your login information in /etc/pwx/config.json or refer docs.portworx.com for more information.
```

>**Important:**<br/> You need to run this command on all Portworx nodes, so that you could create and mount encrypted volumes on all nodes.

If the CLI is used to authenticate with Kubernetes Secrets, for every restart of Portworx container it needs to be re-authenticated with Kubernetes Secrets by running the `login` command on that node.
