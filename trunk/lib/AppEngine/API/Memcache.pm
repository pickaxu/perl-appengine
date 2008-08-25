=pod

=head1 NAME

AppEngine::API::Memcache - Perl version of google.appengine.api.memcache

=head1 SYNOPSIS

    use AppEngine::API::Memcache::Client;

    my $memcache = AppEngine::API::Memcache::Client->new();
    $memcache->set();
    $memcache->set_multi();
    $memcache->get();
    $memcache->get_multi();
    $memcache->delete();
    $memcache->delete_multi();
    $memcache->add();
    $memcache->replace();
    $memcache->incr();
    $memcache->decr();
    $memcache->flush_all();
    $memcache->get_stats();
    
=head1 DESCRIPTION

Implements the Perl version of the Google AppEngine API Memcache interface.

Note: All memcache operations are invoked through a AppEngine::API::Memcache::Client
instance; therefore, the methods described below are for 
AppEngine::API::Memcache::Client.

=head1 METHODS

Note: The following (undocumented) no-op methods are part of the Python SDK, but have
been omitted from this package:

=over

=item set_servers(servers)

Sets the pool of memcache servers used by the client.

=item disconnect_all()

Closes all connections to memcache servers.

=item forget_dead_hosts():

Resets all servers to the alive status.

=item debuglog():

Logging function for debugging information.

=back

=cut

use strict;
use warnings;

package AppEngine::API::Memcache;

1;

package AppEngine::API::Memcache::Client;

use AppEngine::APIProxy;
use AppEngine::Service::Memcache;
use POSIX;
use Storable qw(thaw freeze);
use Scalar::Utils qw(looks_like_number);

=pod

=head2 new()

Constructor.

=cut

sub new {
    return bless { }, $_[0];
}

=pod

=head2 $memcache->set($key, $value, $time, $min_compress_len)

Sets a key's value, regardless of previous contents in cache.

Arguments:

=over

=item key

Key to set. The Key is a string.

Note that the Python SDK supports keys of the form (hash_value, string),
where the hash_value, normally used for sharding onto a memcache instance, 
is instead ignored, as Google App Engine deals with the sharding transparently. That form
is not supported by this Perl implementation.

=item value

Value to set.

=item time

Optional expiration time, either relative number of seconds from current time (up to 1 month), or an absolute Unix epoch time. By default, items never expire, though items may be evicted due to memory pressure. Float values will be rounded up to the nearest whole second.

=item min_compress_len

Ignored option for compatibility.

=back

The return value is True if set, False on error.

=cut

sub _validate_encode_value {
    my $value = shift;
    my $flag = 0;

    my $stored_value = (ref $value) ? freeze($value) : $value;
    $flag |= FLAG_VALUE_PICKLED if ref $value;
    $flag |= FLAG_VALUE_UNICODE;

    die 'Values may not be more than ' . MAX_VALUE_SIZE . 
        ' bytes in length; received ' . length($stored_value) . ' bytes'
        if (length(stored_value) > MAX_VALUE_SIZE);
    return ($stored_value, $flag);
}

sub_decode_value {
    my ($stored_value, $flags) = @_;
#  assert isinstance(stored_value, str)
#  assert isinstance(flags, (int, long))

    return ($flags & FLAG_VALUE_UNICODE) ? utf8::decode($stored_value)
          :  ($flags & FLAG_VALUE_PICKLED) ? thaw($stored_value)
          :  $stored_value;
}

sub _set_with_policy {
    my ($self, $policy, $key, $value, $time) = @_;
    $time = 0 unless defined $time;

    die 'Expiration must be a number.' unless looks_like_number($time);
    die 'Expiration must not be negative.'
        if ($time < 0);

    my $request = AppEngine::Service::Memcache::MemcacheSetRequest->new();
    my $item = $request->add_item();
    $item->set_key(_key_string($key));
    my ($stored_value, $flags) = _validate_encode_value(freeze($value));
    $item->set_value(ref $value ? freeze($value) : $value);
    $item->set_flags( ref $value ? FLAG_VALUE_UNICODE | FLAG_VALUE_PICKLED : FLAG_VALUE_UNICODE);
    $item->set_set_policy(policy);
    $item->set_expiration_time(ceil($time));
    my $response = AppEngine::Service::Memcache::MemcacheSetResponse->new();
    _do_req('memcache', 'Set', $request, $response) or return undef;

    return ($response->set_status_size() != 1) 
        ? undef 
        : ($response->set_status(0) == AppEngine::Service::Memcache::MemcacheSetResponse::STORED);
}

