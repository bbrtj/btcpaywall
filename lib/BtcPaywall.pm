package BtcPaywall;

use header;
use Mojo::Base 'Mojolicious';
use Mojo::Pg;
use Mojo::Log;
use Mojo::File qw(curfile);
use Schema;
use DI;
use Component::MasterKey;
use Dotenv -load;

# This method will run once at server start
sub startup ($self)
{
	$self->configure;
	$self->load_commands;
	$self->load_routes;
	$self->load_models;
}

sub configure ($self)
{
	my $config = $self->plugin('Config');

	# Configure the application
	$self->mode($config->{mode} // "development");
	$self->secrets($config->{secrets});

	if ($self->mode eq 'deployment') {
		my $log = Mojo::Log->new(
			path => curfile->dirname->sibling('logs')->child('application.log'),
			level => 'error',
		);
		$self->log($log);
	}

	DI->set('db',
		Mojo::Pg->new($ENV{DB_CONNECTION})
			->username($ENV{DB_USER})
			->password($ENV{DB_PASS})
	);

	DI->set('dbc',
		Schema->connect(sub { DI->get('db')->db->dbh })
	);

	$self->helper(
		db => sub { state $pg = DI->get('db') }
	);

	$self->helper(
		dbc => sub { state $schema = DI->get('dbc') }
	);

	Component::MasterKey->bootstrap($config->{master_key});
}

sub load_commands ($self)
{
	push $self->commands->namespaces->@*, "BtcPaywall::Command";
}

sub load_routes ($self)
{
	my $r = $self->routes;

	$r->post('/request/new')->to('requests#create');
	$r->get('/paywall/compat/:uuid')->to('main#paywall_compat');
	$r->get('/paywall/:uuid')->to('main#paywall');

}

sub load_models ($self)
{
	require Model::Request;
	require Model::Account;
}

