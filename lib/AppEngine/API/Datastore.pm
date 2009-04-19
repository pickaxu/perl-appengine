package AppEngine::API::Datastore;

use strict;
use warnings;

use AppEngine::API::Datastore::Entity;
use AppEngine::API::Datastore::Key;
use AppEngine::Service::Datastore;
use AppEngine::Service::Entity;
use Carp;

use constant SERVICE => 'datastore_v3';

sub get {
    my $req = AppEngine::Service::Datastore::GetRequest->new;
    my $res = AppEngine::Service::Datastore::GetResponse->new;

    foreach my $key (@_) {
        croak 'expected Key, got ' . ref($key)
            unless ref($key) eq 'AppEngine::API::Datastore::Key';

        $key->_to_pb($req->add_key);
    }

    my $res_bytes = AppEngine::APIProxy::sync_call(SERVICE, 'Get', $req);
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
    my $req = AppEngine::Service::Datastore::PutRequest->new;
    my $res = AppEngine::Service::Datastore::PutResponse->new;

    foreach my $entity (@_) {
        croak 'expected Entity, got ' . ref($entity)
            unless ref($entity) eq 'AppEngine::API::Datastore::Entity';

        $entity->_to_pb($req->add_entity);
    }

    my $res_bytes = AppEngine::APIProxy::sync_call(SERVICE, 'Put', $req);
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
    my $req = AppEngine::Service::Datastore::DeleteRequest->new;

    foreach my $arg (@_) {
        my $type = ref($arg);

        if ($type eq 'AppEngine::API::Datastore::Key') {
            $arg->_to_pb($req->add_key);
        } elsif ($type eq 'AppEngine::API::Datastore::Entity') {
            croak 'cannot delete entity that is not saved' unless $arg->is_saved;
            $arg->key->_to_pb($req->add_key);
        } else {
            croak 'expected Key or Entity, got ' . $type;
        }
    }

    AppEngine::APIProxy::sync_call(SERVICE, 'Delete', $req);
}


1;
