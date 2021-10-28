package BtcPaywall::Command::restore_keys;

use Mojo::Base 'Mojolicious::Command';
use DI;
use Model::Request;

use header;

has description => 'reveal private keys that are containing funds';

# Usage message from SYNOPSIS
has usage => sub ($self) { $self->extract_usage };

sub run ($self)
{
	my $requests = DI->get('requests_unit_repository')->find(
		status => [
			Model::Request->STATUS_COMPLETE,
			Model::Request->STATUS_CALLBACK_FAILED,
		]
	);

	my $mkey = DI->get('master_key');
	for my $unit ($requests->@*) {
		say $mkey->reveal_key($unit->account, $unit->request);
	}

}

__END__
=head1 SYNOPSIS

	Usage: APPLICATION restore-keys
