#!/usr/bin/perl
use strict;
use warnings;

use List::Util qw(min max);

my @grid;
my $COLUMNS = $ENV{COLUMNS} || 80;
my $LINES   = $ENV{LINES}   || 24;

my $CL = 0;
my $CC = 0;
my @sr = (-1, -1);

my $input = do { local $/; <> };

while ($input =~ /(?<ctl>\e (
			(?<keypad> [=>] )
		      | \( (?<charset> ( % . | . ))
		      | (?<priv> \[\? (?<pcontent> [0-9:;]*?) (?<pcsi>) [hl] )
		      | \[ (?<ccontent> [0-9:;]*?) (?<csi> [mtHKbrS] )))
	      | (?<sp> [\r\n] )
	      | (?<oth> . )/sxg) {
    if (length $+{csi}) {
	my $csi = $+{csi};
	if ($csi eq 'S') {
	    my $ccontent = $+{ccontent};
	    $ccontent = 1 unless length $ccontent;

	    my $from = max($sr[ 0 ], 0);
	    my $removed = min( $ccontent, ($sr[ 1 ] == -1 ? scalar @grid : $sr[ 1 ]) - ($sr[ 0 ] == -1 ? 0 : $sr[ 0 ]) );

	    if ($sr[ 1 ] != -1 && @grid > $sr[ 1 ]) {
		splice @grid, $sr[ 1 ], 0, ([]) x $removed;
	    }
	    splice @grid, $from, $removed;
	    next;
	}
	if ($csi eq 'b') {
	    my $ccontent = $+{ccontent};
	    if (length $ccontent) {
		$grid[ $CL ][ $CC ]
		    = $grid[ $CL ][ $CC++ - 1 ]
		    for 2 .. $ccontent;
		next;
	    }
	}
	if ($csi eq 'r') {
	    my $ccontent = $+{ccontent};
	    if (length $ccontent) {
		my ($top, $bot) = split ';', $ccontent;
		@sr = ($top - 1, $bot - 1);
		next;
	    }
	    else {
		@sr = (-1, -1);
		next;
	    }
	}
	if ($csi eq 'K') {
	    my $ccontent = $+{ccontent};
	    $ccontent = 0 unless length $ccontent;
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
	if ($csi eq 't' || $csi eq 'm') {
	    # ignore
	    next;
	}
	die "unhandled csi: $csi";
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
	die "unhandled sp: $sp";
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

sub _dump {
    my @grid = @_;
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
}

_dump(@grid);
