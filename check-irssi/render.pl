#!/usr/bin/perl
use strict;
use warnings;

use List::Util qw(min max);

my @grid;
my $COLUMNS = $ENV{COLUMNS} || 80;
my $LINES   = $ENV{LINES}   || 24;

my $CL = 0;
my $CC = 0;

my $input = do { local $/; <> };

while ($input =~ /(?<ctl>\e (
			(?<keypad> [=>] )
		      | \( (?<charset> ( % . | . ))
		      | (?<priv> \[\? (?<pcontent> [0-9:;]*?) (?<pcsi>) [hl] )
		      | \[ (?<ccontent> [0-9:;]*?) (?<csi> [mtHKb] )))
	      | (?<sp> [\r\n] )
	      | (?<oth> . )/sxg) {
    if (length $+{csi}) {
	my $csi = $+{csi};
	if ($csi eq 'b') {
	    my $ccontent = $+{ccontent};
	    if (length $ccontent) {
		$grid[ $CL ][ $CC ]
		    = $grid[ $CL ][ $CC++ - 1 ]
		    for 2 .. $ccontent;
		next;
	    }
	}
	if ($csi eq 'K') {
	    my $ccontent = $+{ccontent};
	    if (length $ccontent) {
		if ($ccontent == 0) {
		    splice @{$grid[ $CL ]}, $CC;
		    next;
		}
		if ($ccontent == 1) {
		    $grid[ $CL ][$_] = undef
			for 0 .. min($#{ $grid[ $CL ] }, $CC);
		    next;
		}
		if ($ccontent == 2) {
		    @{ $grid[ $CL ] } = ();
		    next;
		}
	    }
	    else {
		splice @{$grid[ $CL ]}, $CC;
		next;
	    }
	}
	if ($csi eq 'H') {
	    my $ccontent = $+{ccontent};
	    if (length $ccontent) {
		my ($row, $col) = split ';', $ccontent;
		$CL = $row - 1;
		$CC = $col - 1;
		next;
	    }
	    else {
		$CL = 0;
		$CC = 0;
		next;
	    }
	}
    }
    if (length $+{sp}) {
	my $sp = $+{sp};
	if ($sp eq "\r") {
	    $CL = 0;
	    next;
	}
	if ($sp eq "\n") {
	    $CC++;
	    next;
	}
    }
    if (length $+{oth}) {
	my $oth = $+{oth};
	if ($oth eq "\e") {
	    die "unrecognised ctl seq: \\e" . substr $input, -1+ pos $input, 10;
	}
	if ($oth =~ /[^[:print:]]/) {
	    die "unrecognised ctl seq: $oth";
	}
	$grid[ $CL ][ $CC++ ] = $oth;
	next;
    }
}

print '╒' . ( '═' x $COLUMNS ) . '╕' . "\n";
for my $line (@grid) {
    print '│';
    my $i = 0;
    for my $col (@$line) {
	print $col // ' ';
	$i++;
    }
    print ' ' x max($COLUMNS - $i, 0) . '│';
    print "\n";
}
print '╘' . ( '═' x $COLUMNS ) . '╛' . "\n";
