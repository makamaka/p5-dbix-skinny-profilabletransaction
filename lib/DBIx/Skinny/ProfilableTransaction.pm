package DBIx::Skinny::ProfilableTransaction;

use strict;
use warnings;

our $VERSION = '0.02';

sub import {
    my $pkg = caller;

    no strict 'refs';

    *{"$pkg\::txn_manager"} = sub {
        my $class = shift;
        $class->_verify_pid;

        $class->_attributes->{txn_manager} ||= do {
            my $dbh = $class->dbh;
            unless ($dbh) {
                Carp::croak("dbh is not found.");
            }
            $class->profiler ? 
                  DBIx::TransactionManager::DBIxSkinnyProfilerAcceptable->new($dbh, $class->profiler)
                : DBIx::TransactionManager->new($dbh);
        };
    };
}


package
    DBIx::TransactionManager::DBIxSkinnyProfilerAcceptable;

use strict;
use base qw(DBIx::TransactionManager);

sub new {
    my ($class, $dbh, $profiler) = @_;
    my $self = $class->SUPER::new( $dbh );
    $self->{ _profiler } = $profiler;
    return $self;
}


sub profiler {  shift->{ _profiler }->record_query( @_ ); }


sub txn_begin {
    my $self = shift;
    $self->profiler('BEGIN WORK') unless ( $self->in_transaction );
    $self->SUPER::txn_begin( @_ );
}


sub txn_rollback {
    my $self = shift;
    $self->profiler('ROLLBACK WORK') unless ( @{$self->active_transactions} > 1 );
    $self->SUPER::txn_rollback( @_ );
}


sub txn_commit {
    my $self = shift;
    $self->profiler('COMMIT WORK') unless ( @{$self->active_transactions} > 1 );
    $self->SUPER::txn_commit( @_ );
}


1;
__END__

=pod

=head1 NAME

DBIx::Skinny::ProfilableTransaction - logging transaction SQL

=head1 SYNOPSIS

    package Your::DB::Schema;

    use DBIx::Skinny connect_info => +{
        dsn => 'dbi:SQLite:',
        username => '',
        password => '',
    };
    use DBIx::Skinny::ProfilableTransaction;
    1;

    # SKINNY_PROFILE=1 or SKINNY_TRACE=1 ...

=head1 DESCRIPTION

Since version 0.0730, L<DBIx::Skinny> profiler cannot record SQL statements about transaction
- 'BEGIN WORK', 'COMMIT WORK' and 'ROLLBACK WORK' because DBIx::Skinny has used
L<DBIx::TransactionManager> instead of Skinny::Transaction.

This module makes profiler modules record those SQL statement.

    use DBIx::Skinny connect_info => ... ;
    use DBIx::Skinny::ProfilableTransaction;


=head1 SEE ALSO

DBIx::Skinny, DBIx::TransactionManager

=head1 AUTHOR

Makamaka Hannyaharamitu C<< <makamaka at cpan.org> >>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
