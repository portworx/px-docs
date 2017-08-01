---
layout: page
title: "Dynamic volume creation through DCOS"
keywords: portworx, px-enterprise, storage, volume, create volume, clone volume, inline, dynamic volumes
sidebar: home_sidebar
redirect_from: "/create-manage-storage-volumes.html"
meta-description: "Read the overview on how volumes can be created dynamically through DCOS. Gain a better understanding of dynamic volumes here!"
---

* TOC
{:toc}

## Inline volume spec
PX supports passing the volume spec inline along with the volume name.  This is useful when creating a volume with DCOS through a marathon application template.  Using the inline spec, volumes can be created dynamically and all PX properties, such as volume size, encryption keys etc can be passed in through marathon.

For example, a PX inline spec can be specified as the following:

```json
"parameters": [
	{
		"key": "volume-driver",
		"value": "pxd"
	},
	{
		"key": "volume",
		"value": "size=100G,repl=3,cos=3,name=mysql_vol:/var/lib/mysql"
	}],
```

The above command will create a volume called mysql_vol with an initial size of 100G, HA factor of 3 and a IO priority level of 3 for the mysql container.

Each spec key must be comma separated.  The following are supported key value pairs:

```
IO priority      - cos=[1,2,3]
Volume size      - size=[1..9][G|M|T]
HA factor        - repl=[1,2,3]
Block size       - bs=[4096...]
Shared volume    - shared=true
File System      - fs=[xfs|ext4]
Encryption       - passphrase=secret
```

These inline specs can be passed in through the scheduler application template or framework
