package Service::Callback;

use Moo;
use Types;
use Crypt::Digest::SHA256 qw(sha256_hex);
use Mojo::UserAgent;

use header;

has 'account_repo' => (
	is => 'ro',
	isa => Types::InstanceOf ['Repository::Account'],
	required => 1,
);

sub run_callback ($self, $request)
{
	my $account = $self->account_repo->get_by_id($request->account_id);
	my $uri = $account->callback_uri;

	my $body = {
		account_id => $account->id,
		request_id => $request->id,
		ts => time,
	};

	$self->generate_hash($body, $account->secret);

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
