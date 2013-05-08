#!/usr/bin/perl -w

use strict;
use Data::Dumper;

sub cachePush($$;$);
sub cacheUnshift($$;$);

my $max_stuff	= 0;

my $thing	= 'A';
my @stuff	= 'A'..'L';
my @other_stuff	= 'M'..'Z';

print "\n".("#"x75)."\n\n";

print "                     \@other_stuff = ( ".(join ", ",map {'"'.$_.'"'} @other_stuff)." )\n";
print "PRE  : [push]        \@stuff       = ( ".(join ", ",map {'"'.$_.'"'} @stuff)." )\n";

print "\npush \@stuff,\@other_stuff\n\n";

push @stuff,@other_stuff;

print "POST : [push]         \@stuff       = ( ".(join ", ",map {'"'.$_.'"'} @stuff)." )\n";

print "\n".("#"x75)."\n\n";

$max_stuff	= 0;
@stuff		= 'A'..'L';

print "                      \$max_stuff   = '".$max_stuff."'\n";
print "                      \@other_stuff = ( ".(join ", ",map {'"'.$_.'"'} @other_stuff)." )\n";
print "PRE  : [cachePush]    \@stuff       = ( ".(join ", ",map {'"'.$_.'"'} @stuff)." )\n";

print "\ncachePush(\\\@stuff,\\\@other_stuff,\$max_stuff)\n\n";

cachePush(\@stuff,\@other_stuff,$max_stuff);

print "POST : [cachePush]    \@stuff       = ( ".(join ", ",map {'"'.$_.'"'} @stuff)." )\n";

print "\n".("#"x75)."\n\n";

$max_stuff	= 5;
@stuff		= 'A'..'L';

print "                      \$max_stuff   = '".$max_stuff."'\n";
print "                      \@other_stuff = ( ".(join ", ",map {'"'.$_.'"'} @other_stuff)." )\n";
print "PRE  : [cachePush]    \@stuff       = ( ".(join ", ",map {'"'.$_.'"'} @stuff)." )\n";

print "\ncachePush(\\\@stuff,\\\@other_stuff,\$max_stuff)\n\n";

cachePush(\@stuff,\@other_stuff,$max_stuff);

print "POST : [cachePush]    \@stuff       = ( ".(join ", ",map {'"'.$_.'"'} @stuff)." )\n";

print "\n".("#"x75)."\n\n";

$max_stuff	= -1;
@stuff		= 'A'..'L';

print "                      \$max_stuff   = '".$max_stuff."'\n";
print "                      \@other_stuff = ( ".(join ", ",map {'"'.$_.'"'} @other_stuff)." )\n";
print "PRE  : [cachePush]    \@stuff       = ( ".(join ", ",map {'"'.$_.'"'} @stuff)." )\n";

print "\ncachePush(\\\@stuff,\\\@other_stuff,\$max_stuff)\n\n";

cachePush(\@stuff,\@other_stuff,$max_stuff);

print "POST : [cachePush]    \@stuff       = ( ".(join ", ",map {'"'.$_.'"'} @stuff)." )\n";

print "\n".("#"x75)."\n\n";

$max_stuff	= 5;
@stuff		= 'A'..'L';

print "                      \$max_stuff   = '".$max_stuff."'\n";
print "                      \@other_stuff = ( ".(join ", ",map {'"'.$_.'"'} @other_stuff)." )\n";
print "PRE  : [cacheUnshift] \@stuff       = ( ".(join ", ",map {'"'.$_.'"'} @stuff)." )\n";

print "\ncacheUnshift(\\\@stuff,\\\@other_stuff,\$max_stuff)\n\n";

cacheUnshift(\@stuff,\@other_stuff,$max_stuff);

print "POST : [cacheUnshift] \@stuff       = ( ".(join ", ",map {'"'.$_.'"'} @stuff)." )\n";

print "\n".("#"x75)."\n\n";

$max_stuff	= 2;
@stuff		= 'A'..'L';

print "                      \$max_stuff   = '".$max_stuff."'\n";
print "                      \$thing       = '".$thing."'\n";
print "PRE  : [cacheUnshift] \@stuff       = ( ".(join ", ",map {'"'.$_.'"'} @stuff)." )\n";

print "\ncacheUnshift(\\\@stuff,\\\$thing,\$max_stuff)\n\n";

cacheUnshift(\@stuff,$thing,$max_stuff);

print "POST : [cacheUnshift] \@stuff       = ( ".(join ", ",map {'"'.$_.'"'} @stuff)." )\n";

exit(0);
1;

sub cachePush($$;$) {
	my @l		= map {ref($_) eq 'ARRAY'?@$_:$_} @_[0,1];
	my ($n,$m)	= ((defined $_[2] && $_[2]=~/^\d+$/?(@l-$_[2]):0),$#l);
	@{$_[0]}	= @l[$n..$m];
}

sub cacheUnshift($$;$) {
	my @l		= map {ref($_) eq 'ARRAY'?@$_:$_} @_[1,0];
	my ($n,$m)	= (0,(defined $_[2] && $_[2]=~/^\d+$/?($_[2]-1):0));
	@{$_[0]}	= @l[$n..$m];
}
