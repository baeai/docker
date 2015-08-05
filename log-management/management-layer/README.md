docker run -d -v /data/management-layer/postgresql:/var/lib/postgresql:rw --name management-layer -e POSTGRES_PASSWORD=secretpassword -e PGDATA=/var/lib/postgresql/data management-layer

