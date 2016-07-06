#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;
eval 'use Test::More::Color';

plan tests => 1;

BEGIN {
    use_ok( 'Munin::Plugin::Graph' ) || print "Bail out!\n";
}

diag( "Testing Munin::Plugin::Graph $Munin::Plugin::Graph::VERSION, Perl $], $^X" );
