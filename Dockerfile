FROM ubuntu:14.04
MAINTAINER Satish Hegde <satish.hegde@wipro.com>

# The Scala 2.12 build is currently recommended by the project.
ENV KAFKA_VERSION 0.11.0.0
ENV KAFKA_RELV 2.11-0.11.0.0
ENV KAFKA_WEB_CONSOLE_VERSION 2.1.0-SNAPSHOT
ENV JAVA_VER 8
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

ENV DEBIAN_FRONTEND noninteractive

RUN echo /usr/bin/debconf shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections

RUN apt-get update && apt-get install software-properties-common -yq

RUN apt-get update && \
  apt-get install -yq python-software-properties && \
  add-apt-repository ppa:webupd8team/java && \
  apt-get remove -yq python-software-properties && \
  apt-get autoremove -yq && \
  apt-get clean -yq && \
  rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
    apt-get install -yq wget unzip oracle-java8-installer oracle-java8-set-default && \
    apt-get autoremove -yq && \
    apt-get clean -yq && \
    rm -rf /var/lib/apt/lists/*

# Download Kafka binary distribution

RUN wget http://apache.parentingamerica.com/kafka/${KAFKA_VERSION}/kafka_${KAFKA_RELV}.tgz && tar xzf kafka_${KAFKA_RELV}.tgz \
    && mv kafka_${KAFKA_RELV} /usr/local/kafka \
    && rm -rf kafka_${KAFKA_RELV}.tgz

WORKDIR /usr/local/kafka
EXPOSE 2181 9092

ADD run_kafka.sh /usr/local/kafka/run_kafka.sh
RUN chmod +x /usr/local/kafka/run_kafka.sh

## Install Kafka webconsole

#RUN useradd -m -s /bin/bash kafka-web-console

RUN mkdir -p /opt/
WORKDIR /opt

COPY kafka-web-console-${KAFKA_WEB_CONSOLE_VERSION}.zip /opt/
RUN unzip /opt/kafka-web-console-${KAFKA_WEB_CONSOLE_VERSION}.zip \
  && mv kafka-web-console-${KAFKA_WEB_CONSOLE_VERSION} /opt/kafka-web \
  && rm -rf /opt/kafka-web-console-${KAFKA_WEB_CONSOLE_VERSION}.zip

COPY webstart.sh /opt/kafka-web/webstart.sh
RUN chmod +x /opt/kafka-web/webstart.sh
########################################################


# broker, jmx
EXPOSE 9092 
EXPOSE 2181 2888 3888
ENV HTTP_PORT 9090


ENV PATH /usr/local/kafka:/usr/local/kafka/bin:/opt/kafka-web/bin:$PATH

CMD ["/usr/local/kafka/run_kafka.sh"]
CMD ["/opt/kafka-web/webstart.sh"]
