use header -noclean;
use Test::More;
use Mock::Sub;
use Object::Sub;
use Model::Request;
use Crypt::Misc qw(random_v4uuid);
use DateTime;
use DI;

my $watcher = DI->get('request_watcher');

my $chain_complete = 0;
my $chain_incorrect = 0;
my $chain_pending = 0;
my $chain_state = Object::Sub->new({
	is_complete => sub { $chain_complete },
	is_incorrect => sub { $chain_incorrect },
	is_pending => sub { $chain_pending },
});

my $model = Model::Request->dummy->new;

my $mock = Mock::Sub->new;
my @mock_subs = (
	$mock->mock('Service::Address::get_request_blockchain_info'),
	$mock->mock('Service::Callback::run_callback'),
	$mock->mock('Repository::Request::find'),
	$mock->mock('Repository::Request::save'),
);
my ($chain_info_mock, $run_callback_mock, $request_find_mock, $request_save_mock) = @mock_subs;

sub setup_mocks
{
	$_->reset for @mock_subs;

	$chain_info_mock->return_value($chain_state);
	$run_callback_mock->return_value(1);
	$request_find_mock->return_value([$model]);
	$request_save_mock->return_value(1);
}

subtest 'no blockchain change' => sub {
	setup_mocks;
	$model->set_status(Model::Request->STATUS_AWAITING);
	$watcher->resolve;

	ok $request_find_mock->called, 'database queried ok';
	ok $chain_info_mock->called, 'node queried ok';
	ok !$run_callback_mock->called, 'callback not called ok';
	ok !$request_save_mock->called, 'model not saved ok';
	is $model->status, Model::Request->STATUS_AWAITING, 'model status ok';
};


subtest 'blockchain pending' => sub {
	setup_mocks;
	$model->set_status(Model::Request->STATUS_AWAITING);
	$chain_pending = 1;
	$watcher->resolve;

	ok $request_find_mock->called, 'database queried ok';
	ok $chain_info_mock->called, 'node queried ok';
	ok !$run_callback_mock->called, 'callback not called ok';
	ok $request_save_mock->called, 'model saved ok';
	is $model->status, Model::Request->STATUS_PENDING, 'model status ok';
};

subtest 'blockchain complete' => sub {
	setup_mocks;
	$model->set_status(Model::Request->STATUS_AWAITING);
	$chain_pending = 1;
	$chain_complete = 1;
	$watcher->resolve;

	ok $request_find_mock->called, 'database queried ok';
	ok $chain_info_mock->called, 'node queried ok';
	ok $run_callback_mock->called, 'callback called ok';
	ok $request_save_mock->called, 'model saved ok';
	is $model->status, Model::Request->STATUS_COMPLETE, 'model status ok';
};

subtest 'callback failed' => sub {
	setup_mocks;
	$model->set_status(Model::Request->STATUS_PENDING);
	$chain_pending = 1;
	$chain_complete = 1;
	$run_callback_mock->return_value(0);
	$watcher->resolve;

	ok $request_find_mock->called, 'database queried ok';
	ok $chain_info_mock->called, 'node queried ok';
	ok $run_callback_mock->called, 'callback called ok';
	ok $request_save_mock->called, 'model saved ok';
	is $model->status, Model::Request->STATUS_CALLBACK_FAILED, 'model status ok';

	setup_mocks;
	$watcher->resolve;
	ok $request_find_mock->called, 'database queried ok';
	ok !$chain_info_mock->called, 'node not queried ok';
	ok $run_callback_mock->called, 'callback called ok';
	ok $request_save_mock->called, 'model saved ok';
	is $model->status, Model::Request->STATUS_COMPLETE, 'model status ok';
};

subtest 'timeout' => sub {
	setup_mocks;
	$model->set_ts(DateTime->now->subtract(seconds => 2 * Model::Request->TTL));
	$chain_pending = 1;
	$chain_complete = 0;
	$watcher->resolve;

	ok $request_find_mock->called, 'database queried ok';
	ok !$chain_info_mock->called, 'node not queried ok';
	ok !$run_callback_mock->called, 'callback not called ok';
	ok $request_save_mock->called, 'model saved ok';
	is $model->status, Model::Request->STATUS_TIMEOUT, 'model status ok';
};


done_testing;

