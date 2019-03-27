#!/usr/bin/perl
use strict;
use warnings;

use Cwd;
my $dir = getcwd;

use CPAN::Meta::YAML 'LoadFile';
my @docs = LoadFile +shift;

use List::Util 'max';

local $\ = "\n";
for (@ARGV) {
    print "echo '╒══════════ " . _cntr($_, 56) . " ══════════╕'";
    print "cd '" . _esc($dir) . "'";
    for (@{$docs[-1]{$_}}) {
	print "echo '⯈ " . _esc($_) . _parat($_, 78, 2) . "¶';$_";
    }
}

sub _parat {
    my ($text, $width, $fl) = @_;
    if ($text =~ /^(.*)\z/m) {
	$width -= length $1;
    }
    if ($text =~ /\n/) {
	$width += $fl;
    }
    ' ' x max($width - 1, 0)
}
sub _cntr {
    my ($text, $width) = @_;
    $width -= length $text;
    my $left = $width - ($width >> 1);
    my $right = $width - $left;
    (' ' x max($left, 0)) . $text . (' ' x max($right, 0))
}
sub _esc {
    $_[0] =~ s/'/'"'"'/gr;
}
