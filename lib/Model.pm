package Model;

use Moo::Role;
use Model::Role::Dummy;

use header;

my %orm_mapping;
my %orm_mapping_reverse;

sub _install_writers ($class)
{
	my @attributes = grep { $_->name !~ /^_/ } $class->meta->get_all_attributes;
	foreach my $attribute (@attributes) {
		my $name = $attribute->name;
		my $writer_attr = $attribute->meta->find_attribute_by_name("writer");

		if (!$writer_attr->get_value($attribute)) {
			$writer_attr->set_value($attribute, "set_$name");
		}
	}

	return $class->meta->make_immutable;
}

sub _register ($class)
{
	if ($class =~ /Model::(.+)/) {
		my $resultset = "Schema::Result::$1";
		$orm_mapping{$class} = $resultset;
		$orm_mapping_reverse{$resultset} = $class;

		return $class->_install_writers;
	}

	croak "cannot register $class";
}

sub serialize ($self)
{
	return {map { $_->name => $_->get_value($self) } grep { $_->has_value($self) } $self->meta->get_all_attributes};
}

sub from_result ($class, $row)
{
	my $resultset = blessed $row;
	croak "invalid argument to from_result"
		unless defined $resultset;

	my $real_class = $orm_mapping_reverse{$resultset};
	return $real_class->new(
		map {
			my $sub = $row->can($_);
			croak "cannot fetch $_ from $resultset result set"
				unless $sub;

			$_ => $sub->($row);
		} $real_class->meta->get_attribute_list
	);
}

sub get_result_class ($self)
{
	my $class = blessed $self // $self;

	croak 'invalid argument for get_result_class'
		unless exists $orm_mapping{$class};

	return $orm_mapping{$class};
}

sub dummy ($class)
{
	croak "dummy only works on class context" if ref $class;
	return Model::Role::Dummy->_make_dummy($class);
}

