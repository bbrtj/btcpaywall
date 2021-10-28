package Repository::Request;

use Moose;
use Model::Request;

use header;

with 'Repository::Role::Repository';

use constant {
	_model => 'Model::Request',
	_class => Model::Request->get_result_class,
};

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

around 'save' => sub ($orig, $self, $model, $update = undef) {
	my $ret = $self->$orig($model, $update);
	if (!$update) {
		my $filled_model = $self->get_by_id($model->id);
		$model->set_derivation_index($filled_model->derivation_index);
	}

	return $ret;
};

__PACKAGE__->meta->make_immutable;
