package Mock::Basic;
use DBIx::Skinny connect_info => +{
    dsn => 'dbi:SQLite:',
    username => '',
    password => '',
    connect_options => { AutoCommit => 1 },
};
use DBIx::Skinny::ProfilableTransaction;

sub setup_test_db {
    shift->do(q{
        CREATE TABLE mock_basic (
            id   integer,
            name text,
            primary key ( id )
        )
    });
}

1;

