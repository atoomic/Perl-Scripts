# from https://gist.github.com/jberger/a0139ebe8390bb208e21a12e0e930273

use strict;
use warnings;
use feature 'say';

package CLI;

use Moo;
use Carp ();

has commands => (
  is => 'ro',
  default => 'CLI::Commands',
);

sub run {
  my ($self, $command) = (shift, shift);
  my $sub = $self->commands->can($command);
  Carp::croak "No such command: $command" unless $sub;
  return $sub->(@_);
}

package CLI::Commands;

sub greet {
  my $name = shift || 'World';
  say "Hello $name!";
}

package main;

my $cli = CLI->new;
$cli->run(@ARGV);
