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

sub raw_find ($self, $query, $params = {})
{
	return [
		$self->db->dbc->resultset($self->_class)
			->search($query, $params)
	];
}

sub save ($self, $model, $update = undef)
{
	(Types::InstanceOf [$self->_model])->assert_valid($model);

	my $type = $update ? 'update' : 'insert';
	my $dbmodel = $self->db->dbc->resultset($self->_class)->new($model->serialize);
	if ($update) {
		$dbmodel->in_storage(1);
		$dbmodel->make_column_dirty($_) for $update->@*;
	}
	$dbmodel->$type;
	return;
}
