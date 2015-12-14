#!/usr/bin/perl -w

use strict;
use warnings;
use Data::Dumper qw(Dumper);
use DBI;

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =
                                                localtime(time);

$year+=1900;

my $dbh = DBI->connect(
	"dbi:SQLite:dbname=mac_tracker.db",
	"",
	"",
	{ RaiseError => 1 },
) or die $DBI::errstr;

my $syslog = "./syslog";

my %macs;

open(SYSLOG, "$syslog");
while(<SYSLOG>) {
	my $mac;
	my $start_ap;
	my $start_time;
	my $end_time;
	my $db_check;

	if($_ =~ m/DOT11-6-ROAMED/ ) {
		my @roamed = split(/\s+/, $_);
	}
	if($_ =~ m/DOT11-6-ASSOC/ && $_ =~ m/(\w+\.\w+\.\w+)/) {
		my @assoc = split(/\s+/, $_);
		$mac = $1;
		$start_ap = $assoc[3];
		
		$start_time = "$assoc[0]-$assoc[1]-$year-$assoc[2]";

		## check database to see if we already have an entry like this
		$db_check = check_database($mac, $start_ap, $start_time, $dbh);
		if($db_check) {
			print "$mac $start_ap $start_time alread exists, woops\n";
		} else {
			# see if a session exists
			my $last_session_id = get_last_session_id($mac, $start_ap, $start_time, $dbh);
			insert_row($mac, $last_session_id+1, $start_ap, $start_time, $dbh);
		}

	}
#
#	if($_ =~ m/DOT11-6-DISASSOC/) {
#		my @disassoc = split(/\s+/, $_);
#		my $highest_session_2 = 0;
#		my $mac = $disassoc[13];
#		my @session_count;
#		foreach my $session_2 (keys % { $macs{$mac} }) {
#			if($session_2 > $highest_session_2) {
#				$highest_session_2 = $session_2;
#			}
#		}
#		$macs{$mac}{$highest_session_2}{end_time} = ($disassoc[0].$disassoc[1].$disassoc[2]);
#	}
#	#print $_;
}
close(SYSLOG);
$dbh->disconnect();

sub get_last_session_id {
	my $mac = shift;
	my $start_ap = shift;
	my $start_time = shift;
	my $dbh = shift;
	my $sth = $dbh->prepare( "SELECT MAX(session_id) FROM mac_sessions WHERE mac=?" );
	$sth->execute($mac);

	my $session_id = $sth->fetchrow();

	if(!$session_id) {
		$session_id = 0;
	}

	return $session_id;
	

}

sub insert_row {
	my $mac = shift;	
	my $session_id = shift;
	my $start_ap = shift;
	my $start_time = shift;
	my $dbh = shift;

	my $sth = $dbh->prepare( "INSERT INTO mac_sessions (mac, session_id, start_time, start_ap) VALUES (?, ?, ?, ?)" );
	$sth->execute($mac, $session_id, $start_time, $start_ap);

	$sth->finish();
}

sub check_database {
	my $mac = shift;
	my $start_ap = shift;
	my $start_time = shift;
	my $dbh = shift;
	my $return = 0;

	my $sth = $dbh->prepare( "SELECT * FROM mac_sessions WHERE mac=?" );
	$sth->execute($mac);
      
	if(my $rows = $sth->rows()) {
		$return = 1;
	}

	$sth->finish();
	return $return;
}
