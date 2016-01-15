#!/bin/bash
set -ex

# RabbitMQ plugin of Logstash has a bug that requires "sudo" when using logstash
# See https://github.com/logstash-plugins/logstash-output-rabbitmq/issues/30

sudo /opt/logstash/bin/logstash -f data-collector.conf < test-data.txt
sudo /opt/logstash/bin/logstash -f data-processing.conf --debug

