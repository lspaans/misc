#!/usr/bin/perl
###############################################################################
#
#   Copyright (C) Reggefiber / Glashart Media
#   All Rights Reserved
#
#   <Module>:=      [watch-log.pl]
#   Author:         L. Spaans
#   Date:           12 July 2013
#   Purpose:        
#
#   <Module>:=      [watch-log.pl]
#   <Library>:=     [monitoring]
#   <Version>:=     [0.1]
#   <Date-Time>:=   [20130712/14:43:00]
#
#   Amendment history:
#   20130712    LS    Initial version
#
###############################################################################

package Object;

#=============================================================================#
# Used Perl modules
#=============================================================================#

use strict;
use warnings;

#=============================================================================#
# Object methods
#=============================================================================#

sub getProperty() {
    my ($self,$property)            = @_;
    exists $self->{'_'.$property}?$self->{'_'.$property}:();
}

sub setProperty() {
    my ($self,$property,$value)     = @_;
    if (exists $self->{'_'.$property}) {
        $self->{'_'.$property}	= $value;
    }
}

sub new {
    my ($class,$value)              = @_;
    my $self                        = {
        '_value'    => undef
    };
    bless $self,$class;
    $self->init();
    $self;
}

sub init {
    my ($self,$value)               = @_;
    $self->setValue($value);
    $self;
}

sub getValue {
    my ($self)                      = @_;
    $self->getProperty('value');
}

sub setValue {
    my ($self,$value)               = @_;
    $self->setProperty('value',$value);
}

sub toString() {
    my ($self)                      = @_;
    String->new($self->getValue());
}

sub equals() {
    my ($self,$objectRef)           = @_;
    return(0);
}

sub equalsIgnoreCase() {
    my ($self,$objectRef)           = @_;
    return(
        Object->new(
            lc $self->getValue())->equals(
                Object->new(lc $objectRef->getValue()
            )
        )
    );
}

1;

###############################################################################
#
# Object  : "Cache"
# Purpose : 
#
###############################################################################

package Cache;

#=============================================================================#
# Used Perl modules
#=============================================================================#

use strict;
use warnings;

our @ISA = qw( Object );

my %meta_data_cache             = (
    'syntax'    => {
        'n_lines_pre_match'     => '^\d+$',
        'n_lines_post_match'    => '^\d+$'
    }
);

#=============================================================================#
# Object methods
#=============================================================================#

sub new {
    my (
        $class,
        $lines_pre,     $lines_post,
        $pre_cache_ref
    )	= @_;
    my $self                        = {
        '_n'                    => 0,
        '_n_lines_pre_match'    => undef,
        '_n_lines_post_match'   => undef,
        '_line_cache'           => []
    };
    bless $self,$class;
    $self->init(
        $lines_pre,     $lines_post
    );
    if (
        defined $pre_cache_ref and
        ref($pre_cache_ref) eq 'ARRAY'
    ) {
        for my $n ((-1*$lines_pre)..-1) {
            if (defined $pre_cache_ref->[$n]) {
                $self->add($pre_cache_ref->[$n]);
            }
        }
        $self->{'_n'} = $lines_pre;
    }
    $self;
}

sub isValidSyntax() {
    my ($self,$type,$value)             = @_;
    if (
        defined $type and defined $value and
        exists $meta_data_cache{'syntax'} and
        exists $meta_data_cache{'syntax'}->{$type} and
        defined $meta_data_cache{'syntax'}->{$type} and
        $value =~ $meta_data_cache{'syntax'}->{$type}
    ) {
        return(1);
    }
    return(0);
}

sub isValid() {
    my ($self,$type,$value)             = @_;
    if (
        $self->isValidSyntax($type,$value)
    ) {
        return(1);
    }
    return(0);
}

sub getCache() {
    my ($self)                          = @_;
    return(\@{$self->{'_line_cache'}});
}

sub isFull() {
    my ($self)                          = @_;
    if (
        $self->{'_n'} >= (
            $self->{'_n_lines_pre_match'} +
            $self->{'_n_lines_post_match'} +
            1
        )
    ) {
        return(1);
    }
    return(0);
}

