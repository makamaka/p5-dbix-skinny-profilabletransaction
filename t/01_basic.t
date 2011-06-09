
use strict;
use warnings;
use Test::More;
use lib './t';

BEGIN {
    eval "use DBD::SQLite";
    plan skip_all => "DBD::SQLite is not installed. skip testing" if $@;
    $ENV{SKINNY_TRACE} = '1=query.log';
}

use Mock::Basic;

my ( $file ) = $ENV{SKINNY_TRACE} =~ /=(.+)$/;
if ( -s $file ) {
    unlink $file;
}


Mock::Basic->setup_test_db;


my $db = Mock::Basic->new;

$db->txn_begin;
$db->txn_commit;

open( my $fh, $file ) or die $!;

seek( $fh, 0, 0 );

like( scalar <$fh>, qr/CREATE TABLE/ );
like( scalar <$fh>, qr/BEGIN WORK/ );
like( scalar <$fh>, qr/COMMIT WORK/ );

$db->txn_begin;
$db->txn_rollback;

like( scalar <$fh>, qr/BEGIN WORK/ );
like( scalar <$fh>, qr/ROLLBACK WORK/ );

{
    my $txn = $db->txn_scope;
}

like( scalar <$fh>, qr/BEGIN WORK/ );
like( scalar <$fh>, qr/ROLLBACK WORK/ );

close( $fh );

if ( -e $file ) {
    unlink $file or warn $!;
}

done_testing();


__END__
