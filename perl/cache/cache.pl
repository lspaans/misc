#!/usr/bin/perl

package Object;

use strict;
use warnings;
use Data::Dumper;

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

use strict;
use warnings;
use Data::Dumper;

our @ISA = qw( Object );

my $rgx_integer                 = '^\d+$';

my %meta_data_cache             = (
    'syntax'    => {
        'n_lines_pre_match'     => $rgx_integer,
        'n_lines_post_match'    => $rgx_integer
    }
);

sub new {
    my (
        $class,
        $lines_pre,     $lines_post
    )	= @_;
    my $self                        = {
        '_n_lines_pre_match'    => undef,
        '_n_lines_post_match'   => undef,
        '_line_cache'           => []
    };
    bless $self,$class;
    $self->init(
        $lines_pre,     $lines_post
    );
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
    return(@{$self->{'_line_cache'}});
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
    while(
        $#{$self->{'_line_cache'}} >
        (
            $self->{'_n_lines_pre_match'} +
            $self->{'_n_lines_post_match'}
        )
    ) {
        shift @{$self->{'_line_cache'}};
    }
}

sub matches() {
    my ($self,$match)                   = @_;
    if (
        defined $self->{'_line_cache'}[$self->{'_n_lines_pre_match'}] and
        defined $match and
        $self->{'_line_cache'}[$self->{'_n_lines_pre_match'}] =~
            /$match/
    ) {
        return(1);
    }
    return(0);
}

1;

package Main;

use 5.010;

use strict;
use warnings;

my $cache   = Cache->new(3,2);

for my $n (0..255) {
    $cache->add($n);
    if ($cache->matches('^67$')) {
        my @cached_lines    = $cache->getCache();
        print "\@cached_lines = ( @cached_lines )\n";
    }
}

1;
