# Kubernetes with Portworx on CoreOS with Packet.net

## Deploy CoreOS Cluster
Use Terraform to stand up etcd and Portworx on CoreOS on Packet.
Here is the [Terraporx Repository](https://github.com/portworx/terraporx/tree/master/packet/coreos)
Use these scripts to quickly/easily get a 5-node cluster up in 10 minutes

## Deploy Kubernetes
Follow [this guide](https://coreos.com/kubernetes/docs/latest/getting-started.html)

Since this cluster is based on CoreOS, the `etcd` cluster comes pre-configured.

### Generate TLS Assets
Follow [the CoreOS Guide](https://coreos.com/kubernetes/docs/latest/openssl.html) 
for generating `Cluster Root CA`, `API Server Keypair`, and `Cluster Administrator Keypair`

####  Generate Worker Keypairs
For generating worker keyparis, here's a script to help with the iteration

```
#!/usr/bin/env python

import os

worker_fqdn = [ "kube-worker-1","kube-worker-2","kube-worker-3","kube-worker-4"]
worker_ip = [ "10.100.48.5","10.100.48.1","10.100.48.9","10.100.48.3"]

for (fqdn,ip) in zip(worker_fqdn, worker_ip):

   os.system ("openssl genrsa -out ${WORKER_FQDN}-worker-key.pem 2048")
   os.system ("WORKER_IP=%s openssl req -new -key %s-worker-key.pem -out %s-worker.csr -subj \"/CN=%s\" -config worker-openssl.cnf" %
               (ip, fqdn, fqdn, fqdn))```
```


