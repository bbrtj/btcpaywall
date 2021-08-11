package Helpers;

use Constants;

use header;

sub satoshi_to_bitcoin ($amount)
{
	return sprintf('%.8f', $amount / Constants::SATOSHI_PER_BITCOIN);
}
