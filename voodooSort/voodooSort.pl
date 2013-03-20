#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;

#-----------------------------------------------------------------------------#
# Function      : voodooSort(;@)
# Dependencies  :
# Purpose       : A sorting algorithm for sorting 2d arrays in a  non-regular
#                 way by indicating the column order to use and the type of
#                 comparison (numerical, lexicographical or by a custom
#                 function) that should be used while sorting.
#
# Out : [1]
#
#-----------------------------------------------------------------------------#

sub funkyCompare($$;@) {
    my ($a,$b,@params)  = @_;
    return(1-(($a+$b)%3));
}

sub voodooSort(;@) {
    my (@instr)   = @_;
    our ($a,$b);
    for(@instr) {
        if (
            (
                exists $_->{'t'} and
                $_->{'t'} !~ /^[snf]$/
            ) or
            not(exists $_->{'c'}) or (
                $_->{'t'} eq 'f' and (
                    not(exists $_->{'f'}) or
                    ref($_->{'f'}) ne 'CODE'
                )
            )
        ) {
            return(0)
        } 
    }
    return(
        (
            grep {$_ ne '0'} map {
                (
                    defined $$a[$_->{'c'}] and
                    defined $$b[$_->{'c'}]
                ) ? (
                    (
                        not(exists $_->{'t'}) or
                        $_->{'t'} eq 's'
                    ) ? $$a[$_->{'c'}] cmp $$b[$_->{'c'}] :
                    ( $_->{'t'} eq 'n' ) ?
                    $$a[$_->{'c'}] <=> $$b[$_->{'c'}] :
                    ( $_->{'t'} eq 'f' ) ?
                    &{$_->{'f'}}(
                        $$a[$_->{'c'}],
                        $$b[$_->{'c'}],
                        @{$_->{'p'}}
                    ) :
                    0
                ) : defined $$a[$_->{'c'}] ?  1 : -1
            } @instr
        )[0]||0
    );
}

my @def_zut     = (
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
my @zut;

my @sortInstructions    = ();

@sortInstructions    = ({'t'=>'s','c'=>0},{'t'=>'n','c'=>1});
@zut    = sort {voodooSort(@sortInstructions)} @def_zut;
print "".(join ",",@$_)."\n" for @zut;
print "\n";

@sortInstructions    = ({'t'=>'n','c'=>1},{'t'=>'s','c'=>0});
@zut    = sort {voodooSort(@sortInstructions)} @def_zut;
print "".(join ",",@$_)."\n" for @zut;
print "\n";

@zut    = sort voodooSort @def_zut;
print "".(join ",",@$_)."\n" for @zut;
print "\n";

@sortInstructions    = ({'t'=>'f','c'=>1, 'f'=>\&funkyCompare,'p'=>[1,3,2]});
@zut    = sort {voodooSort(@sortInstructions)} @def_zut;
print "".(join ",",@$_)."\n" for @zut;
print "\n";
