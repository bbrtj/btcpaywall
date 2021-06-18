package BtcPaywall::Controller::Main;

use header;
use Mojo::Base 'BtcPaywall::Controller::Purpose::API';
use BtcPaywall::Form::Request;

sub create ($self)
{
	my $form = BtcPaywall::Form::Request->new;
	$form->set_input($self->req->json);

	if ($form->valid) {
		my $model = $form->to_model;
		my $repo = DI->get('requests_repository');
		$repo->save($model);
		$repo->add_items($model, $form->fields->{items});
		$self->respond(1, $model->id);
	} else {
		$self->respond(0, $form->errors);
	}
}

