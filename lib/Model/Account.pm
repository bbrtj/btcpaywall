package Model::Account;

use Moose;
use Types;
use String::Random;
use Data::Entropy::Algorithms qw(rand);

use header;

with 'Model';

has 'id' => (
	is => 'ro',
	isa => Types::ULID,
	coerce => 1,
	default => sub { undef },
);

has 'name' => (
	is => 'ro',
	isa => Types::Str,
	required => 1,
);

has 'account_index' => (
	is => 'ro',
	isa => Types::PositiveOrZeroInt,
);

has 'callback_uri' => (
	is => 'ro',
	isa => Types::Str,
	required => 1,
);

has 'secret' => (
	is => 'ro',
	isa => Types::Str,
	default => sub {
		my $string_gen = String::Random->new(
			rand_gen => sub ($max) {
				return int rand $max;
			}
		);

		return $string_gen->randregex('\w{32}');
	}
);

__PACKAGE__->_register;
