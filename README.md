# rhtracker

## Target environment

* Raspberry Pi 2
* Raspbian Jessie
* [RFM69Pi](http://shop.openenergymonitor.com/rfm69pi-433mhz-raspberry-pi-base-station-receiver-board/) 433Mhz Raspberry Pi Base Station Receiver Board
* [emonTH](http://shop.openenergymonitor.com/emonth-433mhz-temperature-humidity-node/) 433MHz - Temperature & Humidity nodes
* AWS IoT framework

## Installation

See [install.sh](install.sh)

## Data queues

* emonth-data: Collection EmonTH data stream

## TBD

Data collection and processing for:

* Logstash instance logs
* syslog
* periodic device status, eg. CPU%, mem%, disk%
