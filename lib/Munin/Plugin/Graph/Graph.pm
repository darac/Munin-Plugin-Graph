package Munin::Plugin::Graph::Graph;

use Moo;
use strictures 2;
use namespace::clean;
use Munin::Plugin::Graph::types -all;

extends 'Munin::Plugin::Graph::BaseGraph';

=head1 NAME

Munin::Plugin::Graph::Graph - A single Munin graph.

=head1 SYNOPSIS

See L<Munin::Plugin::Graph::BaseGraph>

=cut

has 'parent' => (
    is        => 'rwp',
    isa       => InstanceOf ['Munin::Plugin::Graph::MultiGraph'],
    predicate => 1,
);

1;
