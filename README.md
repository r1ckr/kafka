# Kafka Docker Image

Kafka image to form a cluster or run standalone 

## Run a zookeeper server
```
docker run --name zoo -d zookeeper
```

## Now run this image linking the zookeeper image
```
docker run --name kafka0 -d \
-e ZK=172.17.0.4:2181 \
-e KAFKA_BROKER_ID=0 \
-v /tmp/kafka0/:/tmp/kafka-logs \
r1ckr/kafka:0.1
```

### Env Vars:
- ZK: comma-separated list of ZK nodes with ports
- KAFKA_BROKER_ID: integer ID to identify this broker within the cluster

## Run a cluster of 3 with the docker-compose file
```
docker-compose up -d
```
## Testing it:

#### Create a topic:
```
bin/kafka-topics.sh --create --zookeeper zoo1:2181 --replication-factor 2 --partitions 1 --topic my-replicated-topic
```
#### Describe it to check the replication:
```
bin/kafka-topics.sh --describe --zookeeper zoo1:2181 --topic my-replicated-topic
```
#### Run a producer in kafka1
```
# Connect to kafka1
docker exec -it kafka_kafka1_1 bash
# Run the producer script
opt/kafka/bin/kafka-console-producer.sh --broker-list localhost:9092 --topic my-replicated-topic
```
#### Run a consumer in kafka2
```
# Connect to kafka2
docker exec -it kafka_kafka2_1 bash
# Run the consumer script
/opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --from-beginning --topic my-replicated-topic
```
