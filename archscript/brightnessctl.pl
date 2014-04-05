#!/usr/bin/perl

use strict;
use warnings;
$|=1;

my $currBr = `cat /sys/class/backlight/intel_backlight/brightness`;

if($ARGV[0] eq "up"){
	if($currBr == 7812){
		#do nothing
	}
	else{
		my $newBr = $currBr + 781;
		`echo $newBr > /sys/class/backlight/intel_backlight/brightness`;
	}
}
elsif($ARGV[0] eq "dw"){
	if($currBr == 783){
		#do nothing
	}
	else{
		my $newBr = $currBr - 781;
		`echo $newBr > /sys/class/backlight/intel_backlight/brightness`;
	}

}
else{
	#do nothing
}

1;
