#!/bin/bash
set -ex

# From https://www.elastic.co/guide/en/logstash/current/package-repositories.html
wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb http://packages.elastic.co/logstash/2.1/debian stable main" | sudo tee -a /etc/apt/sources.list
sudo apt-get update && sudo apt-get install logstash

# Latest RabbitMQ requires Erlang
# From https://www.erlang-solutions.com/resources/download.html
echo "deb http://packages.erlang-solutions.com/ubuntu trusty contrib" | sudo tee -a /etc/apt/sources.list
wget -qO - http://packages.erlang-solutions.com/ubuntu/erlang_solutions.asc | sudo apt-key add -
sudo apt-get update && sudo apt-get install erlang

# From http://www.rabbitmq.com/install-debian.html
echo "deb http://www.rabbitmq.com/debian/ testing main" | sudo tee -a /etc/apt/sources.list
wget -qO - https://www.rabbitmq.com/rabbitmq-signing-key-public.asc | sudo apt-key add -
sudo apt-get update && sudo apt-get install rabbitmq-server

# Install rabbitmqadmin
sudo rabbitmq-plugins enable rabbitmq_management
sudo wget -qO /usr/sbin/rabbitmqadmin http://localhost:15672/cli/rabbitmqadmin
sudo chmod a+x /usr/sbin/rabbitmqadmin

# Create queue for rhtracker
rabbitmqadmin declare queue name=rhtracker-data durable=true

# TBD: rabbitmq configuration, custom user & password


