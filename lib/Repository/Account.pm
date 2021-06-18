package Repository::Account;

use header;
use Moose;
use Types;
use Model::Request;

with 'Repository::Role::Repository';

use constant {
	_model_type => Types::InstanceOf['Model::Account'],
	_class => Model::Account->get_result_class,
};

__PACKAGE__->meta->make_immutable;
