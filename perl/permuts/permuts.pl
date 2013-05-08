#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;

sub getPermuts(@);

my @someStuff	= qw( a b c );
my @moreStuff	= qw( 1 2 3 );
my @lastStuff	= qw( x y z );

my @stuff	= ( \@someStuff, \@moreStuff, \@lastStuff );
my @permuts	= getPermuts(@stuff);

print Dumper \@permuts;

exit(0);
1;

sub getPermuts(@) {
	my $lRef	= shift @_;
	my @p		= map [$_], @$lRef;
	while(@_>0) {
		my $aRef	= shift @_;
		my @n		= ();
		for my $pSub (@p) {
			for(@$aRef) {
				push @n, [@$pSub,$_];
			}
		}
		@p = @n;
	}
	return(@p);
}
