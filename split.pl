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
        for my $c ( split // => $str ) {
            $out .= $c;
        }

        return $out;
    },
    for => sub {
        my $str = $S;
        my $out = '';
        for my $c ( $str =~ /(.)/g ) {
            $out .= $c;
        }

        return $out;
    },
    while => sub {
        my $str = $S;
        my $out = '';
        while ( $str =~ /(.)/g ) {
            $out .= $1;
        }

        return $out;
    },
    while_G => sub {
        my $str = $S;
        my $out = '';
        while ( $str =~ /\G(.)/gs ) {
            $out .= $1;
        }

        return $out;
    },
    substr => sub {
        my $str = $S;
        my $out = '';
        my $len = length($str) - 1;
        for my $i ( 0 .. $len ) {
            $out .= substr $str, $i, 1;
        }

        return $out;
    },
    substr_while => sub {
        my $str = $S;
        my $out = '';
        my $i   = 0;
        no warnings;
        while ( defined( my $char = substr( $str, $i++, 1 ) ) ) {
            $out .= $char;
        }
        return $out;
    },
    chop => sub {
        my $str = $S;
        my $out = '';
        my $len = length($str) - 1;
        for my $i ( 0 .. $len ) {
            $out .= chop $str;
        }

        return $out;
    },
    reverse_chop => sub {
        my $str = reverse $S;
        my $len = length($str) - 1;
        my $out = '';
        for my $i ( 0 .. $len ) {
            $out .= chop $str;
        }

        return $out;

    },
    unpack => sub {
        my $str = $S;

        my @chars = unpack '(A)*', $S;
        my $out = '';
        foreach my $c (@chars) {
            $out .= $c;
        }
        return $out;
    },
};

note "sanity check";

foreach my $method ( sort keys %$map ) {
    next if $method eq 'chop';    # chop need an extra reverse

    $S = "abcd";
    is $map->{$method}->(), "abcd", "sanity check: '$method'" or die;
}

for my $size ( 4, 16, 64, 256, 1024 ) {
    note "Iterating over a string of length $size.\n";

    $S = join '', map { chr( int rand(255) ) } 1 .. $size;
    die "Incorrect str length $size" unless length $S == $size;

    cmpthese - 5 => $map;

    note "";
}

__END__

# Iterating over a string of length 4.
                  Rate  for while while_G unpack split substr_while substr reverse_chop chop
for           746555/s   --   -4%     -5%   -31%  -46%         -53%   -69%         -71% -73%
while         780082/s   4%    --     -1%   -28%  -43%         -50%   -67%         -69% -72%
while_G       787424/s   5%    1%      --   -27%  -43%         -50%   -67%         -69% -71%
unpack       1084027/s  45%   39%     38%     --  -21%         -31%   -55%         -58% -61%
split        1379830/s  85%   77%     75%    27%    --         -12%   -42%         -46% -50%
substr_while 1575490/s 111%  102%    100%    45%   14%           --   -34%         -38% -43%
substr       2383342/s 219%  206%    203%   120%   73%          51%     --          -7% -14%
reverse_chop 2550870/s 242%  227%    224%   135%   85%          62%     7%           --  -7%
chop         2756259/s 269%  253%    250%   154%  100%          75%    16%           8%   --
#
# Iterating over a string of length 16.
                  Rate  for while_G while unpack split substr_while substr reverse_chop chop
for           215161/s   --    -16%  -17%   -35%  -47%         -63%   -76%         -79% -81%
while_G       255101/s  19%      --   -1%   -23%  -37%         -56%   -72%         -76% -77%
while         257707/s  20%      1%    --   -22%  -37%         -55%   -71%         -75% -77%
unpack        332253/s  54%     30%   29%     --  -18%         -42%   -63%         -68% -70%
split         407331/s  89%     60%   58%    23%    --         -29%   -55%         -61% -63%
substr_while  576972/s 168%    126%  124%    74%   42%           --   -36%         -45% -48%
substr        901228/s 319%    253%  250%   171%  121%          56%     --         -13% -19%
reverse_chop 1041523/s 384%    308%  304%   213%  156%          81%    16%           --  -6%
chop         1109105/s 415%    335%  330%   234%  172%          92%    23%           6%   --
#
# Iterating over a string of length 64.
                 Rate  for while_G while unpack split substr_while substr reverse_chop chop
for           52398/s   --    -22%  -24%   -40%  -49%         -68%   -80%         -83% -84%
while_G       67364/s  29%      --   -2%   -22%  -34%         -59%   -75%         -78% -79%
while         68513/s  31%      2%    --   -21%  -33%         -59%   -74%         -78% -78%
unpack        86884/s  66%     29%   27%     --  -15%         -48%   -67%         -72% -73%
split        102398/s  95%     52%   49%    18%    --         -38%   -61%         -67% -68%
substr_while 165766/s 216%    146%  142%    91%   62%           --   -37%         -47% -48%
substr       264664/s 405%    293%  286%   205%  158%          60%     --         -15% -17%
reverse_chop 311515/s 495%    362%  355%   259%  204%          88%    18%           --  -2%
chop         318521/s 508%    373%  365%   267%  211%          92%    20%           2%   --
#
# Iterating over a string of length 256.
                Rate  for while_G while unpack split substr_while substr reverse_chop chop
for          13151/s   --    -23%  -24%   -39%  -48%         -70%   -81%         -84% -85%
while_G      17036/s  30%      --   -2%   -22%  -33%         -61%   -76%         -80% -80%
while        17309/s  32%      2%    --   -20%  -32%         -60%   -75%         -79% -80%
unpack       21720/s  65%     27%   25%     --  -14%         -50%   -69%         -74% -75%
split        25357/s  93%     49%   46%    17%    --         -42%   -64%         -70% -70%
substr_while 43410/s 230%    155%  151%   100%   71%           --   -38%         -48% -49%
substr       69873/s 431%    310%  304%   222%  176%          61%     --         -16% -18%
reverse_chop 83517/s 535%    390%  382%   285%  229%          92%    20%           --  -2%
chop         85580/s 551%    402%  394%   294%  238%          97%    22%           2%   --
#
# Iterating over a string of length 1024.
                Rate  for while_G while unpack split substr_while substr reverse_chop chop
for           3471/s   --    -19%  -21%   -39%  -47%         -68%   -80%         -84% -84%
while_G       4273/s  23%      --   -3%   -24%  -35%         -61%   -76%         -80% -81%
while         4408/s  27%      3%    --   -22%  -33%         -60%   -75%         -79% -80%
unpack        5655/s  63%     32%   28%     --  -14%         -48%   -68%         -73% -74%
split         6599/s  90%     54%   50%    17%    --         -40%   -63%         -69% -70%
substr_while 10915/s 214%    155%  148%    93%   65%           --   -38%         -49% -50%
substr       17636/s 408%    313%  300%   212%  167%          62%     --         -17% -20%
reverse_chop 21231/s 512%    397%  382%   275%  222%          95%    20%           --  -3%
chop         21955/s 533%    414%  398%   288%  233%         101%    24%           3%   --
#
