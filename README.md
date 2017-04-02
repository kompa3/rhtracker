# zabbix-emonth

These scripts enable reading of [emonTH 433MHz - Temperature & Humidity nodes](http://shop.openenergymonitor.com/emonth-433mhz-temperature-humidity-node/) 
sensor values from Raspberry having
[RFM69Pi 433Mhz Raspberry Pi Base Station Receiver Board](http://shop.openenergymonitor.com/rfm69pi-433mhz-raspberry-pi-base-station-receiver-board/) to [Zabbix](www.zabbix.com).

The scripts have been tested with Raspbian Jessie and Raspberry Pi 2

## Install

Prerequisites:

* Zabbix-agent (`sudo apt-get install zabbix-agent`)
* Redis database used as a message queue (`sudo apt-get install redis-server`)

Copy files under [etc](etc) to /etc/ in the Raspbian file system

* [etc/init.d/emonTH](etc/init.d/emonTH) - init.d script reading from ttyAMA0 and writing to message queue
* [etc/zabbix/scripts/discover_emonTH.pl](etc/zabbix/scripts/discover_emonTH.pl) - discovery script that reads from the message queue and stores latest values to a file
* [etc/zabbix/scripts/read_emonTH.pl](etc/zabbix/scripts/read_emonTH.pl) - item reading script that reads latest values from a file
* [etc/zabbix/zabbix_agentd.conf.d/emonTH.conf](etc/zabbix/zabbix_agentd.conf.d/emonTH.conf) - user parameter definitions for Zabbix

After installation, reboot zabbix-agent so that it notices the new user parameters `sudo service zabbix-agent restart`.

## Zabbix Server configuration

The easiest way to get started is to import [emonth_measurement.xml](emonth_measurement.xml) to Zabbix Server.

Each discovered node has the following items:

* battery_voltage (in V)
* external_temperature (in Celsius)
* internal_humidity (in Percentages)
* internal_temperature (in Celsius)
* rssi (received signal strength indication, as defined by IEEE 802.11)

## Screenshots

![Zabbix items](https://github.com/kompa3/zabbix-emonth/blob/master/zabbix_items.JPG)
