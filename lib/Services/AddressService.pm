package Services::AddressService;

use Moo;
use Types;

use header;

has 'account_repo' => (
	is => 'ro',
	isa => Types::InstanceOf['Repository::Account'],
	required => 1,
);

has 'master_key' => (
	is => 'ro',
	isa => Types::InstanceOf['Component::MasterKey'],
	required => 1,
);

sub get_address ($self, $request, $compat)
{
	my $account = $self->account_repo->get_by_id($request->account_id);
	# This may fail randomly, but the probability of failing is lower than 1 / 2^127, so we don't care
	my $address = $self->master_key->get_payment_address($account, $request, $compat);

	return $address;
}
