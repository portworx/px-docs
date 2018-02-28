To generate the spec file, head on to [https://install.portworx.com](https://install.portworx.com) and fill in the parameters. When filing the _kbver_ (Kubernetes version) on the page, use output of: 

```
kubectl version --short | awk -Fv '/Server Version: /{print $3}'
```

Alternately, you can use curl to generate the spec as described in [Generating Portworx Kubernetes spec using curl](/scheduler/kubernetes/px-k8s-spec-curl.html).

>**Secure ETCD:**<br/> If using secure etcd provide "https" in the URL and make sure all the certificates are in the _/etc/pwx/_ directory on each host which is bind mounted inside PX container.


##### Installing behind the HTTP proxy

During the installation Portworx may require access to the Internet, to fetch kernel headers if they are not available locally on the host system.  If your cluster runs behind the HTTP proxy, you will need to expose _PX\_HTTP\_PROXY_ and/or _PX\_HTTPS\_PROXY_ environment variables to point to your HTTP proxy when starting the DaemonSet. 

Use _e=PX\_HTTP\_PROXY=\<http-proxy>,PX\_HTTPS\_PROXY=\<https-proxy>_ query param when generating the DaemonSet spec.