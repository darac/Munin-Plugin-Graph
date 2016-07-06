#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;
use Test::Output;    # To capture STDOUT
use Test::Exception;
eval 'use Test::More::Color';

no warnings qw(uninitialized);

my $num_tests = 0;

require_ok('Munin::Plugin::Graph');
$num_tests += 1;

# First, test the field_name
my @valid_names = ( "a", "Another", "SOMETHING", "with_underscores", "_leading_underscore", );
my @mapped_names = (
    [ '1234',                                    '_234' ],
    [ 'with spaces',                             'with_spaces' ],
    [ "Недопустимые символы", "_______________________________________" ] );
my @invalid_names = ( undef, \[1.2], "", "root" );

# Next, test the arguments
my @test_matrix = ( {
        field           => 'cdef',
        valid_arguments => [ 'blah', 'blah,8,/', '8', '', undef ],
    }, {
        field             => 'colour',
        valid_arguments   => [ '000000', 'ffffff', undef ],
        mapped_arguments  => [ [ '#123456', '123456' ], ],
        invalid_arguments => [ 'invalid', '123', 0xabc123 ],
    }, {
        field             => 'critical',
        valid_arguments   => [ '123:', ':1', '0:100', ":", undef ],
        invalid_arguments => [123],
    }, {
        field => 'draw',
        valid_arguments =>
          [ qw(AREA LINE1 LINE2 STACK AREASTACK LINESTACK LINE1STACK LINE2STACK), undef ],
        invalid_arguments => [qw(area 1LINE AREA1STACK)],
    }, {
        field           => 'extinfo',
        valid_arguments => [ 'a string', '<b>html text</b>', '<invalid> some < test', undef ],
    }, {
        field            => 'graph',
        valid_arguments  => [ "yes", "no", undef ],
        mapped_arguments => [
            [ "enabled",  "yes" ],
            [ "disabled", "no" ],
            [ "1",        "yes" ],
            [ "0",        "no" ],
            [ "on",       "yes" ],
            [ "off",      "no" ],
            [ "",         "no" ]
        ],
        invalid_arguments => [ 1234, [ 1, 2 ], "yes, please", "not today" ]
    }, {
        field           => 'info',
        valid_arguments => [ 'a string', '<b>html text</b>', '<invalid> some < test', undef ],
    }, {
        field           => 'label',
        valid_arguments => [ 'label', 'a_label', undef ],
        invalid_arguments => [ 'Label', 'Label with spaces' ],
    }, {
        field             => 'line',
        valid_arguments   => [ '10.3', '10.3:abcdef', '10.3:abcdef:a_label', undef ],
        invalid_arguments => [ ':abcdef:', '10.3:', '10.3:label', 'abcdef' ],
    }, {
        field           => 'max',
        valid_arguments => [ 1, 100, -100, 10.3, 0, undef ],
    }, {
        field           => 'min',
        valid_arguments => [ 1, 100, -100, 10.3, 0, undef ],
    }, {
        field           => 'negative',
        valid_arguments => [ 'foo', new Munin::Plugin::Graph::DS( fieldname => 'bar' ), undef ],
        invalid_arguments => [ [ 'foo', 'bar' ] ],
    }, {
        field           => 'stack',
        valid_arguments => [undef],    # TODO
    }, {
        field           => 'sum',
        valid_arguments => [undef],    # TODO
    }, {
        field             => 'type',
        valid_arguments   => [ qw(GAUGE COUNTER DERIVE ABSOLUTE), undef ],
        invalid_arguments => [qw(gauge elephant)],
    }, {
        field             => 'warning',
        valid_arguments   => [ '123:', ':1', '0:100', ":", undef ],
        invalid_arguments => [123],
    }, {
        field             => 'value',
        valid_arguments   => [ '123', '10.3', 'U' ],
        mapped_arguments  => [ [ undef, 'U' ], ],
        invalid_arguments => ['some'],
    },
);


my $DS;
for my $n (@valid_names) {
    $num_tests += 2;
    $DS = new_ok(
        'Munin::Plugin::Graph::DS' => [ fieldname => $n ],
        "Valid New DS, name $n"
    );
    is( $DS->fieldname, $n, "DS fieldname $n" );
}
for my $n (@invalid_names) {
    $num_tests += 1;
    dies_ok( sub { $DS = new Munin::Plugin::Graph::DS( fieldname => $n ) },
        "Invalid New DS, name $n" );
}

for my $a (@mapped_names) {
    my ( $n, $e ) = @{$a};
    $num_tests += 2;
    $DS = new_ok(
        'Munin::Plugin::Graph::DS' => [ fieldname => $n ],
        "Valid New DS, name $n"
    );
    is( $DS->fieldname, $e, "DS fieldname $n mapped to $e" );
}

$DS = new Munin::Plugin::Graph::DS( fieldname => "testing" );

for my $test (@test_matrix) {
    $num_tests += 1;
    my $field = $test->{field};
    subtest "Field $field", sub {
        my ( $value, $expected );
        if ( exists( $test->{valid_arguments} ) ) {
            for $value ( @{ $test->{valid_arguments} } ) {
                is( $DS->$field($value), $value, "Setting $field to $value" )
                  || diag explain $DS->$field;
            }
        }
        if ( exists( $test->{mapped_arguments} ) ) {
            for my $pair ( @{ $test->{mapped_arguments} } ) {
                ( $value, $expected ) = @{$pair};
                is( $DS->$field($value), $expected, "$field: $value -> $expected" )
                  || explain $DS->$field;
            }
        }
        if ( exists( $test->{invalid_arguments} ) ) {
            for $value ( @{ $test->{invalid_arguments} } ) {
                dies_ok( sub { $DS->$field($value) }, "Setting $field to $value" )
                  || diag explain $DS->$field;
                isnt( $DS->$field, $value, "$field new value" );
            }
        }
      }
}


done_testing($num_tests);

#End
