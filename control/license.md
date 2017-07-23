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

OPTIONS:
   --help, -h  show help
```
### pxctl license list

`pxctl license list` command is used to list the details of the licenses. This command gives details of various features limits allowed to run under the current license for the end user. Product SKU gives the details of the license. 

```
/opt/pwx/bin/pxctl license list
DESCRIPTION                  ENABLEMENT      ADDITIONAL INFO
Number of nodes maximum         1000
Number of volumes maximum       1024
Volume capacity [TB] maximum      40
Storage aggregation              yes
Shared volumes                   yes
Volume sets                      yes
BYOK data encryption             yes
Resize volumes on demand         yes
Snapshot to object store         yes
Bare-metal hosts                 yes
Virtual machine hosts            yes
Product SKU                     Trial        expires in 30 days

LICENSE EXPIRES: 2017-08-17 23:59:59 +0000 UTC
For information on purchase, upgrades and support, see
https://docs.portworx.com/knowledgebase/support.html
```

### pxctl license activate

`pxctl license activate <activation-id>` command is used to activate the activation id. You will get activation id from portworx.

### pxctl license add

`pxctl license add <license file>` command is used to add license. Generally user will use activation id to activate license, but some user might need to download license file on the local machines,example without internet access.

