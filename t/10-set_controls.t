use strict;
use warnings;
use feature 'say';

use RF::HC12;
use Test::More;

my $dev = '/dev/ttyUSB0';

my $rf = RF::HC12->new($dev);

is $rf->test, 'OK', "connectivity test ok";
is $rf->baud, 9600, "default baud rate (9600) ok";
is $rf->channel, '001', "default channel (001) is ok";
is $rf->mode, 3, "default functional mode (3) is ok";
is $rf->power, '+20', "default transmit power (+20db) ok";
is $rf->version, 'HC-12_V2.4', "version returns ok";

done_testing();
