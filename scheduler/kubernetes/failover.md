---
layout: page
title: "Testing failover of stateful applications"
keywords: portworx, failover, container, Kubernetes, storage, Docker, k8s, flexvol, pv, persistent disk
sidebar: home_sidebar
meta-description: "Learn how to failover a stateful application using Kubernetes and Portworx.  Try it for yourself today."
---

## Failover MYSQL Pod to a different node

### Show Database
````
export MYSQLPOD=$(kubectl get pods -l app=mysql --no-headers | awk '{print $1}')
kubectl logs $MYSQLPOD
kubectl exec -ti $MYSQLPOD -- bash
mysql --user=root --password=password
show databases;
exit
exit
````

### Create a database 

````
export MYSQLPOD=$(kubectl get pods -l app=mysql --no-headers | awk '{print $1}')
kubectl logs $MYSQLPOD
kubectl exec -ti $MYSQLPOD -- bash
mysql --user=root --password=password
create database TEST_1234;
show databases;
exit
exit
````

### Let's find what node the mysql pod is running
````
export MYSQL_NODE=$(kubectl describe pod -l app=mysql | grep Node: | awk -F'[ \t//]+' '{print $2}')
echo $MYSQL_NODE
````
### Mark node as unschedulable.
````
kubectl cordon $MYSQL_NODE
````
### Delete the pod.  
````
kubectl delete pod -l app=mysql
````
### Verify the pod has moved to a different node
````
kubectl describe pods -l app=mysql
````
### Verify we can see the database we created
````
export MYSQLPOD=$(kubectl get pods -l app=mysql --no-headers | awk '{print $1}')
kubectl logs $MYSQLPOD
kubectl exec -ti $MYSQLPOD -- bash
mysql --user=root --password=password
show databases;
exit
exit
````
###  Clean up 

### Bring the node back online
````
kubectl uncordon $MYSQL_NODE
````

### Delete database
````
export MYSQLPOD=$(kubectl get pods -l app=mysql --no-headers | awk '{print $1}')
kubectl logs $MYSQLPOD
kubectl exec -ti $MYSQLPOD -- bash
mysql --user=root --password=password
drop database TEST_1234;
show databases;
exit
````
