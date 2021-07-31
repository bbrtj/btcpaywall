package BtcPaywall::Command::generate_master_key;

use Mojo::Base 'Mojolicious::Command';
use Bitcoin::Crypto qw(btc_extprv);
use Mojo::File qw(curfile);

use header;

has description => 'generate a new master key';

# Usage message from SYNOPSIS
has usage => sub ($self) { $self->extract_usage };

sub run ($self, @args)
{
	my $path = curfile->dirname->dirname->dirname->sibling('master.key');

	die 'key already exists'
		if -e $path;

	my $mnemonic = btc_extprv->generate_mnemonic(256);
	$path->spurt($mnemonic);

	say 'Mnemonic generated. Make sure to back it up!';
}

__END__
=head1 SYNOPSIS

	Usage: APPLICATION generate-master-key
