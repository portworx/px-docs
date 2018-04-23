To generate the spec file for the 1.3 release, head on to [1.3 install page](https://install.portworx.com/1.3/).

To generate the spec file for the 1.2 release, head on to [1.2 install page](https://install.portworx.com/1.2/).

Alternately, you can use curl to generate the spec as described in [Generating Portworx Kubernetes spec using curl](/scheduler/kubernetes/px-k8s-spec-curl.html).

#### Secure ETCD and Certificates
If using secure etcd provide "https" in the URL and make sure all the certificates are in the _/etc/pwx/_ directory on each host which is bind mounted inside PX container.

#### Using Secrets to Provision Certificates
It is recommended to use Kubernetes Secrets to provide ETCD certificates to Portworx. This way, the certificates will be automatically mounted when new nodes join the cluster.

Copy all your etcd certificates and key in a folder _etcd-secrets/_ to create a Kubernetes secret from it.
```
# ls etcd-secrets
etcd-ca etcd-cert   etcd-key
```

Use `kubectl` to create the secret named `px-etcd-certs` from the above files:
```
# kubectl -n kube-system create secret generic px-etcd-certs --from-file=etcd-secrets/
```

Now edit the Portworx spec file to reference the certificates. Given the names of the files are `etcd-ca`, `etcd-cert` and `etcd-key`, modify the _volumeMounts_ and _volumes_ sections as follows:
```
  volumeMounts:
  - mountPath: /etc/pwx/etcdcerts
    name: etcdcerts
```

```
  volumes:
  - name: etcdcerts
    secret:
      secretName: px-etcd-certs
      items:
      - key: etcd-ca
        path: pwx-etcd-ca.crt
      - key: etcd-cert
        path: pwx-etcd-cert.crt
      - key: etcd-key
        path: pwx-etcd-key.key
```

Now that the certificates are mounted at `/etc/pwx/etcdcerts`, change the portworx container args to use the correct certificate paths:
```
  containers:
  - name: portworx
    args:
      ["-c", "test-cluster", "-a", "-f",
      "-ca", "/etc/pwx/etcdcerts/pwx-etcd-ca.crt",
      "-cert", "/etc/pwx/etcdcerts/pwx-etcd-cert.crt",
      "-key", "/etc/pwx/etcdcerts/pwx-etcd-key.key",
      "-x", "kubernetes"]
```

#### Installing behind the HTTP proxy

During the installation Portworx may require access to the Internet, to fetch kernel headers if they are not available locally on the host system.  If your cluster runs behind the HTTP proxy, you will need to expose _PX\_HTTP\_PROXY_ and/or _PX\_HTTPS\_PROXY_ environment variables to point to your HTTP proxy when starting the DaemonSet.

Use _e=PX\_HTTP\_PROXY=\<http-proxy>,PX\_HTTPS\_PROXY=\<https-proxy>_ query param when generating the DaemonSet spec.
