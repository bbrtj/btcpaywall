package Service::Callback;

use Moo;
use Types;
use Crypt::Digest::SHA256 qw(sha256_hex);
use Mojo::UserAgent;

use header;

sub run_callback ($self, $request_unit)
{
	my $uri = $request_unit->account->callback_uri;

	my $body = {
		account_id => $request_unit->account->id,
		request_id => $request_unit->request->id,
		ts => time,
	};

	$self->generate_hash($body, $request_unit->account->secret);

	my $ua = Mojo::UserAgent->new;
	my $tx = $ua->post($uri => json => $body);
	return $tx->res->is_success;
}

sub generate_hash ($self, $body, $secret)
{
	$body->{hash} = sha256_hex(
		join '//',
		$body->{account_id},
		$body->{request_id},
		$body->{ts},
		$secret,
	);
}
