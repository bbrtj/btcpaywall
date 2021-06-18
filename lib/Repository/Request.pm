package Repository::Request;

use header;
use Moose;
use Types;
use Model::Request;

with 'Repository::Role::Repository';

use constant {
	_model => 'Model::Request',
	_model_type => Types::InstanceOf['Model::Request'],
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

__PACKAGE__->meta->make_immutable;
