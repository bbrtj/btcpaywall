package Repository::Role::Repository;

use header;
use Moose::Role;
use DI;

requires qw(_class _model_type);

has 'dbc' => (
	is => 'ro',
	default => sub { DI->get('dbc') },
);

sub get_by_id ($self, $id)
{
	return $self->dbc->resultset($self->_class)
		->search({id => $id})
		->first;
}

sub save ($self, $model, $update = 0)
{
	$self->_model_type->assert_valid($model);

	my $type = $update ? 'update' : 'create';
	return $self->dbc->resultset($self->_class)->$type($model->serialize);
}
