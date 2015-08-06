#!/usr/bin/env bash
# start up services in transmit docker container
cd /opt/transmit/transmit_to_ingest/transmit_thrift_http
ruby transmit_to_ingest.rb config-prod.json &
