use 5.006;
use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Munin::Plugin::Graph',
    license             => 'mit',
    dist_author         => q{Darac Marjal <darac@darac.org.uk>},
    dist_version_from   => 'lib/Munin/Plugin/Graph.pm',
    release_status      => 'stable',
    configure_requires => {
        'Module::Build' => 0,
    },
    build_requires => {
        'Test::More' => 0,
    },
    requires => {
        #'ABC'              => 1.6,
        #'Foo::Bar::Module' => 5.0401,
    },
    add_to_cleanup     => [ 'Munin-Plugin-Graph-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
