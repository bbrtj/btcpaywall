use header -noclean;
use Test::More;
use Object::Sub;
use BtcPaywall::Form::Request;
use Crypt::Digest::SHA256 qw(sha256_hex);
use Data::Dumper;

my $test_client = 'c397e34f-e686-4d6c-8912-d139eb377c1b';
my $test_secret = 'Uqn3USEcpttjin9Deqb4B8dFl291PUYi';
my $test_time = time;
my $repository_mock = Object::Sub->new({
	get_by_id => sub {
		Object::Sub->new({
			secret => sub { $test_secret },
		});
	},
});

sub create_hash (@data)
{
	return sha256_hex(join '//', @data);
}

my @data = (
	[
		1,
		{
			account_id => $test_client,
			amount => 500,
			items => ['some item'],
			ts => $test_time - 30,
			hash => create_hash($test_client, 500, 'some item', $test_time - 30, $test_secret)
		},
		'basic case ok'
	],
	[
		1,
		{
			account_id => $test_client,
			amount => 500,
			items => ['i1', 'i2'],
			ts => $test_time - 60,
			hash => create_hash($test_client, 500, 'i1', 'i2', $test_time - 60, $test_secret)
		},
		'two items are ok'
	],
	[
		0,
		{
			account_id => $test_client,
			amount => 500,
			items => ['some item'],
			ts => $test_time - 301,
			hash => create_hash($test_client, 500, 'some item', $test_time - 301, $test_secret)
		},
		'too old ok'
	],
	[
		0,
		{
			account_id => $test_client,
			amount => 500,
			items => ['some item'],
			ts => $test_time + 2,
			hash => create_hash($test_client, 500, 'some item', $test_time + 2, $test_secret)
		},
		'timestamp from the future ok'
	],
	[
		0,
		{
			account_id => $test_client,
			amount => 500,
			items => [],
			ts => $test_time - 30,
			hash => create_hash($test_client, 500, $test_time - 30, $test_secret)
		},
		'no items at all ok'
	],
	[
		0,
		{
			account_id => $test_client,
			amount => 500,
			items => ['some item'],
			ts => $test_time - 30,
			hash => create_hash($test_client, 500, 'some item', $test_time - 30, 'this-is-a-wrong-secret')
		},
		'wrong secret ok'
	],
	[
		0,
		{
			account_id => $test_client,
			amount => 0,
			items => ['some item'],
			ts => $test_time - 30,
			hash => create_hash($test_client, 0, 'some item', $test_time - 30, $test_secret)
		},
		'non-positive amount ok'
	],
);

my $form = BtcPaywall::Form::Request->new(repository => $repository_mock);

for my $case (@data)
{
	$form->set_input($case->[1]);
	is !!$form->valid, !!$case->[0], $case->[2];
	note Dumper $form->errors;
}

done_testing;
