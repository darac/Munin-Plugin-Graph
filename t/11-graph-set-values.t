#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;
use Test::Output;	# To capture STDOUT
use Test::Exception;

plan tests => 52;

require_ok('Munin::Plugin::Graph');

my $graph_name = 'testing';

# Create a simple object
my $graph = new_ok( 'Munin::Plugin::Graph::Graph' => [ graph_title => $graph_name ] );

my %fields = (
		# field            old value      new value
		graph          => [undef,        'no'],
		graph_args     => [undef,        "--limit 0"],
		graph_category => [undef,        'testing'],
		graph_height   => [undef,        '10'],
		graph_info     => [undef,        'Some graph info'],
		graph_order    => [undef,        'orderfield'],
		graph_period   => [undef,        'hour'],
		graph_printf   => [undef,        '%5.1f'],
		graph_scale    => [undef,        "no"],
		graph_title    => [$graph_name,  'new testing'],
		graph_total    => [undef,        'totalfield'],
		graph_vlabel   => [undef,        'vlabel'],
		graph_width    => [undef,        '100'],
		host_name      => [undef,        'foo.example.com'],
#		multigraph     => [undef,        'multigraph'],
		update         => [undef,        'no'],
		update_rate    => [undef,        '15'],
);

my $config_output = "";
my $fetch_output = "\n";

for my $field (sort keys %fields) {
	my ($old_value, $new_value) = @{$fields{$field}};
	is ($graph->$field,             $old_value, "$field initial value");
	ok ($graph->$field($new_value),             "Setting new value for $field");
	is ($graph->$field,             $new_value, "$field new value");
	$config_output .= "$field $new_value\n";
}

stdout_is ( sub {$graph->emit_config},  $config_output, "config output");
stdout_is ( sub {$graph->emit_fetch},   $fetch_output,  "fetch output");

#ENd
