#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;

sub relTime($;$) {
    my ($r,$t)          = @_;
    my @m               = (
        {'S' =>  1}, {'M' => 60}, {'H' => 60},
        {'d' => 24}, {'w' =>  7}
    );
    my ($s,$n,$l);
    my $d               = 0;

    if (
        defined $r and
        ($s,$n,$l) = $r =~ /^([\+\-]?)(\d*)([SMHdw])$/g
    ) {
        $d = (defined $s and $s eq '-') ? -1 : 1;
        $n = (defined $n) ? $n : 1;
        $d *= $n;
        for my $ts (@m) {
            my ($k,$v)  = each %$ts;
            $d *= $v;
            if ($l eq $k) {
                last;
            }
        }
    }

    return((defined $t ? $t : time) + $d);
}

my ($S,$M,$H,$d,$m,$Y);

($S,$M,$H,$d,$m,$Y)  = localtime(relTime('-1d',time+86400));
printf("%.4d-%.2d-%.2d %.2d:%.2d:%.2d\n",$Y+1900,$m+1,$d,$H,$M,$S);

($S,$M,$H,$d,$m,$Y)  = localtime(relTime('+1H'));
printf("%.4d-%.2d-%.2d %.2d:%.2d:%.2d\n",$Y+1900,$m+1,$d,$H,$M,$S);


($S,$M,$H,$d,$m,$Y)  = localtime(relTime('5w'));
printf("%.4d-%.2d-%.2d %.2d:%.2d:%.2d\n",$Y+1900,$m+1,$d,$H,$M,$S);

