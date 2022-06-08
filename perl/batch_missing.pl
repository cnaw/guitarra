#!/usr/bin/perl -w
use strict;
use warnings;
use Scalar::Util qw(looks_like_number);
use Cwd qw(cwd getcwd);
#
my $apt;
my $car;
my $count1;
my $count2;
my $file;
my $guitarra_home;
my $host;
my $ii;
my $new_batch;
my $org_batch;
my $reduced;
my $remove;
my $results;
my $size;
my $slope;
my $stpipe_style;
my $string;
my $total;
my $translation;
my $to_simulate;
my $not_simulated;
#
my @junk;
my @list;
my @path;
my @raw;
my @rerun;
my @slope;
#
my %rerun_hash;
my %slope_hash;
my %other_id;
#
#
# these are the subdirectories where data are stored
#
my $data_root;
my $files;
#
my $guitarra_dir   = 'guitarra/';
my $cat_reg        = $guitarra_dir.'cat_reg/';
my $cr             = $guitarra_dir.'cr/';
my $input          = $guitarra_dir.'input/';;
my $ncdhas_raw     = $guitarra_dir.'raw/';
my $ncdhas_reduced = $guitarra_dir.'reduced/';
my $params         = $guitarra_dir.'params/';
my $st_raw         = $guitarra_dir.'st_raw/';
my $st_reduced     = $guitarra_dir.'st_reduced/';
#
$apt           = '1072';
$car           =  '23';
$apt           = '1074';
$car           =  '29';
$remove        = 0;
$guitarra_home = $ENV{GUITARRA_HOME};
$host          = $ENV{HOST};
#
#print "enter APT proposal number and go to create new batch:\n";
#print "1072 go\nor\n1072\n";
#my $input = <STDIN>;
#@junk = split(' ',$input);
#$remove = 0;
#if($#junk > 0) {
#    if($junk[1] eq 'go') {
#	$remove = 1;
#    }
#}
#-----------------------------------------------------------------------
#
# read existing slope files
#  missing files for APT_1074:  F200W_484_0832  F150W_484_0591
#  apt_01074003002_F200W_484_0832  apt_01074003002_F150W_484_0591

