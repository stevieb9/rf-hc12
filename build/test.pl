use warnings;
use strict;

use Inline 'Config' => disable => 'clean_after_build';
use Inline 'C';

__END__
__C__

#include <stdio.h>
#include <string.h>

#include <fcntl.h>
#include <errno.h>
#include <termios.h>
#include <unistd.h>

int tty_open
int serial_port = open("/dev/ttyUSB0", O_RDWR);

struct termios tty;
memset(&tty, 0, sizeof tty);

if(tcgetattr(serial_port, &tty) != 0) {
    printf("Error %i from tcgetattr: %s\n", errno, strerror(errno));
}

tty.c_cflag &= ~PARENB; // Clear parity bit, disabling parity (most common)
tty.c_cflag &= ~CSTOPB; // Clear stop field, only one stop bit used in communication (most common)
tty.c_cflag |= CS8; // 8 bits per byte (most common)
tty.c_cflag &= ~CRTSCTS; // Disable RTS/CTS hardware flow control (most common)
tty.c_cflag |= CREAD | CLOCAL; // Turn on READ & ignore ctrl lines (CLOCAL = 1)

tty.c_lflag &= ~ICANON;
tty.c_lflag &= ~ECHO; // Disable echo
    tty.c_lflag &= ~ECHOE; // Disable erasure
    tty.c_lflag &= ~ECHONL; // Disable new-line echo
    tty.c_lflag &= ~ISIG; // Disable interpretation of INTR, QUIT and SUSP
    tty.c_iflag &= ~(IXON | IXOFF | IXANY); // Turn off s/w flow ctrl
tty.c_iflag &= ~(IGNBRK|BRKINT|PARMRK|ISTRIP|INLCR|IGNCR|ICRNL); // Disable any special handling of received bytes

    tty.c_oflag &= ~OPOST; // Prevent special interpretation of output bytes (e.g. newline chars)
tty.c_oflag &= ~ONLCR; // Prevent conversion of newline to carriage return/line feed
// tty.c_oflag &= ~OXTABS; // Prevent conversion of tabs to spaces (NOT PRESENT ON LINUX)
    // tty.c_oflag &= ~ONOEOT; // Prevent removal of C-d chars (0x004) in output (NOT PRESENT ON LINUX)

tty.c_cc[VTIME] = 10;    // Wait for up to 1s (10 deciseconds), returning as soon as any data is received.
    tty.c_cc[VMIN] = 0;

cfsetispeed(&tty, B9600);
cfsetospeed(&tty, B9600);

if (tcsetattr(serial_port, TCSANOW, &tty) != 0) {
    printf("Error %i from tcsetattr: %s\n", errno, strerror(errno));
}

char read_buf [256];
memset(&read_buf, '\0', sizeof(read_buf);

    // settings above, specifically VMIN and VTIME
    int num_bytes = read(serial_port, &read_buf, sizeof(read_buf));

// n is the number of bytes read. n may be 0 if no bytes were received, and can also be -1 to signal an error.
if (num_bytes < 0) {
    printf("Error reading: %s", strerror(errno));
}

// Here we assume we received ASCII data, but you might be sending raw bytes (in that case, don't try and
    // print it to the screen like this!)
printf("Read %i bytes. Received message: %s", num_bytes, read_buf);

close(serial_port)
