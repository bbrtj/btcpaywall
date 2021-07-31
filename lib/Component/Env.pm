package Component::Env;

use header;
use Types;
use Moo;
use Dotenv -load;

has 'rawenv' => (
	is => 'ro',
	isa => Types::HashRef,
	default => sub {
		\%ENV
	},
);

# adjust any envvars here
sub BUILD ($self, @)
{
	$self->rawenv->{CRYPTO_NETWORK} //= 'bitcoin';
}

sub getenv :lvalue ($self, $name)
{
	my $rawenv = $self->rawenv;

	croak "unknown environmental variable $name"
		unless exists $rawenv->{$name};

	return $rawenv->{$name};
}
