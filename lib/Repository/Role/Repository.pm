package Repository::Role::Repository;

use Moose::Role;
use DI;
use Types;

use header;

requires qw(_class _model);

has 'db' => (
	is => 'ro',
	default => sub { DI->get('db') },
);

sub get_by_id ($self, $id, $raw = 0, %options)
{
	my $result = $self->db->dbc->resultset($self->_class)
		->search({'me.id' => $id}, {prefetch => [$options{prefetch}]})
		->first;

	return $result if $raw;
	return $self->_model->from_result($result);
}

sub save ($self, $model, $update = 0)
{
	(Types::InstanceOf[$self->_model])->assert_valid($model);

	my $type = $update ? 'update' : 'create';
	return $self->db->dbc->resultset($self->_class)->$type($model->serialize);
}
