#!/bin/bash
#entrypoint for docker

set -e

cat <<EOF> /etc/elasticsearch/elasticsearch.yml
cluster.name: $CLUSTER_NAME
node.name: $NODE_NAME
path.data: $DATA_PATH
bootstrap.mlockall: true
network.bind_host: BIND_HOST
discovery.zen.multicast.enabled: false
discovery.zen.ping.unicast.hosts: ["$UNICAST_HOSTS"]
http.cors.enabled: true
http.cors.allow-origin: "*"
http.cors.allow-methods: OPTIONS, HEAD, GET, POST, PUT, DELETE
http.cors.allow-headers: X-Requested-With,X-Auth-Token,Content-Type,Content-Length
EOF

exec "$@"

