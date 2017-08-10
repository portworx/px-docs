---
layout: page
title: "Deploy Jenkins on Portworx"
keywords: portworx, jenkins
sidebar: home_sidebar
redirect_from: "/jenkins.html"
---

* TOC
{:toc}

Portworx can easily be used to simplify the deployment of Jenkins running as a container, as shown by the example below

## Create Portworx Volume
The example below create a 5GB "jenkins_vol1" volume, replicated on 3 different nodes.

```
docker volume create -d pxd --name jenkins_vol1 --opt size=5 --opt repl=3
```

## Launch Jenkins through Docker
Using the name of the volume previously created, start up Jenkins as a container.

```
docker run -d -p 49001:8080 -v jenkins_vol1:/var/jenkins_home:z -t jenkins
```

## Provide the Secret Password
Bring up a browser to the host where you launched Jenkins on port 49001.
You should see 

![jenkins1](/images/jenkins1.png){:width="1998px" height="1170px"}

Run "docker ps" to find the CONTAINER ID of the Jenkins container:

```
[root@mesos2 ~]# docker ps
CONTAINER ID        IMAGE                    COMMAND                  CREATED             STATUS              PORTS                                NAMES
9dfa72c4328c        jenkins                  "/bin/tini -- /usr/lo"   29 seconds ago      Up 23 seconds       50000/tcp, 0.0.0.0:49001->8080/tcp   ecstatic_ptolemy
```

Run the following command to extract the secret password (substituting the actual CONTAINER ID):

```
docker exec -it 9dfa72c4328c cat /var/jenkins_home/secrets/initialAdminPassword
```

## Complete the Installation

Install the Suggested Plugins

![Install Suggested Plugins](/images/jenkins2.png){:width="1998px" height="1184px"}

Configure the Admin User

![Configure Admin User](/images/jenkins3.png){:width="1992px" height="1156px"}

Start Using Jenkins

![Start Using Jenkins](/images/jenkins4.png){:width="2560px" height="1258px"}

## How to speed up Jenkins

Be sure to read ["How to speed up Jenkins builds"](https://portworx.com/speed-up-jenkins-builds/) on the ways in which Portworx can help improve Jenkins performance and speed up CI/CD workloads.  

## Highly Resilient Jenkins Using Docker Swarm

Be sure to read ["Highly Resilient Jenkins Using Docker Swarm"](https://portworx.com/jenkins-docker-swarm/) on way to deploy fault-tolerant on Docker Swarm with Portworx
