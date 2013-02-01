#!/usr/bin/perl

use strict;
use warnings;

sub arraySort {
	my $n	= 0;
	while (
		defined $a and
		defined $b and
		ref($a) eq 'ARRAY' and
		ref($b) eq 'ARRAY' and
		defined $$a[$n] and
		defined $$b[$n] and
		ref($$a[$n]) eq '' and
		ref($$b[$n]) eq '' and
		(
			(
				not(defined $$a[$n]) and
				not(defined $$b[$n])
			) or (
				$$a[$n] eq $$b[$n]
			)
		)
	) {
		$n++;
	}
	if (
		not(defined $a) or
		not(defined $b)
	) {
		return(defined $a?1:-1);
	} elsif (
		ref($a) ne 'ARRAY' or
		ref($b) ne 'ARRAY'
	) {
		return(ref($a) eq 'ARRAY'?1:-1);
	} elsif (
		not(defined $$a[$n]) or
		not(defined $$b[$n])
	) {
		return(defined $$a[$n]?1:-1);
	} elsif (
		ref($$a[$n]) ne '' or
		ref($$b[$n]) ne ''
	) {
		return(ref($$a[$n]) eq ''?1:-1);
	} elsif (
		$$a[$n] =~ /^\d+$/ and
		$$b[$n] =~ /^\d+$/
	) {
		return($$a[$n] <=> $$b[$n]);
	} else {
		return($$a[$n] cmp $$b[$n]);
	}
}

my @listOfListsRefs	= ( [3,2,1], [1,2,3], [2,2,2], [1,1], [1,3], [1,1,2] );

for my $listOfListsRef (sort arraySort @listOfListsRefs) {
	print "\@\$listOfListsRef = ( @$listOfListsRef )\n";
}
