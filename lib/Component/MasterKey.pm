package Component::MasterKey;

use Bitcoin::Crypto qw(btc_extprv);
use Moo;
use Mojo::File qw(path);

use header;

with 'Component::Role::HasEnv';

has '_master_key' => (
	is => 'ro',
	isa => Types::InstanceOf ['Bitcoin::Crypto::Key::ExtPrivate'],
	lazy => 1,
	default => sub ($self) {
		my $key = path($self->env->getenv('MASTER_KEY'));
		croak 'invalid MASTER_KEY path setting'
			unless -f $key;
		my $ext_private = btc_extprv->from_mnemonic($key->slurp);
		$ext_private->set_network($self->env->getenv('CRYPTO_NETWORK'));
		return $ext_private;
	},
	init_arg => undef,
);

sub reveal_key ($self, $account, $request)
{
	return $self->_master_key->derive_key_bip44(
		account => $account->account_index,
		index => $request->derivation_index,
	)->get_basic_key->to_wif;
}

sub get_payment_address ($self, $account, $request, $compat = 0)
{
	my $extprv = $self->_master_key->derive_key_bip44(
		account => $account->account_index,
		index => $request->derivation_index,
	);

	my $public = $extprv->get_basic_key->get_public_key;
	return $compat
		? $public->get_compat_address
		: $public->get_segwit_address
		;
}

