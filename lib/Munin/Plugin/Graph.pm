package Munin::Plugin::Graph;

use v5.10;
use strictures 2;
use namespace::clean;

use Type::Params qw(compile);
use Types::Standard qw(ArrayRef HashRef InstanceOf Str slurpy Dict);

use Munin::Plugin::Graph::Graph;
use Munin::Plugin::Graph::DS;
use Munin::Plugin::Graph::MultiGraph;

require Exporter;

=head1 NAME

Munin::Plugin::Graph - The great new Munin::Plugin::Graph!

=head1 VERSION

Version 0.05

=cut

our $VERSION = '0.10';

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Munin::Plugin::Graph;

    my $foo = Munin::Plugin::Graph->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=cut

our @ISA = qw(Exporter);

our %EXPORT_TAGS = (
	'all' => [ qw (
		find_graph_by_title
		find_graph_by_name
		find_subgraph_by_title
		find_subgraph_by_name
		create_graph
		create_subgraph
		create_ds
		) ],
	'finding' => [ qw (
		find_graph_by_title
		find_graph_by_name
		find_subgraph_by_title
		find_subgraph_by_name
		) ],
	'creating' => [ qw (
		create_graph
		create_subgraph
		create_ds
		) ],
);

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );


=head1 SUBROUTINES/METHODS

=over 4

=cut

our %globals = (
    DIRTYCONFIG => 0,
    AUTOSAVE    => 0,
);

sub import {
    my ( $package, @args ) = @_;

    for my $feature ( keys %globals ) {
        if ( grep { $_ eq $feature} @args ) {
            $globals{$feature} = 1;
        }
    }
}

sub _find_by_title {
	my ($haystack, $needle) = (@_);

	sub _t {
		my ($graph, $title) = (@_);

	    if ( $graph->has_graphs ) {
	        foreach my $g ( @{ $graph->graphs } ) {
	            if ( $g->graph_title eq $title ) {
	                return $g;
	            }
	        }
	    } else {
			if ($graph->graph_title eq $title) {
				return $graph;
			}
	    }
	    return undef;
	}

	if ((InstanceOf['Munin::Plugin::Graph::BaseGraph'])->check($haystack)){
		return _t($haystack, $needle);
	} else {
		for my $g ( @{ $haystack } ) {
			my $n = _t($g, $needle);
			return $n if defined $n;
		}
	}
	return undef;
}

sub _find_by_name {
	my ($haystack, $needle) = (@_);

	sub _n {
		state $paramscheck = compile (InstanceOf['Munin::Plugin::Graph::BaseGraph'], Str);
		my ($graph, $name) = $paramscheck->(@_);

	    if ( $graph->has_graphs ) {
	        foreach my $g ( @{ $graph->graphs } ) {
	            if ( $g->name eq $name ) {
	                return $g;
	            }
	        }
	    } else {
			if ($graph->name eq $name) {
				return $graph;
			}
		}
	    return undef;
	}

	if ((InstanceOf['Munin::Plugin::Graph::BaseGraph'])->check($haystack)){
		return _n($haystack, $needle);
	} else {
		for my $g ( @{ $haystack } ) {
			my $n = _n($g, $needle);
			return $n if defined $n;
		}
	}
	return undef;
}


=item C<find_graph_by_title>

Given an arrayref of C<Munin::Plugin::Graph>s and a title, return a reference to the graph with the given title. 

=cut

sub find_graph_by_title {
	state $paramscheck = compile (ArrayRef[InstanceOf['Munin::Plugin::Graph::BaseGraph']], Str);
	my ($coll, $title) = $paramscheck->(@_);

	return _find_by_title($coll, $title);

}

=item C<find_graph_by_name>

Given an arrayref of C<Munin::Plugin::Graph>s and a name, return a reference to the graph with the given name.

=cut

sub find_graph_by_name {
	state $paramscheck = compile (ArrayRef[InstanceOf['Munin::Plugin::Graph::BaseGraph']], Str);
	my ($coll, $name) = $paramscheck->(@_);

	return _find_by_name($coll, $name);

}

=item C<find_subgraph_by_title>

Given a reference to a C<Munin::Plugin::Graph> and a title, return a reference to the subgraph with the given title.

=cut

