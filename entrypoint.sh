#!/usr/bin/env bash

KAFKA_DIR="/opt/kafka"

logInfo()
{
 TIMESTAMP=`date +'%Y/%m/%d %H:%M:%S'`
 echo -e "${TIMESTAMP} INFO: $*"
}

logWarn()
{
 TIMESTAMP=`date +'%Y/%m/%d %H:%M:%S'`
 echo -e "${TIMESTAMP} WARN: $*"
}

logErr()
{
 TIMESTAMP=`date +'%Y/%m/%d %H:%M:%S'`
 echo -e "${TIMESTAMP} ERROR: $*"
}

finishIt()
{
 logInfo "INFO: Caught STOP signal, shutting down container..."

 logInfo "INFO: Shutting down Kafka..."
 kill $(cat ${KAFKA_DIR}/kafka.pid)
 exit 0
}

trap finishIt SIGHUP SIGINT SIGQUIT SIGKILL SIGTERM

if [ -z "${ZK}" ]
then
    echo "ERROR - There's no Zookeeper endpoint specified, eg:"
    echo "-e ZK=zk1:2181,zk2:2181"
    exit 1
fi

if [ -z "${KAFKA_BROKER_ID}" ]
then
    echo "WARN - There's no Broker id specified, 0 will be used, to use a different one please specify it, eg:"
    echo "-e KAFKA_BROKER_ID=1"
    export KAFKA_BROKER_ID=0
fi

setup(){
    cd ${KAFKA_DIR}
    sed -i -e "s/zookeeper\.connect=.*/zookeeper.connect=${ZK}/" config/server.properties
    sed -i -e "s/broker\.id=.*/broker.id=${KAFKA_BROKER_ID}/" config/server.properties
}


startKafka(){
    cd ${KAFKA_DIR}
    bin/kafka-server-start.sh config/server.properties &
    if [ $? -ne 0 ]; then
      logErr "Kafka failed to start, exiting..."
      exit 1
    fi
    echo $! > kafka.pid
    logInfo "Kafka successfully started!"
    sleep 5
}

monitor(){
    tail -f ${KAFKA_DIR}/logs/server.log &
    child=$!

    wait "$child"
}

setup
startKafka
monitor