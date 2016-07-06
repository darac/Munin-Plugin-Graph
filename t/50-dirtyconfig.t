#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;
use Test::Output;    # To capture STDOUT
use Test::Exception;
eval 'use Test::More::Color';

use Munin::Plugin::Graph;

my $graph = new Munin::Plugin::Graph::Graph (graph_title => "Testing DirtyConfig", name => "dirtyconfig");

my $DS = new Munin::Plugin::Graph::DS (fieldname => "widgets", draw => "LINE1");

$graph->add_DS($DS);

$DS->value(12);

my $clean_config = <<EOF;
graph_title Testing DirtyConfig
widgets.draw LINE1
EOF

my $clean_fetch = <<EOF;
widgets.value 12
EOF

my $dirty_config = <<EOF;
graph_title Testing DirtyConfig
widgets.draw LINE1
widgets.value 12
EOF

my $dirty_fetch = $clean_fetch;

## WANT DIRTYCONFIG 0
## HAVE DIRTYCONFIG 0

stdout_is( sub { $graph->emit_config }, $clean_config, "Clean Config with neither WANT nor HAVE");
stdout_is( sub { $graph->emit_fetch }, $clean_fetch, "Clean Fetch  with neither WANT nor HAVE");


## WANT DIRTYCONFIG 0
## HAVE DIRTYCONFIG 1

$ENV{MUNIN_CAP_DIRTYCONFIG} = 1;

stdout_is( sub { $graph->emit_config }, $clean_config, "Clean Config with HAVE but not WANT");
stdout_is( sub { $graph->emit_fetch }, $clean_fetch, "Clean Fetch  with HAVE but not WANT");


## WANT DIRTYCONFIG 1
## HAVE DIRTYCONFIG 0

Munin::Plugin::Graph->import(qw(DIRTYCONFIG));
$ENV{MUNIN_CAP_DIRTYCONFIG} = 0;

stdout_is( sub { $graph->emit_config }, $clean_config, "Clean Config with WANT but not HAVE");
stdout_is( sub { $graph->emit_fetch }, $clean_fetch, "Clean Fetch  with WANT but not HAVE");


## WANT DIRTYCONFIG 1
## HAVE DIRTYCONFIG 1

$ENV{MUNIN_CAP_DIRTYCONFIG} = 1;

stdout_is( sub { $graph->emit_config }, $dirty_config, "Dirty Config with both WANT and HAVE");
stdout_is( sub { $graph->emit_fetch }, $dirty_fetch, "Clean Fetch  with both WANT and HAVE");



done_testing();

#End
