package BtcPaywall::Controller::Main;

use header;
use Mojo::Base 'BtcPaywall::Controller::Purpose::API';
use BtcPaywall::Form::Request;

sub create ($self)
{
	my $form = BtcPaywall::Form::Request->new;
	$form->set_input($self->req->json);

	if ($form->valid) {
		$form->fields; # TODO
	} else {
		$self->respond(0, $form->errors);
	}
}

