package Services::RequestWatcher;

use Moo;
use Types;
use Model::Request;
use Crypt::Digest::SHA256 qw(sha256_hex);
use Mojo::UserAgent;

use header;

has 'address_service' => (
	is => 'ro',
	isa => Types::InstanceOf['Services::AddressService'],
	required => 1,
);

has 'request_repo' => (
	is => 'ro',
	isa => Types::InstanceOf['Repository::Request'],
	required => 1,
);

has 'account_repo' => (
	is => 'ro',
	isa => Types::InstanceOf['Repository::Account'],
	required => 1,
);

sub get_unresolved_requests ($self)
{
	$self->request_repo->find(
		status => [
			Model::Request->STATUS_AWAITING,
			Model::Request->STATUS_PENDING,
			Model::Request->STATUS_CALLBACK_FAILED,
		]
	);
}

sub run_callback ($self, $request)
{
	my $account = $self->account_repo->get_by_id($request->account_id);
	my $uri = $account->callback_uri;
	my $timestamp = time;

	my $hash = sha256_hex(
		$account->id,
		$request->id,
		$timestamp,
		$account->secret
	);

	my $body = {
		account_id => $account->id,
		request_id => $request->id,
		ts => $timestamp,
		hash => $hash,
	};

	my $ua = Mojo::UserAgent->new;
	my $tx = $ua->post($uri => json => $body);
	return $tx->res->is_success;
}

sub resolve ($self)
{
	my $unresolved = $self->get_unresolved_requests;

	for my $request ($unresolved->@*) {

		if ($request->ts + Model::Request->TTL < time) {
			$request->set_status(Model::Request->STATUS_TIMEOUT);
		}
		else {
			my $info = $self->address_service->get_request_blockchain_info($request);

			# TODO: handle incorrect amount
			if (($request->is_pending || $request->is_awaiting) && $info->is_complete) {
				if ($self->run_callback($request)) {
					$request->set_status(Model::Request->STATUS_COMPLETE);
				}
				else {
					$request->set_status(Model::Request->STATUS_CALLBACK_FAILED);
				}
			}
			if ($request->is_awaiting && $info->is_pending) {
				$request->set_status(Model::Request->STATUS_PENDING);
			}
		}
	}
	return;
}
