package DatabaseTest;

use header;
use Test::DB;
use Mojo::Pg;
use DI;
use Component::DB;

sub test ($class, $sub)
{
	my $env = DI->get('env');
	my $testdb = Test::DB->new;

	$ENV{TESTDB_DATABASE} = 'postgres';
	my $cloned = $testdb->clone(
		hostname => $env->getenv('DB_HOST'),
		hostport => $env->getenv('DB_PORT'),
		username => $env->getenv('DB_USER'),
		password => $env->getenv('DB_PASS'),
		template => $env->getenv('DB_DATABASE'),
	);

	die 'database clone error' unless defined $cloned;

	try {
		DI->forget('db');

		my $pg = Mojo::Pg->new->dsn($cloned->dsn)
			->username($ENV{DB_USERNAME})
			->password($ENV{DB_PASSWORD});

		my $db = Component::DB->new(env => $env, dbh => $pg);
		DI->set('db', $db);

		$sub->();
	}
	catch ($e) {
		require Test::More;
		Test::More::fail("fatal error during database testing: $e");
	}

	# finally
	DI->get('db')->dbh->db->disconnect;
	$cloned->destroy;
}

1;
