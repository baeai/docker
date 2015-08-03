FROM oracle/oraclelinux:6

ENV JAVA_HOME /usr/java/jdk1.7.0_79

ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/LogicalDOC-Community/bin:/usr/libexec/postfix

RUN echo "*    soft    nofile 6000" >>/etc/security/limits.conf \
&& echo "*    hard    nofile 6000">>/etc/security/limits.conf

COPY  * /
RUN chmod 755 /entrypoint.sh
RUN yum update -y 
RUN yum install -y wget unzip

RUN wget --no-check-certificate --header "Cookie: oraclelicense=accept-securebackup-cookie" \
https://download.oracle.com/otn-pub/java/jdk/7u79-b15/jdk-7u79-linux-x64.rpm \
&& yum localinstall jdk-7u79-linux-x64.rpm -y && rm jdk-7u79-linux-x64.rpm

RUN curl http://per5-registry-01.sys.silversky.com/pub/logicaldoc/logicaldoc-community-installer-7.2.1.zip \
>/opt/logicaldoc-community-installer-7.2.1.zip
RUN unzip /opt/logicaldoc-community-installer-7.2.1.zip -d /opt \
&& rm /opt/logicaldoc-community-installer-7.2.1.zip


ENTRYPOINT ["/entrypoint.sh"]
