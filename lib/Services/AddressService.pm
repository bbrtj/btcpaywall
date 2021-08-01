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

sub get_address_blockchain_info ($self, $request, $compat)
{
	my $address = $self->get_address($required, $compat);

	return Object::Sub->new({
		is_complete => sub {
			$self->node->check_payment($address, $request->amount);
		},
		is_correct => sub {
			$self->node->check_incorrect_payment($address, $request->amount);
		},
		is_pending => sub {
			$self->node->check_unconfirmed_payment($address, $request->amount);
		},
	});
}