sub set {
    my ($self, $key, $value, $time, $min_compress_len) = @_;
    $time ||= 0;
    $min_compress_len ||= 0;

    return $self->_set_with_policy(AppEngine::Service::Memcache::MemcacheSetRequest::SET, $key, $value, $time);
}

=pod

=head2 $memcache->set_multi($mapping, $time, $key_prefix, $min_compress_len)

Set multiple keys' values at once. Reduces the network latency of doing many requests in serial.

Arguments:

=over

=item mapping

Dictionary of keys to values.

=item time

Optional expiration time, either relative number of seconds from current time (up to 1 month), or an absolute Unix epoch time. By default, items never expire, though items may be evicted due to memory pressure. Float values will be rounded up to the nearest whole second.

=item key_prefix

Optional prefix for to prepend to all keys.

=item min_compress_len

Ignored option for compatibility.

=back

The return value is a list of keys whose values were NOT set. On total success, this list should be empty.

=cut

sub set_multi {
    my ($self, $mapping, $time, $key_prefix, $min_compress_len) = @_;
    $time ||= 0;
    $key_prefix ||= '';
    $min_compress_len ||= 0;

    die 'Expiration must be a positive number.'
        unless looks_like_number($time) && ($time >= 0);

    my $request = AppEngine::Service::Memcache::MemcacheSetRequest->new();
    my %user_key = ();
    my @server_keys = ();
    while (my $key, $value) = each %$mapping) {
      my $server_key = $key_prefix . $key;
      $user_key{$server_key} = $key;
      my stored_value, flags = _validate_encode_value(value, self._do_pickle)
      push @server_keys, $server_key;

      my $item = $request->add_item();
      $item->set_key($server_key);
      $item->set_value(ref $value ? freeze($value) : $value);
      $item->set_flags(ref $value ? FLAG_VALUE_UNICODE | FLAG_VALUE_PICKLED : FLAG_VALUE_UNICODE);
      $item->set_set_policy(AppEngine::Service::Memcache::MemcacheSetRequest.SET);
      $item->set_expiration_time(ceil($time));
    }

    my $response = AppEngine::Service::Memcache::MemcacheSetResponse->new();
    _do_req('memcache', 'Set', $request, $response) or die;

    return undef unless ($response->set_status_size() == @server_keys);

    my @unset_list = ();
    my @status_list = $response->set_status_list();
    for (0..$#server_keys) {
       push @unset_list, $user_key{$server_key[$_]}
            if ($status_list[$_] != AppEngine::Service::Memcache::MemcacheSetResponse.STORED);
    }
#
#    return as list or as ref ? I think ref, since this could be a long list
#
    return \@unset_list;
}

=pod

=head2 $value = $memcache->get($key)

Looks up a single key in memcache.

Arguments:

=over

=item key

The key in memcache to look up. The Key can be a string or a tuple of (hash_value, string) where the hash_value, normally used for sharding onto a memcache instance, is instead ignored, as Google App Engine deals with the sharding transparently.

=back

The return value is the value of the key, if found in memcache, else None.

=cut

sub get {
    my ($self, $key) = @_;

    my $request = AppEngine::Service::Memcache::MemcacheGetRequest->new();
    $request->add_key(_key_string($key));
    my $response = AppEngine::Service::Memcache::MemcacheGetResponse->new();
    _do_req('memcache', 'Get', $request, $response) or return undef;

    return response.item_size() 
        ? _decode_value($response->item(0)->value(), $response->item(0)->flags());
        : undef;
}

=pod

=head2 $memcache->get_multi(\@keys, $key_prefix)

Looks up multiple keys from memcache in one operation. This is the recommended way to do bulk loads.

Arguments:

=over

=item \@keys

