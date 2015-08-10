FROM oracle/oraclelinux:6

RUN yum install wget tar -y

ENV JAVA_URL https://download.oracle.com/otn-pub/java/jdk/7u79-b15/jdk-7u79-linux-x64.rpm

ENV JAVA_RPM jdk-7u79-linux-x64.rpm

ENV FLUME_VER 1.6.0

##install java
RUN wget --no-check-certificate --header "Cookie: oraclelicense=accept-securebackup-cookie" \
${JAVA_URL}

RUN yum localinstall -y ${JAVA_RPM} && rm -f ${JAVA_RPM}

ENV JAVA_HOME /usr/java/jdk1.7.0_79

##Install flume
RUN mkdir /opt/flume

RUN wget -qO- http://archive.apache.org/dist/flume/${FLUME_VER}/apache-flume-${FLUME_VER}-bin.tar.gz \
  | tar zxvf - -C /opt/flume --strip 1

ADD start-flume.sh /opt/flume/bin/start-flume


ENV PATH /opt/flume/bin:/opt/java/bin:$PATH

CMD [ "start-flume" ]

