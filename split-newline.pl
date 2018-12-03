#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Benchmark qw /timethese cmpthese/;

=pod

Benchmark different method to iterate through a string in Perl
using split and alternate solutions.

Feel free to submit more Pure Perl solutions.

XS is going to provide a better alternative :-)

=cut

note "Perl $]";

our $char;
our $S;

my $map = {
    split => sub {
        my $str = $S;
        my $out = '';
        for my $c ( split m/\n/ => $str ) {
            $out .= $c;
        }

        return $out;
    },
    readsv => sub {
        my $str = $S;
        my $out = '';

        if ( open my $fh, '<', \$S ) {
            my @lines = <$fh>;
            chomp @lines;
            $out .= join '', @lines;
        }

        return $out;
    },

};

note "sanity check";

foreach my $method ( sort keys %$map ) {
    next if $method eq 'chop';    # chop need an extra reverse

    $S = <<'EOS';
this is a multiline.
string and a simple test.
EOS
    is $map->{$method}->(), q{this is a multiline.string and a simple test.}, "sanity check: '$method'" or die;
}

for my $size ( 4, 16, 64, 256 ) {
    my $len = length $S;

    note "Iterating over a string of length ", $len * $size , ".\n";

    
    $S = $S x $size;
    die "Incorrect str length $size" unless length $S == $size * $len;

    cmpthese - 5 => $map;

    note "";
}

__END__