List of keys to look up. A Key can be a string or a tuple of (hash_value, string) where the hash_value, normally used for sharding onto a memcache instance, is instead ignored, as Google App Engine deals with the sharding transparently.

=item $key_prefix

Optional prefix to prepend to all keys when talking to the server; not included in the returned dictionary.

=back

The returned value is a dictionary of the keys and values that were present in memcache. Even if the key_prefix was specified, that key_prefix won't be on the keys in the returned dictionary.

=cut

sub get_multi {
    my ($self, $keys, $key_prefix) = @_;
    $key_prefix ||= '';

    my $request = AppEngine::Service::Memcache::MemcacheGetRequest->new();
    my $response = AppEngine::Service::Memcache::MemcacheGetResponse->new();
    my $user_key = {};
    foreach my $key (@$keys) {
      $request->add_key(_key_string($key, $key_prefix, $user_key));
    }

    _do_req('memcache', 'Get', $request, $response) or return {};

    my %return_value = ();
    my $item_list = $response->item_list();
    foreach my $returned_item (@$item_list) {
          $return_value{$user_key->{$returned_item->key()}} = 
              _decode_value($returned_item->value(), $returned_item->flags());
    }
    return \%return_value;
}

=pod

=head2 $rc = $memcache=>delete($key, $seconds)

Deletes a key from memcache.

Arguments:

=over

=item key

Key to delete. A Key can be a string or a tuple of (hash_value, string) where the hash_value, normally used for sharding onto a memcache instance, is instead ignored, as Google App Engine deals with the sharding transparently.

=item seconds

Optional number of seconds to make deleted items 'locked' for 'add' operations. Value can be a delta from current time (up to 1 month), or an absolute Unix epoch time. Defaults to 0, which means items can be immediately added. With or without this option, a 'set' operation will always work. Float values will be rounded up to the nearest whole second.

=back

The return value is 0 (DELETE_NETWORK_FAILURE) on network failure, 1 (DELETE_ITEM_MISSING) if the server tried to delete the item but didn't have it, and 2 (DELETE_SUCCESSFUL) if the item was actually deleted. This can be used as a boolean value, where a network failure is the only bad condition.

=cut

sub delete {
    my ($self, $key, $seconds) = @_;
    $seconds ||= 0;

    die 'Delete timeout must be a number.'
        unless looks_like_number(seconds);
    die 'Delete timeout must be non-negative.'
        if (seconds < 0);

    my $request = AppEngine::Service::Memcache::MemcacheDeleteRequest->new();
    my $response = AppEngine::Service::Memcache::MemcacheDeleteResponse->new();

    my $delete_item = $request->add_item();
    $delete_item->set_key(_key_string($key));
    $delete_item->set_delete_time(ceil($seconds));
    _do_req('memcache', 'Delete', $request, $response) or return undef;

#    assert response.delete_status_size() == 1, 'Unexpected status size.'
 
    return ($response->delete_status(0) == AppEngine::Service::Memcache::MemcacheDeleteResponse::DELETED)
        ? DELETE_SUCCESSFUL
        : ($response->delete_status(0) == AppEngine::Service::Memcache::MemcacheDeleteResponse::NOT_FOUND)
              ? DELETE_ITEM_MISSING
              : undef;
#    assert False, 'Unexpected deletion status code.'
}

=pod

=head2 $rc = $memcache=>delete_multi(\@keys, $seconds, $key_prefix)

Delete multiple keys at once.

Arguments:

=over

=item keys

List of keys to delete. A Key can be a string or a tuple of (hash_value, string) where the hash_value, normally used for sharding onto a memcache instance, is instead ignored, as Google App Engine deals with the sharding transparently. 

=item seconds

Optional number of seconds to make deleted items 'locked' for 'add' operations. Value can be a delta from current time (up to 1 month), or an absolute Unix epoch time. Defaults to 0, which means items can be immediately added. With or without this option, a 'set' operation will always work. Float values will be rounded up to the nearest whole second.

=item key_prefix

Optional prefix to put on all keys when sending specified keys to memcache. See docs for get_multi() and set_multi()

=back

The return value is True if all operations completed successfully. False if one or more failed to complete.

