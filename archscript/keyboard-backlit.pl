#!/usr/bin/perl

use strict;
use warnings;
$|=1;

my $currBr = `cat /sys/devices/platform/asus-nb-wmi/leds/asus::kbd_backlight/brightness`;

if($ARGV[0] eq "up"){
	if($currBr == 3){
		#do nothing
	}
	else{
		my $newBr = $currBr + 1;
		`echo $newBr > /sys/devices/platform/asus-nb-wmi/leds/asus::kbd_backlight/brightness`;
	}
}
elsif($ARGV[0] eq "dw"){
	if($currBr == 0){
		#do nothing
	}
	else{
		my $newBr = $currBr - 1;
		`echo $newBr > /sys/devices/platform/asus-nb-wmi/leds/asus::kbd_backlight/brightness`;
	}

}
else{
	#do nothing
}

1;
