---
layout: page
title: "CLI Reference–License"
keywords: portworx, pxctl, command-line tool, cli, reference,license
sidebar: home_sidebar
redirect_from: "/cli-reference.html"
---

* TOC
{:toc}

NOTE: This is available from version 1.2.8 onwards.<br>
Licensing gives details of the licenses present with details of the various features allowed and its limits within a given license.


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

### pxctl license activate

`pxctl license activate <activation>` command is used to activate the activation id. You will get activation id from portworx.

### pxctl license add

`pxctl license add <license file>` command is used to add license. Generally user will use activation id to activate license, but some user might need to download license file on the local machines,example without internet access.

### pxctl license trial

`pxctl license trial` command is used to activate 30 day enterprise license. 
Note: this command is only applicable for px-dev only.

```
/opt/pwx/bin/pxctl license trial
Successfully activated trial license.
```

