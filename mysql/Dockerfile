FROM oracle/oraclelinux:6

ENV PATH $PATH:/usr/libexec 

# Install mysql server
RUN yum update -y \
&& yum install mysql-server -y

COPY entrypoint.sh /entrypoint.sh

####Uncoment below if using custom my.cnf
#COPY my.cnf /etc/my.cnf

RUN chmod 755 /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 3306
CMD ["mysqld"]
