package Munin::Plugin::Graph::BaseGraph;

use v5.10;
use Moo;
use strictures 2;
use namespace::clean;
use Munin::Plugin::Graph::types -all;
use Type::Params qw(compile);
use File::Basename;

use lib $ENV{'MUNIN_LIBDIR'} // '.';
eval 'require Munin::Plugin';

=head1 NAME

Munin::Plugin::Graph::BaseGraph - BaseClass common to all graphs

=head1 SYNOPSIS

This module should not be used directly. Instead, use Munin::Plugin::Graph::Graph (a standard graph) or Munin::Plugin::Graph::MultiGraph (a collection of M:P:G::Graphs).

=head1 DESCRIPTION

This class represents a Munin Graph. All attributes are implemented using Getter/Setter methods, or can be passed to the call to C<new>. Additionally there are C<emit_config> and C<emit_fetch> functions to simplify the data to be sent to Munin.

=head2 Attributes

=over 4

=item C<name>

(Required) The 'internal' name of the graph. Used in Multigraph heirarchies. Defaults to C<basename($0)>.

=cut

has 'name' => (
    is      => 'rw',
    isa     => Str,
    default => sub {
        $0 =~ /([^\/\\\.])\.?[^.]*/;
        return $1;
    },
);

=item C<graph>

(Optional) Enable or disable this graph.

=cut

has 'graph' => (
    is        => 'rw',
    isa       => WordyBool,
    coerce    => WordyBoolFromStr,
    predicate => 1,
);

=item C<graph_args>

(Optional) Arguments for the RRD grapher.

=cut

has 'graph_args' => (
    is        => 'rw',
    isa       => StringList,
    coerce    => StrFromList,
    predicate => 1,
);

=item C<graph_category>

(Optional) Category used to sort the graph on the index web page.

=cut

has 'graph_category' => (
    is        => 'rw',
    isa       => Maybe [LowerStr],
    coerce    => LowerStr->coercion,
    predicate => 1,
);

=item C<graph_height>

(Optional) The height of the graph.

=item C<graph_width>

(Optional) The width of the graph.

=cut

has [ 'graph_height', 'graph_width' ] => (
    is        => 'rw',
    isa       => Maybe [NonNegative],
    predicate => 1,
);

=item C<graph_info>

(Optional) Provides general information on what the graph shows.

=cut

has 'graph_info' => (
    is        => 'rw',
    isa       => Maybe [Str],
    predicate => 1,
);

=item C<graph_order>

(Optional) Ensure that the listed fields are displayed in the specified order. Arrayref of either strings or C<Munin::Plugin::Graph::DS>s.

=cut

has 'graph_order' => (
    is        => 'rw',
    isa       => StrOrDS | ArrayRef [StrOrDS] | Undef,
    predicate => 1,
);

=item C<graph_period>

(Optional) Controls the time unit RRD uses to calculate average rates-of-change. This does I<not> change the sample interval.

=cut

has 'graph_period' => (
    is        => 'rw',
    isa       => Maybe [ Enum [qw( second minute hour )] ],
    predicate => 1,
);

=item C<graph_printf>

(optional) C-style printf used when displaying values on the graph.

=cut

has 'graph_printf' => (
    is        => 'rw',
    isa       => Maybe [Str],
    predicate => 1,
);

=item C<graph_scale>

(Optional) Enable or disable automatic SI-style scaling of numbers.

=cut

has 'graph_scale' => (
    is        => 'rw',
    isa       => WordyBool,
    coerce    => WordyBoolFromStr,
    predicate => 1,
);

=item C<graph_title>

(Required) Sets the title of the graph.

=cut

has 'graph_title' => (
    is        => 'rw',
    isa       => Str->where( sub { length($_) > 0 } ),
    required  => 1,
    predicate => 1,
);

=item C<graph_total>

(Optional) Name of a field into which Munin will sum all data sources' values.

=cut

has 'graph_total' => (
    is        => 'rw',
    isa       => Maybe [Str],
    predicate => 1,
);

=item C<graph_vlabel>

(Optional) Label for the vertical axis of the graph.

=cut

has 'graph_vlabel' => (
    is        => 'rw',
    isa       => Maybe [Str],
    predicate => 1,
);

=item C<host_name>

(Optional) Override the hostname for which the plugin is run.

=cut

has 'host_name' => (
    is        => 'rw',
    isa       => Maybe [Str],
    predicate => 1,
);

=item C<update>

(Optional) Enable or disable fetching of data for the graph.

=cut

has 'update' => (
    is        => 'rw',
    isa       => Maybe [WordyBool],
    coerce    => WordyBoolFromStr,
    predicate => 1,
);

=item C<update_date>

(Optional) Set the update_date to be used by Munin when creating the RRD file.

=cut

has 'update_rate' => (
    is        => 'rw',
    isa       => Maybe [Positive],
    predicate => 1,
);

