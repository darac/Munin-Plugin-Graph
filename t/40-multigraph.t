#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;
use Test::Output;    # To capture STDOUT
use Test::Exception;
eval 'use Test::More::Color';

plan tests => 21;

require_ok('Munin::Plugin::Graph');

my $multigraph = new_ok(
    'Munin::Plugin::Graph::MultiGraph' => [ graph_title => 'Multigraph', name => 'multi' ] );

my $subgraph
  = new_ok( 'Munin::Plugin::Graph::Graph' => [ graph_title => 'subgraph', name => "subgraph" ] );

my $DS = new_ok( 'Munin::Plugin::Graph::DS' => [ fieldname => 'widgets' ] );

$multigraph->add_DS($DS);
$subgraph->add_DS($DS);

$DS->value(123);

can_ok( $multigraph, "get_graph_by_title" );
is( $multigraph->get_graph_by_title("blahblah"), undef, "Test get_graph_by_title with no graphs" );

can_ok( $multigraph, 'add_graph' );
ok( $multigraph->add_graph($subgraph), "Adding existing graph to Multigraph" );
dies_ok( sub { $multigraph->add_graph($subgraph) }, "Can't add existing graph a second time" );
ok( $multigraph->add_graph("New"), "Adding new graph to Multigraph" );
ok( $multigraph->add_graph("New"), "Adding second graph by string to Multigraph" );
dies_ok( sub { $multigraph->add_graph("New") }, "Can't add graph third time" );

my $expected_config = <<EOF;
multigraph multi
graph_title Multigraph
widgets.label widgets

multigraph multi.subgraph
graph_title subgraph
widgets.label widgets

multigraph multi.t
graph_title New

multigraph multi.new
graph_title New
EOF

my $expected_fetch = <<EOF;
multigraph multi
widgets.value 123

multigraph multi.subgraph
widgets.value 123

multigraph multi.t

multigraph multi.new
EOF

dies_ok( sub { $multigraph->emit_config() }, "Can't emit_config without CAP_MULTIGRAPH" );
dies_ok( sub { $multigraph->emit_fetch() },  "Can't emit_fetch without CAP_MULTIGRAPH" );

$ENV{MUNIN_CAP_MULTIGRAPH} = 1;
stdout_is( sub { $multigraph->emit_config() },
    $expected_config, "Can emit_config with CAP_MULTIGRAPH" )
  || diag explain $multigraph->emit_config;
stdout_is( sub { $multigraph->emit_fetch() },
    $expected_fetch, "Can emit_fetch with CAP_MULTIGRAPH" )
  || diag explain $multigraph->emit_fetch;


# For coverage
is( $multigraph->get_graph_by_title( $subgraph->graph_title ), $subgraph, "Can retrieve by title" );
is( $multigraph->get_graph_by_title("blahblah"),               undef,     "Can retrieve by title" );
is( $multigraph->get_graph_by_name( $subgraph->name ),         $subgraph, "Can retrieve by name" );

ok( $multigraph->delete_graph($subgraph), "Can Delete graphs" );

ok(
    $multigraph->add_graph(
        new Munin::Plugin::Graph::Graph( graph_title => "foo", name => "bar" )
    ),
    "Adding a different Graph"
);


done_testing();

#End
