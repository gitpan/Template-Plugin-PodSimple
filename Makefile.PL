

use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME         => 'Template::Plugin::PodSimple',
    VERSION_FROM => 'lib/Template/Plugin/PodSimple.pm', # finds \$VERSION
    AUTHOR       => 'D. H. (PodMaster)',
    ABSTRACT     => 'Template::Plugin::PodSimple - simple Pod::Simple plugin for TT',
    PREREQ_PM    => {
        'Pod::Simple'  => 2.05,
        'Test::Simple' => 0.44,
        'Template::Plugin' => 0,
    },
);
