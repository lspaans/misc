#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;

sub sortScore($;$);
sub getPermuts($;$);
sub getPermutsFlattened($$;$);

#my @data    	= qw( A A A B B B C C C );
my @data    	= qw( A A A A A A A A B );
my %result  	= ();
my @permuts	= ();
my %scores	= ();
my $highest	= 0;
my @top		= ();

getPermuts(\%result,\@data);
getPermutsFlattened(\%result,\@permuts);

for my $lRef (@permuts) {
	push @{$scores{sortScore($lRef)}}, $lRef;
}

$highest	= (sort {$a<=>$b} keys %scores)[-1];
@top		= @{$scores{$highest}};

print "".(join " ",@{$_})." (".$highest.")\n" for @top;

exit(0);

sub sortScore($;$) {
    my ($dRef,$debug)   = @_;
    my @d               = @{$dRef};
    my $score           = 0;
    for (my $n=0;$n<@d;$n++) {
        for (my $m=0;$m<@d;$m++) {
            my $inc     = 0;
            next if $n==$m;
            if ( $d[$n] eq $d[$m] ) {
		$inc    = 2**(( $n > $m  ? $n - $m : $m - $n) - 1);
                $score  += $inc;
	    }
            if (
                defined $debug and
                defined $debug != 0
            ) {
                print "".(
                    join "",
                        map {
                            $_==$n ? 
                            "[$d[$_]]" : 
                            $_==$m ? 
                            "($d[$_])" :
                            "$d[$_]"
                        } 0..$#d
                )." = ".$inc." (".$score.")\n";
            }
        }
    }
    return($score);
}

sub getPermuts($;$) {
	my ($rRef,$lRef)    = @_;
	for (my $n=0;$n<=$#{$lRef};$n++) {
   		my @t	= @{$lRef};
		my $e	= splice @t,$n,1;
		if ( $#t > -1 ) {
			getPermuts(\%{$rRef->{$e}},\@t);
		} else {
			$rRef->{$e}	= 1;
		}
	}
}

sub getPermutsFlattened($$;$) {
        my ($hRef,$lRef,$vRef)          = @_;
        for my $key (keys %{$hRef}) {
                my @tmp = ( (defined $vRef?@{$vRef}:()) ,$key);
                if (ref($hRef->{$key}) eq 'HASH') {
                        getPermutsFlattened($hRef->{$key},$lRef,\@tmp);
                } elsif  (
                                ref($hRef->{$key}) eq '' or
                                ref($hRef->{$key}) eq 'ARRAY'
                ) {
                        push @{$lRef}, \@tmp;
                }
        }
}

