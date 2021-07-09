package Model::Request;

use header;
use Moose;
use Crypt::Misc qw(random_v4uuid);
use Types;

with 'Model';

use constant {
	STATUS_AWAITING => 'awaiting',
	STATUS_COMPLETE => 'complete',
	STATUS_TIMEOUT => 'timeout',
};

has 'id' => (
	is => 'ro',
	isa => Types::Uuid,
	default => sub { random_v4uuid },
);

has 'account_id' => (
	is => 'ro',
	isa => Types::Uuid,
	required => 1,
);

has 'amount' => (
	is => 'ro',
	isa => Types::PositiveInt,
	required => 1,
);

has 'derivation_index' => (
	is => 'ro',
	isa => Types::PositiveOrZeroInt,
);

has 'status' => (
	is => 'ro',
	isa => Types::Str,
	default => sub { STATUS_AWAITING },
);

has 'ts' => (
	is => 'ro',
	isa => Types::DateTime,
	coerce => 1,
	default => sub { time },
);

sub is_awaiting ($self)
{
	return $self->status eq STATUS_AWAITING;
}

sub is_complete ($self)
{
	return $self->status eq STATUS_COMPLETE;
}

__PACKAGE__->_register;
