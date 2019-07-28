package RF::HC12;

use strict;
use warnings;

use Carp qw(croak);
use RPi::Serial;

our $VERSION = '0.01';

use constant {
    COMM_BAUD   => 9600,
    EOL         => 0x0A,
};

sub new {
    my ($class, $dev) = @_;

    croak "new() requires a serial device path sent in" if ! defined $dev;

    my $self = bless {}, $class;
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
        if (! $self->_valid_baud($baud)){
            croak "baud rate '$baud' is invalid. See the documentation";
        }
        my $cmd = 'B$baud';
        $self->_serial->puts($cmd);
    }
    return $self->_fetch_control('B');
}
sub channel {
     my ($self, $channel) = @_;

    if (defined $channel){
        if (! $self->_valid_channel($channel)){
            croak "channel '$channel' is invalid. See the documentation";
        }
        my $cmd = 'C$channel';
        $self->_serial->puts($cmd);
    }
    return $self->_fetch_control('C');
}
sub _fetch_control {
    my ($self, $control) = @_;

    if ($control eq 'AT'){
        $self->_serial->puts($control);
    }
    else {
        $self->_serial->puts("AT+R$control");
    }

    my $read;
  
    while (1){
        if ($self->_serial->avail){
            my $char = $self->_serial->getc;
            $read .= chr $char;

            if (hex(sprintf("%x", $char)) == EOL){
                if ($control eq 'AT'){
                    if ($read =~ /(OK)/){
                        return $1;
                    }
                }
                if ($read =~ /.*?(\d+)/){
                    return $1;
                }
            }
        }
    }
}

sub _valid_baud {
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

    return $baud_rates->{$baud} ? 1 : 0;
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

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

1; # End of RF::HC12
