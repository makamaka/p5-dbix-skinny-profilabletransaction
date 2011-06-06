
use strict;
use warnings;
use Test::More;
use lib './t';

BEGIN {
    eval "use DBD::SQLite";
    plan skip_all => "DBD::SQLite is not installed. skip testing" if $@;
}

require_ok( 'Mock::Basic' );

diag( 'DBIx::Skinny VERSION: ' . DBIx::Skinny->VERSION );

done_testing();


__END__
