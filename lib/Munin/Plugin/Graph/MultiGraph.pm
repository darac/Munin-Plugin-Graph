package Munin::Plugin::Graph::MultiGraph;

use v5.10;
use Moo;
use strictures 2;
use namespace::clean;
use Munin::Plugin::Graph::types -all;
use Type::Params qw(compile);

extends 'Munin::Plugin::Graph::BaseGraph';

=head1 NAME

Munin::Plugin::Graph::MultiGraph - A Munin Graph which can also contain other Munin Graphs

=head1 SYNOPSIS

	use Munin::Plugin::Graph;

	my $MG = new Munin::Plugin::Graph::MultiGraph(title => "Overall Network graph", name => "if_octets");

	my $SG = new Munin::Plugin::Graph::Graph(title => "Network Throughput ETH0", name => "if_eth0");

	$MG->add_graph($SG);

	$MG->emit_config;	// Both MG and SG are output

=head1 DESCRIPTION

This class is both a Munin Graph in its own right, plus a container of other Munin Graphs. Thus the mutligraph funcionality is achieved. See C>Munin::Plugin::Graph::BaseGraph> for the graph functionality. 

=cut

has 'graphs' => (
    is        => 'rwp',
    isa       => ArrayRef [ InstanceOf ['Munin::Plugin::Graph::Graph'] ],
    predicate => 1,
);

=head2 Functions

=over 4

=item C<add_graph>

Adds a C<Munin::Plugin::Graph::Graph> below this Multigraph. Can be either a C<Munin:Plugin::Graph::Graph> or a string (in which case, a new one will be instantiated with that title).

=cut

sub add_graph {
    state $paramscheck = compile( Object, ArrayRef [StrOrGraph] | StrOrGraph );
    my ( $self, @args ) = $paramscheck->(@_);

    my @items_added = ();

    for my $item (@args) {
        if ( Str->check($item) ) {

            # Argument is a string. Start by seeing if we can find an existing graph by that name
            my $newgraph = new Munin::Plugin::Graph::Graph( graph_title => $item );
            ( my $altname = lc $item ) =~ s/[^a-zA-Z0-9]/_/g;
            if ( defined( my $checkname = $self->get_graph_by_name( $newgraph->name ) ) ) {

                # There is a naming conflict,. so rename this one
                $newgraph->name($altname);
                if ( defined( my $checkname = $self->get_graph_by_name( $newgraph->name ) ) ) {

                    # There is STILL a conflict
                    die "Cannot add graph $item. Graph name must be unique";
                }
            }
            Graph->assert_valid($newgraph);
            push @{ $self->graphs }, $newgraph;
            push @items_added, $newgraph;
        }
        else {
            # Argument is a Graph, so we can add that
            # First, check if there's an existing Graph
            if ( defined( $self->get_graph_by_name( $item->name ) ) ) {
                die "Cannot add Graph " . $item->graph_title . ". Graph names must be unique";
            }
            if ( $self->has_graphs ) {
                push @{ $self->graphs }, $item;
            }
            else {
                $self->_set_graphs( [$item] );
            }
            push @items_added, $item;
        }
    }

    return @items_added;
}

=item C<delete_graph>

Removes a C<Munin::Plugin::Graph::Graph> from the heirarchy.

=cut

sub delete_graph {
    state $paramscheck = compile( Object, Graph );
    my ( $self, $needle ) = $paramscheck->(@_);

    my @newgraphs = grep { $_ != $needle } @{ $self->graphs };
    $self->_set_graphs( \@newgraphs );
}

=item C<get_graph_by_title>

Given the title of a graph, returns a reference the C<Munin::Plugin::Graph::Graph> with that title.

=cut

sub get_graph_by_title {
    state $paramscheck = compile( Object, Str );
    my ( $self, $name ) = $paramscheck->(@_);

    return unless $self->has_graphs;

    for my $graph ( @{ $self->graphs } ) {
        Graph->assert_valid($graph);
        if ( $graph->graph_title eq $name ) {
            return $graph;
        }
    }

    return undef;
}

=item C<get_graph_by_name>

Given the name of a graph, returns a reference the C<Munin::Plugin::Graph::Graph> with that name.

=cut

sub get_graph_by_name {
    state $paramscheck = compile( Object, Str );
    my ( $self, $name ) = $paramscheck->(@_);

    return unless $self->has_graphs;

    for my $graph ( @{ $self->graphs } ) {
        Graph->assert_valid($graph);
        if ( $graph->name eq $name ) {
            return $graph;
        }
    }

    return undef;
}

=item C<emit_config>

Prints, to STDOUT, the config stage of this graph, PLUS all the C<Munin::Plugin::Graph::Graph>s attached.

As per the Munin spec, this will C<die> unless run by a MULTIGRAPH-capable node (e.g. Munin 1.4.0 or higher).

=cut

sub emit_config {
    state $paramscheck = compile(Object);
    my ($self) = $paramscheck->(@_);

    die "This plugin requires a MULTIGRAPH-capable node" if not exists $ENV{MUNIN_CAP_MULTIGRAPH};

    print "multigraph " . $self->name . "\n";

    # Perform the BaseGraph emit_config
    $self->SUPER::emit_config();

    for my $g ( @{ $self->graphs } ) {
        Graph->assert_valid($g);
        print "\nmultigraph " . $self->name . "." . $g->name . "\n";
        $g->emit_config;
    }
}

=item C<emit_fetch>

Prints, to STDOUT, the fetch stage of this graph, PLUS all the C<Munin::Plugin::Graph::Graph>s attached.

As per the Munin spec, this will C<die> unless run by a MULTIGRAPH-capable node (e.g. Munin 1.4.0 or higher).

=cut

sub emit_fetch {
    state $paramscheck = compile(Object);
    my ($self) = $paramscheck->(@_);

    die "This plugin requires a MULTIGRAPH-capable node" if not exists $ENV{MUNIN_CAP_MULTIGRAPH};

    print "multigraph " . $self->name . "\n";

    # Perform the BaseGraph emit_config
    $self->SUPER::emit_fetch();

    for my $g ( @{ $self->graphs } ) {
        print "\nmultigraph " . $self->name . "." . $g->name . "\n";
        $g->emit_fetch();
    }
}

=back

=cut


1;
