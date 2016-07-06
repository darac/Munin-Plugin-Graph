#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;
use Test::Output;    # To capture STDOUT
use Test::Exception;
eval 'use Test::More::Color';

no warnings qw(uninitialized);

my $num_tests = 0;

require_ok('Munin::Plugin::Graph');
$num_tests += 1;

# First, test the graph_title
my @valid_titles = (
    "a",
    "Another",
    "SOMETHING",
    "with spaces",
    "a really long title which is probably just a bit too long to really be of any use to most people",
    "12345",
    "¿Cuál es el título?",
    "အဲဒါကဘာကိုဆိုသနည်း",
    1234
);
my @invalid_titles = ( undef, \[1.2], "" );

# Next, test the arguments
my @test_matrix = ( {
        field            => 'graph',
        valid_arguments  => [ "yes", "no", undef ],
        mapped_arguments => [
            [ "enabled",  "yes" ],
            [ "disabled", "no" ],
            [ "1",        "yes" ],
            [ "0",        "no" ],
            [ "on",       "yes" ],
            [ "off",      "no" ],
            [ "",         "no" ]
        ],
        invalid_arguments => [ 1234, [ 1, 2 ], "yes, please", "not today" ]
    }, {
        field           => 'graph_args',
        valid_arguments => [ '--rigid', '--limit 0', '-l --limit 0', undef ],
        mapped_arguments =>
          [ [ [ '--array', 'joined' ], "--array joined" ], [ [ '--rigid', 0 ], "--rigid 0" ] ],
    }, {
        field           => 'graph_category',
        valid_arguments => [ "network", "l", "a_longer_category", undef ],
    }, {
        field           => 'graph_height',
        valid_arguments => [ 0, 1, 100, 1000, 1000000, undef ],
        invalid_arguments => [ -1, -100, "large" ],
    }, {
        field => 'graph_info',
        valid_arguments =>
          [ "", undef, "some text", "<b>some html</b>", "<foobar>some < invalid HTML" ],
    }, {
        field           => 'graph_order',
        valid_arguments => [
            "",
            "foo bar baz",
            [ "foo", "bar", "baz" ],
            new Munin::Plugin::Graph::DS( fieldname => 'foo' ), [
                new Munin::Plugin::Graph::DS( fieldname => 'foo' ),
                new Munin::Plugin::Graph::DS( fieldname => 'bar' )
            ],
            [ new Munin::Plugin::Graph::DS( fieldname => 'foo' ), "bar" ]
        ],
    }, {
        field             => 'graph_period',
        valid_arguments   => [ 'second', 'minute', 'hour', undef ],
        invalid_arguments => [ '1s', 'week', '5 minutes', 23 ],
    }, {
        field           => 'graph_printf',
        valid_arguments => [ "", "blah", "%6.0f", undef, 12 ],
    }, {
        field            => 'graph_scale',
        valid_arguments  => [ "yes", "no", undef ],
        mapped_arguments => [
            [ "enabled",  "yes" ],
            [ "disabled", "no" ],
            [ "1",        "yes" ],
            [ "0",        "no" ],
            [ "on",       "yes" ],
            [ "off",      "no" ],
            [ "",         "no" ]
        ],
        invalid_arguments => [ 1234, [ 1, 2 ], "yes, please", "not today" ],
    }, {
        field           => 'graph_total',
        valid_arguments => [ 'blah', '', 'undef', undef ],
    }, {
        field           => 'graph_vlabel',
        valid_arguments => [ 'bytes', 'bytes per ${graph_period}', '', undef ],
    }, {
        field             => 'graph_width',
        valid_arguments   => [ 1, 100, '1', '100', undef ],
        invalid_arguments => [-1],
    }, {
        field           => 'host_name',
        valid_arguments => [ 'venus', 'lothlorien', 'pearly-gates.vatican', undef ],
        invalid_arguments => [ [] ],
    } );

my $graph;
for my $t (@valid_titles) {
    $num_tests += 2;
    $graph = new_ok(
        'Munin::Plugin::Graph::Graph' => [ graph_title => $t ],
        "Valid New Graph, title $t"
    );
    is( $graph->graph_title, $t, "graph_title $t" );
}
for my $t (@invalid_titles) {
    $num_tests += 1;
    dies_ok( sub { $graph = new Munin::Plugin::Graph::Graph( graph_title => $t ) },
        "Invalid New Graph, title $t" );
}

$graph = new Munin::Plugin::Graph::Graph( graph_title => "testing" );

for my $test (@test_matrix) {
    $num_tests += 1;
    my $field = $test->{field};
    subtest "Field $field", sub {
        my ( $value, $expected );
        if ( exists( $test->{valid_arguments} ) ) {
            for $value ( @{ $test->{valid_arguments} } ) {
                is( $graph->$field($value), $value, "Setting $field to $value" )
                  || diag explain $graph->$field;
            }
        }
        if ( exists( $test->{mapped_arguments} ) ) {
            for my $pair ( @{ $test->{mapped_arguments} } ) {
                ( $value, $expected ) = @{$pair};
                is( $graph->$field($value), $expected, "$field: $value -> $expected" );
            }
        }
        if ( exists( $test->{invalid_arguments} ) ) {
            for $value ( @{ $test->{invalid_arguments} } ) {
                dies_ok( sub { $graph->$field($value) }, "Setting $field to $value" )
                  || diag explain $graph->$field;
                isnt( $graph->$field, $value, "$field new value" );
            }
        }
      }
}


done_testing($num_tests);

#End
