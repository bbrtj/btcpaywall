package HashTest;

use header;
use Crypt::Digest::SHA256 qw(sha256_hex);

sub create_hash ($self, @data)
{
	return sha256_hex(join '//', @data);
}

sub serialize ($self, $data, $secret)
{
	return (
		$data->{account_id},
		$data->{amount},
		$data->{items}->@*,
		$data->{ts},
		$secret
	);
}
