#!/usr/bin/perl -w
use Time::localtime;
use strict;
use warnings;
#
my @days_in_month =(31,28,31,30,31,30,31,31,30,31,30,31);

my @names =('Sun','Mon','Tue','Wed','Thu','Fri','Sat');
my($year, $month, $day,$name, $ii);
my($tm) = localtime();
my($date);
my($file);
my($day_in_week);
my($day_number);

if($#ARGV == -1) {
    print "use is get_day_number.pl 2020-05-20\n";
    $year = $tm->year+1900;
    $month = ($tm->mon) + 1;
    $day   = $tm->mday;
    $name  = $tm->wday;
} 
if($#ARGV == 2) {
    $year  = $ARGV[0];
    $month = $ARGV[1];
    $day   = $ARGV[2];
}
if($#ARGV == 0) {
    my @junk = split('-',$ARGV[0]);
    if($#junk == 0) {
	($year, $month, $day) = split('_',$ARGV[0]);
    } else {
	($year, $month, $day) = split('-',$ARGV[0]);
    }
}

# print "$year, $month, $day\n";

#
$day_number = 0;
if($month == 1) {
    $day_number = $day;
} else {
    for($ii = 0 ; $ii < $month-1 ; $ii++) {
	$day_number = $day_number + $days_in_month[$ii];
#
# check for February - is it a Leap year ?
#
	if ($ii == 2 && $year%4 == 0) {
	    $day_number++;
	}
    }
    $day_number = $day_number + $day;
}
$date = sprintf("%04d_%02d_%02d", $year,$month,$day);
print "date: $date  ; day number: $day_number\n";
