package BtcPaywall::Command::configure_node;

use Mojo::Base 'Mojolicious::Command';
use DI;

use header;

has description => 'Configure the bitcoin node';

# Usage message from SYNOPSIS
has usage => sub ($self) { $self->extract_usage };

sub run ($self, @args)
{
	DI->get('node')->configure;

	say 'Node has been configured';
}

__END__
=head1 SYNOPSIS

	Usage: APPLICATION configure-node
