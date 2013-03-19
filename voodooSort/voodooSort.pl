#!/usr/bin/perl

use strict;
use warnings;

#-----------------------------------------------------------------------------#
# Function      : voodooSort(;@)
# Dependencies  :
# Purpose       : A sorting algorithm for sorting 2d arrays in a  non-regular
#                 way by indicating the column order to use and the type of
#                 comparison (numerical or lexicographical) that should be used
#                 while sorting.
#
# In  : [1] An optional array containing sort indicators. Sort indicators
#           instruct the sorting algorithm in which order to sort the columns
#           of the referenced arrays as contained within the array that is
#           being sorted.
#           Sort indicator syntax: '<sort type>:<col.nr>'.
#           '<sort type>' = 'n' (numerical) or 's' (lexicographical).
#           '<col.nr>' = positive integer value indicating the array column
#           (0=col 1, 1=col 2 etc.)
#
# Out : [1]
#
#-----------------------------------------------------------------------------#

sub voodooSort(;@) {
  my (@cData,@c)   = @_;
  our ($a,$b);
  for(@cData) {
      if (/^([sn]):(\d+)$/g) {
          push @c,[$1,$2];
      } else {
          return(0);
      }
  }
  return(
    (
      grep {$_ ne '0'} map {
      (
          defined $$a[$$_[1]] and
          defined $$b[$$_[1]]
      ) ? (
          ( $$_[0] eq 's' or $$_[0] ne 'n' ) ?
          $$a[$$_[1]] cmp $$b[$$_[1]] : 
          $$a[$$_[1]] <=> $$b[$$_[1]]
      ) : defined $$a[$$_[1]] ?  1 : -1
    } @c
    )[0]||0
  );
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