sub setLinesPre() {
    my ($self,$value)                   = @_;
    if ($self->isValid('n_lines_pre_match',$value)) {
        $self->setProperty('n_lines_pre_match',$value);
    }
}

sub setLinesPost() {
    my ($self,$value)                   = @_;
    if ($self->isValid('n_lines_post_match',$value)) {
        $self->setProperty('n_lines_post_match',$value);
    }
}

sub init {
    my (
        $self,
        $lines_pre,  $lines_post
    )                                   = @_;
    $self->setLinesPre($lines_pre);
    $self->setLinesPost($lines_post);
}

sub add() {
    my ($self,$value)                   = @_;
    push @{$self->{'_line_cache'}}, $value;
    $self->{'_n'}++;
    while(
        $#{$self->{'_line_cache'}} >
        (
            $self->{'_n_lines_pre_match'} +
            $self->{'_n_lines_post_match'}
        )
    ) {
        shift @{$self->{'_line_cache'}};
        $self->{'_n'}--;
    }
}

1;

###############################################################################
#
# Object  : "Main"
# Purpose : 
#
###############################################################################

package Main;

#=============================================================================#
# Used Perl modules
#=============================================================================#

use 5.010;

use strict;
use warnings;

use 5.010;

use Getopt::Long;
use IO::Select;
use POSIX           qw(     strftime    );
use Pod::Usage;
use Time::HiRes     qw(     usleep      );
use threads;
use Thread::Queue;

use Data::Dumper;

#=============================================================================#
# Sub-routine prototypes
#=============================================================================#

sub relTime($;$);

sub interpolateVariables($$);
sub interpolateTime($$);

sub initializeParamValues($$$);
sub processParamValues($$$);
sub applyParamDefValues($);

sub matchesOne($$$);
sub matches($$$$);
sub readFile($$$$$$$$$$$);

#=============================================================================#
# Declaration of default values
#=============================================================================#

my $def_file_rel_date   = '0d';
my $def_log_rel_date    = '0d';
my $def_flush           = 1;
my $def_follow          = 0;
my $def_cs              = 0;
my $def_with_filename   = 0;

my @def_includes        = qw( ^.*$ );
my @def_excludes        = qw( );

my $def_after_context   = 0;
my $def_before_context  = 0;
my $def_context         = 0;

my $def_help            = 0;
my $def_man             = 0;

#=============================================================================#
# Declaration of variables
#=============================================================================#

my $rgx_rel_date        = '^[\+\-]?\d+[SMHdw]$';
my $rgx_integer         = '^\d+$';

my %syntaxes            = (
    'file_rel_date'  => {
        'rgx'   => $rgx_rel_date,
        'cs'    => 1
    },
    'log_rel_date'  => {
        'rgx'   => $rgx_rel_date,
        'cs'    => 1
    },
    'after_context'  => {
        'rgx'   => $rgx_integer
    },
    'before_context'  => {
        'rgx'   => $rgx_integer
    },
    'context'  => {
        'rgx'   => $rgx_integer
    }
);

my %transformation  = (
#    'file_rel_date'   => sub{join '',reverse split //,$_[0]}
);

my @files_in        = ();

my $file_rel_date;
my $log_rel_date;
my $flush;
my $follow;
my $cs;
my $with_filename;

my @includes        = ();
my @excludes        = ();

my $after_context;
my $before_context;
my $context;

my $help;
my $man;

my $msg             = "";

my $do_follow       = 1;
my $sleep_usecs     = 1000000;

my @caches_out      = ();

my @threads         = ();
my $queue           = Thread::Queue->new();
my $data_ref;

