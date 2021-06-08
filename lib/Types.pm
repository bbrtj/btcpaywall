package Types;

use header;
use Type::Libraries;
use Type::Tiny;
use Types::Standard qw(Num);
use Types::DateTime qw(DateTime Format);
use Types::XSD::Lite qw(Base64Binary);

Type::Libraries->setup_class(
	__PACKAGE__,
	qw(
		Types::Standard
		Types::Common::Numeric
		Types::Common::String
		Types::TypeTiny
		Types::UUID
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

__PACKAGE__->add_type(Base64Binary);
