package BtcPaywall::Controller::Purpose::API;

use Mojo::Base 'Mojolicious::Controller';
use Mojo::JSON qw(false true);

use header;

sub respond ($self, $status, $data)
{
	my %ret = (
		status => $status ? true : false,
		data => $data,
	);

	return $self->render(json => \%ret);
}

