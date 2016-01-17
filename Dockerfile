FROM 1science/java:oracle-jre-8

MAINTAINER Alexander Dvorkovyy

ENV NEXUS_DATA /nexus-data

ENV NEXUS_VERSION 3.0.0-b2015110601

RUN mkdir -p /opt/sonatype/nexus \
  && apk add --update curl \
  && curl --fail --silent --location --retry 3 \
    https://download.sonatype.com/nexus/oss/nexus-${NEXUS_VERSION}-bundle.tar.gz \
  | gunzip \
  | tar x -C /tmp nexus-${NEXUS_VERSION} \
  && mv /tmp/nexus-${NEXUS_VERSION}/* /opt/sonatype/nexus/ \
  && rm -rf /tmp/nexus-${NEXUS_VERSION}

RUN adduser -S -u 200 -g "nexus role account" -h ${NEXUS_DATA} -s /bin/false nexus

## configure nexus runtime env
RUN sed -e "s|KARAF_HOME}/instances|KARAF_DATA}/instances|" -i /opt/sonatype/nexus/bin/nexus

VOLUME ${NEXUS_DATA}

EXPOSE 8081
USER nexus
WORKDIR /opt/sonatype/nexus

ENV KARAF_BASE /opt/sonatype/nexus
ENV KARAF_DATA ${NEXUS_DATA}
ENV KARAF_ETC ${KARAF_BASE}/etc
ENV KARAF_HOME ${KARAF_BASE}
ENV MAX_MEM 768m
ENV MIN_MEM 256m

CMD bin/nexus start