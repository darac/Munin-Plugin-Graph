use 5.006;
use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->subclass(
    code => q(
			BEGIN { eval 'use Module::Build::Debian'; };
		)
  )->new(
    module_name        => 'Munin::Plugin::Graph',
    license            => 'mit',
    dist_author        => q{Darac Marjal <darac@darac.org.uk>},
    dist_version_from  => 'lib/Munin/Plugin/Graph.pm',
    release_status     => 'stable',
	meta_merge         => {
		resources => {
			repository => 'https://github.com/darac/Munin-Plugin-Graph',
		},
	},
    configure_requires => {
        'Module::Build' => 0,
    },
    build_requires => {
        'Test::Exception' => 0,
        'Test::More'      => 0,
        'Test::Output'    => 0,
        'YAML::XS'        => 0,
        'strictures'      => 2,
    },
    requires => {
        'Moo'        => 0,
        'Type::Tiny' => 0,
        'strictures' => 2,
    },
    add_to_cleanup     => ['Munin-Plugin-Graph-*'],
    create_makefile_pl => 'traditional',
  );

$builder->create_build_script();
