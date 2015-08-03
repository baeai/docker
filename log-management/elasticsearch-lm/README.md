##elasticsearch example runtime environment variables

Example usage: docker run -dit --name elasticsearch-lm \ -e CLUSTER_NAME=log-management-01 \ -e NODE_NAME=LOGM01ELS01 \ -e DATA_PATH="/data/elasticsearch/data01, /data/elasticsearch/data02, /data/elasticsearch/data03" \ -e BIND_HOST=165.212.101.62 \ -e UNICAST_HOSTS="165.212.101.62, 165.212.101.66, 165.212.101.67" \ elasticsearch-lm
