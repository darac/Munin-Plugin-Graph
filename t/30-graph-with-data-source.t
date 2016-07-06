#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;
use Test::Output;    # To capture STDOUT
use Test::Exception;
eval 'use Test::More::Color';

require_ok('Munin::Plugin::Graph');

my $graph = new_ok( "Munin::Plugin::Graph::Graph" => [ graph_title => "testing" ] );

my $ds = new_ok(
    "Munin::Plugin::Graph::DS" => [ fieldname => "data", "type" => "GAUGE", "label" => "data" ] );

can_ok( $graph, "add_DS" );

is( $graph->add_DS($ds),     1, "Adding existing DS to Graph" );
is( $graph->add_DS("newDS"), 1, "Adding new DS to Graph" );
throws_ok(
    sub { $graph->add_DS("newDS") },
    qr/Fieldnames must be unique/,
    "Can't add duplicate DS"
);

can_ok( $graph, "get_DS_by_name" );

is( my $retr = $graph->get_DS_by_name("data"), $ds, "DS retrieval" );
isa_ok( $retr, "Munin::Plugin::Graph::DS" );
is( $retr->fieldname, "data", "Retrieved DS is correct");
is( $retr->label, "data", "Retrieved DS is correct");
is( $retr->type, "GAUGE", "Retrieved DS is correct");

ok ($graph->get_DS_by_name("newDS")->label("blah"), "Can set label on retrieved DS");

can_ok( $graph, "delete_DS" );
$graph->add_DS ("DeleteMe");
my $deleteme = $graph->get_DS_by_name("DeleteMe");
ok ($graph->delete_DS($deleteme), "Can delete DS");

my $expected_out = <<EOF;
graph_title testing
data.label data
data.type GAUGE
newDS.label blah
EOF

stdout_is( sub {$graph->emit_config}, $expected_out, "Graph Output includes DS");

done_testing();

#End
