#!/usr/bin/perl

use strict;
use warnings;

sub format_eng($) {
}

sub unformat_eng($) {
    my ($xP,$xN)        = ([qw(k M G T P E Z Y)],[qw(m u n p f a z y)]);
    my $rgx_math_eng    = '^([+-]?)(\d+|\d*\.\d+)(['.(
        join '',@$xP,@$xN
    ).']?)$';
    my (@vals,$out)		= ();
    if (@vals = $_[0] =~ /$rgx_math_eng/g) {
	my ($m,$f,$u)	= @vals;
        my $e           = 0;
        $m  = ( defined $m && $m eq '-' )?-1:1;
        if (defined $u) {
            my $n   = 0;
            map {++$n and $_ eq $u and $e=$n} @$xP;
            if($e==0) {
                $n      = 0;
                map {--$n and $_ eq $u and $e=$n} @$xN;
            }
        }
        $out = $m*$f*(10**($e*3));
    }
    $out;
}

sub format_sci($) {
}

sub unformat_sci($) {
	my $rgx_math_sci	= '^([+-]?)(\d+|\d*\.\d+)(?:e([+-]?)(\d+))?$';
	my (@vals,$out)	    = ();
	if (@vals = $_[0] =~ /$rgx_math_sci/g) {
		my ($m,$f,$em,$e)	= @vals;
		map {$_=(defined $_ and $_ eq '-')?-1:1} $m,$em;
		$e||=0;
		$out = $m*$f*10**($em*$e);
	}
	$out;
}

printf("in: '%s', out: '%f'\n","2G",unformat_eng("2G"));
printf("in: '%s', out: '%f'\n","2.2e-3",unformat_sci("2.2e-3"));
