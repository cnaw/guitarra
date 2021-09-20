#!/usr/bin/perl -w
use strict;
use warnings;
my $host          = $ENV{HOST};
my $guitarra_home = $ENV{GUITARRA_HOME};
my $guitarra_aux  = $ENV{GUITARRA_AUX};
$guitarra_home = "."      unless defined $guitarra_home;
$guitarra_aux  = "./data/" unless defined $guitarra_aux;
#
my $perl_dir      = $guitarra_home.'/perl/';
my $visibility_tool = 'jwst_gtvt';
my $background_tool = 'jwst_backgrounds';
my $target_dir   = $guitarra_aux;
print "target_dir is $target_dir\n";
#
#
require $perl_dir.'sub_pa_bkg.pl';
#
my $background_file;
my $dec;
my $end_date;
my $field_name;
my $instrument;
my $len;
my $obs_date;
my $pa_max;
my $pa_min;
my $pa_v3;
my $ra;
my $range;
my $result;
my $start_date;
my $wl_filter;
#
$field_name = 'goods_s';
$instrument = 'nircam';
$ra = 53.1496;
$dec = -27.78895;
$pa_v3  =355.0;
$range  = 12;
$wl_filter = 3.56;
$start_date = '2022-06-16';
$end_date   = '2023-06-15';

$obs_date   = '2022-10-20';
#$obs_date = '';
#-----------------------------------------------------------------------
if($#ARGV < 3) {
    print "#ARGV : $#ARGV\n";
    print "pa_bkg.pl  ra dec pa_v3 field_name\n";
    print "pa_bkg.pl  53.1496 -27.78895 355.0 goods_s\n";
#    exit(0);
} else {
    $ra         = $ARGV[0];
    $dec        = $ARGV[1];
    $pa_v3      = $ARGV[2];
    $field_name = $ARGV[3];
    print  "$ra   $dec  $pa_v3 $field_name\n"
}
$target_dir   = $guitarra_aux;
print "$target_dir\n";
($background_file,$pa_min, $pa_max) = sub_pa_bkg( $ra, $dec, $pa_v3, $field_name, $target_dir, $obs_date);
print "background_file is $background_file\n";
exit(0);
