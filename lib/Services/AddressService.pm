package Services::AddressService;

use Moo;
use Types;
use Object::Sub;

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

has 'node' => (
	is => 'ro',
	isa => Types::InstanceOf['Component::BitcoinNode'],
	required => 1,
);

sub get_address ($self, $request, $compat)
{
	my $account = $self->account_repo->get_by_id($request->account_id);
	# This may fail randomly, but the probability of failing is lower than 1 / 2^127, so we don't care
	my $address = $self->master_key->get_payment_address($account, $request, $compat);

	return $address;
}

sub get_request_blockchain_info ($self, $request)
{
	my $address = $self->get_address($request, 0);
	my $address_compat = $self->get_address($request, 1);

	return Object::Sub->new({
		is_complete => sub {
			$self->node->check_payment($address, $request->amount)
				&& $self->node->check_payment($address_compat, $request->amount)
		},
		is_incorrect => sub {
			$self->node->check_incorrect_payment($address, $request->amount)
				&& $self->node->check_incorrect_payment($address_compat, $request->amount)
		},
		is_pending => sub {
			$self->node->check_unconfirmed_payment($address, $request->amount)
				&& $self->node->check_unconfirmed_payment($address_compat, $request->amount)
		},
	});
}
