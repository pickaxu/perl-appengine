package AppEngine::API::Datastore;

use strict;
use warnings;

use AppEngine::API::Datastore::Entity;
use AppEngine::API::Datastore::Key;
use AppEngine::Service::Base;
use AppEngine::Service::Datastore;
use AppEngine::Service::Entity;
use Carp;
use Readonly;

Readonly my $SERVICE => 'datastore_v3';

our $current_transaction;
our $rollback_requested;

sub new {
    my ($pkg) = @_;

    my $self = {};
    bless $self, $pkg;

    return $self;
}

sub get {
    my $pkg = shift;

    my $req = AppEngine::Service::Datastore::GetRequest->new;
    my $res = AppEngine::Service::Datastore::GetResponse->new;

    foreach my $key (@_) {
        croak 'expected Key, got ' . ref($key)
            unless $key->isa('AppEngine::API::Datastore::Key');

        $key->_to_pb($req->add_key);
    }

    if ($pkg->in_transaction) {
        $req->transaction->set_handle($current_transaction);
    }

    my $res_bytes = AppEngine::APIProxy::sync_call($SERVICE, 'Get', $req);
    $res->parse_from_string($res_bytes);

    my @ret;
    foreach my $entity (@{$res->entitys}) {
        if (!$entity->has_entity) {
            push @ret, undef;
        } else {
            push @ret, AppEngine::API::Datastore::Entity::_from_pb($entity->entity);
        }
    }

    return $ret[0] if scalar(@ret) == 1;
    return @ret;
}

sub put {
    my $pkg = shift;

    my $req = AppEngine::Service::Datastore::PutRequest->new;
    my $res = AppEngine::Service::Datastore::PutResponse->new;

    foreach my $entity (@_) {
        croak 'expected Entity, got ' . ref($entity)
            unless $entity->isa('AppEngine::API::Datastore::Entity');

        $entity->_to_pb($req->add_entity);
    }

    if ($pkg->in_transaction) {
        $req->transaction->set_handle($current_transaction);
    }

    my $res_bytes = AppEngine::APIProxy::sync_call($SERVICE, 'Put', $req);
    $res->parse_from_string($res_bytes);

    my @ret;
    for (my $i = 0 ; $i < $res->key_size ; $i++) {
        my $key = AppEngine::API::Datastore::Key::_from_pb($res->keys->[$i]);
        $_[$i]->_set_saved($key);

        push @ret, $key;
    }

    return $ret[0] if scalar(@ret) == 1;
    return @ret;
}

sub delete {
    my $pkg = shift;

    my $req = AppEngine::Service::Datastore::DeleteRequest->new;

    foreach my $arg (@_) {
        if ($arg->isa('AppEngine::API::Datastore::Key')) {
            $arg->_to_pb($req->add_key);
        } elsif ($arg->isa('AppEngine::API::Datastore::Entity')) {
            croak 'cannot delete entity that is not saved' unless $arg->is_saved;
            $arg->key->_to_pb($req->add_key);
        } else {
            croak 'expected Key or Entity, got ' . ref($arg);
        }
    }

    if ($pkg->in_transaction) {
        $req->transaction->set_handle($current_transaction);
    }

    AppEngine::APIProxy::sync_call($SERVICE, 'Delete', $req);
}

sub in_transaction {
    return defined $current_transaction;
}

sub run_in_transaction {
    my ($pkg, $sub, @args) = @_;

    if ($pkg->in_transaction) {
        croak 'cannot call run_in_transaction from within a transaction';
    }

    # Begin transaction
    local $current_transaction = $pkg->_begin_transaction;
    local $rollback_requested  = 0;

    # Call the user's function
    my $ret = eval { &$sub(@args) };

    # Commit or rollback
    if ($@) {
        $pkg->_rollback_transaction();

        if ($rollback_requested) {
            return;
        } else {
            die $@;
        }
    } else {
        $pkg->_commit_transaction();
    }

    return $ret;
}

sub rollback {
    my $pkg = shift;

    unless ($pkg->in_transaction) {
        croak 'cannot call rollback from outside a transaction';
    }

    $rollback_requested = 1;
    croak 'rolling back datastore transaction';
}

sub _begin_transaction {
    my ($pkg) = @_;

    my $req = AppEngine::Service::VoidProto->new;
    my $res = AppEngine::Service::Datastore::Transaction->new;

    my $res_bytes = AppEngine::APIProxy::sync_call($SERVICE, 'BeginTransaction', $req);
    $res->parse_from_string($res_bytes);

    return $res->handle;
}

sub _rollback_transaction {
    my $req = AppEngine::Service::Datastore::Transaction->new;
    $req->set_handle($current_transaction);

    AppEngine::APIProxy::sync_call($SERVICE, 'Rollback', $req);
}

sub _commit_transaction {
    my $req = AppEngine::Service::Datastore::Transaction->new;
    $req->set_handle($current_transaction);

    AppEngine::APIProxy::sync_call($SERVICE, 'Commit', $req);
}

1;
