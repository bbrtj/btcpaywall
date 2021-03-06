package Service::RequestWatcher;

use Moo;
use Types;
use Model::Request;

use header;

has 'address_service' => (
	is => 'ro',
	isa => Types::InstanceOf ['Service::Address'],
	required => 1,
);

has 'callback_service' => (
	is => 'ro',
	isa => Types::InstanceOf ['Service::Callback'],
	required => 1,
);

has 'request_unit_repo' => (
	is => 'ro',
	isa => Types::InstanceOf ['Repository::Unit::Request'],
	required => 1,
);

has 'request_repo' => (
	is => 'ro',
	isa => Types::InstanceOf ['Repository::Request'],
	required => 1,
);

sub get_unresolved_requests ($self)
{
	# returns full request units
	$self->request_unit_repo->find(
		status => [
			Model::Request->STATUS_AWAITING,
			Model::Request->STATUS_PENDING,
			Model::Request->STATUS_CALLBACK_FAILED,
		]
	);
}

sub _callback ($self, $request_unit)
{
	if ($self->callback_service->run_callback($request_unit)) {
		$request_unit->request->set_status(Model::Request->STATUS_COMPLETE);
	}
	else {
		$request_unit->request->set_status(Model::Request->STATUS_CALLBACK_FAILED);
	}
}

sub _update ($self, $request)
{
	$self->request_repo->save($request, [qw(status)]);
}

sub resolve ($self)
{
	my $unresolved = $self->get_unresolved_requests;

	for my $request_unit ($unresolved->@*) {
		$self->resolve_single($request_unit);
	}
	return scalar $unresolved->@*;
}

sub resolve_single ($self, $request_unit)
{
	my $request = $request_unit->request;

	if ($request->check_timeout) {
		$request->set_status(Model::Request->STATUS_TIMEOUT);
		$self->_update($request);
	}
	elsif ($request->is_callback) {
		$self->_callback($request_unit);
		$self->_update($request);
	}
	else {
		my $info = $self->address_service->get_request_blockchain_info($request_unit);

		# TODO: handle incorrect amount
		if (($request->is_pending || $request->is_awaiting) && $info->is_complete) {
			$self->_callback($request_unit);
			$self->_update($request);
		}
		if ($request->is_awaiting && $info->is_pending) {
			$request->set_status(Model::Request->STATUS_PENDING);
			$self->_update($request);
		}
	}
}
