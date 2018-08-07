---
layout: page
title: "Run Lighthouse as Marathon service"
keywords: portworx, container, Mesos, Mesosphere, storage, lighthouse, GUI
meta-description: "Find out how to deploy Lighthouse as a marathon service."
---

Lighthouse is a GUI dashboard that can be used to monitor multiple Portworx clusters. The Portworx package
in the DCOS Universe allows you to install Lighthouse which manages the cluster it is deployed with.
If you want to connect multiple Portworx clusters to Lighthouse, it is recommended to run Lighthouse as a
separate Marathon service and connect Portworx clusters to it.

>**Note:**<br/>This Lighthouse is supported from PX Enterprise 1.4 onwards

### Deploying Lighthouse
Use the following Marathon service file to run Lighthouse:
```
{
  "id": "/lighthouse",
  "instances": 1,
  "container": {
    "type": "DOCKER",
    "volumes": [
      {
        "persistent": {
          "size": 100
        },
        "mode": "RW",
        "containerPath": "config"
      }
    ],
    "docker": {
      "image": "portworx/px-lighthouse:1.4.2"
    }
  },
  "cpus": 0.3,
  "mem": 1024,
  "requirePorts": false,
  "cmd": "/entry-point.sh -confpath $MESOS_SANDBOX/config -http_port 8085"
}
```

### Accessing Lighthouse
Since Lighthouse is deployed on a private agent it might not be accessible from outside your network depending on your
network configuration. To access Lighthouse from an external network you can deploy the
[Repoxy](https://gist.github.com/nlsun/877411115f7e3b885b5e9daa8821722f) service to redirect traffic from one of the
public agents.

To do so, run the following Marathon application:
```
{
  "id": "/repoxy",
  "cpus": 0.1,
  "acceptedResourceRoles": [
      "slave_public"
  ],
  "instances": 1,
  "mem": 128,
  "container": {
    "type": "DOCKER",
    "docker": {
      "image": "mesosphere/repoxy:2.0.0"
    },
    "volumes": [
      {
        "containerPath": "/opt/mesosphere",
        "hostPath": "/opt/mesosphere",
        "mode": "RO"
      }
    ]
  },
  "cmd": "/proxyfiles/bin/start marathon $PORT0",
  "portDefinitions": [
    {
      "port": 9998,
      "protocol": "tcp"
    },
    {
      "port": 9999,
      "protocol": "tcp"
    }
  ],
  "requirePorts": true,
  "env": {
    "PROXY_ENDPOINT_0": "Lighthouse,http,lighthouse,mesos,8085,/,/"
  }
}
```

You can then access the Lighthouse WebUI on http://\<public_agent_IP\>:9998.
If your public agent is behind a firewall you will also need to open up two ports, 9998 and 9999.
