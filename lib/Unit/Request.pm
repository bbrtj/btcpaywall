package Unit::Request;

use Moo;
use Types;

use header;

has 'request' => (
	is => 'ro',
	isa => Types::InstanceOf['Model::Request'],
	required => 1,
);

has 'account' => (
	is => 'ro',
	isa => Types::InstanceOf['Model::Account'],
	required => 1,
);

has 'items' => (
	is => 'ro',
	isa => Types::ArrayRef[Types::Str],
	required => 1,
);
