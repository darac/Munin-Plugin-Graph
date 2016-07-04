package Munin::Plugin::Graph::BaseGraph;

use v5.10;
use Moo;
use strictures 2;
use namespace::clean;
use Munin::Plugin::Graph::types -all;
use Type::Params qw(compile);

use lib $ENV{'MUNIN_LIBDIR'} // '.';
use Munin::Plugin;

has 'graph' => (
    is        => 'rw',
    isa       => WordyBool,
    coerce    => WordyBoolFromStr,
    predicate => 1,
);

has 'graph_args' => (
    is => 'rw',

    #isa       => Maybe[Str],
    isa       => StringList,
    coerce    => StrFromList,
    predicate => 1,
);

has 'graph_category' => (
    is        => 'rw',
    isa       => Maybe [LowerStr],
    coerce    => LowerStr->coercion,
    predicate => 1,
);

has [ 'graph_height', 'graph_width' ] => (
    is        => 'rw',
    isa       => Maybe [NonNegative],
    predicate => 1,
);

has 'graph_info' => (
    is        => 'rw',
    isa       => Maybe [Str],
    predicate => 1,
);

has 'graph_order' => (
    is        => 'rw',
    isa       => StrOrDS | ArrayRef [StrOrDS] | Undef,
    predicate => 1,
);

has 'graph_period' => (
    is        => 'rw',
    isa       => Maybe [ Enum [qw( second minute hour )] ],
    predicate => 1,
);

has 'graph_printf' => (
    is        => 'rw',
    isa       => Maybe [Str],
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
    isa       => Str->where( sub { length($_) > 0 } ),
    required  => 1,
    predicate => 1,
);

has 'graph_total' => (
    is        => 'rw',
    isa       => Maybe [Str],
    predicate => 1,
);

has 'graph_vlabel' => (
    is        => 'rw',
    isa       => Maybe [Str],
    predicate => 1,
);

has 'host_name' => (
    is        => 'rw',
    isa       => Maybe [Str],
    predicate => 1,
);

has 'update' => (
    is        => 'rw',
    isa       => Maybe [WordyBool],
    coerce    => WordyBoolFromStr,
    predicate => 1,
);

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

sub emit_config {
    state $paramscheck = compile(Object);
    my ($self) = $paramscheck->(@_);
    if ( !$self->has_graph_title ) {
        die "Can't configure a graph without a title";
    }
    else {
        for my $attr (
            qw( graph graph_args graph_category graph_height graph_info graph_order
            graph_period graph_printf graph_scale graph_title graph_total graph_vlabel
            graph_width host_name update update_rate)
          ) {
            print "$attr " . Str->( $self->$attr ) . "\n" if defined $self->$attr;
        }
    }
    if ( $self->has_data_sources ) {
        for my $ds ( @{ $self->data_sources } ) {
            DS->validate($ds);
            $ds->emit_config;
        }
    }
}

sub emit_fetch {
    state $paramscheck = compile(Object);
    my ($self) = $paramscheck->(@_);

    # Nothing to do during the fetch stage
    print "\n";
    if ( $self->has_data_sources ) {
        for my $ds ( @{ $self->data_sources } ) {
            DS->validate($ds);
            $ds->emit_fetch;
        }
    }
}

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

sub delete_DS {
    state $paramscheck = compile( Object, DS );
    my ( $self, $needle ) = $paramscheck->(@_);

    $self->_set_data_sources( grep { $_ != $needle } $self->data_sources );
}

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

sub DEMOLISH {
    my ( $self, $in_global_destruction ) = @_;
    if ( $Munin::Plugin::Graph::globals{AUTOSAVE} ) {
        #
    }
}

1;
