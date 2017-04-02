#!/usr/bin/perl

# Discover and synchronize (=read) emonTH sensor input from RFM69Pi
# The script will store the retrieved sensor input values into a cache file read by read_emonTH.pl
# The discovery will return the following keys for each discovered item:
#  {#NODE}: Discovered node number

use Storable;
use File::Find;

# Read a line from our message queue
chomp(my $line = `echo 'RPOP emonTH' | redis-cli`);

# Read the message queue until it's empty
while (defined $line && $line ne "")
{
  my ($node, $i1, $i2, $i3, $i4, $i5, $i6, $i7, $i8, $rssi) = $line =~ /^OK (\d+) (\d+) (\d+) (\d+) (\d+) (\d+) (\d+) (\d+) (\d+) \((-?\d+)\)$/;
  if ($node && $rssi) {
    # Convert to SI units
    my $internal_temperature = ($i2 * 256 + $i1) / 10.0;
    my $external_temperature = ($i4 * 256 + $i3) / 10.0;
    my $internal_humidity = ($i6 * 256 + $i5) / 10.0;
    my $battery_voltage = ($i8 * 256 + $i7) / 10.0;

    my %hash = (
      node => "$node",
      internal_temperature => "$internal_temperature",
      external_temperature => "$external_temperature",
      internal_humidity => "$internal_humidity",
      battery_voltage => "$battery_voltage",
      rssi => "$rssi"
    );

#    print "internal temperature $hash{internal_temperature}\n";
#    print "external temperature $hash{external_temperature}\n";
#    print "internal humidity $hash{internal_humidity}\n";
#    print "battery voltage $hash{battery_voltage}\n";

    # Write the latest measurement to a file
    my $filename = "/tmp/$node.emonTH";
    store(\%hash, "$filename") or die "Could not write to file $filename";
  }

  chomp($line = `echo 'RPOP emonTH' | redis-cli`);
}

# Finally discover all the nodes that have been transmitting data
print "{\"data\":[";
$first = 1;
find(\&discover, "/tmp");
print "]}";

exit(0);

sub discover
{
  my $file = $_;
  my ($node) = $file =~ /^(\d+).emonTH$/;
  if ($node)
  {
    print "," if not $first;
    $first = 0;
    print "{ \"{#NODE}\":\"$node\"}";
  }
}
