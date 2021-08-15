package Service::Address;

use Moo;
use Types;
use Object::Sub;

use header;

has 'master_key' => (
	is => 'ro',
	isa => Types::InstanceOf ['Component::MasterKey'],
	required => 1,
);

has 'node' => (
	is => 'ro',
	isa => Types::InstanceOf ['Component::BitcoinNode'],
	required => 1,
);

sub get_address ($self, $request_unit, $compat)
{
	# This may fail randomly, but the probability of failing is lower than 1 / 2^127, so we don't care
	my $address = $self->master_key->get_payment_address($request_unit->account, $request_unit->request, $compat);

	return $address;
}

sub get_request_blockchain_info ($self, $request_unit)
{
	my $address = $self->get_address($request_unit, 0);
	my $address_compat = $self->get_address($request_unit, 1);

	return Object::Sub->new(
		{
			is_complete => sub {
				$self->node->check_payment($address, $request_unit->request->amount)
					|| $self->node->check_payment($address_compat, $request_unit->request->amount);
			},
			is_incorrect => sub {
				$self->node->check_incorrect_payment($address, $request_unit->request->amount)
					|| $self->node->check_incorrect_payment($address_compat, $request_unit->request->amount);
			},
			is_pending => sub {
				$self->node->check_unconfirmed_payment($address, $request_unit->request->amount)
					|| $self->node->check_unconfirmed_payment($address_compat, $request_unit->request->amount);
			},
		}
	);
}
