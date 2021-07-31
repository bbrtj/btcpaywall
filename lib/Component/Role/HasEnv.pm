package Component::Role::HasEnv;

use header;
use Types;
use Moo::Role;

has 'env' => (
	is => 'ro',
	isa => Types::InstanceOf['Component::Env'],
	required => 1,
);
