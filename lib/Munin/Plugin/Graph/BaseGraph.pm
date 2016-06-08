package Munin::Plugin::Graph::BaseGraph;

use Moo;
use strictures 2;
use namespace::clean;
use Types::Standard qw( Bool Str Int Maybe InstanceOf Enum Num );
use Type::Utils qw( declare as where inline_as coerce from );

my $_lowerstr = declare
	as	      Str,
	where	  { lc($_) eq $_},
	inline_as { my $varname = $_[1]; "lc($varname) eq $varname" };
coerce $_lowerstr, from Str, q{lc $_};

my $_str_or_ds = declare
	as 			Str | InstanceOf["Munin::Plugin::Graph::DS"];

my $_wordybool = declare
	as			Str;
coerce $_wordybool, from Str, q{return 0 if /^(0|false|off|disabled|no|)$/; return 1 if /^(1|true|on|enabled|yes)/; return undef};
coerce $_wordybool, from Num, q{return 0 if $_ == 0; return 1};
coerce $_wordybool, from Bool, q{return $_};

has 'graph' => (
	is        => 'rw',
	isa       => Maybe[$_wordybool],
	predicate => 1,
);

has 'graph_args' => (
	is        => 'rw',
	isa       => Maybe[Str],
	predicate => 1,
);

has 'graph_category' => (
	is        => 'rw',
	isa       => Maybe[$_lowerstr],
	coerce    => $_lowerstr->coercion,
	predicate => 1,
);

has 'graph_height' => (
	is        => 'rw',
	isa       => Maybe[Int],
	predicate => 1,
);

has 'graph_info' => (
	is        => 'rw',
	isa       => Maybe[Str],
	predicate => 1,
);

has 'graph_order' => (
	is        => 'rw',
	isa       => Maybe[$_str_or_ds],
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
	isa       => Str,
	predicate => 1,
);

has 'graph_title' => (
	is        => 'rw',
	isa       => Str,
	predicate => 1,
);

has 'graph_total' => (
	is        => 'rw',
	isa       => Str,
	predicate => 1,
);

has 'graph_vlabel' => (
	is        => 'rw',
	isa       => Str,
	predicate => 1,
);

has 'graph_width' => (
	is        => 'rw',
	isa       => Str,
	predicate => 1,
);

has 'host_name' => (
	is        => 'rw',
	isa       => Str,
	predicate => 1,
);

has 'update' => (
	is        => 'rw',
	isa       => $_wordybool,
	predicate => 1,
);

has 'update_rate' => (
	is        => 'rw',
	isa       => Int,
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
			print "$attr " . $self->$attr . "\n" if defined $self->$attr;
		}
	}
}

sub emit_fetch {
	my $self = shift;

	# Nothing to do during the fetch stage
	print "\n";
}

1;
