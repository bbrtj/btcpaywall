package BtcPaywall::Command::add_client;

use Mojo::Base 'Mojolicious::Command';
use DI;
use Model::Account;

use header;

has description => 'add a new API client';

# Usage message from SYNOPSIS
has usage => sub ($self) { $self->extract_usage };

sub run ($self, $name, $uri, @args)
{
	my $model = Model::Account->new(
		name => $name,
		callback_uri => $uri
	);
	DI->get('accounts_repository')->save($model);

	say 'Client ID: ' . $model->id;
	say 'Client secret: ' . $model->secret;
}

__END__
=head1 SYNOPSIS

	Usage: APPLICATION add-client [NAME] [CALLBACK URI]