sub find_subgraph_by_title {
	state $paramscheck = compile (InstanceOf['Munin::Plugin::Graph::BaseGraph'], Str);
	my ($graph, $title) = $paramscheck->(@_);

	return _find_by_name ($graph, $title);

}

=item C<find_subgraph_by_name>

Given a reference to a C<Munin::Plugin::Graph> and a name, return a reference to the subgraph with the given name.

=cut

sub find_subgraph_by_name {
	state $paramscheck = compile (InstanceOf['Munin::Plugin::Graph::BaseGraph'], Str);
	my ($graph, $name) = $paramscheck->(@_);

	return _find_by_name($graph, $name);

}

=item C<create_graph>

A shorthand for creating a single instance of a graph.

Given an arrayref of C<Munin::Plugin::Graph>s and a hashref of arguments, ensures that the specified graph exists in the array.

This method scans the array for a graph with a matching title and, if one is found, returns that graph, otherwise adds the new graph to the array and returns the new graph.

The intention here is that one would create graphs, save them, and re-load them at the start of the next run. By calling this function you don't need to worry about how many times your code creates the graph (perhaps because, during parsing the data, it's easier to create the graph several times). By saving and restoring the stack of graphs, you also have less likelihood of graphs disappearing because of missing data or parsing failures. Be sure to run C<clear()> on each graph, though, to remove values from the attacned C<Munin::Plugin::Graph::DS>es.

Be aware that, if a graph is found with different arguments to those passed, the new arguments are ignored. If parameters of the graph change, add them manually after the call to C<create_graph>.

=cut

sub create_graph {
	state $paramscheck = compile (ArrayRef, slurpy Dict);
	my ($coll, $args) = $paramscheck->(@_);

	if (!defined $args->{graph_title} ) {
		die ("Invalid call to create_args(): Missing attribute 'graph_title'");
	}

	my $graph = new Munin::Plugin::Graph::MultiGraph(%{$args});
	my $other;

	if ( defined( $other = find_graph_by_title( $coll, $graph->graph_title))) {
		return $other;
	} else {
		push @{$coll}, $graph;
		return $graph;
	}
}

=item C<create_subgraph>

Given a reference to a C<Munin::Plugin::Graph>, finds or adds a subgraph to it. See L<create_graph> for details.

=cut

sub create_subgraph {
	state $paramscheck = compile (ArrayRef, slurpy Dict);
	my ($graph, $args) = $paramscheck->(@_);

    if ( !defined $args->{graph_title} ) {
        die( "Invalid call to create_subgraph(): Missing attribute 'graph_title'") ;
    }

    my $subgraph = Munin::Plugin::Graph::Graph->new(%{$args});
    my $other;

    if ( defined( $other = find_subgraph_by_title( $graph, $subgraph->graph_title ) ) ) {
        return $other;
    }
    else {
        $graph->add_graph($subgraph);
        return $subgraph;
    }
}

=item C<create_ds>

Given a reference to a C<Munin::Plugin::Graph> (or subgraph), find or create the specified C<Munin::Plugin::Graph::DS>.

=cut

sub create_ds {
	state $paramscheck = compile (InstanceOf["Munin::Plugin::Graph::BaseGraph"], slurpy Dict);
    my ( $g, $args ) = $paramscheck->(@_);

    if ( !defined $args->{fieldname} ) {
        die "Invalid call to create_ds: Missing attribute 'fieldname'" ;
    }

    my $ds = Munin::Plugin::Graph::DS->new(%{$args});
    my $other;

    if ( defined( $other = $g->get_DS_by_name( $ds->fieldname ) ) ) {
        return $other;
    }
    else {
        $g->add_DS($ds);
        return $ds;
    }
}

=back

=cut

1;

=head1 AUTHOR

Darac Marjal, C<< <darac at darac.org.uk> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-munin-plugin-graph at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Munin-Plugin-Graph>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Munin::Plugin::Graph


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Munin-Plugin-Graph>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Munin-Plugin-Graph>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Munin-Plugin-Graph>

=item * Search CPAN

L<http://search.cpan.org/dist/Munin-Plugin-Graph/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2016 Darac Marjal.

This program is distributed under the MIT (X11) License:
L<http://www.opensource.org/licenses/mit-license.php>

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.


=cut

1;    # End of Munin::Plugin::Graph
