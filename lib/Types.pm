package Types;

use Type::Libraries;
use Type::Tiny;
use Types::Standard qw(Num Undef);
use Types::Common::String qw(StrLength);
use Data::ULID;
use Types::DateTime qw(DateTime Format);

use header;

Type::Libraries->setup_class(
	__PACKAGE__,
	qw(
		Types::Standard
		Types::Common::Numeric
		Types::Common::String
		Types::TypeTiny
	),
);

my $DateTime = Type::Tiny->new(
	name => 'DateTime',
	parent => DateTime,
);

__PACKAGE__->add_type($DateTime)->coercion->add_type_coercions(
	Num, q{ Types::DateTime::DateTime->coerce($_) },
	Format ['Pg'],
)->freeze;

# TODO: reduced alphabet
my $ULID = Type::Tiny->new(
	name => 'ULID',
	parent => (StrLength[26])->where(q{ /\A[0-9a-zA-Z]+\z/ }),
);

__PACKAGE__->add_type($ULID)->coercion->add_type_coercions(
	Undef, q{ Data::ULID::ulid() },
)->freeze;

