package Repository::Role::Repository;

use header;
use Moose::Role;
use DI;

requires qw(_class _model_type);

has 'dbc' => (
	is => 'ro',
	default => sub { DI->get('dbc') },
);

sub get_by_id ($self, $id, $raw = 0, %options)
{
	my $result = $self->dbc->resultset($self->_class)
		->search({id => $id}, {prefetch => [$options{prefetch}]})
		->first;

	return $result if $raw;
	return $self->model->from_result($result);
}

sub save ($self, $model, $update = 0)
{
	$self->_model_type->assert_valid($model);

	my $type = $update ? 'update' : 'create';
	return $self->dbc->resultset($self->_class)->$type($model->serialize);
}
