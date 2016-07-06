#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;
use Test::Output;    # To capture STDOUT
use YAML::XS;
eval 'use Test::More::Color';

plan tests => 4;

require_ok('Munin::Plugin::Graph');

# Set up Item to serialise
my $graph = Munin::Plugin::Graph::Graph->new( graph_title => "title" );
$graph->graph_vlabel("%percent");
$graph->graph_info("Somehthing");
my ($DS) = $graph->add_DS("foo");
$DS->draw("LINE2");
$DS->value(23);

my $ser;
ok( $ser = Dump($graph), "Graph can be dumped" );

ok( my $newgraph = Load($ser), "Graph can be loaded" );

is_deeply( $newgraph, $graph, "Deserialisation produces identical data" );

done_testing();

#End
