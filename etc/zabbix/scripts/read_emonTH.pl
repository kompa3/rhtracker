#!/usr/bin/perl

# Get the latest measurement of emonTH sensor, read by discover_emonTH.pl
# Usage: read_emonTH.pl [node] [item]
#  - node: node number as returned by discovery
#  - item: one of 'internal_temperature', 'external_temperature', 'internal_humidity', 'battery_voltage' and 'rssi'
# Temperatures are in Celsius (C)
# Humidity is in Percentage (%)
# Battery voltage is in Voltage (V)
# RRSI is received signal strength indication, as defined in IEEE 802.11

use Storable;
use Data::Dumper;

my ($node, $item) = @ARGV;
if (not defined $item) {
  die "Missing command-line arguments\n";
}

# Read latest measurement from a file written by discover_emonTH.pl
my $filename = "/tmp/$node.emonTH";
my $hashref = retrieve($filename);
die "Unable to retrieve latest measurement data from $filename" unless defined $hashref;
print $hashref->{$item};
