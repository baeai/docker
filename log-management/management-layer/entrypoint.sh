#!/bin/bash

set -e

CIDR=$(ip route|awk 'NR==2'|awk -F' ' '{print $1}')

if [[ ! -e /postgresql.installed ]];
then

	if [[ ! -d $PGDATA ]];then
	mkdir -p $PGDATA
	chown postgres $PGDATA
    fi
    
##Initializing DB
su postgres -c "initdb"
echo "host all all $CIDR trust" >>/var/lib/postgresql/data/pg_hba.conf
echo "listen_addresses='*'" >>/var/lib/postgresql/data/postgresql.conf
su postgres -c "postgres"
su postgres -c "psql -U postgres -d postgres -c \"alter user postgres with password '$POSTGRES_PASSWORD';\"" \
&& touch /postgresql.installed
psql --file /usr/share/pgsql/contrib/adminpack.sql
else

su postgres "$@"

fi

