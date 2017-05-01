---
layout: page
title: "Run Kafka on Portworx Volumes for Topic Persistence"
keywords: portworx, px-developer, cassandra, database, cluster, storage
sidebar: home_sidebar
redirect_from: "/run-kafka-on-px.html"
---

*For this document, we will use the kafka container at https://hub.docker.com/r/ches/kafka/*

**Kafka uses Zookeeper as the KV store for configuration data.**

```
docker run -d --name zookeeper jplock/zookeeper:3.4.6
```

**Run kafka container and use the --volume-driver=pxd option to invoke the Portworx Volume Driver and create a portworx volume size of 30G for data (kafka_data) and a portworx volume size of 10G for logs (kafka_logs).**

```
docker run -d --name kafka --volume-driver=pxd \
             -v name=kafka_data,size=30G:/data      \
             -v name=kafka_log,size=10G:/logs        \
             --link zookeeper:zookeeper ches/kafka
```
**Get the IP address of Zookeeper and Kafka services.**

```
ZK_IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' zookeeper)

KAFKA_IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' kafka)
```

**Create a Kafka Topic named “foobar”.**

```
docker run --rm ches/kafka kafka-topics.sh --create --topic foobar --partitions 1 --replication-factor 1 --zookeeper $ZK_IP:2181
```

**Start a kafka producer to publish content into the kafka topic "foobar".**

```
docker run --rm --interactive ches/kafka kafka-console-producer.sh --topic foobar --broker-list $KAFKA_IP:9092
```
**Type a bunch of content to the producer for topic “foobar”.   Terminate with Cntrl-D.**

```
docker run --rm ches/kafka kafka-console-consumer.sh --topic foobar --from-beginning --zookeeper $ZK_IP:2181
```
See the stuff you created appear to the client

**Stop and remove the kafka container.**

```
docker stop kafka && docker rm kafka    
```

**Attempt to read the same topic from the client.**

```
docker run --rm  ches/kafka kafka-console-consumer.sh --topic foobar --from-beginning --zookeeper $ZK_IP:2181                 
```

This would fail with error message stating “No Brokers” indicating kafka producer doesn't exist.

**Now start the kafka container and point to the same volumes via the -v option (kafka_data and kafka_log).**

```
docker run -d --name kafka --volume-driver=pxd \
             -v name=kafka_data,size=30G:/data      \
             -v name=kafka_log,size=10G:/logs        \
             --link zookeeper:zookeeper ches/kafka
```
**Run the consumer again and the same topics that were published before can now be read or replayed from the client without recreating them.**

```
docker run --rm  ches/kafka kafka-console-consumer.sh --topic foobar --from-beginning --zookeeper $ZK_IP:2181
```

And that's how Portworx enables persitent data streams for kafka clusters.


