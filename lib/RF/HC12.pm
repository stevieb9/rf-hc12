package RF::HC12;

use strict;
use warnings;

use Carp qw(croak);
use RPi::Serial;

our $VERSION = '0.01';

use constant {
    COMM_BAUD   => 9600,
    EOL         => 0x0A,
    DEBUG_FETCH => 0,
};

sub new {
    my ($class, $dev, $eol) = @_;

    croak "new() requires a serial device path sent in" if ! defined $dev;

    $eol = defined $eol ? $eol : EOL;
    my $self = bless {
        eol => $eol,
    }, $class;
    $self->_serial($dev, COMM_BAUD);
    return $self;
}
sub _serial {
    my ($self, $dev, $comm_baud) = @_;
    return $self->{serial} if exists $self->{serial};
    $self->{serial} = RPi::Serial->new($dev, $comm_baud);
    return $self->{serial};
}
sub test {
    my ($self) = @_;
    my $cmd = 'AT';
    return $self->_fetch_control($cmd);
}
sub baud {
    my ($self, $baud) = @_;

    if (defined $baud){
        if (! $self->baud_rates($baud)){
            croak "baud rate '$baud' is invalid. See the documentation";
        }
        my $cmd = "AT+B$baud";
        $self->_set_control($cmd);
    }
    return $self->_fetch_control('AT+RB');
}
sub power {
    my ($self, $tp) = @_;

    if (defined $tp){
        if (! $self->power_rates($tp)){
            croak "transmit power '$tp' is invalid. See the documentation";
        }
        my $cmd = "AT+P$tp";
        $self->_set_control($cmd);
    }
    return $self->_fetch_control('AT+RP');
}
sub mode {
    my ($self, $mode) = @_;

    if (defined $mode){
        if (! $self->_valid_baud($mode)){
            croak "functional mode'$mode' is invalid. See the documentation";
        }
        my $cmd = 'AT+FU$mode';
        $self->_serial->puts($cmd);
    }
    return $self->_fetch_control('AT+RF');
}
sub version {
    my ($self, $ver) = @_;

    if (defined $ver){
        croak "hardware version isn't something that can be set";
    }

    return $self->_fetch_control('AT+V');
}
sub channel {
     my ($self, $channel) = @_;

    if (defined $channel){
        if (! $self->_valid_channel($channel)){
            croak "channel '$channel' is invalid. See the documentation";
        }
        my $cmd = 'AT+C$channel';
        $self->_serial->puts($cmd);
    }
    return $self->_fetch_control('AT+RC');
}
sub _set_control {
    my ($self, $control) = @_;
    $self->_serial->puts("$control");
}
sub _fetch_control {
    my ($self, $control) = @_;

    $self->_serial->puts($control);

    my $read;

    while (1){
        if ($self->_serial->avail){
            my $char = $self->_serial->getc;

            if (hex(sprintf("%x", $char)) == 0x0D){
                next;
            }

            if (hex(sprintf("%x", $char)) == 0x0A){
                return $read;
            }

            $read .= chr $char;
        }
    }
}
sub _eol {
    my ($self) = @_;
    return $self->{eol};
}
sub baud_rates {
    my ($self, $baud) = @_;

    my $baud_rates = {
        1200    => 1,
        2400    => 1,
        4800    => 1,
        9600    => 1,
        19200   => 1,
        38400   => 1,
        57600   => 1,
        115200  => 1,
    };

    return sort {$a <=> $b}(keys(%$baud_rates)) if ! defined $baud;

    return $baud_rates->{$baud} ? 1 : 0;
}
sub power_rates {
    my ($self, $rate) = @_;

    my $power_rates = {
        1   => -1,
        2   => 2,
        3   => 5,
        4   => 8,
        5   => 11,
        6   => 14,
        7   => 17,
        8   => 20
    };

    return %$power_rates if ! defined $rate;
    return $power_rates->{$rate} ? 1 : 0;
}
1;
__END__

=head1 NAME

RF::HC12 - Interface to the 433 MHz HC-12 RF trancievers

=head1 SYNOPSIS

=head1 METHODS

=head1 AUTHOR

Steve Bertrand, C<< <steveb at cpan.org> >>

=head1 LICENSE AND COPYRIGHT

Copyright 2019 Steve Bertrand.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>