=cut

sub delete_multi {
    my ($self, $keys, $seconds, $key_prefix) = @_;
    $seconds ||= 0;
    $key_prefix ||= '';

    die 'Delete timeout must be a number.'
        unless looks_like_number(seconds);
    die 'Delete timeout must be non-negative.'
        if (seconds < 0);

    my $request = AppEngine::Service::Memcache::MemcacheDeleteRequest->new();
    my $response = AppEngine::Service::Memcache::MemcacheDeleteResponse->new();

    foreach my $key (@$keys) {
      my $delete_item = $request->add_item();
      $delete_item->set_key(_key_string($key, $key_prefix));
      $delete_item->set_delete_time(ceil($seconds));
    }
    _do_req('memcache', 'Delete', $request, $response) or return undef;
    return 1;
}

=pod

=head2 $rc = $memcache->add($key, $value, $time, $min_compress_len)

Sets a key's value, if and only if the item is not already in memcache.

Arguments:

=over

=item key

Key to set. The Key can be a string or a tuple of (hash_value, string) where the hash_value, normally used for sharding onto a memcache instance, is instead ignored, as Google App Engine deals with the sharding transparently.

=item value

Value to set.

=item time

Optional expiration time, either relative number of seconds from current time (up to 1 month), or an absolute Unix epoch time. By default, items never expire, though items may be evicted due to memory pressure. Float values will be rounded up to the nearest whole second.

=item min_compress_len

Ignored option for compatibility.

=back

The return value is True if added, False on error.

=cut

sub add {
    my ($self, $key, $value, $time, $min_compress_len) = @_;
    $time ||= 0;
    $min_compress_len ||= 0;

    return $self->_set_with_policy(AppEngine::Service::Memcache::MemcacheSetRequest::ADD, $key, $value, $time);
}

=pod

=head2 $rc = $memcache->replace($key, $value, $time, $min_compress_len)

Replaces a key's value, failing if item isn't already in memcache.

Arguments:

=over

=item key

Key to set. The Key can be a string or a tuple of (hash_value, string) where the hash_value, normally used for sharding onto a memcache instance, is instead ignored, as Google App Engine deals with the sharding transparently.

=item value

Value to set.

=item time

Optional expiration time, either relative number of seconds from current time (up to 1 month), or an absolute Unix epoch time. By default, items never expire, though items may be evicted due to memory pressure. Float values will be rounded up to the nearest whole second.

=item min_compress_len

Ignored option for compatibility.

=back

The return value is True if replaced. False on error or cache miss.

=cut

sub replace {
    my ($self, $key, $value, $time, $min_compress_len) = @_;
    $time ||= 0;
    $min_compress_len ||= 0;
    return $self->_set_with_policy(AppEngine::Service::Memcache::MemcacheSetRequest.REPLACE, $key, $value, $time);
}

=pod

=head2 $newkey = $memcache->incr($key, $delta)

Atomically increments a key's value. Internally, the value is a unsigned 64-bit integer. Memcache doesn't check 64-bit overflows. The value, if too large, will wrap around.

The key must already exist in the cache to be incremented. To initialize a counter, set() it to the initial value, as an ASCII decimal integer. Future get()s of the key, post-increment, will still be an ASCII decimal value.

Arguments:

=over

=item key

Key to increment. The Key can be a string or a tuple of (hash_value, string) where the hash_value, normally used for sharding onto a memcache instance, is instead ignored, as Google App Engine deals with the sharding transparently. 

=item delta

Optional non-negative integer value (int or long) to increment key by, defaulting to 1.

=back

The return value is a new long integer value, or None if key was not in the cache or could not be incremented for any other reason.

=cut

