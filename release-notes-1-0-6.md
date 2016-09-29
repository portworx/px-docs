---
layout: page
title: "Release notes 1.0.6"
keywords: portworx, px-enterprise, release notes
sidebar: home_sidebar
---

### Release date: Sept 29th, 2016

## Key enhancements to the previous release
* Support for Consul
* Ability to add storage to a head-only node
* Ability to import data from an external storage source
* Ability to bootstrap and deploy PX through external automated procedures.  PX takes command line parameters and does not need a config.json. 
* Support for Rancher


## Key bugs addressed since the previous release
* Fix for occasional PX node restart.  Occasionaly during heavy load, a PX node would get marked down by gossip, and asked to restart.  While this did not cause any noticable delay in IO, it would flood the logs with gossip error messages.  This bug has been fixed.
* Minor CLI enhancements around displaying IP addresses instead of node IDs (where possible).

