#!/usr/bin/perl -Tw

#Authenticate Apache user using redmine Database

#Use with libapache2-mod-authnz-external

# Based On:
# MySQL-auth version 1.0b
# Anders Nordby <anders@fix.no>, 2002-01-20
# This script is usable for authenticating users against a MySQL database with
# the Apache module mod_auth_external. See
# http://www.wwnet.net/~janc/mod_auth_external.html for mod_auth_external.
#
# Updates to this script will be made available on:
# http://anders.fix.no/software/#unix


my $config_file = "/etc/redmine/default/database.yml";
my $environment = "production";
my $dbhost="localhost";
my $dbuser="redmine";
my $dbpw="redmine";
my $dbname="redmine";
my $dbport="3306";


# Below this, only the SQL query should be interesting to modify for users.

use DBI;
use YAML::Tiny;


sub validchars
{
	# 0: string 1: valid characters
	my $streng = $_[0];

	my $ok = 1;
	my $i = 0;
	while ($ok && $i < length($_[0])) {
		if (index($_[1], substr($_[0],$i,1)) == -1) {
			$ok = 0;
		}
		$i++;
	}
	return($ok);
}






# Get the name of this program
$prog= join ' ',$0,@ARGV;
$logprefix='[' . scalar (localtime) . '] ' . $prog;

# Get the user name
$user= <STDIN>;
chomp $user;

# Get the requied group name
$group= <STDIN>;
chomp $group;


# Open the config
$yaml = YAML::Tiny->read( $config_file );

$config = $yaml->[0]{$environment};


#production:
#  adapter: mysql2
#  database: redmine
#  host: localhost
#  username: redmine
#  password: "redmine"
#  # Use "utf8" instead of "utfmb4" for MySQL prior to 5.7.7
#  encoding: utf8mb4


$dbhost=$config->{host};
$dbuser=$config->{username};
$dbpw=$config->{password};
$dbname=$config->{database};
$dbport="3306";


# check for password in mysql database
#if 
my $dbh = DBI->connect("DBI:mysql:database=$dbname:host=$dbhost:port=$dbport",$dbuser,$dbpw,{PrintError=>0});

if (!$dbh) {
	print STDERR "$logprefix: could not connect to database - Rejected\n";
	exit 1;
}

my $dbq = $dbh->prepare("SELECT count(*) AS groups FROM users WHERE id IN (SELECT group_id FROM groups_users WHERE  user_id = (SELECT id FROM users WHERE login=?)) AND users.lastname LIKE ?;");
$dbq->bind_param(1, $user);
$dbq->bind_param(2, $group);
$dbq->execute;

my $row = $dbq->fetchrow_hashref();
if ($row->{groups} eq "0") {
	print STDERR "$logprefix: $user - is not member of $group - Rejected\n";
	exit 1;
} else {
	print STDERR "$logprefix: $user is member of $group - Accepted\n";
	exit 0;
}

$dbq->finish;
$dbh->disconnect;
