package BtcPaywall::Controller::Main;

use Mojo::Base 'Mojolicious::Controller';
use DI;
use Image::PNG::QRCode 'qrpng';
use MIME::Base64;
use Helpers;

use header;

sub paywall ($self, $compat = 0)
{
	state $repo = DI->get('requests_unit_repository');
	state $address_service = DI->get('address_service');
	state $watcher = DI->get('request_watcher');

	my $id = $self->param('id');

	my $unit;
	try {
		$unit = $repo->get_by_id($id);
	}
	catch ($e) {
		$self->reply->not_found;
		return;
	}

	if ($unit->request->is_timed_out) {
		$self->render('main/timed_out');
		$self->rendered(410);
	}
	else {
		if (!$unit->request->is_complete) {
			$watcher->resolve_single($unit);
		}

		my $address = $address_service->get_address($unit, $compat);
		$self->stash(
			unit => $unit,
			address => $address,
			address_compat => $compat,
			png => encode_base64(qrpng(text => $address, scale => 7, quiet => 0), ''),
			segwit => $self->stash('segwit') // 1,
		);

		$self->render('main/paywall');
	}
}

sub paywall_compat ($self)
{
	$self->stash(segwit => 0);
	$self->paywall(-compat);
}
