package DI;

use header;
use Beam::Wire;
use Path::Tiny;

sub _create ($class)
{
	state $wire = Beam::Wire->new(file => path(__FILE__)->parent->child('wire.yml'));
}

sub get ($class, @args)
{
	$class->_create->get(@args);
}

sub set ($class, $name, $value, $replace = 0)
{
	if ($replace || !exists $class->_create->config->{$name}) {
		$class->_create->set($name, $value);
	}
}
