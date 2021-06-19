package DatabaseTest;

use header;
use Test::DB;
use Mojo::Pg;
use DI;
use Dotenv -load;

sub test ($class, $sub)
{
	my $testdb = Test::DB->new;

	$ENV{TESTDB_DATABASE} = 'postgres';
	my $cloned = $testdb->clone(
		hostname => $ENV{DB_HOST},
		hostport => $ENV{DB_PORT},
		username => $ENV{DB_USER},
		password => $ENV{DB_PASS},
		template => $ENV{DB_DATABASE},
	);

	die 'database clone error' unless defined $cloned;

	my $pg;
	try {
		my $pg = Mojo::Pg->new->dsn($cloned->dsn)
			->username($ENV{DB_USERNAME})
			->password($ENV{DB_PASSWORD});

		DI->set('db', $pg);

		$sub->();
	}
	catch ($e) {
		require Test::More;
		Test::More::fail("fatal error during database testing: $e");
	}

	# finally
	if (defined $pg) {
		$pg->db->disconnect;
	}
	$cloned->destroy;
}

1;
