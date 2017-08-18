---
layout: page
title: "Spark on DCOS with Portworx"
keywords: portworx, container, Mesos, Mesosphere, DCOS, spark, spark-standalone
---

* TOC
{:toc}



This guide describe how to use ``px-universe``  ``spark-standalone-px`` package on DCOS cluster. Assume you have successfully deployed DCOS and PX cluster.

## Installation

Update your DCOS universe package repo

     dcos package repo add --index=0 spark-standalone-px \
     https://px-dcos.s3.amazonaws.com/v1/spark-standalone/spark-standalone.zip

### Default Install
If you want to use the defaults, you can now run the dcos command to install the service

    $ dcos package install --yes spark-standalone-px

![Spark-standalone-px in DCOS Universe](/images/spark-px-universe-001.PNG){:width="1145px" height="702px"}

You can also click on the  “Install” button on the WebUI next to the service and then click “Install Package”.

### Advanced Install
If you want to modify the default, click on the “Install” button next to the package on the DCOS UI and then click on
``Advanced Installation``

![Spark-standalone-px in DCOS Universe](/images/spark-px-universe-002.PNG){:width="1131px" height="692px"}


Here you have the option to change the service name, spark master and worker nodes' memory and default port information, and you can update the spark worker node counts. You will need to input the master and worker JAVA OPTS, please check details from [official spark documentation ](http://spark.apache.org/docs/latest/spark-standalone.html). For master JAVA OPTS e.g. ``spark.deploy.spreadOut=true`` and for worker JAVA OPTS e.g. ``spark.worker.cleanup.enabled=false``. The default setup is to launch 1 master node and 2 worker nodes. And the PX volumes being created will have name prefix with SparkWorker and default volume size is 2GB.

![Spark-standalone-px in DCOS Universe](/images/spark-px-universe-003.PNG){:width="1140px" height="689px"}

![Spark-standalone-px in DCOS Universe](/images/spark-px-universe-004.PNG){:width="1132px" height="689px"}

when everything is updated, then click ``install`` button

![Spark-standalone-px in DCOS Universe](/images/spark-px-universe-005.PNG){:width="1138px" height="697px"}


### Verify Installation
Once the service is completed, 5 tasks are running under ``spark-standlone`` services

![Spark-standalone-px in DCOS Universe](/images/spark-px-universe-005-b.PNG){:width="1169px" height="478px"}

Inspect each task under spark-standalone service

![Spark-standalone-px in DCOS Universe](/images/spark-px-universe-006.PNG){:width="1136px" height="681px"}

Inspect PX created PX volumes, from the DCOS client machine, use ``dcos node ssh`` to access to one of the mesos private agent and run ``pxctl`` command to check created volumes with ``SparkWorker`` prefix.

       $ dcos node ssh --master-proxy --mesos-id=08552aa4-65e2-46a5-b89c-c7bb04be54ed-S1

       $ /opt/pwx/bin/pxctl v l |grep Spark
       957614426375257008      SparkWorker-0           2 GiB   1       no      no              LOW             0       up - attached on 10.0.1.121 *
       16622435564753245       SparkWorker-1           2 GiB   1       no      no              LOW             0       up - attached on 10.0.0.38 *

From the DCOS WEb UI, the spark master node is exposed on IP address ``10.0.3.241``.

![Spark-standalone-px in DCOS Universe](/images/spark-px-universe-006-b.PNG){:width="1170px" height="376px"}

From the DCOS client find the exposed spark master Web port (default is on 4040)

      $ dcos marathon app show spark-standalone |grep SPARK_MASTER_WEBUI
        "SPARK_MASTER_WEBUI_PORT": "4040",

Accessing to the Spark Master WebUI. Create a ssh tunnel from DCOS/Mesos master node and tunnel to the spark master node's port 4040. Since DCOS/Mesos master node has access to all private agent nodes. You should see the spark master web console similar like below and connected with two worker nodes.

![Spark-standalone-px in DCOS Universe](/images/spark-px-universe-007.PNG){:width="1175px" height="675px"}


## Running Spark job

### Preparing a spark client 

The spark client should be able to access all DCOS/Mesos private agent nodes. The Spark version of this spark-standalone-px is from Spark 2.1.0 support Hadoop 2.7

Setup spark 2.1.0 on the client machine. The following example is based on Centos and with ``OpenJDK 1.7`` and Scala 2.10.1. 

