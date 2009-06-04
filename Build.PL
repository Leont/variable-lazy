use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Variable::Lazy',
    license             => 'perl',
    dist_author         => 'Leon Timmermans <leont@cpan.org>',
    dist_version_from   => 'lib/Variable/Lazy.pm',
    build_requires => {
        'Test::More' => 0,
    },
    add_to_cleanup      => [ 'Variable-Lazy-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
