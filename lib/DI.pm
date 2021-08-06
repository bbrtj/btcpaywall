package DI;

use Beam::Wire;
use Mojo::File qw(path);

use header;

sub _create ($class)
{
	state $wire = Beam::Wire->new(file => path(__FILE__)->dirname->child('wire.yml'));
}

sub get ($class, @args)
{
	$class->_create->get(@args);
}

sub set ($class, $name, $value, $replace = 0)
{
	if ($replace || !exists $class->_create->services->{$name}) {
		$class->_create->set($name, $value);
	}
	return;
}

sub forget ($class, $name)
{
	my $bm = $class->_create;
	if (exists $bm->services->{$name}) {
		delete $bm->services->{$name};
	}
	return;
}

sub has ($class, $name)
{
	return exists $class->_create->services->{$name};
}