my %param_config    = (
    'file_rel_date'   => {
        'var'       => \$file_rel_date,
        'option'    => 'f|file-rel-date=s{1}',
        'def'       => \$def_file_rel_date
    },
    'log_rel_date'   => {
        'var'       => \$log_rel_date,
        'option'    => 'l|log-rel-date=s{1}',
        'def'       => \$def_log_rel_date
    },
    'flush'     => {
        'var'       => \$flush,
        'option'    => 'flush!',
        'def'       => \$def_flush
    },
    'follow'    => {
        'var'       => \$follow,
        'option'    => 'follow!',
        'def'       => \$def_follow
    },
    'include'   => {
        'var'       => \@includes,
        'option'    => 'i|include=s',
        'def'       => \@def_includes
    },
    'exclude'   => {
        'var'       => \@excludes,
        'option'    => 'e|exclude=s',
        'def'       => \@def_excludes
    },
    'after_context' => {
        'var'       => \$after_context,
        'option'    => 'A|after-context=i{1}',
        'def'       => \$def_after_context
    },
    'before_context' => {
        'var'       => \$before_context,
        'option'    => 'B|before-context=i{1}',
        'def'       => \$def_before_context
    },
    'context'   => {
        'var'       => \$context,
        'option'    => 'C|context=i{1}',
        'def'       => \$def_context
    },
    'cs'        => {
        'var'       => \$cs,
        'option'    => 'cs!',
        'def'       => \$def_cs
    },
    'with_filename' => {
        'var'       => \$with_filename,
        'option'    => 'w|with-filename',
        'def'       => \$def_with_filename
    },
    'help'      => {
        'var'       => \$help,
        'option'    => 'h|help',
        'def'       => \$def_help
    },
    'man'       => {
        'var'       => \$man,
        'option'    => 'm|man',
        'def'       => \$def_man
    }
);

#=============================================================================#
# Processing the command-line
#=============================================================================#

GetOptions(
    map @{$_}{'option','var'}, values %param_config
) or pod2usage(2);

if (defined $context) {
    if (not(defined $after_context)) {
        $after_context  = $context;
    }
    if (not(defined $before_context)) {
        $before_context  = $context;
    }
}

initializeParamValues(
    \%param_config,
    \%syntaxes,
    \%transformation
);

if ( $help ) {
    pod2usage(1);
}

if ( $man ) {
    pod2usage(
        "-exitstatus"   => 0,
        "-verbose"      => 2
    )
}

push @files_in, @ARGV;

@files_in   = map interpolateVariables($_,relTime($file_rel_date)), @files_in;
@includes   = map interpolateVariables($_,relTime($log_rel_date)), @includes;
@excludes   = map interpolateVariables($_,relTime($log_rel_date)), @excludes;

#=============================================================================#
# MAIN
#=============================================================================#

if ( $#files_in >= 0 ) {
    my $name        = "";
    for my $file_in (@files_in) {
        my ($fh,$thr);
        if(not(open $fh,"<".$file_in)) {
            $msg    = "ERROR: Cannot open file: '".$file_in."' for reading. ".
                "Exiting!\n";
            die $msg;
        }
        if ( $with_filename != 0 ) {
            $name   = $file_in;
        }
        $thr    = threads->create(
            \&readFile,     $fh,            $name,
            $flush,         $follow,
            $after_context, $before_context,
            \@includes,     \@excludes,
            $cs,            $sleep_usecs,   $queue
        );
        if (defined $thr) {
            push @threads, $thr;
        } else {
            $msg    = "ERROR: Could not create thread for reading file: ".
                "'".$file_in."'. Exiting!\n";
            die $msg;
        }
    }
} else {
    my $name        = "";
    my $thr         = threads->create(
        \&readFile,     \*STDIN,        $name,
        $flush,         $follow,
        $after_context, $before_context,
        \@includes,     \@excludes,
        $cs,            $sleep_usecs,   $queue
    );
    if (defined $thr) {
        push @threads, $thr;
    } else {
        $msg    = "ERROR: Could not create thread for reading STDIN. ".
           "Exiting!\n";
        die $msg;
    }
}

while( $#threads >= 0 and $data_ref = $queue->dequeue() ) {
    if ( exists $data_ref->{'data'} ) {
        for my $line_out (@{$data_ref->{'data'}}) {
            print $line_out."\n";
        }
    } else {
        @threads    = grep {$_->tid() ne $data_ref->{'tid'}} @threads;
        for my $thr (threads->list()) {
            if ($thr->tid() eq $data_ref->{'tid'}) {
                $thr->join();
            }
        }
    }
}

