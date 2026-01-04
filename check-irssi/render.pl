#!/bin/sh
#! -*-perl-*-
eval 'exec perl -C -x -wS $0 ${1+"$@"}'
    if 0;
use strict;
use warnings;
use utf8;

use List::Util qw(min max);

# line drawing characters
my ($a, $b, $c, $d, $e, $f, $g, $h, $m, $n, $o, $p, $q, $r, $s, $t, $u, $v) =
    ("\x{2000}", "\x{20db}", "\x{20e8}", "\x{2395}", "\x{2502}", "\x{2550}", "\x{2551}", "\x{2552}", "\x{2554}", "\x{2555}", "\x{2557}", "\x{2558}", "\x{255a}", "\x{255b}", "\x{255d}", "\x{255e}", "\x{2561}", "\x{a671}");


my @grid;
my $COLUMNS = $ENV{COLUMNS} || 80;
my $LINES   = $ENV{LINES}   || 24;
my $DEBUG = $ENV{DEBUG} || 0;

my $CL = 0;
my $CC = 0;
my @sr = (-1, -1);
my $debug_text = '';

my $input = do { local $/; <> };

_debug() if $DEBUG;
while ($input =~ /(?<ctl>\e (
                        (?<keypad> [=>] )
                      | \( (?<charset> ( % . | . ))
                      | (?<priv> \[\? (?<pcontent> [0-9:;]*?) (?<pcsi>) [hl] )
                      | \[ (?<ccontent> [0-9:;]*?) (?<csi> [mtHKbrS] )))
              | (?<sp> [\r\n] )
              | (?<oth> . )/sxg) {
    if (length $+{csi}) {
        my $csi = $+{csi};
        my $ccontent = $+{ccontent};
        if ($csi eq 'S') {
            $ccontent = 1 unless length $ccontent;

            my $from = max($sr[ 0 ], 0);
            my $removed = min( $ccontent, ($sr[ 1 ] == -1 ? scalar @grid : $sr[ 1 ]) - ($sr[ 0 ] == -1 ? 0 : $sr[ 0 ]) );

            if ($sr[ 1 ] != -1 && @grid > $sr[ 1 ]) {
                splice @grid, $sr[ 1 ], 0, map {[]} 1..$removed;
            }
            splice @grid, $from, $removed;
            _debug($csi, $ccontent, @grid) if $DEBUG;
            next;
        }
        if ($csi eq 'b') {
            if (length $ccontent) {
                $grid[ $CL ][ $CC ]
                    = $grid[ $CL ][ $CC++ - 1 ]
                    for 2 .. $ccontent;
                _debug($csi, $ccontent, @grid) if $DEBUG;
                next;
            }
        }
        if ($csi eq 'r') {
            if (length $ccontent) {
                my ($top, $bot) = split ';', $ccontent;
                @sr = ($top - 1, $bot - 1);
                _debug($csi, $ccontent, @grid) if $DEBUG;
                next;
            }
            else {
                @sr = (-1, -1);
                _debug($csi, $ccontent, @grid) if $DEBUG;
                next;
            }
        }
        if ($csi eq 'K') {
            $ccontent = 0 unless length $ccontent;
            if ($ccontent == 0) {
                splice @{$grid[ $CL ]}, $CC;
                _debug($csi, $ccontent, @grid) if $DEBUG;
                next;
            }
            if ($ccontent == 1) {
                $grid[ $CL ][$_] = undef
                    for 0 .. min($#{ $grid[ $CL ] }, $CC);
                _debug($csi, $ccontent, @grid) if $DEBUG;
                next;
            }
            if ($ccontent == 2) {
                @{ $grid[ $CL ] } = ();
                _debug($csi, $ccontent, @grid) if $DEBUG;
                next;
            }
        }
        if ($csi eq 'H') {
            if (length $ccontent) {
                my ($row, $col) = split ';', $ccontent;
                $CL = $row - 1;
                $CC = $col - 1;
                _debug($csi, $ccontent, @grid) if $DEBUG;
                next;
            }
            else {
                $CL = 0;
                $CC = 0;
                _debug($csi, $ccontent, @grid) if $DEBUG;
                next;
            }
        }
        if ($csi eq 't' || $csi eq 'm') {
            # ignore
            _debug($csi, $ccontent, @grid) if $DEBUG;
            next;
        }
        die "unhandled csi: $csi";
    }
    if (length $+{sp}) {
        my $sp = $+{sp};
        if ($sp eq "\r") {
            $CL = 0;
            _debug("\\r", "", @grid) if $DEBUG;
            next;
        }
        if ($sp eq "\n") {
            $CC++;
            _debug("\\n", "", @grid) if $DEBUG;
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
        $debug_text .= $oth if $DEBUG;
        next;
    }
}
_debug('', '') if $DEBUG;

sub _dump {
    my @grid = @_;
    print "$h" . ( "$f" x $COLUMNS ) . "$n\n";
    for my $line (@grid) {
        print "$e";
        my $i = 0;
        for my $col (@$line) {
            print $col // ' ';
            $i++;
        }
        print ' ' x max($COLUMNS - $i, 0) . "$e\n";
    }
    print "$p" . ( "$f" x $COLUMNS ) . "$r\n";
}

sub _debug {
    my ($csi, $cc, @grid) = @_;
    if (!defined $csi) {
        print "$m$f$f$f SINGLE COMMAND DEBUG MODE BEGIN ". ( "$f" x ($COLUMNS - 32) ) ."$o\n";
        return;
    }
    my $str = "COMMAND: $csi ( $cc )";
    if ($csi eq '') {
        print "$q$f$f$f SINGLE COMMAND DEBUG MODE END ". ( "$f" x ($COLUMNS - 30) ) ."$s\n";
    } elsif ($csi eq 't' || $csi eq 'm') {
        print "$g$t$f$f$f $str ". ( "$f" x ($COLUMNS - 3 - length $str)  ) ."$u$g\n";
    } else {
        if (length $debug_text) {
            print "$g$h$f$f$f TEXT: ". ( "$f" x ($COLUMNS - 8)  ) ."$n$g\n";
            print "$g$e [$debug_text] ". ( ' ' x ($COLUMNS - 3 - length $debug_text) ) ." $e$g\n";
            print "$g$p" . ( "$f" x ($COLUMNS + 2) ) . "$r$g\n";
            $debug_text = '';
        }
        print "$g$h$f$f$f $str ". ( "$f" x ($COLUMNS - 3 - length $str)  ) ."$n$g\n";
        my $cell = $grid[ $CL ][ $CC ];
        local $grid[ $CL ][ $CC ] = (!length $cell || $cell eq ' ') ? "$d" : "$cell$v";
        my $ln = 0;
        print "$g$e$h" . ( "$f" x $COLUMNS ) . "$n$e$g\n";
        for my $line (@grid) {
            print "$g$e$e";
            my $i = 0;
            for my $col (@$line) {
                if ($ln eq $sr[0]) {
                    print ((!length $col || $col eq ' ') ? "$a$b" : "$col$b");
                } elsif ($ln eq $sr[1]) {
                    print ((!length $col || $col eq ' ') ? "$a$c" : "$col$c");
                } else {
                    print $col // ' ';
                }
                $i++;
            }
            print( ($ln eq $sr[0] ? "$a$b" :
                    $ln eq $sr[1] ? "$a$c" :
                    ' ') x max($COLUMNS - $i, 0) );
            print "$e$e$g\n";
            $ln++;
        }
        print "$g$e$p" . ( "$f" x $COLUMNS ) . "$r$e$g\n";
        print "$g$p" . ( "$f" x ($COLUMNS + 2) ) . "$r$g\n";
    }
}

_dump(@grid);
