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
	STATUS_INVALID => 'invalid',
};

has 'id' => (
	is => 'ro',
	isa => Types::Uuid,
	default => sub { random_v4uuid },
);

has 'amount' => (
	is => 'ro',
	isa => Types::PositiveInt,
	required => 1,
);

has 'derivation_index' => (
	is => 'ro',
	isa => Types::PositiveOrZeroInt,
	required => 1,
);

has 'status' => (
	is => 'ro',
	isa => Types::PositiveInt,
	default => sub { STATUS_AWAITING },
);

has 'ts' => (
	is => 'ro',
	isa => Types::DateTime,
	default => sub { time },
);

__PACKAGE__->_register;