exit(0);
1;

#=============================================================================#
# Sub-routine declarations
#=============================================================================#

#-----------------------------------------------------------------------------#
# Function     : relTime($;$)
# Dependencies : 
# Function     : This function returns the number of seconds since epoch time
#                (i.e. 00:00:00 01-01-1970) that have passed until the moment
#                indicated by this sub-routines arguments.
#
#
# In  : [1] Delta time (Examples, '-1d', '+2H', '3w', indicating respectively
#           '1 day ago', '2 hours from now' and '3 weeks from now). Valid
#           period indicators are: 'S' for seconds, 'M' for minutes, 'H' for
#           hours, 'd' for days and 'w' for weeks.
#       [2] An optional value indicating the number of seconds since epoch time
#           to which the delta time should be applied. Default is the current
#           epoch time.
#
# Out : [1] The number of seconds since the epoch that have passed until the
#           moment indicated by this sub-routines arguments.
#
#-----------------------------------------------------------------------------#

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

#-----------------------------------------------------------------------------#
# Function     : interpolateVariables($$)
# Dependencies : 
# Function     : A generic sub-routine for interpolating variables into a
#                supplied string. This implementation currently only inter-
#                polates time indicators.
#
# In  : [1] String that might contain variables that need to be interpolated.
#       [2] A time indicator in seconds since epoch time
#
# Out : [1] String that has all applicable variables interpolated.
#
#-----------------------------------------------------------------------------#

sub interpolateVariables($$)  {
    my ($str,$relTime)  = @_;
    $str    = interpolateTime($str,$relTime);
    return($str);
}

#-----------------------------------------------------------------------------#
# Function     : interpolateTime($$)
# Dependencies : POSIX
# Function     : This is an interface to the POSIX strftime function.
#
# In  : [1] String that might contain time indicating variables that need to be
#           interpolated
#       [2] A time indicator in seconds since the epoch time
#
# Out : [1] String that has all time indicating variables interpolated.
#
#-----------------------------------------------------------------------------#

sub interpolateTime($$) {
    my ($str,$relTime)  = @_;
    $str    = strftime($str,localtime($relTime));
    return($str);
}

#-----------------------------------------------------------------------------#
# Function     : initializeParamValues($$$)
# Dependencies : 
# Function     : This sub-routine processes the command-line parameters,
#                applies default values where applicable, initiates syntax
#                checks and initiates any defined transformations.
#
# In  : [1] Ref. to the parameter configuration.
#       [2] Ref. to the parameter syntax definition.
#       [3] Ref. to the parameter transformation definition.
#
# Out :
#
#-----------------------------------------------------------------------------#

sub initializeParamValues($$$) {
    my ($prmCfg_ref,$stx_ref,$trf_ref)  = @_;
    applyParamDefValues($prmCfg_ref);
    processParamValues($prmCfg_ref,$stx_ref,$trf_ref);
}

#-----------------------------------------------------------------------------#
# Function     : processParamValues($$$)
# Dependencies : 
# Function     : This sub-routine performs syntax checks and transformations.
#
# In  : [1] Ref. to the parameter configuration.
#       [2] Ref. to the parameter syntax definition.
#       [3] Ref. to the parameter transformation definition.
#
# Out :
#
#-----------------------------------------------------------------------------#

