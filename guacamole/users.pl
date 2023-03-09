#!/usr/bin/perl

use strict;
use warnings;

open(FH, '>', 'user-mapping.xml');
open(US, 'users');

print FH "<user-mapping>\n";

my %prots = (
	rdp => 3389,
	ssh => 22,
	vnc => 5900
);

if (scalar(@ARGV) > 0) {
    print "This will take a in a users file and generate a users-mapping.xml file for apache guacamole\n";
    print "Please see the users file for specifications\n";
    exit(1);
}


while (<US>) {
	chomp;
    next if ($_ =~ /^\#/);
	my @parts = split(/\|/, $_);
	my $command = 'useradd -m ';
	if (length($parts[2]) > 1) {
		$command .= "-G $parts[2] ";
	}
	$command .= "$parts[0]";
	$command .= qq{ && echo -e "$parts[0]:$parts[1]" | chpasswd --md5 $parts[0]};
	#system($command);
	print($command, "\n");
	print FH qq{    <authorize
            username="$parts[0]"
            password="$parts[1]">\n};
	foreach my $prot (split(/,/, $parts[3])) {
		my $port = $prots{$prot};
		print FH qq{		<connection name="$prot">
		    <protocol>$prot</protocol>
		    <param name="hostname">localhost</param>
		    <param name="port">$port</param>\n};
		if ($prot eq 'ssh' || $prot eq 'rdp') {
			print FH qq{		    <param name="username">$parts[0]</param>\n};
		}
print FH qq{		    <param name="password">$parts[1]</param>
		</connection>\n};
	}
	print FH qq{    </authorize>\n};
}
print FH "</user-mapping>\n";

close(FH);
close(US);
