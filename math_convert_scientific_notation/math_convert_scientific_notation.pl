#!/usr/bin/perl

use strict;
use warnings;

sub format_eng($) {
}

sub unformat_eng($) {
	my $rgx_math_scientific	= '^([+-]?)(\d+|\d*\.\d+)(?:e([+-]?)(\d+))?$';
	my (@vals,$out)		= ();
	if (@vals = $_[0] =~ /$rgx_math_scientific/g) {
		my ($m,$f,$em,$e)	= @vals;
		map {$_=(defined $_ && $_ eq '-')?-1:1} $m,$em;
		$e||=0;
		$out = $m*$f*10**($em*$e);
	}
	$out;
}
