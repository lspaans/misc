#!/usr/bin/perl

use strict;
use warnings;

sub findInPath($) {
    my ($file)                  = @_;
    my ($file_full);
    if (
        defined $file and
        exists $ENV{'PATH'}
    ) {
        for my $path (split /:/,$ENV{'PATH'}) {
            my @path_files  = ();
            if(not(opendir(DIR, $path))) {
                next;
            }
            @path_files = grep {!/^\.{1,2}$/} readdir(DIR);
            for my $path_file (@path_files) {
                if ($file eq $path_file) {
                    $file_full  = $path."/".$path_file;
                    last;
                }
            }
            closedir(DIR);
        }
    }
    return($file_full);
}

my $file_bin_pgrep          = "pgrep";
my $file_bin_pgrep_full     = findInPath($file_bin_pgrep);

if ( defined $file_bin_pgrep_full ) {
    print "\$file_bin_pgrep_full = '".$file_bin_pgrep_full."'\n";
}

