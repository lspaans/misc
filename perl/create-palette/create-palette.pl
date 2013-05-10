#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;

sub p_init($);
sub p_create($$);
sub p_print($$$$);

my $output_fmt				= "%s\n";
my $output_typ				= 'dec';
my $output_sep				= ' ';
my $p_steps				= 256;
my $p_steps_most			= 0;
my %p_cfg				= (
	'start'		=> {
		'r' => 128,	'g' => 255,	'b' => 221
	},
	'end'		=> {
		'r' => 255,	'g' => 128,	'b' => 128
	},
	'steps'		=> {
		'r' => $p_steps,'g' => $p_steps,'b' => $p_steps
	}
	
);
my @p					= ();

p_init(\%p_cfg);
p_create(\@p,\%p_cfg);
p_print(\@p,$output_fmt,$output_typ,$output_sep);

exit(0);
1;

#######################################################
# Subroutines
#######################################################

sub p_init($) {
	my $cfg_ref	= shift;
	for my $c ('r','g','b') {
		my $start		= $$cfg_ref{'start'}->{$c};
		my $end			= $$cfg_ref{'end'}->{$c};
		my $steps		= $$cfg_ref{'steps'}->{$c};
		$$cfg_ref{'inc'}->{$c}	= ($end-$start)/$steps;
	}
}

sub p_create($$) {
	my ($p_ref,$cfg_ref)		= @_;
	my $steps_max			= (sort {$a<=>$b}
		values %{$$cfg_ref{'steps'}})[-1];
	my %total			= ();
	my @palette			= ();

	for my $n (1..$steps_max) {
		my %p_entry			= ();
		if (
			not(exists $total{'r'}) or
			not(exists $total{'g'}) or
			not(exists $total{'b'})
		) {
			@p_entry{'r','g','b'}	=
				@{$cfg_ref->{'start'}}{'r','g','b'};
			%total			= %p_entry;
		} else {
			for my $c ('r','g','b') {
				$total{$c}	+= $$cfg_ref{'inc'}->{$c};
				$p_entry{$c}	= int($total{$c} + .5); # !!!
			}
		}
		for my $c ('r','g','b') {
			my ($min,$max)	= sort {$a<=>$b} (
					$$cfg_ref{'start'}->{$c},
					$$cfg_ref{'end'}->{$c}
			);
			if (
				$p_entry{$c} < $min or
				$p_entry{$c} > $max
			) {
				$p_entry{$c}	= $$cfg_ref{'end'}->{$c};
			}
		}
		push @$p_ref, \%p_entry;
	}
}

sub p_print($$$$) {
	my ($p_ref,$fmt,$typ,$sep)	= @_;
	my $out				= "";
	for my $rgb (@$p_ref) {
		$out .= sprintf(
			$fmt,
			join $sep,
				map sprintf(
					(
						$typ eq 'hex' ?
						"%2.2x" :
						"%d"
					),
					$_
				), @$rgb{'r','g','b'}
		);
	}
	print $out;
}

