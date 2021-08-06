package Component::Role::HasEnv;

use Types;
use Moo::Role;

use header;

has 'env' => (
	is => 'ro',
	isa => Types::InstanceOf ['Component::Env'],
	required => 1,
);
