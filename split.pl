#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Benchmark qw /timethese cmpthese/;

note "Perl $]";

our $char;
our $S;

for my $size ( 4, 16, 64, 256, 1024 ) {
    note "Iterating over a string of length $size.\n";

    $S = join '', map { chr( int rand(255) ) } 1 .. $size;
    die "Incorrect str length $size" unless length $S == $size;

    cmpthese - 5 => {
        split => sub {
            my $str = $S;
            for my $c ( split // => $str ) { $char = $c }

            return;
        },
        for => sub {
            my $str = $S;
            for my $c ( $str =~ /(.)/g ) { $char = $c }

            return;
        },
        while => sub {
            my $str = $S;
            while ( $str =~ /(.)/g ) { $char = $1 }

            return;
        },
        substr => sub {
            my $str = $S;
            my $len = length($str) - 1;
            for my $i ( 0 .. $len ) { $char = substr $str, $i, 1 }

            return;
        },
        chop => sub {
            my $str = $S;
            my $len = length($str) - 1;
            for my $i ( 0 .. $len ) { $char = chop $str }

            return;
        },
        unpack => \&using_unpack,
    };
}

sub using_unpack {
    my $str = $S;
    my @A = unpack '(A)*', $S;

    return;
}
__END__

# Perl 5.026002
# Iterating over a string of length 4.
            Rate    for  while  split unpack substr   chop
for     745114/s     --    -9%   -47%   -48%   -71%   -74%
while   817702/s    10%     --   -42%   -43%   -68%   -71%
split  1413399/s    90%    73%     --    -1%   -45%   -51%
unpack 1432269/s    92%    75%     1%     --   -44%   -50%
substr 2548620/s   242%   212%    80%    78%     --   -11%
chop   2868839/s   285%   251%   103%   100%    13%     --
# Iterating over a string of length 16.
            Rate    for  while  split unpack substr   chop
for     212789/s     --   -19%   -47%   -49%   -77%   -81%
while   261649/s    23%     --   -34%   -38%   -71%   -76%
split   398898/s    87%    52%     --    -5%   -56%   -64%
unpack  420763/s    98%    61%     5%     --   -54%   -62%
substr  911667/s   328%   248%   129%   117%     --   -18%
chop   1111687/s   422%   325%   179%   164%    22%     --
# Iterating over a string of length 64.
           Rate    for  while  split unpack substr   chop
for     53605/s     --   -23%   -47%   -50%   -79%   -83%
while   69421/s    30%     --   -32%   -36%   -73%   -78%
split  101820/s    90%    47%     --    -6%   -61%   -68%
unpack 107990/s   101%    56%     6%     --   -58%   -66%
substr 257964/s   381%   272%   153%   139%     --   -18%
chop   315248/s   488%   354%   210%   192%    22%     --
# Iterating over a string of length 256.
          Rate    for  while  split unpack substr   chop
for    13295/s     --   -24%   -47%   -51%   -80%   -83%
while  17471/s    31%     --   -30%   -35%   -74%   -78%
split  25119/s    89%    44%     --    -7%   -63%   -68%
unpack 27052/s   103%    55%     8%     --   -60%   -66%
substr 67265/s   406%   285%   168%   149%     --   -15%
chop   79480/s   498%   355%   216%   194%    18%     --
# Iterating over a string of length 1024.
          Rate    for  while  split unpack substr   chop
for     3438/s     --   -21%   -47%   -52%   -80%   -83%
while   4342/s    26%     --   -33%   -39%   -74%   -79%
split   6487/s    89%    49%     --    -9%   -62%   -68%
unpack  7150/s   108%    65%    10%     --   -58%   -65%
substr 16880/s   391%   289%   160%   136%     --   -17%
chop   20328/s   491%   368%   213%   184%    20%     --
