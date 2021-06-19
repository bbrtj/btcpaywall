package BtcPaywall::Command::add_client;

use header;
use Mojo::Base 'Mojolicious::Command';
use DI;
use Model::Account;

has description => 'add a new API client';

# Usage message from SYNOPSIS
has usage => sub ($self) { $self->extract_usage };

sub run ($self, $uri, @args)
{
	my $model = Model::Account->new(
		callback_uri => $uri
	);
	DI->get('accounts_repository')->save($model);

	say 'Client ID: ' . $model->id;
	say 'Client secret: ' . $model->secret;
}

__END__
=head1 SYNOPSIS
	Usage: APPLICATION add_client [CALLBACK URI]
