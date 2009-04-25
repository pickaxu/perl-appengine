use strict;
use warnings;

{
    package DBD::Datastore;

    our $VERSION = '1.0';
    our $drh = undef;

    sub driver {
        return $drh if $drh;
        my ($class, $attr) = @_;

        $class .= "::dr";

        #DBD::Driver::db->install_method('drv_example_dbh_method');
        #DBD::Driver::st->install_method('drv_example_sth_method');

        $drh = DBI::_new_drh($class, {
            'Name'        => 'Datastore',
            'Version'     => $VERSION,
            'Attribution' => 'DBD::Datastore by David Sansome',
        }) or return;

        return $drh;
    }

    sub CLONE {
        undef $drh;
    }
}

{
    package DBD::Datastore::dr;

    $DBD::Datastore::dr::imp_data_size = 0;

    sub connect {
        my ($drh, $dr_dsn, $user, $auth, $attr) = @_;

        my $driver_prefix = 'datastore_';

        # Process attributes from the DSN; we assume ODBC syntax
        # here, that is, the DSN looks like var1=val1;...;varN=valN
        foreach my $var ( split /;/, $dr_dsn ) {
            my ($attr_name, $attr_value) = split '=', $var, 2;
            return $drh->set_err($DBI::stderr, "Can't parse DSN part '$var'")
                unless defined $attr_value;

            # add driver prefix to attribute name if it doesn't have it already
            $attr_name = $driver_prefix.$attr_name
                unless $attr_name =~ /^$driver_prefix/o;

            # Store attribute into %$attr, replacing any existing value.
            # The DBI will STORE() these into $dbh after we've connected
            $attr->{$attr_name} = $attr_value;
        }

        my ($outer, $dbh) = DBI::_new_dbh($drh, { Name => 'Datastore' });
        $dbh->STORE('Active', 1 );

        return $outer;
    }

    sub data_sources { ( 'dbi:Datastore:' ) }
}

{
    package DBD::Datastore::db;

    BEGIN { $ENV{DBI_SQL_NANO} = 1 }
    use Data::Dumper;
    use DBI::SQL::Nano;

    $DBD::Datastore::db::imp_data_size = 0;

    sub prepare {
        my ($dbh, $statement, @attribs) = @_;

        # create a 'blank' sth
        my ($outer, $sth) = DBI::_new_sth($dbh, { Statement => $statement });

        # Parse the SQL
        my $stmt = DBI::SQL::Nano::Statement->new($statement);

        # Do some basic validation
        return $dbh->set_err($DBI::stderr, $stmt->{command} . ' not supported')
            unless $stmt->{command} eq 'SELECT';

        $sth->STORE('NUM_OF_PARAMS', 0); # TODO(davidsansome)
        $sth->{datastore_params} = [];
        $sth->{datastore_stmt} = $stmt;

        warn Dumper($stmt);

        return $outer;
    }

    sub STORE {
        my ($dbh, $attr, $val) = @_;
        if ($attr eq 'AutoCommit') {
            if (!$val) { die "Can't disable AutoCommit"; }
            return 1;
        }
        if ($attr eq 'RaiseError') {
            $dbh->{datastore_parser}->{RaiseError} = $val;
        }
        if ($attr eq 'PrintError') {
            $dbh->{datastore_parser}->{PrintError} = $val;
        }
        if ($attr =~ m/^datastore_/) {
            $dbh->{$attr} = $val;
            return 1;
        }
        $dbh->SUPER::STORE($attr, $val);
    }

    sub FETCH {
        my ($dbh, $attr) = @_;
        if ($attr eq 'AutoCommit') { return 1; }
        if ($attr =~ m/^datastore_/) {
            return $dbh->{$attr};
        }
        $dbh->SUPER::FETCH($attr);
    }

    sub disconnect {
        my $dbh = shift;
        $dbh->STORE('Active', 0);
        1;
    }

    sub DESTROY ($) {
        my $dbh = shift;
        $dbh->disconnect if $dbh->SUPER::FETCH('Active');
    }
}

{
    package DBD::Datastore::st;

    use AppEngine::API::Datastore::Query;
    use Data::Dumper;

    $DBD::Datastore::st::imp_data_size = 0;

    sub bind_param {
        my ($sth, $pNum, $val, $attr) = @_;

        $sth->{datastore_params}->[$pNum-1] = $val;

        1;
    }

    sub execute {
        my ($sth, @bind_values) = @_;

        # start of by finishing any previous execution if still active
        $sth->finish if $sth->FETCH('Active');

        my $params = (@bind_values) ? \@bind_values : $sth->{datastore_params};
        my $numParam = $sth->FETCH('NUM_OF_PARAMS');
        return $sth->set_err($DBI::stderr, "Wrong number of parameters")
            if @$params != $numParam;

        my $stmt = $sth->{datastore_stmt};

        my $query = AppEngine::API::Datastore::Query->new($stmt->{table_name});

        if ($stmt->{order_clause}) {
            my $column = (keys %{$stmt->{order_clause}})[0];
            my $direction = $stmt->{order_clause}{$column};
            my $property = ($direction eq 'DESC' ? '-' : '') . $column;
            $query->order($property);
        }

        # TODO(davidsansome): where

        $sth->STORE('NUM_OF_FIELDS', scalar @{$stmt->{column_names}});
        $sth->{Active} = 1;
        $sth->{datastore_query} = $query;
    }

    sub finish {
        my $sth = shift;
        $sth->SUPER::STORE(Active => 0);
        return 1;
    }

    sub fetch ($) {
        my $sth = shift;

        my $stmt = $sth->{datastore_stmt};
        my $query = $sth->{datastore_query};
        unless ($query) {
            $sth->set_err($DBI::stderr, 'Attempt to fetch row without a preceeding execute() call');
            return;
        }

        my $entity = $query->fetch;
        unless ($entity) {
            $sth->finish;
            return;
        }

        my $data = [];
        foreach my $column (@{$stmt->{column_names}}) {
            if ($column eq '*') {
                foreach my $key (sort keys %$entity) {
                    next if $key =~ m/^_/;
                    push @$data, $entity->{$key};
                }
            }
            else {
                push @$data, $entity->{$column};
            }
        }

        $sth->_set_fbav($data);
    }
    *fetchrow_arrayref = \&fetch;
}

1;
