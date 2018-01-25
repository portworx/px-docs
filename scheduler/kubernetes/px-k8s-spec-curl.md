---
layout: page
title: "Generating Portworx Kubernetes spec using curl"
keywords: portworx, container, Kubernetes, storage, Docker, k8s, flexvol, pv, persistent disk
meta-description: "Find out how to generate the Portworx Kubernetes spec using curl."
---

* TOC
{:toc}

## Generating the Portworx spec using curl

Below is an example of using curl to generate the Portworx spec file. Review the [query parameters table](/scheduler/kubernetes/px-k8s-spec-curl.html#px-k8s-query-params) below and add parameters as needed.

>**Openshift Users:**<br/> Make sure you use `osft=true` when generating the spec.

```bash
$ VER=$(kubectl version --short | awk -Fv '/Server Version: /{print $3}')
$ curl -L -o px-spec.yaml "https://install.portworx.com?c=mycluster&k=etcd://<ETCD_ADDRESS>:<ETCD_PORT>&kbver=$VER"
```

Below are all parameters that can be given in the query string.
<a name="px-k8s-query-params"></a>

| Value  | Description                                                                                                                           | Example                                                    |
|:-------|:--------------------------------------------------------------------------------------------------------------------------------------|:-----------------------------------------------------------|
|        | <center>REQUIRED PARAMETERS</center>                                                                                                  |                                                            |
| c      | Specifies the unique name for the Portworx cluster.                                                                                   | <var>c=test_cluster</var>                                  |
| k      | Your key value database, such as an etcd cluster or a consul cluster.                                                                 | <var>k=etcd:http://etcd.fake.net:2379</var>                |
|        | <center>OPTIONAL PARAMETERS</center>                                                                                                  |                                                            |
| s      | Specify comma-separated list of drives.                                                                                               | <var>s=/dev/sdb,/dev/sdc</var>                             |
| d      | Specify data network interface. This is useful if your instances have non-standard network interfaces.                                | <var>d=eth1</var>                                          |
| m      | Specify management network interface. This is useful if your instances have non-standard network interfaces.                          | <var>m=eth1</var>                                          |
| kbver  | Specify Kubernetes version (current default is 1.7)                                                                                   | <var>kbver=1.8.4</var>                                     |
| stork  | Specify if you want to install STORK                                                                                        | <var>stork=true</var>                                     |
| coreos | REQUIRED if target nodes are running coreos.                                                                                          | <var>coreos=true</var>                                     |
| osft | REQUIRED if installing on Openshift.                                                                                          | <var> osft =true</var>                                     |
| mas    | Specify if PX should run on the Kubernetes master node. For Kubernetes 1.6.4 and prior, this needs to be true (default is false)      | <var>mas=true</var>                                        |
| z      | Instructs PX to run in zero storage mode on Kubernetes master.                                                                        | <var>z=true</var>                                          |
| f      | Instructs PX to use any available, unused and unmounted drives or partitions. PX will never use a drive or partition that is mounted. | <var>f=true</var>                                          |
| st     | Select the secrets type (_aws_, _kvdb_ or _vault_)                                                                                    | <var>st=vault</var>                                        |
|        | <center>KVDB CONFIGURATION PARAMETERS</center>                                                                                        |                                                            |
| pwd    | Username and password for ETCD authentication in the form user:password                                                               | <var>pwd=username:password</var>                           |
| ca     | Location of CA file for ETCD authentication.                                                                                          | <var>ca=/path/to/server.ca</var>                           |
| cert   | Location of certificate for ETCD authentication.                                                                                      | <var>cert=/path/to/server.crt</var>                        |
| key    | Location of certificate key for ETCD authentication.                                                                                  | <var>key=/path/to/server.key</var>                         |
| acl    | ACL token value used for Consul authentication.                                                                                       | <var>acl=398073a8-5091-4d9c-871a-bbbeb030d1f6</var>        |
| e      | Comma-separated list of environment variables that will be exported to portworx.                                                      | <var>e=MYENV1=myvalue1,MYENV2=myvalue2</var> |


>**Note:**<br/> If using secure etcd provide "https" in the URL and make sure all the certificates are in the `/etc/pwx/` directory on each host which is bind mounted inside PX container.
