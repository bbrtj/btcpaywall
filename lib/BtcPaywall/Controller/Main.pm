package BtcPaywall::Controller::Main;

use Mojo::Base 'Mojolicious::Controller';
use DI;
use Image::PNG::QRCode 'qrpng';
use MIME::Base64;

use header;

sub paywall ($self, $compat = 0)
{
	state $req_repo = DI->get('requests_repository');
	state $address_service = DI->get('address_service');
	my $uuid = $self->param('uuid');

	my ($model, $items);
	try {
		($model, $items) = $req_repo->get_with_items($uuid);
	} catch ($e) {
		$self->reply->not_found;
		return;
	}

	my $address = $address_service->get_address($model, $compat);
	$self->stash(
		model => $model,
		items => $items,
		address => $address,
		address_compat => $compat,
		png => encode_base64(qrpng(text => $address, quiet => 0), ''),
	);

	$self->render('main/paywall');
}

sub paywall_compat ($self)
{
	$self->paywall(-compat);
}
