package Model::Role::Dummy;

use header;
use Moose::Role;
use Moose::Util qw(find_meta);
use List::Util qw(first);

before "dummy" => sub {
	die "Cannot dummy a dummy";
};

sub _make_dummy ($role, $class)
{
	my $dummy_class = "${class}::Dummy";
	if (!find_meta($dummy_class)) {
		my $meta = Moose::Meta::Class->create(
			$dummy_class,
			superclasses => [$class],
			roles => [$role],
		);

		foreach my $attribute ($meta->get_all_attributes) {
			my $name = $attribute->name;
			$meta->add_attribute("+$name", required => 0);
		}

		$meta->make_immutable;
	}
	return $dummy_class;
}

sub promote ($self)
{
	my $base = first { $_ =~ /Model::/ && $_ !~ /::Dummy$/ }
		$self->meta->class_precedence_list;
	$base->meta->rebless_instance_back($_[0]);
}
