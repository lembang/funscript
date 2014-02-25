#!/usr/bin/perl

#
# (c) J.P. Hendrix
# http://wirespeed.xs4all.nl/mediawiki
#
# Script to echo all data sent from Arduino to PC
# To set up proper udev rules, refer to http://wirespeed.xs4all.nl/mediawiki/index.php/Udev_rules_file_for_Arduino_boards
# 

use warnings;
use strict;
use Device::SerialPort;
use Getopt::Long;

my $PortObj;
$| = 1;				# make the output line bufferend

my %parameters;
GetOptions (\%parameters , 'device=s' , 'flush!' , 'reset!' , 'reset-once!' , 'restart!' );
my $PortName = $parameters{ 'device' } || "/dev/ttyUSB0";
my $restart  = $parameters{ 'restart' } || 1;

if ( ! -e $PortName ) { die "Device '$PortName' does not exist." }

###
### This sub is to be called when the program exits so the lockfile is removed
### and memory is freed.
###
sub finalize {
	print STDERR "Finalize: ";
	if ( defined( $PortObj ) ) {
		$PortObj->close || die "failed to close";
		undef $PortObj;
		print STDERR "done.";
	}
	print STDERR "\n";
};

###
### When a Ctrl-C is received, clean up after us.
###
$SIG{ INT } = sub { finalize; die "\nSIGINT received. Quitting"; };
$SIG{ KILL } = sub { finalize; die "\nSIGINT received. Quitting"; };

my $lockfile = $PortName;
$lockfile =~ s/dev/tmp/;
# my $file_exists = "";
if ( -e "$lockfile" ) {
	# $file_exists = "Manually remove $lockfile when sure the device is not in use.\n";
	die "Manually remove $lockfile when sure the device is not in use.\n";
}


my $restartRequired = 0;
do {
	print STDERR "Initializing serial port $PortName (115200, 8N1) ...\n";
	my $quiet = 'false';
	my $data;
	my $count;
	
	###
	### Open the serial port device to the Arduino
	###
	if ( $PortObj = new Device::SerialPort ($PortName, $quiet, $lockfile) ) {
		$restartRequired = 0
	} else {
		$restartRequired = 1;
	}
	if ( not $restartRequired ) {
		$PortObj->databits( 8 );
		$PortObj->baudrate( 115200 );
		$PortObj->parity( "none" );
		$PortObj->stopbits( 1 );
		$PortObj->handshake( "none" );
		$PortObj->read_char_time( 0 );
		# $PortObj->read_const_time( 60000 );
		$PortObj->read_const_time( 20 );
	
		###
		### Reset Arduino
		###
		if ( ! defined( $parameters{ 'reset' } ) or $parameters{ 'reset' } ) {
			print STDERR "Resetting Arduino ...\n";
			$PortObj->pulse_dtr_on( 200 );	# Reset Arduino
			if ( $parameters{ 'reset-once' } ) { $parameters{ 'reset' } = 0; }
		}
	
		###
		### Flush serial buffer
		###
		if ( ! defined( $parameters{ 'flush' } ) or $parameters{ 'flush' } ) {
			print STDERR "Flushing serial buffer ...\n";
			#$PortObj->lookclear;	# Doesn't work!
			my ( $count, $data ) = $PortObj->read( 1 );
			while ( $count != 0 ) {
				( $count, $data ) = $PortObj->read( $count );
			}
		}
	
	
		print STDERR "Receiving serial data ...\n";
		( $count, $data ) = $PortObj->read( 1 );
		while ( ord( $data ) == 0x00 ) {
			( $count, $data ) = $PortObj->read( 1 );
		}
	}

	while ( not $restartRequired ) {
	 	if ( ( $data ne  ) ) { printf $data; };
	        ( $count, $data ) = $PortObj->read( 1 ) or $restartRequired = $restart;
	}
	finalize;
	sleep 1;
} until ( not $restartRequired );
