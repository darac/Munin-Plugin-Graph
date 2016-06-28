#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;
use Test::Output;    # To capture STDOUT

require_ok('Munin::Plugin::Graph');

my $multigraph = new_ok ('Munin::Plugin::Graph::MultiGraph' => [ graph_title => 'multi' ] );

my $subgraph = new_ok ('Munin::Plugin::Graph::Graph' => [ graph_title => 'subgraph' ]);

can_ok($multigraph, 'add_graph');
ok($multigraph->add_graph($subgraph), "Adding existing graph to Multigraph");

done_testing();

#End
