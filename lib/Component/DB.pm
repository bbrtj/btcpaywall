package Component::DB;

use Types;
use Moo;
use Mojo::Pg;
use Schema;

use header;

with 'Component::Role::HasEnv';

has 'dbh' => (
	is => 'ro',
	isa => Types::InstanceOf ['Mojo::Pg'],
	lazy => 1,
	default => sub ($self) {
		Mojo::Pg->new($self->env->getenv('DB_CONNECTION'))
			->username($self->env->getenv('DB_USER'))
			->password($self->env->getenv('DB_PASS'));
	},
);

has 'dbc' => (
	is => 'ro',
	isa => Types::InstanceOf ['Schema'],
	lazy => 1,
	default => sub ($self) {
		Schema->connect(sub { $self->dbh->db->dbh });
	},
);
