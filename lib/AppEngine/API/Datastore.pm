package AppEngine::API::Datastore;

use strict;
use warnings;

use AppEngine::API::Datastore::Entity;
use AppEngine::API::Datastore::Key;
use AppEngine::Service::Datastore;
use AppEngine::Service::Entity;
use Data::Dumper;

use constant SERVICE => 'datastore_v3';


sub get {
    # TODO(davidsansome): error check arguments

    my $req = AppEngine::Service::Datastore::GetRequest->new;
    my $res = AppEngine::Service::Datastore::GetResponse->new;

    foreach my $key (@_) {
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
    # TODO(davidsansome): error check arguments

    my $req = AppEngine::Service::Datastore::PutRequest->new;
    my $res = AppEngine::Service::Datastore::PutResponse->new;

    foreach my $entity (@_) {
        $entity->_to_pb($req->add_entity);
    }

    my $res_bytes = AppEngine::APIProxy::sync_call(SERVICE, 'Put', $req);
    $res->parse_from_string($res_bytes);

    for (my $i = 0 ; $i < $res->key_size ; $i++) {
        my $key = AppEngine::API::Datastore::Key::_from_pb($res->keys->[$i]);
        $_[$i]->_set_saved($key);
    }
}


1;
