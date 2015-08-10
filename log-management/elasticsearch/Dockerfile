FROM oracle/oraclelinux:6

ENV ELASTICSEARCH_VERSION 1.6


##configure elasticsearch repo
RUN echo "[elasticsearch-$ELASTICSEARCH_VERSION]">>/etc/yum.repos.d/elasticsearch.repo \
&& echo "name=Elasticsearch repository for $ELASTICSEARCH_VERSION packages" >>/etc/yum.repos.d/elasticsearch.repo \
&& echo "baseurl=http://packages.elastic.co/elasticsearch/$ELASTICSEARCH_VERSION/centos">>/etc/yum.repos.d/elasticsearch.repo \
&& echo "gpgcheck=1" >>/etc/yum.repos.d/elasticsearch.repo \
&& echo "gpgkey=http://packages.elastic.co/GPG-KEY-elasticsearch">>/etc/yum.repos.d/elasticsearch.repo \
&& echo "enabled=1">>/etc/yum.repos.d/elasticsearch.repo 

##configure ulimit
RUN echo "elasticsearch - nofile 65535" >>/etc/security/limits.conf \
&& echo "elasticsearch - memlock unlimited" >>/etc/security/limits.conf

RUN yum install elasticsearch wget which -y

COPY logm-transform-plugin.jar /usr/share/elasticsearch/lib/logm-transform-plugin.jar 

##install java
RUN wget --no-check-certificate --header "Cookie: oraclelicense=accept-securebackup-cookie" \
https://download.oracle.com/otn-pub/java/jdk/7u79-b15/jdk-7u79-linux-x64.rpm

RUN yum localinstall -y jdk-7u79-linux-x64.rpm && rm -f jdk-7u79-linux-x64.rpm

ENV JAVA_HOME /usr/java/jdk1.7.0_79

ENV PATH /usr/share/elasticsearch/bin:$PATH

COPY config /usr/share/elasticsearch/config

#RUN sed -i s/256m/4g/ /usr/share/elasticsearch/bin/elasticsearch.in.sh \
#&& sed -i s/1g/4g/ /usr/share/elasticsearch/bin/elasticsearch.in.sh

COPY entrypoint.sh /

VOLUME /usr/share/elasticsearch/data

RUN chmod 755 /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 9200 9300

CMD ["elasticsearch"]
