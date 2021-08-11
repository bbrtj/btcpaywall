package Helpers;

use Constants;

use header;

sub satoshi_to_bitcoin ($amount)
{
	return sprintf('%.8f', $amount / Constants::SATOSHI_PER_BITCOIN);
}

sub format_address ($address, $group_size = 6)
{
	my @groups;
	while (length $address > 0) {
		push @groups, substr $address, 0, $group_size, '';
	}

	return join ' ', @groups;
}
