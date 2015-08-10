FROM oracle/oraclelinux:6

ENV KIBANA_VER 4.0.2

ENV KIBANA_URL https://download.elastic.co/kibana/kibana/kibana-${KIBANA_VER}-linux-x64.tar.gz

RUN yum install tar -y

RUN useradd kibana

##Download kibana
RUN curl $KIBANA_URL|tar zx \
&& mv kibana-${KIBANA_VER}-linux-x64 /opt/kibana 

ENV PATH /opt/kibana/bin:$PATH

COPY entrypoint.sh /

RUN chmod 755 /entrypoint.sh

EXPOSE 5601
ENTRYPOINT ["/entrypoint.sh"]
CMD ["kibana"]
