#!/usr/bin/perl --

my $smac=$ARGV[0];

if ($smac) {
my @amac = split(":",$smac);

my $section1 = qq($amac[0]$amac[1]);
my $section2 = qq($amac[2]$amac[3]);
my $section3 = qq($amac[4]$amac[5]);

my $result = qq($section1.$section2.$section3);

print "$result\n";
};

exit 0;
