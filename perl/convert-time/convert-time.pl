#!/usr/bin/env perl

use warnings;
use strict;

use POSIX;

our $FORMAT_DATE_TIME_INPUT = '%Y%m%d%H%M%S';
our $FORMAT_DATE_TIME_OUTPUT = '%s';
our $DATE_TIME_INPUT = strftime(
    $FORMAT_DATE_TIME_INPUT,
    localtime(time)
);


sub get_converted_date_time_stamp(@) {
    my $date_time_input = shift || $DATE_TIME_INPUT;
    my $format_date_time_input = shift || $FORMAT_DATE_TIME_INPUT;
    my $format_date_time_output = shift || $FORMAT_DATE_TIME_OUTPUT;
    my $rgx_date_time_input = $format_date_time_input;
    my @now = localtime(time);
    my %time = map {$_=>shift @now} qw(S M H d m Y);

    my @time_indicators = $format_date_time_input =~ /(?:%([YmdHMS]))/g;

    $rgx_date_time_input =~ s/(%[YmdHMS])/"(\\d{".
        length(strftime($1, localtime)).
    "})"/ge;

    for my $value ($date_time_input =~ /$rgx_date_time_input/g) {
        my $time_indicator = shift @time_indicators;
        if ($time_indicator eq 'Y') {
            $value -= 1900;
        } elsif ($time_indicator eq 'm') {
            $value -= 1;
        }
        $time{$time_indicator} = $value
    }

    return(strftime(
        $format_date_time_output,
        map $time{$_}, qw(S M H d m Y)
    ));
}


sub main() {
    print(get_converted_date_time_stamp(@ARGV)."\n")
};


main();