$data_root = '/data1/'.join('_','car',$car,'apt',sprintf("%05d",$apt)).'/';
$string  = $data_root.$ncdhas_raw.'*.fits';
@list    = `ls $string`;
$count1 = 0;
for ($ii = 0 ; $ii <= $#list ; $ii++) {
    $list[$ii] =~ s/\n//g;
    $file      = $list[$ii];
    @junk = split('\/',$file);
    if (-s $file == 0 ) {
	print "$file has 0 size\n";
	push(@rerun, $junk[$#junk]);
	$rerun_hash{$junk[$#junk]} = $file;
	$count1++;
    } else {
	$slope = $file;
	$slope =~ s/$ncdhas_raw/$ncdhas_reduced/;
	$slope =~ s/.fits/.slp.fits/;
	if(-e $slope) {
	    $slope_hash{$file} = $slope;
	} else {
#	    print "slope file $slope does not exist\n";
#	    push(@rerun, $file);
	    $rerun_hash{$junk[$#junk]} = $file;
	$count1++;
	}
    }
}
#-----------------------------------------------------------------------
#
# read table translating guitarra -> DMS names
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
$org_batch = $data_root.'batch_'.$apt;
open(BATCH,"<$org_batch") || die "cannot open $org_batch";
$reduced   = 0;
$total     = 0;
$not_simulated = 0;
$count2 = 0;
while(<BATCH>) {
    chop $_;
    @junk = split(' ',$_);
    $file = $junk[$#junk];
    @junk = split('\/',$file);
    $file = $junk[$#junk];
    $total++;
#    print "step2: $file\n";
    if(exists($rerun_hash{$file})) {
	print "rerun $file\n";
	print NEW $_,"\n";
	$count2++;
    }
#    if(exists($slope_hash{$file})) {
#	print "file reduced: $file\n";
#	$reduced++;
#	next;
#    }
#    if(-e $file) {
#	$size = -s $file;
#	print "$file has  size $size\n";
#	if($remove == 1) {
#	    print "removing $file\n";
#	    unlink $file;
#	    $not_simulated++;
#	}
#	if(exists($other_id{$file})){
#	    $stpipe_style = $guitarra_home.'/results/'.$other_id{$file};
#	    print "$stpipe_style exists\n";
#	    if($remove == 1) {
#		print "removing $stpipe_style\n";
#		unlink $stpipe_style;
#	    }
#	}
#    }
#    print NEW $_,"\n";
}
close(BATCH);
close(NEW);
print "original batch has $total images\n";
print "simulations completed $reduced\n";
print "incomplete simulations : $not_simulated\n";
print "count 1 : $count1\n";
print "count 2 : $count2\n";
$to_simulate = $total - $reduced;
print "scenes to simulate $to_simulate\n";
print "new batch is $new_batch\n";
#-----------------------------------------------------------------------------
#
sub move_back{
    my($root, $cat, $apt, $missing_ref) = @_ ;
    my $cat_reg;
    my $command;
    my $cr;
    my $files;
    my $guitarra_dir;
    my $input;
    my $ncdhas_raw;
    my $ncdhas_reduced;
    my $params;
    my $st_raw;
    my $st_reduced;
    my $source_dir;
    my $target_dir;

    $source_dir = $root.sprintf("car_%02d_apt_%05d",$car,$apt);
    $target_dir = '/home/cnaw/test/guitarra/results/';
    print "$source_dir\n$target_dir\n";
    $guitarra_dir   = $source_dir.'/guitarra/';
#
    $ncdhas_raw     = $guitarra_dir.'raw/';
    $ncdhas_reduced = $guitarra_dir.'reduced/';
#
    $st_raw         = $guitarra_dir.'st_raw/';
    $st_reduced     = $guitarra_dir.'st_reduced/';
#
    $cat_reg        = $guitarra_dir.'cat_reg/';
    $cr             = $guitarra_dir.'cr/';
    $input          = $guitarra_dir.'input/';
    $params         = $guitarra_dir.'params/';
    #

    $files    = $source_dir.sprintf("%05d",$apt).'*params.dat';
    $command  = join(' ','mv -fi',$files, $params);
    print "$command\n";
#    system($command);
#
    $files    = $source_dir.$missing_ref.'*.input';
    $command  = join(' ','mv -fi',$files, $target_dir);
    print "$command\n";
#    system($command);
    #
    $files    = $source_dir.'*.reg';
    $command  = join(' ','mv -fi',$files, $target_dir);
#    system($command);
    #
    $files    = $source_dir.'*.cat';
    $command  = join(' ','mv -fi',$files, $target_dir);
    print "$command\n";
#    system($command);
    #
    $files    = $source_dir.'cr*';
    $command  = join(' ','mv -fi',$files, $target_dir);
    print "$command\n";
#    system($command);
    #
    $files    = $source_dir.'*jmp.txt';
    $command  = join(' ','mv -fi',$files, $target_dir);
    print "$command\n";
#    system($command);
    #
    $files    = $source_dir.'*slp.fits';
    $command  = join(' ','mv -fi',$files, $target_dir);
    print "$command\n";
#    system($command);
    #
    $files    = $source_dir.'*dia.fits';
    $command  = join(' ','mv -fi',$files, $target_dir);
    print "$command\n";
#    system($command);
    #
    $files    = $source_dir.'jw0'.$apt.'*uncal.fits';
    $command  = join(' ','mv -fi',$files, $target_dir);
    print "$command\n";
#    system($command);
    #
    #
    $files    = $source_dir.'jw0'.$apt.'*rate.fits';
    $command  = join(' ','mv -fi',$files, $target_dir);
    print "$command\n";
#    system($command);
    #
    $files    = $source_dir.'apt*.fits';
    $command  = join(' ','mv -fi',$files, $target_dir);
    print "$command\n";
#    system($command);
    
}
