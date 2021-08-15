package BtcPaywall::Controller::Requests;

use Mojo::Base 'BtcPaywall::Controller::Purpose::API';
use BtcPaywall::Form::Request;
use Unit::Request;

use header;

sub create ($self)
{
	state $repo = DI->get('requests_repository');
	state $node = DI->get('node');
	state $address_service = DI->get('address_service');

	my $form = BtcPaywall::Form::Request->new;
	$form->set_input($self->req->json);

	if ($form->valid) {
		my $unit = $form->to_unit;

		$repo->save($unit->request);
		$repo->add_items($unit->request, $unit->items);

		# watch both compat and segwit addresses
		$node->watch_address($address_service->get_address($unit, 0));
		$node->watch_address($address_service->get_address($unit, 1));

		$self->respond(1, $unit->request->id);
	}
	else {
		$self->respond(0, $form->errors);
	}
}

