package BtcPaywall::Command::autoresolve;

use Mojo::Base 'Mojolicious::Command';
use DI;

use header;

has description => 'resolve requests automatically (meant to be a cron action)';

# Usage message from SYNOPSIS
has usage => sub ($self) { $self->extract_usage };

sub run ($self, @args)
{
	my $requests = DI->get('request_watcher')->resolve;

	say "$requests requests were checked";
}

__END__
=head1 SYNOPSIS

	Usage: APPLICATION autoresolve
