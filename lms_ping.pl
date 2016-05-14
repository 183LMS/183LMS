#!/usr/bin/perl

###############################################################################
# This is a script for pinging multiple times and averaging and 
# entering it into the database.
###############################################################################

# The default ping format reports
# "10 packets transmitted, 10 received, 0% packet loss, time 8992ms"
# "rtt min/avg/max/mdev = 0.167/0.178/0.208/0.020 ms"
# at the end of each ping request that we run with "ping -c 10 <ip>"

my $pidf = "/var/run/lms_ping.pid";
my $pinged_ip = "192.168.2.6";
my $f;
my $sqlf = "/var/run/lms_ping.sql";

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


my @ping_output = `ping -c 10 $pinged_ip`;

my $pkts_loss_pct = -1;
my $pkt_avg_ping = -1;
my $pkt_jitter = -1;

foreach my $line(@ping_output) {
	if ($line =~ m/^\d+ packets transmitted, \d+ received, (\d+)% packet loss, time \d+ms$/) {
		$pkts_loss_pct = $1;
	}
	if ($line =~ m/^rtt min\/avg\/max\/mdev = [\d|.]+\/([\d|.]+)\/[\d|.]+\/([\d|.]+) ms$/) {
		$pkt_avg_ping = $1;
		$pkt_jitter = $2;
	}
}

if ($pkts_loss_pct == -1) {
	print "No lost packet count found. Likely not pingable.\n";
} else {
	print "$pkts_loss_pct packets lost \n";
}

if ($pkt_avg_ping == -1) {
	print "No average count found. Likely not pingable.\n";
} else {
	print "Average ping: $pkt_avg_ping\n";
}

if ($pkt_jitter == -1) {
	print "No packet jitter found.  Likely not pingable.\n";
} else {
	print "Packet Jitter: $pkt_jitter \n";
}

my $sqf;
open $sqf, "> $sqlf"
	or die "could not open sql file";

print $sqf "INSERT INTO testpings(ping) VALUES (\"$pkt_avg_ping\");";

`mysql -prootpass cs183 < $sqlf`;

unlink $sqlf;


unlink $pidf;
