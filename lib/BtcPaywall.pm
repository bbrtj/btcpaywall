package BtcPaywall;

use header;
use Mojo::Base 'Mojolicious';
use Mojo::Pg;
use Schema;
use BtcPaywall::Component::MasterKey;
use DI;
use Dotenv -load;

# This method will run once at server start
sub startup ($self)
{
	load_config($self);
	load_commands($self);
	load_routes($self);
	load_models($self);
}

sub load_config ($self)
{
	my $config = $self->plugin('Config');

	# Configure the application
	$self->mode($config->{mode} // "development");
	$self->secrets($config->{secrets});

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

	BtcPaywall::Component::MasterKey::bootstrap($config->{master_key});
}

sub load_commands ($self)
{
	push $self->commands->namespaces->@*, "BtcPaywall::Command";
}

sub load_routes ($self)
{
	my $r = $self->routes;

	# Normal route to controller
	$r->post('/request/new')->to('requests#create');

}

sub load_models ($self)
{
	require Model::Request;
	require Model::Account;
}

