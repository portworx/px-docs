---
layout: page
title: "Kafka on DCOS with Portworx"
keywords: portworx, container, Mesos, Mesosphere, kafka
meta-description: "Find out how to install the Kafka service on your DCOS cluster. Follow our step-by-step guide to running stateful services on DCOS today!"
---

* TOC
{:toc}

This guide will help you to install the Kafka service on your DCOS cluster backed by PX volumes for persistent storage.

Since the stateful services in DCOS universe do not have support for external volumes, you will need to add additional
repositories to your DCOS cluster to install the services mentioned here. 

The source code for these services can be found here: [Portworx DCOS-Commons Frameworks](https://github.com/portworx/dcos-commons)

>**Note:**<br/>This framework is only supported directly by Portworx.
>Please contact support@portworx.com directly for any support issues related with using this framework.

Please make sure you have installed [Portworx on DCOS](/scheduler/mesosphere-dcos/install.html) before proceeding further.

## Adding the repository for the service:

For this step you will need to login to a node which has the dcos cli installed and is authenticated to your DCOS cluster.

Run the following command to add the repository to your DCOS cluster:


     $ dcos package repo add --index=0 kafka-px https://px-dcos.s3.amazonaws.com/v1/kafka/kafka.zip


Once you have run the above command you should see the Kafka service available in your universe

![Kafka-PX in DCOS Universe](/images/dcos-kafka-px-universe.png){:width="655px" height="200px"}

## Installation
### Default Install
If you want to use the defaults, you can now run the dcos command to install the service

     $ dcos package install --yes kafka-px

You can also click on the  “Install” button on the WebUI next to the service and then click “Install Package”.

### Advanced Install
If you want to modify the default, click on the “Install” button next to the package on the DCOS UI and then click on
“Advanced Installation”

Here you have the option to change the service name, volume name, volume size, and provide any additional options that you
want to pass to the docker volume driver. You can also configure other Kafka related parameters on this page including the
number of broker nodes.

![Kafka-PX install options](/images/dcos-kafka-px-install-options.png){:width="655px" height="200px"}

Click on “Review and Install” and then “Install” to start the installation of the service.

## Install Status
Once you have started the install you can go to the Services page to monitor the status of the installation.

![Kafka-PX on services page](/images/dcos-kafka-px-service.png){:width="655px" height="200px"}

If you click on the Kafka service you should be able to look at the status of the nodes being created. 

![Kafka-PX install started](/images/dcos-kafka-px-started-install.png){:width="655px" height="200px"}

When the Scheduler service as well as all the Kafka services are in Running (green) status, you should be ready to start 
using the Kafka service.

![Kafka-PX install finished](/images/dcos-kafka-px-finished-install.png){:width="655px" height="200px"}

If you check your Portworx cluster, you should see multiple volumes that were automatically created using the options
provided during install, one for each of the Brokers.

![Kafka-PX volumes](/images/dcos-kafka-px-volume-list.png){:width="655px" height="200px"}

If you run the "dcos service" command you should see the kafka-px service in ACTIVE state with 3 running tasks


     $ dcos service
     NAME                  HOST             ACTIVE  TASKS  CPU   MEM      DISK   ID                                         
     kafka      ip-10-0-3-116.ec2.internal   True     3    3.0  6144.0    0.0    66d598b0-2f90-4d0a-9567-8468a9979190-0038  
     marathon           10.0.7.49            True     2    2.0  2048.0    0.0    66d598b0-2f90-4d0a-9567-8468a9979190-0001  
     metronome          10.0.7.49            True     0    0.0   0.0      0.0    66d598b0-2f90-4d0a-9567-8468a9979190-0000  
     portworx   ip-10-0-1-127.ec2.internal   True     4    3.3  4096.0    25.0   66d598b0-2f90-4d0a-9567-8468a9979190-0031  
     portworx   ip-10-0-2-42.ec2.internal    True     3    1.2  3168.0  12288.0  66d598b0-2f90-4d0a-9567-8468a9979190-0032


## Verify Setup

From the DCOS client; install the new command for kafka-px

      $ dcos package install kafka-px --cli

Find out all the kafka broker endpoints

      $ dcos kafka endpoints broker
      {
       "address": [
        "10.0.2.82:1025",
        "10.0.0.49:1025",
        "10.0.3.101:1029"
       ],
      "dns": [
      "kafka-2-broker.kafka.mesos:1025",
      "kafka-0-broker.kafka.mesos:1025",
      "kafka-1-broker.kafka.mesos:1029"
       ],
      "vip": "broker.kafka.l4lb.thisdcos.directory:9092"
      }

Find out the zookeeper endpoint for the create kafka service

     $ dcos kafka endpoints zookeeper
     master.mesos:2181/dcos-service-kafka


Create a topic, from the DCOS client use dcos command to create a test topic ``test-one`` with replication set to three

    $ dcos kafka topic create test-one --partitions 1 --replication 3
    {
        "message": "Output: Created topic \"test-one\".\n"
    }

Connect to the master node and launch a kafka client container. 
   
     $ dcos node ssh --master-proxy --leader
    
     core@ip-10-0-6-66 ~ $ docker run -it mesosphere/kafka-client
     root@d19258d46fd3:/bin#
   
Produce a message and send to all kafka brokers

   
     $  echo "Hello, World." | ./kafka-console-producer.sh --broker-list 10.0.2.82:1025,10.0.0.49:1025,10.0.3.101:1029 --topic test-one

Consume the message

     $ ./kafka-console-consumer.sh --zookeeper master.mesos:2181/dcos-service-kafka --topic test-one --from-beginning
     Hello, World.
