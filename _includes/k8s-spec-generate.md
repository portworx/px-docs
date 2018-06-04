{{ include.asg-addendum }}

{{ include.env-addendum }}

To generate the spec file, head on to the below URLs for the PX release you wish to use.

* [1.4 Tech Preview](https://install.portworx.com/1.4/).
{% unless include.skip13 == "true" %}
* [1.3 Stable](https://install.portworx.com/1.3/).
{% endunless %}
{% unless include.skip12 == "true" %}
* [1.2 Stable](https://install.portworx.com/1.2/).
{% endunless %}

Alternately, you can use curl to generate the spec as described in [Generating Portworx Kubernetes spec using curl](/scheduler/kubernetes/px-k8s-spec-curl.html).

#### Secure ETCD and Certificates
If using secure etcd provide "https" in the URL and make sure all the certificates are in the _/etc/pwx/_ directory on each host which is bind mounted inside PX container.

##### Using Secrets to Provision Certificates
Instead of manually copying the certificates on all the nodes, it is recommended to use [Kubernetes Secrets to provide etcd certificates to Portworx](/scheduler/kubernetes/etcd-certs-using-secrets.html). This way, the certificates will be automatically available to new nodes joining the cluster.

#### Installing behind the HTTP proxy

During the installation Portworx may require access to the Internet, to fetch kernel headers if they are not available locally on the host system.  If your cluster runs behind the HTTP proxy, you will need to expose _PX\_HTTP\_PROXY_ and/or _PX\_HTTPS\_PROXY_ environment variables to point to your HTTP proxy when starting the DaemonSet.

Use _e=PX\_HTTP\_PROXY=\<http-proxy>,PX\_HTTPS\_PROXY=\<https-proxy>_ query param when generating the DaemonSet spec.
