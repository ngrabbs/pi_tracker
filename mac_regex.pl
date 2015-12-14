#!/usr/bin/perl -w

use warnings;
use strict;

my $mac_line = "#Dec 11 17:33:37 e8b1.fc56.128d shop-bridge ASSOC";

print "mac_line: [$mac_line]\n";
$mac_line =~ m/(\w+\.\w+.\w+)/;
print "$1\n";
