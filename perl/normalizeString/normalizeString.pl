#!/usr/bin/perl

use strict;
use warnings;

sub normalizeString($$) {
    my ($str_in,$dRef)      = @_;
    my $str_out             = $str_in;
    if ( exists $dRef->{'pre'} ) {
        for my $rKey (keys %{$dRef->{'pre'}}) {
            $str_out =~ s/$rKey/$dRef->{'pre'}->{$rKey}/g;
        }
    }
    if ( exists $dRef->{'valid'} ) {
        $str_out    =~ s/[^$dRef->{'valid'}]+//g;
    }
    if ( exists $dRef->{'post'} ) {
        for my $rKey (keys %{$dRef->{'post'}}) {
            $str_out =~ s/$rKey/$dRef->{'post'}->{$rKey}/g;
        }
    }
    return($str_out);
}

my %normProcessName     = (
    'pre'      => {
        '\s+'   => '_'
    },
    'valid'     => 'A-Za-z_',
    'post'   => {
        '_+'    => '_',
        '^_|_$' => ''
    }
);

print normalizeString("Hoi:, dit is echt ()* leuk []",\%normProcessName);
