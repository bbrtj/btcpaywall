package Repository::Account;

use Moose;
use Model::Account;

use header;

with 'Repository::Role::Repository';

use constant {
	_model => 'Model::Account',
	_class => Model::Account->get_result_class,
};

__PACKAGE__->meta->make_immutable;
