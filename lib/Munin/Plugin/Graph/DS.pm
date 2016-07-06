package Munin::Plugin::Graph::DS;

use Moo;
use strictures 2;
use namespace::clean;
use Munin::Plugin::Graph::types -all;

=head1 NAME

Munin::Plugin::Graph::DS - A Munin Datasource

=head1 SYNOPSIS

	use Munin::Plugin::Graph;
	my $DS = Munin::Plugin::Graph::DS->new(fieldname => 'in_octets');
	$DS->draw('LINE2');
	$DS->type('DERIVE');
	$DS->value(23);
	...
	$DS->emit_config;
	$DS->emit_fetch;

=head1 DESCRIPTION

This class represents a Munin Data Source. All attributes are implemented using Getter/Setter methods, or can be passed to the call to C<new>. Additionally there are C<emit_config> and C<emit_fetch> functions to simplify the data to be sent to Munin.

=head2 Attributes

=over 4

=item C<fieldname>

(Required) This is the name of the datasource and must be unique for a given graph. See also: L<http://munin-monitoring.org/wiki/notes_on_datasource_names>.

=cut

has 'fieldname' => (
    is        => 'ro',
    isa       => ValidFieldName,
    coerce    => FieldNameFromStr,
    predicate => 1,
    required  => 1,
);

=item C<cdef>

(Optional) Used to modify the value before graphing. See also: L<http://oss.oetiker.ch/rrdtool/tut/cdeftutorial.en.html>

=cut

has 'cdef' => (
    is        => 'rw',
    isa       => Maybe [Str],
    predicate => 1,
);

=item C<colour>

(Optional) Hexadecimal colour code for drawing the curve.

=cut

has 'colour' => (
    is        => 'rw',
    isa       => HexStr | Undef,
    coerce    => HexStrFromStr,
    predicate => 1,
);

=item C<critical>, C<warning>

(Optional) Used by munin-limits to warn of error state. See also: L<https://munin.readthedocs.io/en/latest/tutorial/alert.html#tutorial-alert>

=cut

has [qw(critical warning)] => (
    is        => 'rw',
    isa       => WarnCritType | Undef,
    predicate => 1,
);

=item C<draw>

(Optional) Determines how the data points are drawn on the graph.

=cut

has 'draw' => (
    is        => 'rw',
    isa       => Maybe [DrawEnum],
    predicate => 1,
);

=item C<info>, C<extinfo>

(Optional) C<info> explains the data source. C<extinfo> is displayed in alerts and in extended HTML pages.

=cut

has [qw(info extinfo)] => (
    is        => 'rw',
    isa       => Maybe [Str],
    predicate => 1,
);

=item C<graph>

(Optional) Enables or disables drawing of this data source.

=cut

has 'graph' => (
    is        => 'rw',
    isa       => WordyBool,
    coerce    => WordyBoolFromStr,
    predicate => 1,
);

=item C<label>

(Optional) The label used in the legend.

=cut

has 'label' => (
    is        => 'rw',
    isa       => Maybe [LowerStr],
    coercion  => LowerStr->coercion,
    predicate => 1,
);

=item C<line>

(Optional) Add a horizontal line to the graph.

=cut

has 'line' => (
    is        => 'rw',
    isa       => Maybe [LineType],
    coerce    => 1,
    predicate => 1,
);

=item C<min>, C<max>

(Optional) Values above max or below min will be discarded.

=cut

has [qw(min max)] => (
    is        => 'rw',
    isa       => Maybe [Num],
    predicate => 1,
);

=item C<negative>

(Optional) Name of a field to be drawn as the "mirror" of this one. Can be either a string or a reference to a C<Munin::Plugin::Graph::DS>.

=cut

has 'negative' => (
    is        => 'rw',
    isa       => Maybe [StrOrDS],
    predicate => 1,
);

=item C<stack>

(Optional) List of fields to stack. Can be a mixture of strings or C<Munin::Plugin::Graph::DS>s. See also: L<http://munin-monitoring.org/wiki/faq#Q:HowdoIusefieldname.stack>.

=item C<sum>

(Optional) List of fields to summarise. Can be a mixture of strings or C<Munin::Plugin::Graph::DS>s. See also: L<http://munin-monitoring.org/wiki/faq#Q:HowdoIusefieldname.sum>.

=cut

has [qw(stack sum)] => (
    is        => 'rw',
    isa       => Maybe [ ArrayRef [StrOrDS] | StrOrDS ],
    predicate => 1,
);

=item C<type>

(Optional) Sets the RRD Data Source Type for this field. B<Must> be written in capitals.

=cut

has 'type' => (
    is        => 'rw',
    isa       => Maybe [ Enum [qw(GAUGE COUNTER DERIVE ABSOLUTE)] ],
    predicate => 1,
);

=item C<value>

(Required) The value to be graphed. May be either a single value (integer, decimal or the string "U"), or an arrayref of strings. If using spooled data (an arrayref of strings), each item should be the time (in seconds since the epoch) when the data was sampled then the value sampled, separated by a colon. For example: "1467641358:32.5"

=cut

has 'value' => (
    is        => 'rw',
    isa       => ValueType->plus_coercions(ValueFromUndef) | ArrayRef [SpoolType],
    coerce    => 1,
    predicate => 1,
    default   => 'U',
);

=back

=head2 Functions

=over 4

=item C<emit_config>

Print, to STDOUT, the configuration of this Data Source.

=cut

sub emit_config {
    my $self = shift;

    for my $attr (
        sort qw( cdef colour critical warning draw info extinfo
        graph label line min max negative stack sum type )
      ) {
        print $self->fieldname . ".$attr " . $self->$attr . "\n" if defined $self->$attr;
    }
}

=item C<emit_fetch>

Print, to STDOUT, the value of this Data Source.

=cut

sub emit_fetch {
    my $self = shift;

    if ( ArrayRef->check( $self->value ) ) {
        for my $datum ( @{ $self->value } ) {
            print $self->fieldname . ".value $datum\n";
        }
    }
    else {
        print $self->fieldname . ".value " . $self->value . "\n";
    }
}

=back

=cut

1;
