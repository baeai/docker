#!/bin/bash
set -e

exec fluentd -c ./fluent/fluent.conf
