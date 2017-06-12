#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;
use Test::Output;    # To capture STDOUT
eval 'use Test::More::Color';
use DateTime;
use Time::HiRes qw(usleep);

plan tests => 17;

require_ok('Munin::Plugin::Graph');

my $ds_name = 'testing';

# Create a simple object
my $ds = new_ok( 'Munin::Plugin::Graph::DS' => [ fieldname => $ds_name ] );

is( $ds->last_update, DateTime->from_epoch( epoch => 0, time_zone => 'UTC' ), "Default is 0" );

# Note the time
my $start = DateTime->now;
usleep(1_000_000);

# Update the DS
$ds->value(23);

usleep(1_000_000);

# Note the time
my $end = DateTime->now;
usleep(1_000_000);

# Check that the DS timestamp was updated correctly
cmp_ok( $ds->last_update, '>=', $start ) and cmp_ok( $ds->last_update, '<=', $end );

# Check that updating some other aspect doesn't affect the timestamp
my $lut = $ds->last_update;
usleep(1_000_000);
$ds->info("blah");

is( $ds->last_update, $lut, "Updating info doesn't change LUT" );

# Check that READING the value doesn't affect the timestamp
my $nothing = $ds->value();
usleep(1_000_000);

is( $ds->last_update, $lut, "Reading the value doesn't change LUT" );

$ds->value('U');
usleep(1_000_000);

is( $ds->last_update, $lut, "Setting value to 'U' doesn't change LUT" );


# To Check expiry, add the DS to a graph
my $g = Munin::Plugin::Graph::Graph->new( graph_title => "testing" );
$g->add_DS($ds);

# Show the item is there
is( my $retr = $g->get_DS_by_name($ds_name), $ds, "Item exists" );

can_ok( $g, "expire" );
ok( $g->expire, "Can actually expire" );  # Expires anything two weeks old (Why two weeks? Why not?)

# Show the item hasn't expired
is( $retr = $g->get_DS_by_name($ds_name), $ds, "Item hasn't expired" );

# Now set the timestamp back two weeks
$ds->_set_last_update( DateTime->now()->subtract( weeks => 2 ) );

# Show the time has gone back
is( $ds->last_update, DateTime->now()->subtract( weeks => 2 ), "LUT has gone back" );

usleep(1_000_000);

ok( $g->expire );

is( $retr = $g->get_DS_by_name($ds_name), undef, "Item has expired" );    # Might be wrong

##
# Now, add the DS back, and try with a non-default expiration
$g->add_DS($ds);

$g->expire( new DateTime::Duration( months => 2 ) );    # Expires anything 2 months old

# Show the item is there
is( $retr = $g->get_DS_by_name($ds_name), $ds, "Item hasn't expired" );

$g->expire( new DateTime::Duration( seconds => 2 ) );    # Should expire the DS

is( $retr = $g->get_DS_by_name($ds_name), undef, "Item has expired" );    # Might be wrong

#End