sub processParamValues($$$) {
    my ($prmCfg_ref,$stx_ref,$trf_ref)   = @_;
    my $forceHelp               = sub {${$prmCfg_ref->{'help'}->{'var'}}=1};
    my $msgErr;
    my $cs                      = 0;

    for my $cfgEntryKey (keys %$prmCfg_ref) {
        my $cfgEntryRef = $prmCfg_ref->{$cfgEntryKey};
        my @values      = ();

        if ( ref($cfgEntryRef->{'var'}) eq 'ARRAY' ) {
            @values = ( @{$cfgEntryRef->{'var'}} );
        } elsif (
            ref($cfgEntryRef->{'var'}) eq '' or
            ref($cfgEntryRef->{'var'}) eq 'SCALAR'
        ) {
            @values = ( ${$cfgEntryRef->{'var'}} );
        } else {
            next;
        }

        if (exists $stx_ref->{$cfgEntryKey}) {
            if (
                exists $stx_ref->{$cfgEntryKey}->{'cs'} and
                defined $stx_ref->{$cfgEntryKey}->{'cs'} and
                $stx_ref->{$cfgEntryKey}->{'cs'} ne '0'
            ) {
                $cs = 1;
            }

            for my $var (@values) {
                if (
                    (
                        $cs != 0  and $var !~
                            /$stx_ref->{$cfgEntryKey}->{'rgx'}/
                    ) or (
                        $cs == 0 and $var !~
                            /$stx_ref->{$cfgEntryKey}->{'rgx'}/i
                    )
                ) {
                    &$forceHelp;
                    $msgErr = "WARNING: The supplied value ".
                        "'".$var."' for the ".
                        "'".$cfgEntryKey."'-parameter is syntactically ".
                        "incorrect.\n";
                    warn $msgErr;
                    last;
                }
            }
        }

        if (
            exists $trf_ref->{$cfgEntryKey} and
            ref($trf_ref->{$cfgEntryKey}) eq 'CODE'
        ) {
            if ( ref($cfgEntryRef->{'var'}) eq 'ARRAY' ) {
                @{$cfgEntryRef->{'var'}}    =
                    map &{$trf_ref->{$cfgEntryKey}}($_),
                        @{$cfgEntryRef->{'var'}};
            } elsif (
                ref($cfgEntryRef->{'var'}) eq '' or
                ref($cfgEntryRef->{'var'}) eq 'SCALAR'
            ) {
                ${$cfgEntryRef->{'var'}}    =
                    &{$trf_ref->{$cfgEntryKey}}(${$cfgEntryRef->{'var'}});
            } else {
                next;
            }
        }
    }
}

#-----------------------------------------------------------------------------#
# Function     : applyParamDefValues($)
# Dependencies : 
# Function     : This applies default values for command-line variables where
#                applicable.
#
# In  : [1] Ref. to the parameter configuration.
#
# Out :
#           
#
#-----------------------------------------------------------------------------#

sub applyParamDefValues($) {
    my ($prmCfg_ref)      = @_;
    for my $cfgEntryKey (keys %$prmCfg_ref) {
        my $cfgEntryRef = $prmCfg_ref->{$cfgEntryKey};
        if (
            exists $cfgEntryRef->{'var'} and (
                (
                    ref($cfgEntryRef->{'var'}) eq 'SCALAR' and
                    not(defined ${$cfgEntryRef->{'var'}})
                ) or (
                    ref($cfgEntryRef->{'var'}) eq 'ARRAY' and
                    $#{$cfgEntryRef->{'var'}} == -1
                )
            ) and exists $cfgEntryRef->{'def'}
        ) {
            if ( ref($cfgEntryRef->{'var'}) eq 'ARRAY' ) {
                @{$cfgEntryRef->{'var'}}  = @{$cfgEntryRef->{'def'}};
            } else {
                ${$cfgEntryRef->{'var'}}  = ${$cfgEntryRef->{'def'}};
            }
        }
    }
}

#-----------------------------------------------------------------------------#
# Function     : matchesOne($$$)
# Dependencies : 
# Function     : This sub-routine returns 'TRUE' if one of the supplied
#                regexes matches the supplied string.
#
# In  : [1] String
#       [2] Enables case sensitive comparisons
#       [3] Ref. to an array of regexes
#
# Out : [1] Boolean result (0|1)
#
#-----------------------------------------------------------------------------#

sub matchesOne($$$) {
    my ($str,$cs,$listRef)              = @_;
    for my $entry (@$listRef) {
        if ( $cs ne '0' and $str =~ /$entry/ ) {
            return(1);
        } elsif ( $cs eq '0' and $str =~ /$entry/i ) {
            return(1);
        }
    }
    return(0);
}