For name resolving issue within Mesos cluster, udpate the /etc/resolv.conf on the spark client to include the mesos DNS IP address and that is the DCOS/Mesos master node IP address.
    
     $ wget http://www.scala-lang.org/files/archive/scala-2.10.1.tgz
     $ tar xvf scala-2.10.1.tgz
     $ mv scala-2.10.1 /usr/lib/
     $ ln -s /usr/lib/scala-2.10.1 /usr/lib/scala
     $ export PATH=$PATH:/usr/lib/scala/bin
     $ wget https://d3kbcqa49mib13.cloudfront.net/spark-2.1.0-bin-hadoop2.7.tgz
     $ mkdir -p /usr/local/spark
     $ tar -xvf spark-2.1.0-bin-hadoop2.7.tgz
     $ cp -r spark-2.1.0-bin-hadoop2.7/* /usr/local/spark
     $ export SPARK_EXAMPLES_JAR=/usr/local/spark/examples/jars/spark-examples_2.11-2.1.0.jar

### Using Spark-shell

From the spark client machine, run ``spark-shell`` and specify ``--master`` to the spark master URL, and that is observed from Spark master node Web UI.

![Spark-standalone-px in DCOS Universe](/images/spark-px-universe-008-b.PNG){:width="1172px" height="390px"}

 
 From the spark client use the following command to launch a spark-shell

      $ spark-shell --master spark://master-0-server.spark-standalone.mesos:7070

You should see the spark shell has a ``scala`` prompt.

     Using Spark's default log4j profile: org/apache/spark/log4j-defaults.properties
     Setting default log level to "WARN".
     To adjust logging level use sc.setLogLevel(newLevel). For SparkR, use setLogLevel(newLevel).
     17/05/23 01:24:12 WARN SparkContext: Support for Java 7 is deprecated as of Spark 2.0.0
     17/05/23 01:24:14 WARN NativeCodeLoader: Unable to load native-hadoop library for your platform... using builtin-java classes where applicable
     17/05/23 01:24:44 WARN ObjectStore: Failed to get database global_temp, returning NoSuchObjectException
     Spark context Web UI available at http://10.0.5.245:4040
     Spark context available as 'sc' (master = spark://master-0-server.spark-standalone.mesos:7070, app id = app-20170523012419-0001).
     Spark session available as 'spark'.
     Welcome to
              ____              __
             / __/__  ___ _____/ /__
            _\ \/ _ \/ _ `/ __/  '_/
           /___/ .__/\_,_/_/ /_/\_\   version 2.1.0
              /_/

     Using Scala version 2.11.8 (OpenJDK 64-Bit Server VM, Java 1.7.0_131)
     Type in expressions to have them evaluated.
     Type :help for more information.

     scala>

From the master node Web console, A new running application is observed

![Spark-standalone-px in DCOS Universe](/images/spark-px-universe-008.PNG){:width="1174px" height="648px"}

Do a simple wordcount  for a local file ``/etc/hosts`` on spark shell. The /etc/hosts file contains only 3 word strings shown below.

    $ cat /etc/hosts
      127.0.0.1   localhost localhost.localdomain


On the spark shell run the following interactive scala commands; and observe the result line displays ``3``.

      scala> val file = sc.textFile("/etc/hosts");
      file: org.apache.spark.rdd.RDD[String] = /etc/hosts MapPartitionsRDD[1] at textFile at <console>:24

      scala> file.count();
      res0: Long = 3


### Submitting a job

From the spark client submit an example job ``SparkPi`` (calculating Pi) to this spark cluster.

     spark-submit --class org.apache.spark.examples.SparkPi \
     --deploy-mode client \
     --master spark://master-0-server.spark-standalone.mesos:7070 \
     /usr/local/spark/examples/jars/spark-examples_2.11-2.1.0.jar 10


Once job is submitted, A new running application is observed on the Spark master Web console.

![Spark-standalone-px in DCOS Universe](/images/spark-px-universe-010.PNG){:width="1163px" height="679px"}

The screen output of this job is length and when completed the result look similar like below.

     17/05/23 01:50:06 INFO DAGScheduler: ResultStage 0 (reduce at SparkPi.scala:38) finished in 1.726 s
     17/05/23 01:50:06 INFO DAGScheduler: Job 0 finished: reduce at SparkPi.scala:38, took 2.513401 s
     Pi is roughly 3.1422751422751425
