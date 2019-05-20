#!/usr/bin/perl -w
use strict;
use warnings;
require "read_visit_parameters.pl";

my $file = '1180_MEDS0001_params.dat';
#$file  = '1180_POINTINGTWO-CENTER_params.dat';
#$file   = '1180_complete_params.dat';
#$file   ='1180_TARGET-OBSERVATION-25_params.dat';
#$file = '1180_POINTINGFOUR_params.dat';
print "file is $file\n";
my ($p1) = read_visit_parameters($file);
my $ndithers;
my $key;
my @values ;
my %parameters = %$p1;
foreach $key (sort(keys(%parameters))){

    @values = split('#',$parameters{$key});
    for (my $ii = 0 ; $ii <=$#values ; $ii++) {
	print "$ii $values[$ii]\n";
    }
#    <STDIN>;
}
exit(0);

