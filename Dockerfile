FROM openjdk:8u121

RUN \
    cd /opt \
    && wget http://ftp.heanet.ie/mirrors/www.apache.org/dist/kafka/0.10.2.0/kafka_2.11-0.10.2.0.tgz \
    && tar -xvf kafka_2.11-0.10.2.0.tgz \
    && ln -s kafka_2.11-0.10.2.0 kafka \
    && rm -rf kafka_2.11-0.10.2.0.tgz

COPY ./entrypoint.sh /

RUN chmod +x entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
