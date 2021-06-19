package BtcPaywall::Component::MasterKey;

use header;
use Exporter qw(import);
use Bitcoin::Crypto qw(btc_extprv);

use constant PATH => "m/1337'";

our @EXPORT = qw(
	sys_sign
	sys_verify
);

my $signature_key = undef;

sub bootstrap ($self, $key)
{
	if (defined $key) {
		$signature_key = btc_extprv->from_mnemonic($key)->derive_key(PATH)->get_basic_key;
	}
	return;
}

sub _check
{
	die "cannot complete cryptographic action: no master key" unless defined $signature_key;
}

sub sys_sign ($message)
{
	_check;
	return $signature_key->sign_message($message);
}

sub sys_verify ($message, $signature)
{
	_check;
	return $signature_key->verify_message($message, $signature);
}

