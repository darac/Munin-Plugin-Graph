package Munin::Plugin::Graph::BaseGraph;

use Moo;
use strictures 2;
use namespace::clean;
use Munin::Plugin::Graph::types -all;

has 'graph' => (
	is        => 'rw',
	isa       => WordyBool,
	coerce    => WordyBoolFromStr,
	predicate => 1,
);

has 'graph_args' => (
	is        => 'rw',
	#isa       => Maybe[Str],
	isa       => StringList,
	coerce    => StrFromList,
	predicate => 1,
);

has 'graph_category' => (
	is        => 'rw',
	isa       => Maybe[LowerStr],
	coerce    => LowerStr->coercion,
	predicate => 1,
);

has ['graph_height', 'graph_width'] => (
	is        => 'rw',
	isa       => Maybe[NonNegative],
	predicate => 1,
);

has 'graph_info' => (
	is        => 'rw',
	isa       => Maybe[Str],
	predicate => 1,
);

has 'graph_order' => (
	is        => 'rw',
	isa       => StrOrDS | ArrayRef[StrOrDS] | Undef,
	predicate => 1,
);

has 'graph_period' => (
	is        => 'rw',
	isa       => Maybe[Enum[qw( second minute hour )]],
	predicate => 1,
);

has 'graph_printf' => (
	is        => 'rw',
	isa       => Maybe[Str],
	predicate => 1,
);

has 'graph_scale' => (
	is        => 'rw',
	isa       => WordyBool,
	coerce    => WordyBoolFromStr,
	predicate => 1,
);

has 'graph_title' => (
	is        => 'rw',
	isa       => Str->where(sub { length($_) > 0 }),
	required  => 1,
	predicate => 1,
);

has 'graph_total' => (
	is        => 'rw',
	isa       => Maybe[Str],
	predicate => 1,
);

has 'graph_vlabel' => (
	is        => 'rw',
	isa       => Maybe[Str],
	predicate => 1,
);

has 'host_name' => (
	is        => 'rw',
	isa       => Maybe[Str],
	predicate => 1,
);

has 'update' => (
	is        => 'rw',
	isa       => Maybe[WordyBool],
	coerce    => WordyBoolFromStr,
	predicate => 1,
);

has 'update_rate' => (
	is        => 'rw',
	isa       => Maybe[Positive],
	predicate => 1,
);

sub emit_config {
	my $self = shift;
	if (!$self->has_graph_title) {
		die "Can't configure a graph without a title";
	} else {
		for my $attr (qw( graph graph_args graph_category graph_height graph_info graph_order
	                      graph_period graph_printf graph_scale graph_title graph_total graph_vlabel
					      graph_width host_name update update_rate)) {
			print "$attr " . Str->($self->$attr) . "\n" if defined $self->$attr;
		}
	}
}

sub emit_fetch {
	my $self = shift;

	# Nothing to do during the fetch stage
	print "\n";
}

1;