#-----------------------------------------------------------------------------#
# Function     : matches($$$$)
# Dependencies : 
# Function     : This sub-routine implements the scripts inclusion-/eclusion-
#                logic.
#
# In  : [1] String
#       [2] Enables case sensitive comparisons
#       [3] Ref. to an array of "includes"
#       [4] Ref. to an array of "excludes"
#
# Out : [1] Boolean result (0|1)
#
#-----------------------------------------------------------------------------#

sub matches($$$$) {
    my ($str,$cs,$inclRef,$exclRef)     = @_;
    if ($#{$inclRef} < 0) {
        if ($#{$exclRef} < 0) {
            return(1);
        } else {
            return(not(matchesOne($str,$cs,$exclRef)));
        }
    } else {
        if ($#{$exclRef} < 0) {
            return(matchesOne($str,$cs,$inclRef));
        } else {
            return(
                matchesOne($str,$cs,$inclRef) and
                not(matchesOne($str,$cs,$exclRef))
            );
        }
    }
    return(0);
}

#-----------------------------------------------------------------------------#
# Function     : readFile($$$$$$$$$$$)
# Dependencies : threads, Object, Cache
# Function     : The sub-routine implements a log-file reader, which typically
#                runs in a thread as created in the main-section of this
#                script.
#
# In  :  [1] File handle.
#        [2] String containing the name of the file hanlde if applicable.
#        [3] Boolean value indicating whether file flushing should be taken
#            into account.
#        [4] Boolean value indicating whether the sub-routine should continue
#            reading from the file when EOF has been reached.
#        [5] A scalar indicating the number of lines after the matching line
#            that should be returned ("after context").
#        [6] A scalar indicating the number of lines before the matching line
#            that should be returned ("before context").
#        [7] A ref. to an array of "inclusion" regexes.
#        [8] A ref. to an array of "exclusion" regexes.
#        [9] Enables case sensitive comparisons.
#       [10] A scalar indicating the number of microseconds to wait after
#            EOF has been reached before trying to read again when in 'follow'-
#            mode.
#       [11] A ref. to the Thread queue, used to communicate with the scripts
#            main thread.
#
# Out : Matching lines, including their before- and after-context are
#       returned using the Thread queuing-mechanism ("enqueue").
#
#-----------------------------------------------------------------------------#

sub readFile($$$$$$$$$$$) {
    my (
        $fh,    $name,          $flush,     $follow,
        $ac,    $bc,            $inclRef,   $exclRef,
        $cs,    $sleep_usecs,   $queue
    )               = @_;
    my $tid         = threads->self()->tid();
    my $cache_adm   = Cache->new($bc,$ac);    
    my @caches      = ();
    my $do_follow   = 1;
    my $fh_pos      = 0;
    my $errMsg      = "";

    while( $do_follow > 0 ) {

        if (
            $flush != 0 and
            -s $fh < $fh_pos
        ) {
            seek $fh, 0, 0;
            $fh_pos = tell $fh;
            $errMsg = "WARNING: File '".$name."' was flushed. Resetting ".
                "file pointer!\n";
            warn $errMsg;
        }

        while(my $line_in=<$fh>) {
            chomp($line_in);
            if (matches($line_in,$cs,$inclRef,$exclRef) ) {
                push @caches, Cache->new(
                    $bc, $ac, $cache_adm->getCache()
                );
            }
            if ( $name ne "" ) {
                $line_in    = join ":",$name,$line_in;
            }
            $cache_adm->add($line_in);
            for my $cache (@caches) {
                $cache->add($line_in);
                if ($cache->isFull()) {
                    $queue->enqueue( {
                            'tid'   => $tid,
                            'data'  => $cache->getCache()
                    } );
                }
            }
            @caches = grep {not($_->isFull())} @caches;
        }

        for my $cache (@caches) {
            $queue->enqueue( {
                    'tid'   => $tid,
                    'data'  => $cache->getCache()
            } );
        }

        if ($flush != 0) {
            $fh_pos = tell $fh;
        }

        if ($follow != 0) {
            usleep($sleep_usecs);
        } else {
            $do_follow  = 0;
            $queue->enqueue( { 'tid'   => $tid } );
        }
    }
}

