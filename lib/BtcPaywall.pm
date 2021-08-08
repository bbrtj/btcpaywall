package BtcPaywall;

use Mojo::Base 'Mojolicious';
use Mojo::Log;
use Mojo::File qw(curfile);
use DI;

use header;

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
	my $env = DI->get('env');
	$self->secrets($env->getenv('APP_SECRETS'));
	$self->mode($env->getenv('APP_MODE'));

	my $log = Mojo::Log->new(
		path => curfile->dirname->sibling('logs')->child('application.log'),
		level => 'error',
	);
	$self->log($log);
}

sub load_commands ($self)
{
	push $self->commands->namespaces->@*, "BtcPaywall::Command";
}

sub load_routes ($self)
{
	my $r = $self->routes;

	$r->post('/request/new')->to('requests#create');
	$r->get('/paywall/compat/:id')->to('main#paywall_compat');
	$r->get('/paywall/:id')->to('main#paywall');

}

sub load_models ($self)
{
	require Model::Request;
	require Model::Account;
}

