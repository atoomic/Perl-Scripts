#!/usr/bin/env perl

use strict;
use warnings;

use Test2::Bundle::Extended;
use Test2::Tools::Explain;
use Test2::Plugin::NoWarnings;

use Benchmark;
use Colon::Config;

my $data = <<'EOS';
a:b:c
KK:key
X:Y
AAA::BBB
Z:
some:key:value:other
EOS

my $datax = <<'END';
aa:KKK:VVVV
ab:KKK:VVVV
ac:KKK:VVVV
ad:KKK:VVVV
ae:KKK:VVVV
af:KKK:VVVV
ag:KKK:VVVV
ah:KKK:VVVV
ai:KKK:VVVV
aj:KKK:VVVV
ak:KKK:VVVV
al:KKK:VVVV
am:KKK:VVVV
an:KKK:VVVV
ao:KKK:VVVV
ap:KKK:VVVV
aq:KKK:VVVV
ar:KKK:VVVV
as:KKK:VVVV
at:KKK:VVVV
au:KKK:VVVV
av:KKK:VVVV
aw:KKK:VVVV
ax:KKK:VVVV
ay:KKK:VVVV
az:KKK:VVVV
ba:KKK:VVVV
bb:KKK:VVVV
bc:KKK:VVVV
bd:KKK:VVVV
be:KKK:VVVV
bf:KKK:VVVV
bg:KKK:VVVV
bh:KKK:VVVV
bi:KKK:VVVV
bj:KKK:VVVV
bk:KKK:VVVV
bl:KKK:VVVV
bm:KKK:VVVV
bn:KKK:VVVV
bo:KKK:VVVV
bp:KKK:VVVV
bq:KKK:VVVV
br:KKK:VVVV
bs:KKK:VVVV
bt:KKK:VVVV
bu:KKK:VVVV
bv:KKK:VVVV
bw:KKK:VVVV
bx:KKK:VVVV
by:KKK:VVVV
bz:KKK:VVVV
ca:KKK:VVVV
cb:KKK:VVVV
cc:KKK:VVVV
cd:KKK:VVVV
ce:KKK:VVVV
cf:KKK:VVVV
cg:KKK:VVVV
ch:KKK:VVVV
ci:KKK:VVVV
cj:KKK:VVVV
ck:KKK:VVVV
cl:KKK:VVVV
cm:KKK:VVVV
cn:KKK:VVVV
co:KKK:VVVV
cp:KKK:VVVV
cq:KKK:VVVV
cr:KKK:VVVV
cs:KKK:VVVV
ct:KKK:VVVV
cu:KKK:VVVV
cv:KKK:VVVV
cw:KKK:VVVV
cx:KKK:VVVV
cy:KKK:VVVV
cz:KKK:VVVV
da:KKK:VVVV
db:KKK:VVVV
dc:KKK:VVVV
dd:KKK:VVVV
de:KKK:VVVV
df:KKK:VVVV
dg:KKK:VVVV
dh:KKK:VVVV
di:KKK:VVVV
dj:KKK:VVVV
dk:KKK:VVVV
dl:KKK:VVVV
dm:KKK:VVVV
dn:KKK:VVVV
do:KKK:VVVV
dp:KKK:VVVV
dq:KKK:VVVV
dr:KKK:VVVV
ds:KKK:VVVV
dt:KKK:VVVV
du:KKK:VVVV
dv:KKK:VVVV
dw:KKK:VVVV
dx:KKK:VVVV
dy:KKK:VVVV
dz:KKK:VVVV
ea:KKK:VVVV
eb:KKK:VVVV
ec:KKK:VVVV
ed:KKK:VVVV
ee:KKK:VVVV
ef:KKK:VVVV
eg:KKK:VVVV
eh:KKK:VVVV
ei:KKK:VVVV
ej:KKK:VVVV
ek:KKK:VVVV
el:KKK:VVVV
em:KKK:VVVV
en:KKK:VVVV
eo:KKK:VVVV
ep:KKK:VVVV
eq:KKK:VVVV
er:KKK:VVVV
es:KKK:VVVV
et:KKK:VVVV
eu:KKK:VVVV
ev:KKK:VVVV
ew:KKK:VVVV
ex:KKK:VVVV
ey:KKK:VVVV
ez:KKK:VVVV
fa:KKK:VVVV
fb:KKK:VVVV
fc:KKK:VVVV
fd:KKK:VVVV
fe:KKK:VVVV
ff:KKK:VVVV
END

our $DATA = $data;

my $map = {
    split => sub {
        return { map { ( split(m{:}), 3 )[ 0, 2 ] } split( m{\n}, $DATA ) };
    },
    colon => sub {
        my $a = Colon::Config::read($DATA);
        my $n = scalar @$a;
        for ( my $i = 1; $i < $n; $i += 2 ) {
            next unless defined $a->[$i];

            # preserve bogus behavior
            #do { $a->[ $i ] = 3; next } unless index( $a->[ $i ], ':' ) >= 0;
            # suggested fix
            #next unless index( $a->[ $i ], ':' ) >= 0;
            $a->[$i] = ( split( ':', $a->[$i], 3 ) )[1] // 3;    # // 3 to preserve bogus behavior
        }

        return {@$a};
    },
};

my $h1 = $map->{'split'}->();
my $h2 = $map->{colon}->();

#note "H1 ", explain $h1;
#note "H2 ",explain $h2;

is $h2, $h1, "split ~ colon" or die;

Benchmark::cmpthese( -5 => $map );

__END__

short string

          Rate colon split
colon  99384/s    --  -12%
split 112351/s   13%    --

large string

        Rate colon split
colon 5012/s    --   -2%
split 5109/s    2%    --