__END__

=head1 NAME

watch-log.pl - documentation

=head1 SYNOPSIS

watch-log.pl [options] <file> [<file> <...>]

 Options:

   -f (--file-rel-date) delta   Indicates a time relative to now, used for
                                interpolating in the supplied filenames
   -l (--log-rel-date) delta    Indicates a time relative to now, used for
                                interpolating in the supplied include(s) and
                                excludes(s)
   -i (--include) string        One or more regular expressions, that have a
                                logical OR relationship. Every encountered
                                line must match with at least one of the in-
                                cludes. If none provided, "^.*$" is assumed
   -e (--exclude) string        One or more regular expressions, that have a
                                logical OR relationship. Every string that
                                passed through the inclusion filter can be
                                excluded by one or more excludes
   -A (--after-context) num     Displays num lines after the match
   -B (--before-context) num    Displays num lines before the match
   -C (--context) num           Displays num lines before and after the match
   -w (--with-filename)         Indicates whether to output the filename on
                                each line
   --[no]follow                 After reading all data the script will wait
                                for more data indefinitely
   --[no]flush                  Will monitor the input files for flushing.
                                Works in conjunction with the "--follow" flag
   --[no]cs                     Indicates whether to regard the supplied
                                "--include" and/or "--exclude" values as being
                                case sensitive
   -h (--help)                  Displays the help documentation
   -m (--man)                   Displays full documentation

=head1 DESCRIPTION

=over 8

=item B<-f> or B<--file-rel-date> "I<DELTA>"

Indicates a time relative to now, used for interpolating in the supplied
filenames.

Valid values for I<DELTA>:
    B<S> = seconds, B<M> = minutes, B<H> = hours, B<d> = days, B<w> = weeks.

Example(s): "B<-1d>" (one day ago), "B<2H>" (two hours from now)

=item B<-l> or B<--log-rel-date> "I<DELTA>"

Indicates a time relative to now, used for interpolating in the supplied
B<--include> and/or B<--exclude> values.

Valid values for I<DELTA>:
    B<S> = seconds, B<M> = minutes, B<H> = hours, B<d> = days, B<w> = weeks.

Example(s): "B<-1d>" (one day ago), "B<2H>" (two hours from now)

=item B<-i> or B<--include> "I<STRING>"

One or more regular expressions, that have a logical OR relationship. Every
encountered line must match with at least one of the includes. If none
provided, "B<^.*$>" is assumed.

Example(s): "B<^%Y-$m-$d %H:>" (which will be interpolated with the date
indicated by the B<-l> parameter or the default value "B<0d>"), "B<ERROR: >".

=item B<-e> or B<--exclude> "I<STRING>"

One or more regular expressions, that have a logical OR relationship. Every
string that passed through the inclusion filter can be excluded by one or more
excludes.

Example(s): "B<^%Y-$m-$d %H:>" (which will be interpolated with the date
indicated by the B<-l> parameter or the default value "B<0d>"), "B<ERROR: >".

=item B<-A> or B<--after-context> "I<NUM>"

Displays I<NUM> lines after the match.

=item B<-B> or B<--before-context> "I<NUM>"

Displays I<NUM> lines before the match.

=item B<-C> or B<--context> "I<NUM>"

Displays I<NUM> lines before and after the match.

=item B<-w> or B<--with-filename>

Indicates whether to output the filename on each line.

=item B<--[no]follow>

After reading all data the script will continue waiting for input from the
supplied files (default is B<false>).

=item B<--[no]flush>

Works in conjunction with the B<--follow> flag. Will monitor the input files
for flushing (default is B<true>).

=item B<--[no]cs>

Indicates whether to regard the supplied B<--include> and/or B<--exclude>
values as being case sensitive (default is B<false>).

=item B<-h> or B<--help>

Displays the help documentation.

=item B<-m> or B<--man>

Displays the full documentation.

=back
