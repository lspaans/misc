#!/usr/bin/perl

use strict;
use warnings;

sub randomize($$$$$) {
	my ($val,$min,$max,$delta_min_pct,$delta_max_pct)	= @_;
	my $delta_pct = $delta_min_pct + rand($delta_max_pct-$delta_min_pct);
	$val = $val + ( $val / 100 ) * $delta_pct;
	$val = $val > $max ? $max : $val < $min ? $min : $val;
	return($val);
}

my $L20_score_min			= 0;
my $L20_score_max			= 2000;
my $L20_score_delta_pct_min		= -2;
my $L20_score_delta_pct_max		= 0;
my $L20_score				= $L20_score_max;

my $asset_size_bytes_min		= 1024**3*0.5;
my $asset_size_bytes_max		= 1024**3*8;
my $asset_size_bytes_delta_pct_min	= -50;
my $asset_size_bytes_delta_pct_max	= 50;
my $asset_size_bytes			= $asset_size_bytes_max;

my $iterations				= 400;
my $output_separator			= " ";

for(my $n=0;$n<$iterations;$n++) {
	print "".(
		join $output_separator,
			int($L20_score),
			int($asset_size_bytes)
	)."\n";
	$L20_score		= randomize(
		$L20_score,
		$L20_score_min,
		$L20_score_max,
		$L20_score_delta_pct_min,
		$L20_score_delta_pct_max
	);
	$asset_size_bytes	= randomize(
		$asset_size_bytes,
		$asset_size_bytes_min,
		$asset_size_bytes_max,
		$asset_size_bytes_delta_pct_min,
		$asset_size_bytes_delta_pct_max
	);
}
