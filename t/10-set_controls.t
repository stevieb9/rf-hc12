use strict;
use warnings;
use feature 'say';

use RF::HC12;
use Test::More;

if (! $ENV{UART_DEV}){
    plan skip_all => "UART_DEV env var not set";
}

my $dev = $ENV{UART_DEV};

my $rf = RF::HC12->new($dev);

is $rf->test, 'OK', "connectivity test ok";

if ($rf->test ne 'OK'){
    plan skip_all => "HC-12 CONN TEST FAILED... CAN'T CONTINUE";
}

for ($rf->baud_rates){
    $rf->baud($_);
    is $rf->baud, "OK+B$_", "baud rate set to $_ ok";
}

for (qw(1 a A ! 1111 9999)){
    is
        eval { $rf->baud($_); 1; },
        undef,
        "baud croaks if sent in $_";

    like $@, qr/baud rate '$_' is invalid/, "...and error is sane";
}

is $rf->baud(9600), 'OK+B9600', "baud set back to default ok";

#is $rf->channel, '001', "default channel (001) is ok";
#is $rf->mode, 3, "default functional mode (3) is ok";
#is $rf->power, '+20', "default transmit power (+20db) ok";
#is $rf->version, 'HC-12_V2.4', "version returns ok";

done_testing();

