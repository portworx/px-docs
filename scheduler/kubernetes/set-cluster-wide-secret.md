#### Step 1: Create cluster wide secret key
A cluster wide secret key is a common key that points to a secret value/passphrase which can be used to encrypt all your volumes.

Below are the 2 options for creating the cluster wide secret key:

##### Option 1: Kubernetes Secrets
Create a cluster wide secret in Kubernetes, if not already created:
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

##### Option 2: Other secrets provider
Similar to Kubernetes secrets, you can set the cluster wide secret key in the secrets provider that you have configured. Refer to the 'Setting cluster wide secret key' section under the respective [secrets provider integration](/secrets).
