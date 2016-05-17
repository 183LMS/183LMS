#!/usr/bin/perl

my $pidf = "/var/run/lms_bsnmp.pid";
my $snmped_ip = "192.168.2.6";
my $f;
my $sqlf = "/var/run/lms_bsnmp.sql";
my $sqf;
my $inoctets = -1;
my $outoctets = -1;
my $Iface = 6;

if (-f $pidf) {
	open $f, "< $pidf"
		or die "could not open pid file.";
	my $pid_test = <$f>;
	if (kill 0, "$pid_test") {
		die "another lms_ping is running.";
	}
}

open $f, "> $pidf"
	or die "could not open pid file.";
print $f $$;
close $f;

my @snmp_output = `snmpwalk -v2c -cpublic $snmped_ip IF-MIB::ifOutOctets.$Iface`;

foreach my $line(@snmp_output) {
	chomp $line;
	if ($line =~ m/^IF-MIB::ifOutOctets.\d+ = Counter32: (\d+)$/) {
		$outoctets = $1;
	}
}

@snmp_output = `snmpwalk -v2c -cpublic $snmped_ip IF-MIB::ifInOctets.$Iface`;

foreach my $line(@snmp_output) {
	chomp $line;
	if ($line =~ m/^IF-MIB::ifInOctets.\d+ = Counter32: (\d+)$/) {
		$inoctets = $1;
	}
}

my $sqf;
open $sqf, "> $sqlf"
	or die "could not open sql file";

print $sqf "INSERT INTO btable(inB, outB) VALUES (";

if ($inoctets == -1) {
	print $sqf "NULL,";
} else {
	print $sqf "\"$inoctets\",";
}

if ($outoctets == -1) {
	print $sqf "NULL,";
} else {
	print $sqf "\"$outoctets\"";
}

print $sqf ");";

`mysql -prootpass cs183 < $sqlf`;

unlink $sqlf;

unlink $pidf;
