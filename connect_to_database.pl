#!/usr/bin/perl

use strict;
use DBI;

my $dbh = DBI->connect(          
    "dbi:SQLite:dbname=test.db", 
    "",                          
    "",                          
    { RaiseError => 1 },         
) or die $DBI::errstr;

my $sth = $dbh->prepare("SELECT SQLITE_VERSION()");
$sth->execute();

my $ver = $sth->fetch();

print @$ver;
print "\n";

$sth->finish();
$dbh->disconnect();
