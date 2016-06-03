#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;
use Test::Output;	# To capture STDOUT
use Test::Exception;

plan tests => 21;

require_ok('Munin::Plugin::Graph');

my $ds_name = 'testing';

# Create a simple object
my $ds = new_ok( 'Munin::Plugin::Graph::DS' => [ $ds_name ] );

my %fields = (
		# field       old value   new value
		fieldname => [$ds_name,  'new_testing'],
		cdef      => [undef,     "$ds_name,8,/"],
		colour    => [undef,     '1A2B3C'],
		critical  => [undef,     '10'],
		draw      => [undef,     'AREA'],
		extinfo   => [undef,     'Some extra info'],
		graph     => [undef,     'no'],
		info      => [undef,     'Some info'],
		label     => [undef,     "A label"],
		line      => [undef,     '23'],
		max       => [undef,     '100'],
		min       => [undef,     '1'],
		negative  => [undef,     'negativefield'],
		stack     => [undef,     'stackfield'],
		sum       => [undef,     'sumfield'],
		type      => [undef,     'DERIVE'],
		warning   => [undef,     '15'],
		value     => ['U',       '10'],
);

my $config_output = "";
my $fetch_output = "";
for my $field (sort keys %fields) {
	my ($old_value, $new_value) = $fields{$field};
	if ($field eq 'fieldname') {
		# This field should be read-only
		is      ($ds->$field,             $old_value, "$field initial value");
		dies_ok (sub {$ds->$field($new_value)},       "Setting new value for $field");
		isnt    ($ds->$field,             $new_value, "$field new value");
	} else {
		is      ($ds->$field,             $old_value, "$field initial value");
		ok      ($ds->$field($new_value),             "Setting new value for $field");
		is      ($ds->$field,             $new_value, "$field new value");
		if ($field ne 'value') {
			$config_output .= "$ds_name.$field $new_value\n";
		} else {
			$fetch_output .= "$ds_name.$field $new_value\n";
		}
	}
}

TODO {
	local $TODO = "functions don't exist yet";
	stdout_is ( \&{$ds->emit_config},  $config_output, "config output");
	stdout_is ( \&{$ds->emit_fetch},   $fetch_output,  "fetch output");
}

#ENd
