use header -noclean;
use Test::More;
use Test::Mojo;

use Model::Account;
use DI;
use Types;

use lib 't/lib';
use DatabaseTest;
use HashTest;

DatabaseTest->test(
	sub {
		my $t = Test::Mojo->new('BtcPaywall', {mode => 'deployment'});

		my $acc = Model::Account->new(
			name => 'Test vendor',
			callback_uri => '127.0.0.1/test'
		);
		DI->get('accounts_repository')->save($acc);

		my $ts = time - 50;
		my $raw_items = ['test item', 'another item'];
		my %data = (
			account_id => $acc->id,
			amount => 9999,
			items => $raw_items,
			ts => $ts,
		);
		$data{hash} = HashTest->create_hash(HashTest->serialize(\%data, $acc->secret));

		$t->post_ok('/request/new' => json => \%data)
			->status_is(200)
			->json_is('/status' => 1);

		my $request_id = $t->tx->res->json('/data');
		my ($request, $items) = DI->get('requests_repository')->get_with_items($request_id);

		is $request->account_id, $acc->id, 'account ok';
		is $request->amount, 9999, 'amount ok';
		is $request->ts, Types::DateTime->coerce($ts), 'timestamp ok';

		is_deeply $items, $raw_items, 'items ok';

		$ts = time - 50;
		$raw_items = ['yet another item'];
		%data = (
			account_id => $acc->id,
			amount => 9998,
			items => $raw_items,
			ts => $ts,
		);
		$data{hash} = HashTest->create_hash(HashTest->serialize(\%data, $acc->secret));

		$t->post_ok('/request/new' => json => \%data)
			->status_is(200)
			->json_is('/status' => 1);
	}
);

done_testing;

