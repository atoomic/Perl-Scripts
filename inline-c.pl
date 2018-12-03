#!/usr/bin/env perl

# read https://www.usenix.org/system/files/login/articles/1137-turoff.pdf

use strict;
use warnings;

use Inline C => "DATA";

print add( 3, 4 ), "\n";
print mult( 3, 4 ), "\n";

__DATA__
__C__
int add(int x, int y) { return x+y; }
int mult(int x, int y) { return x*y; }
