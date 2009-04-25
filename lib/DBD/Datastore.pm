use strict;
use warnings;

# This is a really really nasty way to stop SQL::Statement from converting names
# of tables and columns to upper case
my $override_uc = 0;
BEGIN {
    *CORE::GLOBAL::uc = sub ($) {
        return CORE::uc($_[0]) unless $override_uc;
        return $_[0];
    };
}

{
    package DBD::Datastore::Parser;

    use base qw(SQL::Parser);

    sub new {
        my $self = SQL::Parser::new(@_);
        $self->feature('valid_comparison_operators', 'OR', 0);
        $self->feature('valid_comparison_operators', 'LIKE', 0);
        $self->feature('valid_comparison_operators', 'CLIKE', 0);
        $self->feature('valid_comparison_operators', 'ANCESTOR_IS', 1);
        $self->create_op_regexen();
        return $self;
    }

    sub transform_syntax {
        my ($self, $string) = @_;

        $string =~ s/ANCESTOR IS/dummy_column ANCESTOR_IS/gi;
        return $string;
    }
}

{
    package DBD::Datastore;

    our $VERSION = '1.0';
    our $drh = undef;

    sub driver {
        return $drh if $drh;
        my ($class, $attr) = @_;

        $class .= "::dr";

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

        my $parser = DBD::Datastore::Parser->new;

        my ($outer, $dbh) = DBI::_new_dbh($drh, { Name => 'Datastore' });
        $dbh->STORE('Active', 1 );
        $dbh->{datastore_parser} = $parser;

        return $outer;
    }

    sub data_sources { ( 'dbi:Datastore:' ) }
}

{
    package DBD::Datastore::db;

    use Data::Dumper;
    use SQL::Statement;

    $DBD::Datastore::db::imp_data_size = 0;

    sub prepare {
        my ($dbh, $statement, @attribs) = @_;

        # create a 'blank' sth
        my ($outer, $sth) = DBI::_new_sth($dbh, { Statement => $statement });

        # Parse the SQL
        $override_uc = 1;
        my $stmt = SQL::Statement->new($statement, $dbh->{datastore_parser});
        $override_uc = 0;

        # Do some basic validation
        return $dbh->set_err($DBI::stderr, $stmt->command . ' not supported')
            unless uc $stmt->command eq 'SELECT';
        return $dbh->set_err($DBI::stderr, 'no table specified')  if scalar $stmt->tables == 0;
        return $dbh->set_err($DBI::stderr, 'joins not supported') if scalar $stmt->tables > 1;

        $sth->STORE('NUM_OF_PARAMS', scalar $stmt->params);
        $sth->{datastore_params} = [];
        $sth->{datastore_stmt} = $stmt;

        return $outer;
    }

    sub STORE {
        my ($dbh, $attr, $val) = @_;
        if ($attr eq 'AutoCommit') {
            if (!$val) { die "Can't disable AutoCommit"; }
            return 1;
        } elsif ($attr =~ m/^datastore_/) {
            $dbh->{$attr} = $val;
            return 1;
        } elsif ($attr eq 'RaiseError') {
            $dbh->{datastore_parser}->{RaiseError} = $val;
        } elsif ($attr eq 'PrintError') {
            $dbh->{datastore_parser}->{PrintError} = $val;
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
        $sth->{datastore_params} = $params;

        my $stmt = $sth->{datastore_stmt};

        my $query = AppEngine::API::Datastore::Query->new($stmt->tables(0)->name);

        foreach my $order ($stmt->order) {
            my $property = ($order->desc ? '-' : '') . $order->column;
            $query->order($property);
        }

        if ($stmt->where) {
            _parse_where($sth, $query, $stmt->where) or return;
        }

        if ($stmt->columns(0)->name eq '*') {
            # We look at the first entity to determine the number of fields and
            # get the names of columns
            my $first_entity = $query->fetch(1);
            my @column_names = ('key');

            if ($first_entity) {
                foreach my $key (keys %$first_entity) {
                    push @column_names, $key unless $key =~ m/^_/;
                }
            }

            $sth->STORE('NUM_OF_FIELDS', scalar @column_names);
            $sth->{datastore_column_names} = \@column_names;
        } else {
            $sth->STORE('NUM_OF_FIELDS', scalar $stmt->columns);
            $sth->{datastore_column_names} = [ map { $_->name } $stmt->columns ];
        }

        $sth->{Active} = 1;
        $sth->{datastore_query} = $query;
    }

    sub FETCH {
        my ($sth, $attr) = @_;
        return $sth->{datastore_column_names} if $attr eq 'NAME';
        return $sth->SUPER::FETCH($attr);
    }

    sub _parse_where {
        my ($sth, $query, $op) = @_;
        my $dbh = $sth->{Database};

        if (uc $op->op eq 'AND') {
            return _parse_where($sth, $query, $op->arg1) &&
                   _parse_where($sth, $query, $op->arg2);
        } else {
            my $param;
            my $value;
            my $operator = $op->op;

            if (ref $op->arg1 eq 'SQL::Statement::Column') {
                $param = $op->arg1->name;
                $value = _value($sth, $op->arg2);
            } elsif (ref $op->arg2 eq 'SQL::Statement::Column') {
                $param = $op->arg2->name;
                $value = _value($sth, $op->arg1);
            } else {
                return $dbh->set_err($DBI::stderr, 'one argument in a WHERE condition must be the name of a column');
            }

            return $dbh->set_err($DBI::stderr, 'one argument in a WHERE condition must be a literal value or bound parameter')
                unless defined $value;

            if ($operator eq 'ANCESTOR_IS') {
                $query->ancestor($value);
            } else {
                $query->filter("$param $operator", $value);
            }
        }

        return 1;
    }

    sub _value {
        my ($sth, $arg) = @_;

        return $arg unless ref $arg;

        if (ref $arg eq 'SQL::Statement::Param') {
            return shift @{$sth->{datastore_params}};
        }
        return;
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
                push @$data, $entity->key->str;
                foreach my $key (sort keys %$entity) {
                    next if $key =~ m/^_/;
                    push @$data, $entity->{$key};
                }
            } elsif ($column eq 'key') {
                push @$data, $entity->key->str;
            } else {
                push @$data, $entity->{$column};
            }
        }

        $sth->_set_fbav($data);
    }
    *fetchrow_arrayref = \&fetch;
}


1;
