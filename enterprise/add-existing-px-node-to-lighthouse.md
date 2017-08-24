---
layout: page
title: "Add Existing PX Node to Lighthouse"
keywords: portworx, lighthouse, px, config.json
sidebar: home_sidebar
redirect_from: "/add-existing-px-node-to-lighthouse.html"
meta-description: "Find out how to add your Portworx node to Lighthouse, the PX-Enterprise web console. Follow our step-by-step guide today!"
---

```
Note: This guide requires that both your PX node and lighthouse are talking to the same kvdb store.
```

Following guide shows you how you can add your portworx node to PX-Enterprise console.

* Setup your lighthouse container with the same kvdb store as your PX node. If you are following instructions from [our on premise Lighthouse](/enterprise/on-premise-lighthouse.html), then you can specify this kvdb url to lighthouse with '-k' option.
* Visit your lighthouse URL in the browser, and complete initial setup.
* Once you are logged in, click on 'Manage clusters' button. This will take you to a new page. Here, click on 'New'. This will open a widget. Here click on 'Existing Cluster'. Add your cluster ID here.
* Once you click 'Create', it will generate 'Auth Token' for this cluster.
* Login to each PX node, and add following line in config.json located at /etc/pwx

```
"loggingurl": "<your-lighthouse-url>/api/stats/listen?token=<Auth-Token>",
```

* Restart PX container on each node. 

At this point, you should be able to monitor PX node from web console.
