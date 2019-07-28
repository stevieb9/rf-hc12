use strict;
use warnings;
use feature 'say';

use RF::HC12;
use Test::More;

my $dev = '/dev/ttyUSB0';

my $rf = RF::HC12->new($dev);

is $rf->baud, 9600, "default baud rate (9600) ok";
is $rf->channel, '001', "default channel (001) is ok";
is $rf->test, 'OK', "connectivity test ok";

done_testing();

