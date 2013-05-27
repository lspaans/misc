#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;

#                                                                                                     1
#           1         2         3         4         5         6         7         8         9         0
# 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
# -----------------------------------------------------------------------------------------------------
#                     A                   A                   A                   A
# 
#                  A               A                A                A                A


sub sortDistributed(@) {
    my %s = ();
    $s{'s'}->{$_}++ for @_;
    $s{'t'} = scalar @_;
    $s{'w'} = 10**2*(int($s{'t'}/10)+1);
    for my $k (sort keys %{$s{'s'}}) {
        for(my $n=1;$n<=$s{'s'}->{$k};$n++) {
            push @{$s{'d'}->{$n*int(($s{'w'}/($s{'s'}->{$k}+1))+.5)}},$k;
        }
    }
#print Dumper %s;
    map {@{$s{'d'}->{$_}}} sort {$a<=>$b} keys %{$s{'d'}};
}

my @d   = ();
my @r   = ();

@d = qw( A A A A B B B B C C C C );
@r = sortDistributed(@d);

print "( @d ) => ( @r )\n";

@d = qw( A A A A B B C C );
@r = sortDistributed(@d);

print "( @d ) => ( @r )\n";

@d = qw( A A A B A A A );
@r = sortDistributed(@d);

print "( @d ) => ( @r )\n";
