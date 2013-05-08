#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;

sub setDeepStoreValue($$@);
sub getDeepStoreValue($$@);
sub convertDeepStoreToArray($$;$);

my %data	= ();

my @hosts	= map {join ".",$_,$_,$_,$_} 0..7;
my @ports	= map {int(rand(65536))} 0..7;

my %remote_data	= (
	'remote_port'	=> \@ports,
	'remote_host'	=> \@hosts
);

my @group_keys		= qw( remote_host remote_port );

my @permuts		= ();

for my $n (1..10) {
	my @group_values	= map {$remote_data{$_}->[int(rand($#{$remote_data{$_}}))]} @group_keys;
	my $value		= 1;
	setDeepStoreValue(\%data,1,@group_values,$value);
}

print "x"x75 ."\n";
print Dumper %data;
print "x"x75 ."\n";

convertDeepStoreToArray(\%data,\@permuts);

print "="x75 ."\n";
print Dumper \@permuts;
print "="x75 ."\n";

exit(0);
1;

sub setDeepStoreValue($$@) {
	my ($hRef,$push,@elems)	= @_;
	my $key			= shift @elems;
	if ( @elems > 1 ) {
		my %h		= ();
		if (
			exists $hRef->{$key} and
			ref($hRef->{$key}) eq 'HASH'
		) {
			%h	= %{$hRef->{$key}};
		}
		$hRef->{$key}	= setDeepStoreValue(\%h,$push,@elems);
	} else {
		if (exists $hRef->{$key}) {
			if (
				(
					ref($hRef->{$key}) eq '' or
					ref($hRef->{$key}) eq 'ARRAY'
				) and
				defined $push and
				$push !~ /^(0|false)$/i
			) {
				my @elems_prev	= ();
				if ( ref($hRef->{$key}) eq '' ) {
					@elems_prev	= ( $hRef->{$key} );
				} else {
					@elems_prev	= @{$hRef->{$key}}
				}
				if ( $push eq '1' ) {
					push @elems, @elems_prev;
				} else {
					unshift @elems, @elems_prev;
				}
				$hRef->{$key}	= \@elems;
			} else {
				$hRef->{$key}	= shift @elems;
			}
		} else {
			$hRef->{$key}	= shift @elems;
		}
	}
	return($hRef);
}

sub getDeepStoreValue($$@) {
	my ($hRef,$pop,@elems)	= @_;
	my $key			= shift @elems;
	my $out;
	if ( @elems > 0 ) {
		if ( exists $hRef->{$key} ) {
			$out	= getDeepStoreValue($hRef->{$key},$pop,@elems);
		} else {
			$out	= undef;
		}
	} else {
		if ( exists $hRef->{$key} ) {
			if (
				defined $pop and
				$pop !~ /^(0|false)$/i
			) {
				if ( ref($hRef->{$key}) eq 'ARRAY' ) {
					if ( $pop eq '2' ) {
						$out	= shift @{$hRef->{$key}};
					} else {
						$out	= pop @{$hRef->{$key}};
					}
				} elsif ( ref($hRef->{$key}) eq '' ) {
					$out	= $hRef->{$key};
					delete $hRef->{$key};
				}
			} else {
				$out	= $hRef->{$key};
			}
		} else {
			$out	= undef;
		}
	}
	return($out);
}

sub convertDeepStoreToArray($$;$) {
	my ($hRef,$lRef,$vRef)		= @_;
	for my $key (keys %{$hRef}) {
		my @tmp	= ( (defined $vRef?@{$vRef}:()) ,$key);
		if (ref($hRef->{$key}) eq 'HASH') {
			convertDeepStoreToArray($hRef->{$key},$lRef,\@tmp);
		} elsif  (
				ref($hRef->{$key}) eq '' or
				ref($hRef->{$key}) eq 'ARRAY'
		) {
			push @{$lRef}, \@tmp;
		}
	}
}
