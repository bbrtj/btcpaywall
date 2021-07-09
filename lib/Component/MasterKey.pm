package Component::MasterKey;

use header;
use Bitcoin::Crypto qw(btc_extprv);

# as private as it gets
my $master_key = undef;

sub bootstrap ($self, $key)
{
	if (defined $key) {
		$master_key = btc_extprv->from_mnemonic($key);
		$master_key->set_network($ENV{NETWORK} // 'bitcoin');
	}
	return;
}

sub _check
{
	die "cannot complete cryptographic action: no master key" unless defined $master_key;
}

sub get_payment_address ($self, $account, $request, $compat = 0)
{
	_check;
	my $extprv = $master_key->derive_key_bip44(
		account => $account->account_index,
		index => $request->derivation_index,
	);

	my $public = $extprv->get_basic_key->get_public_key;
	return $compat
		? $public->get_compat_address
		: $public->get_segwit_address
	;
}

