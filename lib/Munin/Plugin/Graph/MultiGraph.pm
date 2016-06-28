package Munin::Plugin::Graph::MultiGraph;

use v5.10;
use Moo;
use strictures 2;
use namespace::clean;
use Munin::Plugin::Graph::types -all;
use Type::Params qw(compile multisig);

extends 'Munin::Plugin::Graph::BaseGraph';

has 'graphs' => (
	is => 'rwp',
	isa => ArrayRef[InstanceOf['Munin::Plugin::Graph::BaseGraph']],
	predicate => 1,
);

sub add_graph {
	state $paramscheck = compile( Object, ArrayRef[StrOrGraph] | StrOrGraph);
	my ($self, @args) = $paramscheck->(@_);

	my $number_added = 0;
	for my $item (@args) {
		if (Str->check($item)) {
			# Argument is a string. Start by seeing if we can find an existing graph by that name
			if (defined(my $newgraph = $self->get_graph_by_title($item))) {
				die "Cannot add Graph $item. Graph titles must be unique";
			} else {
				push @{$self->graphs}, new Munin::Plugin::Graph::Graph(graph_title => $item);
			}
			$number_added += 1;
		} else {
			# Argument is a Graph, so we can add that
			# First, check if there's an existing Graph
			if (defined ($self->get_graph_by_title($item->graph_title))) {
				die "Cannot add Graph " . $item->graph_title . ". Graph titles must be unique";
			}
			if ($self->has_graphs) {
				push @{$self->graphs}, $item;
			} else {
				$self->_set_graphs([$item]);
			}
			$number_added += 1;
		}
	}

	return $number_added;
}

sub delete_graph {
	state $paramscheck = compile (Object, Graph);
	my ($self, $needle) = $paramscheck->(@_);

	$self->_set_graphs(grep {$_ != $needle} $self->graphs);
}

sub get_graph_by_title {
	state $paramscheck = compile( Object, Str);
	my ($self, $name) = $paramscheck->(@_);

	return unless $self->has_graphs;

	for my $graph (@{$self->graphs}) {
		InstanceOf['Munin::Plugin::Graph::Graph']->assert_valid($graph);
		if ($graph->graph_title eq $name) {
			return $graph;
		}
	}

	return undef;
}


1;
