#!/bin/bash
set -ex

echo "Usage: ./install.sh <raspberry-order-number>"
echo "  eg. ./install.sh 001"

SERIAL_NUMBER="$1"
if [ -z "$0" ]; then
  echo "Missing arguments"
  exit 1
fi

# Check that ttyAMA0 is not used for console
if grep -Fxq "ttyAMA0" /boot/cmdline.txt; then
  echo "ERROR: ttyAMA0 (serial port) is configured as the console in /boot/cmdline.txt"
  echo "Serial port cannot be used for communicating with RFM69Pi until the console command is removed"
  echo "Aborting installation"
  exit 1
fi

# Logstash apt-get repository does not support ARM, download .deb instead
wget https://download.elastic.co/logstash/logstash/packages/debian/logstash_2.1.1-1_all.deb
sudo gdebi -y logstash_2.1.1-1_all.deb

# https://github.com/jruby/jruby/issues/1561
cd /tmp/
sudo git clone https://github.com/jnr/jffi.git
cd jffi/
sudo apt-get install -y ant
sudo ant jar
sudo cp /tmp/jffi/build/jni/libjffi-1.2.so /opt/logstash/vendor/jruby/lib/jni/arm-Linux/

# Allow logstash user to access serial port
sudo adduser logstash dialout

# Latest RabbitMQ requires Erlang
# From https://www.erlang-solutions.com/resources/download.html
echo "deb http://packages.erlang-solutions.com/ubuntu trusty contrib" | sudo tee -a /etc/apt/sources.list
wget -qO - http://packages.erlang-solutions.com/ubuntu/erlang_solutions.asc | sudo apt-key add -
sudo apt-get update && sudo apt-get install -y erlang

# From http://www.rabbitmq.com/install-debian.html
echo "deb http://www.rabbitmq.com/debian/ testing main" | sudo tee -a /etc/apt/sources.list
wget -qO - https://www.rabbitmq.com/rabbitmq-signing-key-public.asc | sudo apt-key add -
sudo apt-get update && sudo apt-get install -y rabbitmq-server

# Install rabbitmqadmin
sudo rabbitmq-plugins enable rabbitmq_management
sudo wget -qO /usr/sbin/rabbitmqadmin http://localhost:15672/cli/rabbitmqadmin
sudo chmod a+x /usr/sbin/rabbitmqadmin

# Create queue for rhtracker
# Is this necessary? Probably would be created by Logstash rabbitmq input plugin as well?
rabbitmqadmin declare queue name=emonth-data durable=true

# Install logstash-output-mqtt plugin
sudo /opt/logstash/bin/plugin install logstash-output-mqtt

# TBD: rabbitmq configuration, custom user & password

# Install .conf files to /etc/logstash/conf.d/ and take them into use immediately
sudo cp *.conf /etc/logstash/conf.d/
sudo service logstash restart

# Remote access
sudo apt-get install -y autossh
sudo adduser --system autossh
sudo cp autossh.service /etc/systemd/system/
# Use port 9001 for R001, 9002 for R002 etc.
sudo sed -i "s/9001/9$SERIAL_NUMBER/g" /etc/systemd/service/autossh.service
sudo systemctl daemon-reload
sudo systemctl start autossh.service
sudo systemctl enable autossh.service
sudo -u autossh ssh-keygen -N '' -f /home/autossh/.ssh/id_rsa
echo "On the remote access server, nano /etc/passwd and change raspberry user shell temporarily to /bin/bash"
echo "Also, set PasswordAuthentication to yes in /etc/ssh/sshd_config; then sudo service ssh restart"
echo "Then, set a temporary password with sudo passwd raspberry"
read -p "Press [Enter] when ready"
sudo -u autossh ssh-copy-id raspberry@52.18.36.77
echo "Now change to login back to /usr/sbin/nologin and PasswordAuthentication to no in /etc/ssh/sshd_config"
echo "Then, sudo service ssh restart"
read -p "Press [Enter] when ready"
