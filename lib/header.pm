package header;

use strict;
use warnings;
use utf8;
use feature ':5.32';
use Import::Into;

use experimental;
require namespace::autoclean;
require true;
require Syntax::Keyword::Try;
require Carp;
require Scalar::Util;
require Const::Fast;

sub import
{
	my $pkg = caller;
	my ($me, @args) = @_;

	strict->import::into($pkg);
	warnings->import::into($pkg);
	utf8->import::into($pkg);
	feature->import::into($pkg, ':5.32', qw(isa signatures));
	Syntax::Keyword::Try->import::into($pkg);
	true->import::into($pkg);
	Carp->import::into($pkg, qw(croak));
	Scalar::Util->import::into($pkg, qw(blessed));
	Const::Fast->import::into($pkg);

	namespace::autoclean->import(-cleanee => scalar(caller));
	feature->unimport::out_of($pkg, 'indirect');
	return;
}

1;
