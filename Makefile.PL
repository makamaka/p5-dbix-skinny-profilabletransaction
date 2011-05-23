use 5.008;
use inc::Module::Install;
name 'DBIx-Skinny-ProfilableTransaction';
all_from 'lib/DBIx/Skinny/ProfilableTransaction.pm';

requires 'DBIx::Skinny' => '0.0733';

build_requires 'Test::More' => '0.96';

author_tests('xt');

repository 'http://github.com/makamaka/p5-dbix-skinny-profilabletransaction';

auto_include;

WriteAll;

1;
__END__