has 'data_sources' => (
    is        => 'rwp',
    isa       => ArrayRef [DS],
    predicate => 1,
);

=back

=head2 Functions

=over 4

=item C<emit_config>

Print, to STDOUT, the configuration of this graph. This will also call C<emit_config> on all attached C<Munin::Plugin::Graph::DS>s.

=cut

sub emit_config {
    state $paramscheck = compile(Object);
    my ($self) = $paramscheck->(@_);
    for my $attr (
        qw( graph graph_args graph_category graph_height graph_info graph_order
        graph_period graph_printf graph_scale graph_title graph_total graph_vlabel
        graph_width host_name update update_rate)
      ) {
        print "$attr " . Str->( $self->$attr ) . "\n" if defined $self->$attr;
    }
    if ( $self->has_data_sources ) {
        for my $ds ( @{ $self->data_sources } ) {
            DS->validate($ds);
            $ds->emit_config;

            # If the node tells use it can do DIRTYCONFIG *and*
            #  the module was loaded with DIRTYCONFIG wanted,
            #  then do emit_fetch for this DS, too.

            if (    $Munin::Plugin::Graph::globals{DIRTYCONFIG}
                and exists $ENV{MUNIN_CAP_DIRTYCONFIG}
                and $ENV{MUNIN_CAP_DIRTYCONFIG} eq 1 ) {

                $ds->emit_fetch;
            }
        }
    }
}

=item C<emit_fetch>

Calls C<emit_fetch> on all attached C<Munin::Plugin::Graph::DS>s.

=cut


sub emit_fetch {
    state $paramscheck = compile(Object);
    my ($self) = $paramscheck->(@_);

    if ( $self->has_data_sources ) {
        for my $ds ( @{ $self->data_sources } ) {
            DS->validate($ds);
            $ds->emit_fetch;
        }
    }
}

=item C<add_DS>

Add one or more C<Munin::Plugin::Graph::DS>s to this graph. Strings may also be supplied, in which case objects are created.

References to the items added are returned.

=cut

sub add_DS {
    state $paramscheck = compile( Object, ArrayRef [StrOrDS] | StrOrDS );
    my ( $self, @args ) = $paramscheck->(@_);

    my @items_added = ();

    for my $item (@args) {
        if ( DS->check($item) ) {

            # Argument is a DS, so we can add that
            # First, check if there's an existing DS by this name
            if ( defined( $self->get_DS_by_name( $item->fieldname ) ) ) {
                die "Cannot add DS " . $item->fieldname . ". Fieldnames must be unique";
            }
            DS->assert_valid($item);
            if ( $self->has_data_sources ) {
                push @{ $self->data_sources }, $item;
            }
            else {
                $self->_set_data_sources( [$item] );
            }
            push @items_added, $item;
        }
        elsif ( Str->check($item) ) {

            # Argument is a string. Start by seeing if we can find an existing DS by that name
            if ( defined( my $newDS = $self->get_DS_by_name($item) ) ) {
                die "Cannot add DS $item. Fieldnames must be unique";
            }
            else {
                my $added = new Munin::Plugin::Graph::DS( fieldname => $item );
                if ( $self->has_data_sources ) {
                    push @{ $self->data_sources }, $added;
                }
                else {
                    $self->_set_data_sources( [$added] );
                }
                push @items_added, $added;
            }
        }
    }

    return @items_added;
}

=item C<delete_DS>

Remove an attached C<Munin::Plugin::Graph::DS> from this graph.

=cut

sub delete_DS {
    state $paramscheck = compile( Object, DS );
    my ( $self, $needle ) = $paramscheck->(@_);

    $self->_set_data_sources( grep { $_ != $needle } $self->data_sources );
}

=item C<get_DS_by_name>

Find a C<Munin::Plugin::Graph::DS> by its fieldname, and return a reference thereto.

=cut

sub get_DS_by_name {
    state $paramscheck = compile( Object, Str );
    my ( $self, $name ) = $paramscheck->(@_);

    return unless $self->has_data_sources;

    for my $ds ( @{ $self->data_sources } ) {
        DS->assert_valid($ds);
        if ( $ds->fieldname eq $name ) {
            return $ds;
        }
    }
    return undef;
}

=item C<clear>

Clears the value of all C<Munin::Plugin::Graph::DS>s attached. This is useful after serialisation/deserialisation.

=cut

sub clear {
    state $paramscheck = compile(Object);
    my ($self) = $paramscheck->(@_);

    for my $ds ( @{ $self->data_sources } ) {
        $ds->value('U');
    }
    return 1;
}

=back

=cut

sub DEMOLISH {
    my ( $self, $in_global_destruction ) = @_;
    if ( $Munin::Plugin::Graph::globals{AUTOSAVE} ) {
        #
    }
}

1;
