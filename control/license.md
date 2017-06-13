---
layout: page
title: "CLI Reference"
keywords: portworx, pxctl, command-line tool, cli, reference,license
sidebar: home_sidebar
redirect_from: "/cli-reference.html"
---

* TOC
{:toc}

### License help

`pxctl license --help` command gives details of the help.
```
/opt/pwx/bin/pxctl license --help
NAME:
   pxctl license - Manage licenses

USAGE:
   pxctl license command [command options] [arguments...]

COMMANDS:
     list, l        List available licenses
     add            Add a license from a file
     activate, act  Activate license from a license server
     trial, try     Activate 30 day trial license

OPTIONS:
   --help, -h  show help
   
```
### pxctl license list

`pxctl license list` command is used to list the details of the licenses. This command gives details of various features limits allowed to run under the current license for the end user. Product SKU gives the details of the license. 

```
 /opt/pwx/bin/pxctl license list
DESCRIPTION				ENABLEMENT	ADDITIONAL INFO
Number of nodes maximum			1000		
Number of volumes maximum		1024		
Volume capacity [TB] maximum		  40		
Aggregated volumes			 yes		
Shared volumes				 yes		
Volume sets				 yes		
Data Encryption				 yes		
Resize volumes on demand		 yes		
Snapshot to object store		 yes		
Enable bare-metal platforms		 yes		
Enable virtual machine platforms	 yes		
Product SKU				Trial		expires in 6 days, 2:59

LICENSE EXPIRES: 2017-06-19 23:59:59 +0000 UTC
For information on purchase, upgrades and support, see
https://portworx.com/products/support
```

