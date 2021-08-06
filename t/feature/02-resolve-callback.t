use header -noclean;
use Test::More;
use Test::Mojo;
use Mock::Sub;
use Object::Sub;
use Mojo::Server::Daemon;
use Mojo::IOLoop;
use Test::TCP;

use Model::Account;
use Model::Request;
use DI;

use lib 't/lib';
use DatabaseTest;
use CallbackServer;
use Service::Address;

my $chain_state = Object::Sub->new(
	{
		is_complete => sub { 1 },
		is_incorrect => sub { 0 },
		is_pending => sub { 1 },
	}
);

my $mock = Mock::Sub->new;
my $blockchain_info = $mock->mock('Service::Address::get_request_blockchain_info', return_value => $chain_state);
my $secret = 'ahrchOEHUdATUdEuNOUhurAUdjqkqbA';

my $server = Test::TCP->new(
	code => sub ($port) {
		my $callback_app = CallbackServer->new($secret);
		my $callback_server = Mojo::Server::Daemon->new(listen => ["http://*:$port"])->app($callback_app)->start;
		Mojo::IOLoop->start;
	},
);

DatabaseTest->test(
	sub {
		my $port = $server->port;
		my $acc = Model::Account->new(
			callback_uri => "127.0.0.1:$port/cb",
			secret => $secret,
		);

		my $req = Model::Request->new(
			account_id => $acc->id,
			amount => 999,
			ts => time - 50,
		);

		DI->get('accounts_repository')->save($acc);
		for (DI->get('requests_repository')) {
			$_->save($req);
			$_->add_items($req, ['test item']);
		}

		DI->get('request_watcher')->resolve;

		$req = DI->get('requests_repository')->get_by_id($req->id);
		is $req->status, Model::Request->STATUS_COMPLETE, 'request complete ok';
	}
);

undef $server;

done_testing;

