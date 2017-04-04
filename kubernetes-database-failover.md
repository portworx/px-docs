---
layout: page
title: "Failover a database using Kubernetes"
keywords: portworx, container, Kubernetes, storage, Docker, k8s, stateful application failover, database failover, pv, pv claim, persistent disk
sidebar: home_sidebar
---
One of the most powerful features of Kubernetes is stateful application failover.  Using [PVs](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) and [PV Claims](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#persistentvolumeclaims), Kubernetes can reschedule a pod when a host fails and make sure that it has its data when it rescheduled on a new node.

We can see this in action using PX volumes below.

### Failover MYSQL Pod to a different node

#### Show Database
````
export MYSQLPOD=$(kubectl get pods -l app=mysql --no-headers | awk '{print $1}')
kubectl logs $MYSQLPOD
kubectl exec -ti $MYSQLPOD -- bash
mysql --user=root --password=password
show databases;
exit
exit
````

#### Create a database 

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

#### Let's find what node the mysql pod is running
````
export MYSQL_NODE=$(kubectl describe pod -l app=mysql | grep Node: | awk -F'[ \t//]+' '{print $2}')
echo $MYSQL_NODE
````
#### Mark node as unschedulable.
````
kubectl cordon $MYSQL_NODE
````
#### Delete the pod.  
````
kubectl delete pod -l app=mysql
````
#### Verify the pod has moved to a different node
````
kubectl describe pods -l app=mysql
````
#### Verify we can see the database we created
````
export MYSQLPOD=$(kubectl get pods -l app=mysql --no-headers | awk '{print $1}')
kubectl logs $MYSQLPOD
kubectl exec -ti $MYSQLPOD -- bash
mysql --user=root --password=password
show databases;
exit
exit
````
####  Clean up 

#### Bring the node back online
````
kubectl uncordon $MYSQL_NODE
````

#### Delete database
````
export MYSQLPOD=$(kubectl get pods -l app=mysql --no-headers | awk '{print $1}')
kubectl logs $MYSQLPOD
kubectl exec -ti $MYSQLPOD -- bash
mysql --user=root --password=password
drop database TEST_1234;
show databases;
exit
````

Read on for detailed instructions on running stateful services on Kubernetes.

* [Install PX into an Kubernetes 1.6 cluster]()
* [Force Kubernetes to schedule pods on hosts with your data](/kubernetes-convergence.html)
* [Create Kubernetes Storage Class](/kubernetes-define-storage-class.html)
* [Using pre-provisioned volumes with Kubernetes](/kubernetes-preprovisioned-volumes.html)
* [Dynamically provision volumes with Kubernetes](/kubernetes-dynamically-provisioned-volumes.html)
* [Using Stateful sets](/kubernetes-stateful-sets.html)
* [Running a pod from a snapshot](/kubernetes-running-a-pod-from-snapshot.html)
* [Failover a database using Kubernetes](kubernetes-database-failover.html)
* [Install PX on Kubernetes < 1.6](/kubernetes-run-with-flexvolume.html)
* [Cost calculator for converged container cluster using Kubernetes and Portworx](kubernetes-infrastructure-cost-calculator.html)