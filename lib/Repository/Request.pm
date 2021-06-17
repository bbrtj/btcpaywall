package Repository::Request;

use header;
use Moose;
use Types;
use DI;
use Model::Request;

const my $model_type => Types::InstanceOf[Model::Request::];
const my $class => Model::Request->get_result_class;

has 'dbc' => (
	is => 'ro',
	default => sub { DI->get('dbc') },
);

sub get_by_id ($self, $id)
{
	return $self->dbc->resultset($class)
		->search({id => $id})
		->first;
}

sub get_awaiting ($self)
{
	return [
		$self->dbc->resultset($class)->search({
			status => Model::Request->STATUS_AWAITING,
		})
	];
}

sub save ($self, $model, $update = 0)
{
	$model_type->assert_valid($model);

	my $type = $update ? 'update' : 'create';
	return $self->dbc->resultset($class)->$type($model->serialize);
}

__PACKAGE__->meta->make_immutable;
