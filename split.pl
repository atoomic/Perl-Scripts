#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Benchmark qw /timethese cmpthese/;

note "Perl $]";

our $char;

for my $size ( 4, 16, 64, 256, 1024 ) {
    note "Iterating over a string of length $size.\n";

    our $S = join '', map { chr( int rand(255) ) } 1 .. $size;
    die "Incorrect str length $size" unless length $S == $size;

    cmpthese - 5 => {
        split => sub {
            my $str = $S;
            for my $c ( split // => $str ) { $char = $c }
        },
        for => sub {
            my $str = $S;
            for my $c ( $str =~ /(.)/g ) { $char = $c }
        },
        while => sub {
            my $str = $S;
            while ( $str =~ /(.)/g ) { $char = $1 }
        },
        substr => sub {
            my $str = $S;
            my $len = length($str) - 1;
            for my $i ( 0 .. $len ) { $char = substr $str, $i, 1 }
        },
    };
}

__END__

# Perl 5.026002
# Iterating over a string of length 4.
            Rate    for  while  split substr
for     760839/s     --    -8%   -48%   -71%
while   830451/s     9%     --   -44%   -68%
split  1470358/s    93%    77%     --   -43%
substr 2602040/s   242%   213%    77%     --
# Iterating over a string of length 16.
           Rate    for  while  split substr
for    213412/s     --   -21%   -48%   -77%
while  269588/s    26%     --   -34%   -71%
split  410738/s    92%    52%     --   -55%
substr 914574/s   329%   239%   123%     --
# Iterating over a string of length 64.
           Rate    for  while  split substr
for     53588/s     --   -23%   -48%   -79%
while   69553/s    30%     --   -32%   -73%
split  102603/s    91%    48%     --   -60%
substr 259172/s   384%   273%   153%     --
# Iterating over a string of length 256.
          Rate    for  while  split substr
for    13471/s     --   -23%   -47%   -80%
while  17570/s    30%     --   -31%   -74%
split  25316/s    88%    44%     --   -62%
substr 67111/s   398%   282%   165%     --
# Iterating over a string of length 1024.
          Rate    for  while  split substr
for     3375/s     --   -22%   -47%   -80%
while   4322/s    28%     --   -32%   -74%
split   6335/s    88%    47%     --   -62%
substr 16557/s   391%   283%   161%     --
