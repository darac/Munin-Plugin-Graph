#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;
use Test::Output;    # To capture STDOUT

plan tests => 38;

require_ok('Munin::Plugin::Graph');

my $graph_name = 'testing';

# Create a simple object
my $graph = new_ok( 'Munin::Plugin::Graph::Graph' => [ graph_title => $graph_name ] );

my %attributes = (
    graph          => undef,
    graph_args     => undef,
    graph_category => undef,
    graph_height   => undef,
    graph_info     => undef,
    graph_order    => undef,
    graph_period   => undef,
    graph_printf   => undef,
    graph_scale    => undef,
    graph_title    => $graph_name,    # This is the only required item
    graph_total    => undef,
    graph_vlabel   => undef,
    graph_width    => undef,
    host_name      => undef,

    #	multigraph     => undef,
    update      => undef,
    update_rate => undef,
);

# Can we query information from the object?
for my $f ( sort keys %attributes ) {
    can_ok( $graph, $f );
    is( $graph->$f, $attributes{$f}, "Default $f" );
}

# Also check the non-attribute functions
can_ok( $graph, 'emit_config' );
stdout_is( sub { $graph->emit_config }, "graph_title $graph_name\n", "Default config output" );

can_ok( $graph, 'emit_fetch' );
stdout_is( sub { $graph->emit_fetch }, "\n", "Default fetch output" );

#End
