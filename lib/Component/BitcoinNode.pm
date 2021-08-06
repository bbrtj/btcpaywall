package Component::BitcoinNode;

use Moo;
use Bitcoin::RPC::Client;
use Types;
use Mojo::JSON qw(true false);
use List::Util qw(sum0);

use header;

use constant WALLET_NAME => 'paywall_wallet.dat';
use constant BLOCKS_NOLIMIT => 9999999;
use constant SATOSHI_PER_BITCOIN => 1_0000_0000;

with 'Component::Role::HasEnv';

has 'rpc' => (
	is => 'ro',
	isa => Types::InstanceOf ['Bitcoin::RPC::Client'],
	default => sub ($self) {
		Bitcoin::RPC::Client->new(
			user => $self->env->getenv('RPC_USERNAME'),
			password => $self->env->getenv('RPC_PASSWORD'),
			port => $self->env->getenv('RPC_PORT'),
			host => $self->env->getenv('RPC_HOST'),
		);
	},
);

sub _get_balance ($self, $address, $blocks)
{
	my $txs = $self->rpc->listunspent($blocks, BLOCKS_NOLIMIT, [$address]);

	return sum0 map { $_->{amount} * SATOSHI_PER_BITCOIN }
	$txs->@*;
}

sub configure ($self)
{
	$self->rpc->createwallet(WALLET_NAME);
	$self->rpc->unloadwallet(WALLET_NAME);
	$self->rpc->loadwallet(WALLET_NAME, true);
	return;
}

sub watch_address ($self, $address)
{
	$self->rpc->importaddress($address, '', false);
	return;
}

sub check_unconfirmed_payment ($self, $address, $amount)
{
	return $self->check_payment($address, $amount, 0);
}

sub check_payment ($self, $address, $amount, $blocks = 3)
{
	my $balance = $self->_get_balance($address, $blocks);
	return $balance >= $amount;
}

sub check_incorrect_payment ($self, $address, $amount)
{
	my $balance = $self->_get_balance($address, 0);

	return $balance > 0 && $balance < $amount;
}

