package CallbackServer;

use Mojo::Base 'Mojolicious';
use HashTest;

use header;

my $secret;

sub new ($self, $param_secret, @params)
{
	$secret = $param_secret;
	return $self->SUPER::new(@params);
}

sub startup ($self)
{
	$self->routes->post('/cb')->to(cb => sub ($c) {
		my $data = $c->req->json;
		if (HashTest->create_hash(HashTest->serialize_callback($data, $secret)) eq $data->{hash}) {
			$c->rendered(200);
		} else {
			$c->rendered(406);
		}
	});
}
