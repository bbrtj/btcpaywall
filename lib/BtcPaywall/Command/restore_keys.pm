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

	say 'Note: not all of following addresses contain funds.';

	for my $mkey (DI->get('master_key'), DI->get('master_key_fixed')) {
		for my $unit ($requests->@*) {
			say $mkey->reveal_key($unit->account, $unit->request);
		}
	}

	for my $mkey (DI->get('master_key_hd')) {
		for my $unit ($requests->@*) {
			say $mkey->reveal_key($unit->account, $unit->request, 0);
			say $mkey->reveal_key($unit->account, $unit->request, 1);
		}
	}
}

__END__
=head1 SYNOPSIS

	Usage: APPLICATION restore-keys
