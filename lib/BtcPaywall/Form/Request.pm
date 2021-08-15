package BtcPaywall::Form::Request;

use Form::Tiny -strict;
use Types;
use DI;
use Crypt::Digest::SHA256 qw(sha256_hex);
use Model::Request;

use header;

use constant _ts_treshold => 300;    # 5 minutes
use constant MINIMUM_AMOUNT => 5460;

has 'repository' => (
	is => 'ro',
	default => sub { DI->get('accounts_repository') },
);

has 'account' => (
	is => 'rw',
	isa => Types::Maybe [Types::InstanceOf ['Model::Account']],
);

form_field 'account_id' => (
	type => Types::ULID,
	required => 1,
);

form_field 'amount' => (
	type => Types::PositiveInt->where(q{ $_ >= } . MINIMUM_AMOUNT),
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

	try {
		$self->account($self->repository->get_by_id($data->{account_id}));
	}
	catch ($e) {
		$self->add_error(account_id => 'unknown account id');
		return;
	}

	$self->add_error(hash => 'incorrect hash')
		unless $data->{hash} eq $self->create_hash($data, $self->account->secret);
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

sub to_unit ($self)
{
	return Unit::Request->new(
		request => $self->to_model,
		items => $self->fields->{items},
		account => $self->account,
	);
}
