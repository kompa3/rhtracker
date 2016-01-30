# AWS Architecture

## Policies

* [raspberry.policy](raspberry.policy): A generic policy attached to all raspberry devices, allowing connect & publish

Inline policies attached to roles:

* aws_iot_republish: Allow IoT rules to republish to new topics
* aws_iot_log: Allow IoT to log to CloudWatch
* aws_iot_dynamoDB: Allow IoT rules to write to DynamoDB

## Things

* Rxxx: Raspberry #xxx. The reported shadow data contains current device state (cpu% etc).
** Each raspberry device has its own certificate
* ETxxx: emonTH #xxx. The shadow contains the latest measurement values.

## Topics

* $aws/things/Rxxx/shadow/update: Raspberry device state update (shadow data update)
* $aws/things/ETxxx/shadow/update: emonTH shadow data update
* emonth-data/Rxxx: Emonth data stream published by a Raspberry device, containing data from multiple nodes
* TBD: syslog/Rxxx: Syslog stream of a Raspberry device
* TBD: Logstash logs

## Rules

* ETxxx.collect.rule: Listens to emonth-data/Rxxx topic for node yy and republishes to ETxxx shadow update
* ETxxx.archive.rule: Listens to emonTH thing shadow updates and writes the log to DynamoDB

## Shadow Data

Rxxx Raspberry device:

* state.reported
** cpu_percentage: cpu% (0.0-100.0)

ETxxx emonTH device:

* state.reported
** internal_temperature (Celsius, float)
** external_temperature (Celsius, float)
** internal_humidity (RH%, float)
** battery_voltage (V, float)
** node (current node number, integer)
** rssi (negative integer)
** message (latest message line, string)
** @version ?
** @timestamp (latest timestamp, format?)
** host (latest host ?)

