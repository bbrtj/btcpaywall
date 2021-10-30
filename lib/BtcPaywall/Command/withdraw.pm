package BtcPaywall::Command::withdraw;

use Mojo::Base 'Mojolicious::Command';
use DI;

use header;

has description => 'Withdraw all available coins to an address';

# Usage message from SYNOPSIS
has usage => sub ($self) { $self->extract_usage };

sub run ($self, $address)
{
	my $requests = DI->get('requests_unit_repository')->find(
		status => [
			Model::Request->STATUS_COMPLETE,
			Model::Request->STATUS_CALLBACK_FAILED,
		]
	);

	my $node = DI->get('node');
	my $mkey = DI->get('master_key');
	for my $unit ($requests->@*) {
		$node->import_private_key($mkey->reveal_key($unit->account, $unit->request, 0));
		$node->import_private_key($mkey->reveal_key($unit->account, $unit->request, 1));
	}

	$node->withdraw($address);
	say 'Withdrawal complete';
}

__END__
=head1 SYNOPSIS

	Usage: APPLICATION withdraw [ADDRESS]
