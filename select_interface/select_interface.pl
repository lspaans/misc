#!/usr/bin/perl

use strict;
use warnings;

my $bin_ifconfig                    = "/sbin/ifconfig";

my @interface_ip_ignore             = ( '127.0.0.1' );
my @interface_ip_list               = ();

my $rgx_dec_ip_address_separator    = '\.';                         
my $rgx_dec_ip_octet                = '(?:\d{1,2}|[01]\d{2}|2[0..4]\d|25[0..5])';
my $rgx_dec_ip_address              = join $rgx_dec_ip_address_separator, (
    map $rgx_dec_ip_octet, 1..4                                         
); 
my $rgx_interface_ip                = "inet addr:(".$rgx_dec_ip_address.")";

my $choice                          = "";

unless(open PH, $bin_ifconfig."|") {
    die "ERROR: Cannot open pipe to: '".$bin_ifconfig."'\n";
}

while(my $line_in=<PH>) {
    chomp($line_in);
    if ( $line_in =~ /$rgx_interface_ip/ ) {
        my $interface_ip    = $1;
        unless(scalar map {$interface_ip eq $_ ? 1 : ()} @interface_ip_ignore) {
            push @interface_ip_list, $interface_ip;
        }
    }
}

close(PH);

if ($#interface_ip_list>=0) {
    for(my $n=0;$n<@interface_ip_list;$n++) {
        print "[".($n+1)."] ".$interface_ip_list[$n]."\n";
    }
    while(
        $choice eq "" or (
            $choice =~ /^[a-z]+$/i and
            lc($choice) ne 'q'
        ) or (
            $choice =~ /^\d+$/ and
            (
                $choice < 1 or
                $choice > @interface_ip_list
            )
        ) or $choice !~ /^[a-z0-9]+$/i
    ) {
        print "Make your choice [q=quit]: ";
        $choice = <STDIN>;
        chomp($choice);
    }
}

if ( lc($choice) ne 'q' ) {
    print "You have chosen: '".$interface_ip_list[$choice-1]."'\n";
}
