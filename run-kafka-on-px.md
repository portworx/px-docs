[ Ref:  https://hub.docker.com/r/ches/kafka/  ]

docker run -d --name zookeeper jplock/zookeeper:3.4.6

docker run -d --name kafka --volume-driver=pxd \
             -v name=kafka_data,size=30G:/data      \
             -v name=kafka_log,size=10G:/logs        \
             --link zookeeper:zookeeper ches/kafka

ZK_IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' zookeeper)

KAFKA_IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' kafka)


[ Create a Kafka Topic named “foobar” ]
docker run --rm ches/kafka kafka-topics.sh --create --topic foobar --partitions 1 --replication-factor 1 --zookeeper $ZK_IP:2181

docker run --rm --interactive ches/kafka kafka-console-producer.sh --topic foobar --broker-list $KAFKA_IP:9092

<Type a bunch of content to the producer for topic “foobar”.   Terminate with Cntrl-D>

docker run --rm ches/kafka kafka-console-consumer.sh --topic foobar --from-beginning --zookeeper $ZK_IP:2181
<See the stuff you created appear to the client>

docker stop kafka && docker rm kafka    <Blow away Kafka>

docker run --rm  ches/kafka kafka-console-consumer.sh --topic foobar --from-beginning --zookeeper $ZK_IP:2181                     [  Try to read from client.   Can’t.   “No Brokers” ]

[Restart Kafka]

docker run -d --name kafka --volume-driver=pxd \
             -v name=kafka_data,size=30G:/data      \
             -v name=kafka_log,size=10G:/logs        \
             --link zookeeper:zookeeper ches/kafka

docker run --rm  ches/kafka kafka-console-consumer.sh --topic foobar --from-beginning --zookeeper $ZK_IP:2181
<See the stuff you created appear to the client.   No need to recreate the “topic” --- it’s persistent data!>
