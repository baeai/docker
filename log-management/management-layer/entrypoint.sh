#!/bin/bash

set -e

if [[ ! -e /postgresql.installed ]];
then

	if [[ ! -d $PGDATA ]];then
	mkdir -p $PGDATA
	chown postgres $PGDATA
    fi
    
##Initializing DB
su postgres -c "initdb"
echo "host all all 172.17.0.0/16 trust" >>/var/lib/postgresql/data/pg_hba.conf
echo "listen_addresses='*'" >>/var/lib/postgresql/data/postgresql.conf
su postgres -c "postgres"
su postgres -c "psql -U postgres -d postgres -c \"alter user postgres with password '$POSTGRES_PASSWORD';\"" \
&& touch /postgresql.installed
else

su postgres "$@"

fi