sub _incrdecr {
    my ($self, $key, $is_negative, $delta) = @_;

    die "Delta must be an integer or long, received delta\n"
        unless (delta=~/^\d+$/);
    die "Delta must not be negative."
        if (delta < 0);

    my $request = AppEngine::Service::Memcache::MemcacheIncrementRequest->new();
    my $response = AppEngine::Service::Memcache::MemcacheIncrementResponse->new();
    $request->set_key(_key_string($key));
    $request->set_delta($delta);
    $request->set_direction($is_negative 
          ? AppEngine::Service::Memcache::MemcacheIncrementRequest::DECREMENT
        : AppEngine::Service::Memcache::MemcacheIncrementRequest::INCREMENT);

    _do_req('memcache', 'Increment', $request, $response) or return undef;

    return $response->has_new_value() ? $response->new_value() : undef;

sub incr {
    my ($self, $key, $delta) = @_;
    $delta = 1 unless defined $delta;
    return $self->_incrdecr($key, 1, $delta);
}

=pod

=head2 $newkey = $memcache->decr($key, $delta)

Atomically decrements a key's value. Internally, the value is a unsigned 64-bit integer. Memcache doesn't check 64-bit overflows. The value, if too large, will wrap around.

The key must already exist in the cache to be decremented. To initialize a counter, set() it to the initial value, as an ASCII decimal integer. Future get()s of the key, post-increment, will still be an ASCII decimal value.

Arguments:

=over

=item key

Key to decrement. The Key can be a string or a tuple of (hash_value, string) where the hash_value, normally used for sharding onto a memcache instance, is instead ignored, as Google App Engine deals with the sharding transparently. 

=item delta

Optional non-negative integer value (int or long) to decrement key by, defaulting to 1.

=back

The return value is a new long integer value, or None if key was not in the cache or could not be decremented for any other reason.

=cut

sub decr {
    my ($self, $key, $delta) = @_;
    $delta = 1 unless defined $delta;
    return $self->_incrdecr($key, undef, $delta);
}

=pod

=head2 $rc = $memcache->flush_all()

Deletes everything in memcache.

The return value is True on success, False on RPC or server error.

=cut

sub flush_all{
    my $self = shift;

    my $request = AppEngine::Service::Memcache::MemcacheFlushRequest->new();
    my $response = AppEngine::Service::Memcache::MemcacheFlushResponse->new();
    _do_req('memcache', 'FlushAll', $request, $response) or return undef;
    return 1;
}

=pod

=head2 $stats = $memcache->get_stats()

Gets memcache statistics for this application. All of these statistics may reset due to various transient conditions. They provide the best information available at the time of being called.

The return value is a dictionary mapping statistic names to associated values. 
Statistics and their associated meanings:

=over

=item hits

Number of cache get requests resulting in a cache hit.

=item misses

Number of cache get requests resulting in a cache miss.

=item byte_hits

Sum of bytes transferred on get requests. Rolls over to zero on overflow.

=item items

Number of key/value pairs in the cache.

=item bytes

Total size of all items in the cache.

=item oldest_item_age

How long in seconds since the oldest item in the cache was accessed. Effectively, this indicates how long a new item will survive in the cache without being accessed. This is _not_ the amount of time that has elapsed since the item was created.

=back

=cut

sub get_stats {
    my $self = shift;

    my $request = AppEngine::Service::Memcache::MemcacheStatsRequest->new();
    my $response = AppEngine::Service::Memcache::MemcacheStatsResponse->new();
    _do_req('memcache', 'Stats', $request, $response)
        or return undef;

    return undef
        unless response.has_stats();

    my $stats = $response->stats();
    return {
      STAT_HITS => stats->hits(),
      STAT_MISSES => stats->misses(),
      STAT_BYTE_HITS => stats->byte_hits(),
      STAT_ITEMS => stats->items(),
      STAT_BYTES => stats->bytes(),
      STAT_OLDEST_ITEM_AGES => stats->oldest_item_age(),
    };
}

1;

=pod

=head1 SEE ALSO

Refer to the Google AppEngine SDK document for detailed descriptions of the classes,
constructors, and public methods of the google.appengine.api.memcache components.

=head1 AUTHOR, COPYRIGHT, AND LICENSE

Copyright(C) 2008, Dean Arnold, USA.

Dean Arnold L</mailto:darnold@presicient.com>

Permission is granted to use, modify, and redistribute this software under the terms of
either

a) the GNU General Public License as published by the Free Software Foundation; either version 1, 
or (at your option) any later version, or

b) the "Artistic License".

Google(R) is a registered trademark of Google, Inc.

=cut

