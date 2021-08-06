package BtcPaywall::Form::Request;

use Form::Tiny -strict;
use Types;
use DI;
use Crypt::Digest::SHA256 qw(sha256_hex);
use Model::Request;

use header;

use constant _ts_treshold => 300;    # 5 minutes

has 'repository' => (
	is => 'ro',
	default => sub { DI->get('accounts_repository') },
);

form_field 'account_id' => (
	type => Types::Uuid,
	required => 1,
);

form_field 'amount' => (
	type => Types::PositiveInt,
	required => 1,
);

form_field 'items.*' => (
	type => Types::Str,
	required => 1,
);

form_field 'ts' => (
	type => Types::Str,
	required => 1,
);

form_field 'hash' => (
	type => Types::Str,
	required => 1,
);

form_hook cleanup => sub ($self, $data) {
	$self->add_error('items.*' => 'at least one item is required')
		if $data->{items}->@* == 0;

	$self->add_error(ts => 'timestamp timed out')
		if time < $data->{ts} || time - $data->{ts} > _ts_treshold;

	my $account = $self->repository->get_by_id($data->{account_id});

	$self->add_error(account_id => 'unknown account id')
		unless defined $account;

	$self->add_error(hash => 'incorrect hash')
		unless $data->{hash} eq $self->create_hash($data, $account->secret);
};

sub create_hash ($self, $data, $secret)
{
	return sha256_hex(
		join '//',
		$data->{account_id},
		$data->{amount},
		$data->{items}->@*,
		$data->{ts},
		$secret
	);
}

sub to_model ($self)
{
	return Model::Request->new($self->fields);
}
