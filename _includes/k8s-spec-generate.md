To generate the spec file for the 1.2 release, head on to [1.2 install page](https://install.portworx.com/1.2.22/).

To generate the spec file for the 1.3 release, head on to [1.3 install page](https://install.portworx.com/1.3.0/).

Alternately, you can use curl to generate the spec as described in [Generating Portworx Kubernetes spec using curl](/scheduler/kubernetes/px-k8s-spec-curl.html).

#### Secure ETCD and Certificates
If using secure etcd provide "https" in the URL and make sure all the certificates are in the _/etc/pwx/_ directory on each host which is bind mounted inside PX container.

#### Using Secrets to Provision Certificates
>**Note for ASG users:**<br/>When using PX with Auto Scaling Groups in AWS, you should use Secrets to have Kubernetes provision the ETCD certificates.  This way, the certificates will be provisioned on any new EC2 instance automatically.

Use `kubectl` to create the secret, for example:

```
# kubectl -n kube-system create secret generic etcd-certs --from-file=etcd-secrets/
```

Now edit the Portworx spec file to reference the certificates.  For example, assuming the names of the files are `pwx-ca.crt` `pwx-user-cert.crt` and `pwx-user-key.key`, modify the spec file as follows:

```
  - mountPath: /etc/pwx/etcdcerts
    name: etcdcerts
```

```
  - name: etcdcerts
    secret:
      secretName: etcd-certs
      items:
      - key: pwx-ca.crt
        path: pwx-ca.crt
      - key: pwx-user-cert.crt
        path: pwx-user-cert.crt
      - key: pwx-user-key.key
        path: pwx-user-key.key
```

#### Installing behind the HTTP proxy

During the installation Portworx may require access to the Internet, to fetch kernel headers if they are not available locally on the host system.  If your cluster runs behind the HTTP proxy, you will need to expose _PX\_HTTP\_PROXY_ and/or _PX\_HTTPS\_PROXY_ environment variables to point to your HTTP proxy when starting the DaemonSet. 

Use _e=PX\_HTTP\_PROXY=\<http-proxy>,PX\_HTTPS\_PROXY=\<https-proxy>_ query param when generating the DaemonSet spec.
