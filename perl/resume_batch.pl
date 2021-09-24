#!/usr/bin/perl -w
use strict;
use warnings;
use Scalar::Util qw(looks_like_number);
use Cwd qw(cwd getcwd);

my $apt;
my $file;
my $guitarra_home;
my $host;
my $ii;
my $new_batch;
my $org_batch;
my $results;
my $size;
my $slope;
my $stpipe_style;
my $string;
my $translation;
#
my @junk;
my @list;
my @path;
#
my %slope_hash;
my %other_id;
#
$apt           = '1072';
$guitarra_home = $ENV{GUITARRA_HOME};
$host          = $ENV{HOST};
#

#-----------------------------------------------------------------------
#
# read existing slope files
#
$results = $guitarra_home.'/results/';
$string  = $results.'*slp.fits';
@list    = `ls $string`;
for ($ii = 0 ; $ii <= $#list ; $ii++) {
    $slope = $list[$ii];
    $slope =~ s/\n//g;
    $file  = $slope;
    $file  =~ s/.slp.fits/.fits/;
    $slope_hash{$file} = $slope;
#    print "$slope\n$file\n\n";
}
#-----------------------------------------------------------------------
#
# read existing slope files
#
$translation = $guitarra_home.'/results/'.$apt.'_mirage_guitarra.dat';
open(CAT,"<$translation") || die "cannot open $translation";
while(<CAT>) {
    chop $_;
    @junk = split(' ',$_);
    $file = $junk[0];
    $other_id{$file} = $junk[2];
}
close(CAT);
#  /home/cnaw/guitarra//results/apt_01072001001_F150W_484_0116.fits
#/home/cnaw/test/guitarra/results/jw01072001001_01101_00010_nrca4_F150W_01_02_uncal.fits
#-----------------------------------------------------------------------
#
$new_batch = $guitarra_home.'/new_batch_'.$apt;
open(NEW,">$new_batch") || die "cannot open $new_batch";

$org_batch = $guitarra_home.'/batch_'.$apt;
open(BATCH,"<$org_batch") || die "cannot open $org_batch";
while(<BATCH>) {
    chop $_;
    @junk = split(' ',$_);
    $file = $junk[$#junk];
    if(exists($slope_hash{$file})) {
	print "file reduced: $file\n";
	next;
    }
    if(-e $file) {
	$size = -s $file;
	print "$file has  size $size; will remove\n";
	unlink $file;
	if(exists($other_id{$file})){
	    $stpipe_style = $guitarra_home.'/results/'.$other_id{$file};
	    print "$stpipe_style exists; will remove\n";
	    unlink $stpipe_style;
	}
    }
    print NEW $_,"\n";
}
close(BATCH);
close(NEW);
print "new batch is $new_batch\n";
