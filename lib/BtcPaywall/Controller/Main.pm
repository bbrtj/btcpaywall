package BtcPaywall::Controller::Main;

use Mojo::Base 'Mojolicious::Controller';
use DI;
use Image::PNG::QRCode 'qrpng';
use MIME::Base64;
use Helpers;

use header;

sub paywall ($self, $compat = 0)
{
	state $req_repo = DI->get('requests_repository');
	state $acc_repo = DI->get('accounts_repository');
	state $address_service = DI->get('address_service');
	state $watcher = DI->get('request_watcher');

	my $id = $self->param('id');

	my ($model, $items);
	try {
		($model, $items) = $req_repo->get_with_items($id);
	}
	catch ($e) {
		$self->reply->not_found;
		return;
	}

	if ($model->is_timed_out) {
		$self->render('main/timed_out');
		$self->rendered(410);
	}
	else {
		my $account = $acc_repo->get_by_id($model->account_id);

		if (!$model->is_complete) {
			$watcher->resolve_single($model);
		}

		my $address = $address_service->get_address($model, $compat);
		$self->stash(
			model => $model,
			account => $account,
			items => $items,
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
