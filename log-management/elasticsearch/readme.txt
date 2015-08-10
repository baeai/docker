You can run the default elasticsearch command simply:

docker run -d elasticsearch
You can also pass in additional flags to elasticsearch:

docker run -d elasticsearch elasticsearch -Des.node.name="TestNode"
This image comes with a default set of configuration files for elasticsearch, but if you want to provide your own set of configuration files, you can do so via a volume mounted at /usr/share/elasticsearch/config:

docker run -d -v "$PWD/config":/usr/share/elasticsearch/config elasticsearch
This image is configured with a volume at /usr/share/elasticsearch/data to hold the persisted index data. Use that path if you would like to keep the data in a mounted volume:

docker run -d -v "$PWD/esdata":/usr/share/elasticsearch/data elasticsearch
This image includes EXPOSE 9200 9300 (), so standard container linking will make it automatically available to the linked containers.
