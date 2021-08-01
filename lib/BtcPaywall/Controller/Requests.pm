package BtcPaywall::Controller::Requests;

use Mojo::Base 'BtcPaywall::Controller::Purpose::API';
use BtcPaywall::Form::Request;

use header;

sub create ($self)
{
	state $repo = DI->get('requests_repository');
	state $node = DI->get('node');
	state $address_service = DI->get('address_service');

	my $form = BtcPaywall::Form::Request->new;
	$form->set_input($self->req->json);

	if ($form->valid) {
		my $model = $form->to_model;
		$repo->save($model);
		$repo->add_items($model, $form->fields->{items});

		# watch both compat and segwit addresses
		$node->watch_address($address_service->get_address($model, 0));
		$node->watch_address($address_service->get_address($model, 1));

		$self->respond(1, $model->id);
	} else {
		$self->respond(0, $form->errors);
	}
}

