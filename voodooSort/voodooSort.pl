#!/usr/bin/perl

use strict;
use warnings;

sub voodooSort(;@) {
  my (@cData,@c,@out)   = @_;
  our ($a,$b);
  for my $cDataEntry (@cData) {
      if ($cDataEntry =~ /^([sn]):(\d+)$/g) {
          push @c,[$1,$2];
      } else {
          return(0);
      }
  }
  @out = grep {$_ ne '0'} map {
    (
        defined $$a[$$_[1]] and
        defined $$b[$$_[1]]
    ) ? (
        ( $$_[0] eq 's' or $$_[0] ne 'n' ) ?
        $$a[$$_[1]] cmp $$b[$$_[1]] : 
        $$a[$$_[1]] <=> $$b[$$_[1]]
    ) : defined $$a[$$_[1]] ?  1 : -1
  } @c;
  return($out[0]||0);
}

my @zut     = (
        [ 'd1', 7,  'c1' ],
        [ 'd3', -5.5, 'c7' ],
        [ 'd2', 2,  'a3' ],
        [ 'd1', 3,  'b2' ],
        [ 'd1', 5,  'c3' ],
        [ 'd3', 5,  'b3' ],
        [ 'd2', 5,  'a3' ],
        [ 'd3', 0, 'd0' ],
        [ 'd3', 1000, 'd8' ]
);

@zut    = sort {voodooSort('s:0','n:1')} @zut;

for my $zut_entry_ref (@zut) {
        print "".(join ",",@$zut_entry_ref)."\n";
}
print "\n";

@zut    = sort {voodooSort('n:1','s:0')} @zut;

for my $zut_entry_ref (@zut) {
        print "".(join ",",@$zut_entry_ref)."\n";
}
print "\n";

@zut    = sort voodooSort @zut;

for my $zut_entry_ref (@zut) {
        print "".(join ",",@$zut_entry_ref)."\n";
}
print "\n";
