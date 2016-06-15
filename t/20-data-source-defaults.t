#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;
use Test::Output;    # To capture STDOUT

plan tests => 42;

require_ok('Munin::Plugin::Graph');

my $ds_name = 'testing';

# Create a simple object
my $ds = new_ok( 'Munin::Plugin::Graph::DS' => [ fieldname => $ds_name ] );

my %attributes = (
    fieldname => $ds_name,
    cdef      => undef,
    colour    => undef,
    critical  => undef,
    draw      => undef,
    extinfo   => undef,
    graph     => undef,
    info      => undef,
    label     => undef,
    line      => undef,
    max       => undef,
    min       => undef,
    negative  => undef,
    stack     => undef,
    sum       => undef,
    type      => undef,
    warning   => undef,
    value     => 'U',
);

# Can we query information from the object?
for my $f ( sort keys %attributes ) {
    can_ok( $ds, $f );
    is( $ds->$f, $attributes{$f}, "Default $f" );
}

can_ok( $ds, 'emit_config' );
stdout_is( sub { $ds->emit_config }, "", "Default config output" );
can_ok( $ds, 'emit_fetch' );
stdout_is( sub { $ds->emit_fetch }, "${ds_name}.value U\n", "Default fetch output" );

#End
