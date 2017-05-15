---
layout: page
title: "Portworx on the Digital Ocean Cloud Platform"
keywords: portworx, digital ocean, PaaS, IaaS, docker, converged
sidebar: home_sidebar
---

* TOC
{:toc}

This guide shows you how you can easily deploy Portworx on the [**digitalocean.com** cloud platform](http://digitalocean.com)
using [Terraform](http://terraform.io) infrastructure automation.

Following these simple instructions you can have a 3-node Portworx cluster up and running in under 5 minutes.

Other supported bare metal cloud providers are

* [Packet.net](/cloud/packet.html)
* [Rackspace](/cloud/rackspace.html)

Pre-requisites:   You will need to have a valid Digital Ocean account

### Step 1: Install Terraform

Download, unzip and install Terraform for your particular OS distro from the main [Terraform Download site](https://www.terraform.io/downloads.html)

### Step 2: Clone the Terraporx Repository

```
git clone https://github.com/portworx/terraporx.git
cd terraporx/digital_ocean
```

### Step 3: Select your OS Distro
This Digital Ocean repository currently supports 3 different Linux OS flavors: 

* CoreOS
* Ubuntu16
* CentOS7

Select and `cd` into the OS distro of your choice.

The scripts for Ubuntu and CentOS will both install the current version 
of **'docker-ce'** and launch a single **'etcd'** container for the Portworx required 'kvdb'.

CoreOS will configure **user_data** to launch the internal **'etcd2'** service and also launch **'px-dev'** as a 'systemd' service.

### Step 4: Configure your Terraform variables

The following variable definitions are required in the `vars.tf` file in the corresponding OS directory:

* 'do_token'  : Your Digital Ocean API key.  Obtain or generate your token from here [https://cloud.digitalocean.com/settings/api/tokens](https://cloud.digitalocean.com/settings/api/tokens)
* 'region'    : These scripts require block storage, which is only available in these regions **fra1, nyc1, sfo2 and sgp1**
* 'size'      : These are the valid instance sizes (strings) : **"2gb", "4gb", "8gb", "16gb", "32gb", "48gb", "64gb"**
* 'volsize'   : These are the valid external volume sizes (integer in GB):  **100, 250, 500, 1000, 2000**
* 'prefix'    : An arbitrary distinguishing name for your cluster prefix
* 'ssh_key_path'  :  The path to your private SSH key
* 'pub_key'       :  The contents of your public SSH key
* 'ssh_fingerprint' :  The fingerprint of your SSH key, best obtained via `ssh-keygen -E md5  -lf ~/.ssh/id_rsa.pub`

In addition for CoreOS, you will need to supply a *'discovery_url'* for the 'etcd' service,
which can be best obtained from the output of `curl http://discovery.etcd.io/new?size=3`

Make sure the SSH key variables correspond to a valid SSH key in your Digital Ocean profile
in the Security settings for your account [https://cloud.digitalocean.com/settings/security](https://cloud.digitalocean.com/settings/security)

### Step 5: Create your cluster

Run `terraform apply`
If all variables have been properly specified then after a few minutes, the following output will appear:

```
Outputs:

ip-addrs = [
    ssh core@138.197.219.111,
    ssh core@138.68.225.115,
    ssh core@138.68.248.179
]
```

You can then login to validate the cluster state:

```
ssh core@138.197.219.111
The authenticity of host '138.197.219.111 (138.197.219.111)' can't be established.
ECDSA key fingerprint is 0e:9f:26:88:2a:3b:66:3d:08:11:b7:70:84:df:92:1f.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '138.197.219.111' (ECDSA) to the list of known hosts.
Container Linux by CoreOS stable (1353.7.0)
Update Strategy: No Reboots
core@my-coreos-1 ~ $ sudo /opt/pwx/bin/pxctl status
Status: PX is operational
Node ID: dd2d8751-3740-4188-9915-741d1b2996f5
	IP: 138.197.219.111
 	Local Storage Pool: 1 pool
	POOL	IO_PRIORITY	RAID_LEVEL	USABLE	USED	STATUS	ZONE	REGION
	0	MEDIUM		raid0		100 GiB	2.0 GiB	Online	default	default
	Local Storage Devices: 1 device
	Device	Path		Media Type		Size		Last-Scan
	0:1	/dev/sda	STORAGE_MEDIUM_MAGNETIC	100 GiB		15 May 17 17:57 UTC
	total			-			100 GiB
Cluster Summary
	Cluster ID: px-cluster-coreos
	IP		ID					Used	Capacity	Status
	10.138.40.143	3a96fe16-ee59-4221-908a-53dea0d0734d	0 B	100 GiB		Online
	10.138.48.159	dd2d8751-3740-4188-9915-741d1b2996f5	0 B	100 GiB		Online (This node)
	10.138.40.145	9ad0ed12-16a1-4ecb-86da-bd5e7f321f05	0 B	100 GiB		Online
Global Storage Pool
	Total Used    	:  0 B
	Total Capacity	:  300 GiB
  ```

### Step 6: (optional)  Tear down your cluster

To teardown the cluster, use `terraform destroy` or `terraform destroy --force`

