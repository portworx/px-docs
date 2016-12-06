---
layout: page
title: "On-Prem Lighthouse Release Notes"
keywords: portworx, px-enterprise, px-lighthouse, release notes
sidebar: home_sidebar
---

## Lighthouse 1.1.2 Release notes


### Key Fixes

* Handle kvdb access failures and show banner alerts to indicate access issues
* Handle influxDB access timeouts and show banner alerts to indicate access issues
* Improve feedback on Consul and influxDB container restarts
* Fix panics around influx or consul being down and when customer does first login after initial setup
* Fix inability to create new clusters after a node is added to a cluster

### Known issues

* This version does not support clear alerts. This will be fixed in the upcoming 1.1.3 release along with the addition of "Clear All Alerts" capability.

