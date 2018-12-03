#!/usr/bin/env perl

use strict;
use warnings;

use Inline C => "DATA",
  ENABLE     => "AUTOWRAP",
  LIBS       => "-lm";

my $pi = 4 * atan(1);

print "pi = $pi\n";

__DATA__
__C__
double tan(double x);
double asin(double x);
double acos(double x);
double atan(double x);
