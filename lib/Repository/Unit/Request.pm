package Repository::Unit::Request;

use Moo;
use Unit::Request;
use Model::Request;
use Model::Account;
use Ref::Util qw(is_arrayref);

use header;

has 'request_repo' => (
	is => 'ro',
);

sub _create_from_result ($self, $request, $req_model = undef)
{
	return Unit::Request->new(
		request => $req_model // Model::Request->from_result($request),
		items => [map { $_->item } $request->items],
		account => Model::Account->from_result($request->account),
	);
}

sub get_by_id ($self, $id)
{
	my $request = $self->request_repo->get_by_id($id, 1, prefetch => [qw(items account)]);

	return $self->_create_from_result($request);
}

sub promote_model ($self, $model)
{
	my $request = $self->request_repo->get_by_id($model->id, 1, prefetch => [qw(items account)]);

	return $self->_create_from_result($request, $model);
}

sub find ($self, %params)
{
	my $query = {};
	for my $pkey (keys %params) {
		my $pvalue = $params{$pkey};

		if (is_arrayref($pvalue)) {
			$query->{"me.$pkey"} = {'IN', $pvalue};
		}
		else {
			$query->{"me.$pkey"} = $pvalue;
		}
	}

	return [
		map { $self->_create_from_result($_) }
			$self->request_repo->raw_find($query, {prefetch => [qw(items account)]})->@*
	];
}

