package BtcPaywall::Controller::Main;

use Mojo::Base 'Mojolicious::Controller';
use DI;
use Image::PNG::QRCode 'qrpng';
use MIME::Base64;

use header;

sub paywall ($self, $compat = 0)
{
	state $req_repo = DI->get('requests_repository');
	state $acc_repo = DI->get('accounts_repository');
	state $master_key = DI->get('master_key');
	my $uuid = $self->param('uuid');

	my ($model, $items);
	try {
		($model, $items) = $req_repo->get_with_items($uuid);
	} catch ($e) {
		$self->reply->not_found;
		return;
	}

	my $account = $acc_repo->get_by_id($model->account_id);
	# This may fail randomly, but the probability of failing is lower than 1 / 2^127, so we don't care
	my $address = $master_key->get_payment_address($account, $model, $compat);

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
