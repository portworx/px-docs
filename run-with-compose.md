---
layout: page
title: "Run PX-Developer with Docker Compose"
sidebar: home_sidebar
---
You can run PX-Developer with [docker-compose](https://docs.docker.com/compose/install/) as follows:

```
# git clone https://github.com/portworx/px-dev.git
# cd px-dev/quick-start
# docker-compose run portworx -daemon --kvdb=etcd:http://myetcd.example.com:4001 --clusterid=YOUR_CLUSTER_ID --devices=/dev/xvdi
```

OR, if you have a custom [px configuration file](https://github.com/portworx/px-dev/edit/master/quick-start/config.json) at `/etc/pwx/config.json`, you can start PX-Developer as follows:

```
# docker-compose up -d
```

You now have a scale-out storage cluster for containers. To continue, refer to the resources listed in [Get Started with PX-Developer](get-started-px-developer.html).
