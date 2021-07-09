package Repository::Request;

use header;
use Moose;
use Model::Request;

with 'Repository::Role::Repository';

use constant {
	_model => 'Model::Request',
	_class => Model::Request->get_result_class,
};

sub get_awaiting ($self)
{
	return [
		$self->dbc->resultset($self->_class)->search({
			status => Model::Request->STATUS_AWAITING,
		})
	];
}

sub get_with_items ($self, $id)
{
	my $result = $self->get_by_id($id, 1, prefetch => 'items');

	return $self->_model->from_result($result), [
		map { $_->item } $result->items
	];
}

sub add_items ($self, $model, $items)
{
	my $result = $self->get_by_id($model->id, 1);

	for my $item ($items->@*) {
		$result->create_related(items => {item => $item});
	}

	return;
}

__PACKAGE__->meta->make_immutable;
