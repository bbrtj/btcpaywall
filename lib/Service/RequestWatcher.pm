package Service::RequestWatcher;

use Moo;
use Types;
use Model::Request;

use header;

has 'address_service' => (
	is => 'ro',
	isa => Types::InstanceOf['Service::Address'],
	required => 1,
);

has 'callback_service' => (
	is => 'ro',
	isa => Types::InstanceOf['Service::Callback'],
	required => 1,
);

has 'request_repo' => (
	is => 'ro',
	isa => Types::InstanceOf['Repository::Request'],
	required => 1,
);

sub get_unresolved_requests ($self)
{
	$self->request_repo->find(
		status => [
			Model::Request->STATUS_AWAITING,
			Model::Request->STATUS_PENDING,
			Model::Request->STATUS_CALLBACK_FAILED,
		]
	);
}

sub resolve ($self)
{
	my $unresolved = $self->get_unresolved_requests;

	for my $request ($unresolved->@*) {

		if ($request->ts + Model::Request->TTL < time) {
			$request->set_status(Model::Request->STATUS_TIMEOUT);
		}
		else {
			my $info = $self->address_service->get_request_blockchain_info($request);

			# TODO: handle incorrect amount
			if (($request->is_pending || $request->is_awaiting) && $info->is_complete) {
				if ($self->callback_service->run_callback($request)) {
					$request->set_status(Model::Request->STATUS_COMPLETE);
				}
				else {
					$request->set_status(Model::Request->STATUS_CALLBACK_FAILED);
				}

				$self->request_repo->save($request, 1);
			}
			if ($request->is_awaiting && $info->is_pending) {
				$request->set_status(Model::Request->STATUS_PENDING);
				$self->request_repo->save($request, 1);
			}
		}
	}
	return;
}
