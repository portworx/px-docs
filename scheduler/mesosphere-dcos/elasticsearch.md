---
layout: page
title: "Elasticsearch on DCOS with Portworx"
keywords: portworx, container, Mesos, Mesosphere, DCOS, Elasticsearch
meta-description: "Find out how to install the ElasticSearch service on your DCOS cluster. Follow our step-by-step guide to running stateful services on DCOS today!"
---

* TOC
{:toc}

This guide will help you to install the Elasticsearch service on your DCOS cluster backed by PX volumes for persistent storage.

Since the stateful services in DCOS universe do not have support for external volumes, you will need to add additional
repositories to your DCOS cluster to install the services mentioned here. 

The source code for these services can be found here: [Portworx DCOS-Commons Frameworks](https://github.com/portworx/dcos-commons)

>**Note:**<br/>This framework is only supported directly by Portworx.
>Please contact support@portworx.com directly for any support issues related with using this framework.

Please make sure you have installed [Portworx on DCOS](/scheduler/mesosphere-dcos/install.html) before proceeding further.

## Adding the repository for the service:

For this step you will need to login to a node which has the dcos cli installed and is authenticated to your DCOS cluster.

Run the following command to add the repository to your DCOS cluster:

```
 $ dcos package repo add --index=0 elastic-px https://px-dcos.s3.amazonaws.com/v1/elastic/elastic.zip
```

Once you have run the above command you should see the Cassandra-PX service available in your universe

![Elasticsearch-PX in DCOS Universe](/images/elasticsearch-px-universe-001.PNG)

## Installation
### Default Install
If you want to use the defaults, you can now run the dcos command to install the service
```
$ dcos package install --yes elastic-px
```
You can also click on the  “Install” button on the WebUI next to the service and then click “Install Package”.

### Advanced Install
If you want to modify the default, click on the “Install” button next to the package on the DCOS UI and then click on
“Advanced Installation”

Here you have the option to change the service name, secret name, and principal..etc. Then you can change individual components setting of elastic search, such as ``master_nodes`` volume name and volume size, and provide any additional options that you
want to pass to the docker volume driver on ``PORTWORX_VOLUME_OPTIONS``. The default number of master_node count is 3 and this is not changeable. The default number of ``data_nodes`` count is 2; and default count for ``ingest_nodes``, ``coordinator_nodes``, ``kibana`` is 1 and can be changed.  


![Elasticsearch install options](/images/elasticsearch-px-universe-002.PNG)

![Elasticsearch install options](/images/elasticsearch-px-universe-003.PNG)


Click on “Review and Install” and then “Install” to start the installation of the service.

### Check installation

Monitor the DCOS service screen untill all ``9 + 1`` tasks are completed.

![Elasticsearch install status](/images/elasticsearch-px-universe-004.PNG)

![Elasticsearch install status](/images/elasticsearch-px-universe-004.PNG)


From the DCOS workstation, verify the service, look for ``elastic``

     $ dcos service
     NAME                  HOST             ACTIVE  TASKS  CPU     MEM      DISK   ID
     elastic    ip-10-0-1-194.ec2.internal   True     9    7.1   19556.0    0.0    41474f9b-6b81-44ba-ad2c-184f71efbb26-0003
     etcd       ip-10-0-2-56.ec2.internal    True     3    3.3    6240.0  12288.0  41474f9b-6b81-44ba-ad2c-184f71efbb26-0002
     marathon           10.0.5.179           True     7    10.7  12416.0    0.0    41474f9b-6b81-44ba-ad2c-184f71efbb26-0000
     metronome          10.0.5.179           True     0    0.0     0.0      0.0    41474f9b-6b81-44ba-ad2c-184f71efbb26-0001

From the DCOS workstation, verify the task; it will show ``9`` tasks.

      $ dcos task |grep -iv etcd |grep -iv px
      NAME                HOST        USER  STATE  ID
      coordinator-0-node  10.0.0.236  root    R    coordinator-0-node__1287a918-20a1-4c1d-a008-3426ebb4e229
      data-0-node         10.0.2.96   root    R    data-0-node__f7e584a7-1684-4ce9-80b8-2b112e02aa02
      data-1-node         10.0.0.236  root    R    data-1-node__47e5b205-82f9-4950-851f-c9eda469dd19
      elastic             10.0.1.194  root    R    elastic.0eedb90c-3c06-11e7-aa5d-6a7db698255f
      ingest-0-node       10.0.1.194  root    R    ingest-0-node__23c02a10-9e36-4e97-bb8a-7a8fd6657f7b
      kibana-0-node       10.0.2.56   root    R    kibana-0-node__550a1a8c-e508-470d-926a-ff0461d3b561
      master-0-node       10.0.1.194  root    R    master-0-node__69072b45-423a-4bd1-a181-0115277d5a63
      master-1-node       10.0.2.56   root    R    master-1-node__c97b196c-969c-49f1-bdc2-a80fe14d6daf
      master-2-node       10.0.0.19   root    R    master-2-node__2d1bd321-1ca2-46e1-96b3-6049f04784b9
      proxylite-0-server  10.0.2.96   root    R    proxylite-0-server__f7d4d08a-507f-4b7d-856a-6c3e264b03dc


In the above example, the DCOS Mesos cluster is running with 1 master, 1 public slave and 5 private slave agents. Elasticsearch components will be distributed evenly on every slave agents. See below diagram of the example setup.

![Elasticsearch example setup](/images/elasticsearch-px-universe-006.PNG)


When the last elasticsearch  component with ID ``elastic.XXXX`` that is the scheduler service shows green, and all 
elasticsearch tasks are in Running (green) status, you should be ready to start using the elasticsearch in DCOS.

![Elasticsearch service running](/images/elasticsearch-px-universe-007.PNG)

### Check PX volumes 

The PX volumes for all elasticsearch task components are automatically created, and you can check that from one of the mesos private agent node

    $ dcos node ssh --master-proxy --mesos-id=41474f9b-6b81-44ba-ad2c-184f71efbb26-S1 '/opt/pwx/bin/pxctl v l'
      Running `ssh -A -t core@34.203.197.47 ssh -A -t core@10.0.0.236 /opt/pwx/bin/pxctl v l`
      ID                      NAME                    SIZE    HA      SHARED  ENCRYPTED       IO_PRIORITY     SCALE   STATUS
      471143287909897714      CoordinatorNodeVolume-0 1 GiB   1       no      no              LOW             0       up - attached on 10.0.0.236 
      473886186773881112      DataNodeVolume-0        10 GiB  1       no      no              LOW             0       up - attached on 10.0.2.96
      94264136141713933       DataNodeVolume-1        10 GiB  1       no      no              LOW             0       up - attached on 10.0.0.236 
      621227572710557179      IngestNodeVolume-0      2 GiB   1       no      no              LOW             0       up - attached on 10.0.1.194 
      236802011708171217      KibanaVolume-0          1 GiB   1       no      no              LOW             0       up - attached on 10.0.2.56 
      513496078941740225      MasterNodeVolume-0      2 GiB   1       no      no              LOW             0       up - attached on 10.0.1.194 
      859913199692077675      MasterNodeVolume-1      2 GiB   1       no      no              LOW             0       up - attached on 10.0.2.56 
      1016863270687558253     MasterNodeVolume-2      2 GiB   1       no      no              LOW             0       up - attached on 10.0
    
### Test run Elasticsearch on DCOS

Find the elastic search coordinator endpoint from DCOS workstation

     $ dcos elastic endpoints coordinator
     {
        "address": [
        "10.0.0.236:1029",
        "10.0.0.236:1030"
         ],
        "dns": [
        "coordinator-0-node.elastic.mesos:1029",
        "coordinator-0-node.elastic.mesos:1030"
        ],
       "vip": "coordinator.elastic.l4lb.thisdcos.directory:9300"
     }
     
SSH to the DCOS master node; from the DCOS workstation use ``dcos node ssh`` command

    $ dcos node ssh --master-proxy --leader

From the DCOS master node, run the Elasticsearch REST API to the coordinator address at port 9200. The default credential is ``elastic:changeme`` for the coordinator. A json output from coordinator node is shown below by accessing the coordinator port ``9200``.

    
    $ curl -s -u elastic:changeme http://coordinator.elastic.l4lb.thisdcos.directory:9200
     {
        "name" : "coordinator-0-node",
        "cluster_name" : "elastic",
        "cluster_uuid" : "2IVa4DVyRoaGXXzebdHdvw",
        "version" : {
          "number" : "5.3.0",
          "build_hash" : "3adb13b",
          "build_date" : "2017-03-23T03:31:50.652Z",
          "build_snapshot" : false,
          "lucene_version" : "6.4.1"
     },
     "tagline" : "You Know, for Search"
     }


Loading sample data in REST API from DCOS master node. Below showing an example of inserting a json document.

     $ curl -s -u elastic:changeme -XPUT 'coordinator.elastic.l4lb.thisdcos.directory:9200/books/book/2' -d '
       {
         "title": "test book 1",
         "author": "bok hun",
         "language": "C++",
         "publishYear": 2015,
         "summary": "test book C++."
       }'


Verify the inserted document 

     $ curl -s -u elastic:changeme -XGET 'coordinator.elastic.l4lb.thisdcos.directory:9200/books/book/2?pretty'
       {
         "_index" : "books",
         "_type" : "book",
         "_id" : "2",
         "_version" : 1,
         "found" : true,
         "_source" : {
           "title" : "test book 1",
           "author" : "bok hun",
           "language" : "C++",
           "publishYear" : 2015,
           "summary" : "test book C++."
          }
        }
    
Repeat inserting 4 more sample documents, then issue a search query to look for string "java" in the entered document.

     $ curl -s -u elastic:changeme -XPOST 'coordinator.elastic.l4lb.thisdcos.directory:9200/books/book/_search' '
      {
         "query" :
         {
            "query_string":
             {
               "query": "java"
              }
         }
      }'


### Inserting document from Chrome Sense plugin

Use Chrome Sense plugin from Google Chrome and you can do the document insert and query in Chrome browser. Before that you will have to establish a ssh tunnel from DCOS master node to the corrdinator port 9200. [Sense plugin for Chrome](https://chrome.google.com/webstore/detail/sense-beta/lhjgkmllcaadmopgmanpapmpjgmfcfig?hl=en) can be obtained from here.

Below is the screen for inserting document in Chrome Sense; the POST command will execute once the green arrow is clicked.

![Elasticsearch input data from Chrome Sense](/images/elasticsearch-px-universe-009.PNG)

The following is running a search query for "java" from Chrome Sense

![Elasticsearch input data from Chrome Sense](/images/elasticsearch-px-universe-010.PNG)


### Kibana in DCOS

The kibana URL is ``http://<dcos_url>/service/elastic/kibana/login`` ; and the default login ID and password is ``elastic`` and ``changeme``.

Login to the Kibana

![Elasticsearch input data from Chrome Sense](/images/elasticsearch-px-universe-011.PNG)

Create the default Index pattern

![Elasticsearch input data from Chrome Sense](/images/elasticsearch-px-universe-012.PNG)

On the Kibana console click "Discover" on the left menu, and observe  number of hits with search ``*`` 

![Elasticsearch input data from Chrome Sense](/images/elasticsearch-px-universe-013.PNG)

And replace the ``*`` with ``books`` in the search field, that is the ``books`` index documents hits

![Elasticsearch input data from Chrome Sense](/images/elasticsearch-px-universe-014.PNG)

Document insert and query can also be done in ``Dev Tools`` similar like Chrome Sense

![Elasticsearch input data from Chrome Sense](/images/elasticsearch-px-universe-015.PNG)





