FROM oracle/oraclelinux:6

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added

RUN mkdir /docker-entrypoint-initdb.d

ENV PG_MAJOR 8.4

ENV PG_VERSION 8.4.20-3

RUN yum install postgresql-server postgresql-contrib -y

RUN mkdir -p /var/run/postgresql && chown -R postgres /var/run/postgresql

ENV PATH /usr/lib/postgresql/$PG_MAJOR/bin:$PATH

ENV PGDATA /var/lib/postgresql/data

COPY entrypoint.sh /

RUN chmod 755 /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 5432
CMD ["postgres"]
