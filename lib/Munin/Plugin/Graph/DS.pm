package Munin::Plugin::Graph::DS;

use Moo;
use strictures 2;
use namespace::clean;
use Munin::Plugin::Graph::types -all;

has 'fieldname' => (
	is        => 'ro',
	isa       => ValidFieldName,
	coerce    => FieldNameFromStr,
	predicate => 1,
	required  => 1,
);
	

has 'cdef' => (
	is        => 'rw',
	isa       => Maybe[Str],
	predicate => 1,
);

has 'colour' => (
	is        => 'rw',
	isa       => HexStr | Undef,
	coerce    => HexStrFromStr,
	predicate => 1,
);

has [qw(critical warning)] => (
	is        => 'rw',
	isa       => WarnCritType | Undef,
	predicate => 1,
);

has 'draw' => (
	is        => 'rw',
	isa       => Maybe[DrawEnum],
	predicate => 1,
);

has [qw(info extinfo)] => (
	is        => 'rw',
	isa       => Maybe[Str],
	predicate => 1,
);

has 'graph' => (
	is        => 'rw',
	isa       => WordyBool,
	coerce    => WordyBoolFromStr,
	predicate => 1,
);

has 'label' => (
	is        => 'rw',
	isa       => Maybe[LowerStr],
	coercion  => LowerStr->coercion,
	predicate => 1,
);

has 'line' => (
	is        => 'rw',
	isa       => Maybe[LineType],
	coerce    => 1,
	predicate => 1,
);

has [qw(min max)] => (
	is        => 'rw',
	isa       => Maybe[Num],
	predicate => 1,
);

has 'negative' => (
	is        => 'rw',
	isa       => Maybe[StrOrDS],
	predicate => 1,
);

has [qw(stack sum)] => (
	is        => 'rw',
	isa       => Maybe[ArrayRef[StrOrDS] | StrOrDS],
	predicate => 1,
);

has 'type' => (
	is        => 'rw',
	isa       => Maybe[Enum[qw(GAUGE COUNTER DERIVE ABSOLUTE)]],
	predicate => 1,
);

has 'value' => (
	is        => 'rw',
	isa       => ValueType->plus_coercions(ValueFromUndef) | ArrayRef[SpoolType],
	coerce    => 1,
	predicate => 1,
	default   => 'U',
);

sub emit_config {
	my $self = shift;

	for my $attr (sort qw( cdef colour critical warning draw info extinfo
		                   graph label line min max negative stack sum type )) {
		print $self->fieldname . ".$attr " . $self->$attr . "\n" if defined $self->$attr;
	}
}

sub emit_fetch {
	my $self = shift;

	if (ArrayRef->check($self->value)) {
		for my $datum (@{$self->value}) {
			print $self->fieldname . ".value $datum\n";
		}
	} else {
		print $self->fieldname . ".value " . $self->value . "\n";
	}
}


1;
