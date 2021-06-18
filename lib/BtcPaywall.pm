package BtcPaywall;

use header;
use Mojo::Base 'Mojolicious';
use Mojo::Pg;
use Schema;
use BtcPaywall::Component::MasterKey;
use DI;

use Model::Request;

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
	# Load configuration from config file
	my $config = $self->plugin('Config');
	my $config_local = $self->plugin('Config', ext => "conf.local");
	$config = {%$config, %$config_local};

	# Configure the application
	$self->mode($config->{mode} // "development");
	$self->secrets($config->{secrets});

	$self->helper(
		db => sub {
			state $pg = Mojo::Pg->new($config->{db}{connection})
				->username($config->{db}{user})
				->password($config->{db}{pass});
		}
	);

	$self->helper(
		dbc => sub ($self) {
			state $schema = Schema->connect(sub { $self->db->db->dbh });
		}
	);

	DI->set('dbc', $self->dbc);

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
}

