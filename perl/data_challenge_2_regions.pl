#!/usr/bin/perl -w
use strict;
my $host          = $ENV{HOST};
my $guitarra_home = $ENV{GUITARRA_HOME};
print "$ENV{GUITARRA_HOME}\n";
my $guitarra_aux  = $ENV{GUITARRA_AUX};
my $python_dir    = $ENV{PYTHON_DIR};
my $perl_dir      = '/home/cnaw/git_arra/perl/';
my $results_path  = $guitarra_home.'/results/';
my($debug) = 0;
require $perl_dir.'translate_instruments.pl';
require $perl_dir.'nrc_regions.pl';
#
# This makes life easier for debugging
# if not defined
#
#$guitarra_home = "~/guitarra"      unless defined $guitarra_home;
#$guitarra_aux  = "~/guitarra/data/" unless defined $guitarra_aux;
$guitarra_home = "."      unless defined $guitarra_home;
$guitarra_aux  = "./data/" unless defined $guitarra_aux;
#
my $outline = $guitarra_aux.'NIRCam_outline.ascii';

my %visit;
$visit{'01180013001'} = 'pointing3b';
$visit{'01180014001'} = 'pointing3c';
$visit{'01180015001'} = 'pointing3a';
$visit{'01180016001'} = 'pointing4b'; 
$visit{'01180017001'} = 'pointing4c';
$visit{'01180018001'} = 'pointing4a';
$visit{'01180019001'} = 'meds0001';
$visit{'01180020001'} = 'meds0002';
$visit{'01180023001'} = 'meds0005';
$visit{'01180024001'} = 'meds0006';
$visit{'01180025001'} = 'med_hst_f1';
$visit{'01180026001'} = 'med_hst_f2';
$visit{'01180029001'} = 'med_hst_f5';
$visit{'01180030001'} = 'med_hst_f6';

print "host is $host\nguitarra_home is $guitarra_home\n";
my $csv_file = '/home/cnaw/guitarra/data/1180.csv';
my ($dithers_id_ref, $dithers_ref, $regions_ref) = 
    get_apt_csv($csv_file);
my (%dithers_id) = %$dithers_id_ref;
my (%dithers)    = %$dithers_ref;
my (%regions)    = %$regions_ref;
my (@regions) ;
my $reg  = $results_path.'regions.reg';
open(REG,">$reg") || die "cannot open $reg";
foreach my $key (keys(%dithers_id)){
    print "key of dithers_id is $key\n";
    print "$dithers_id{$key}\n";
    my($visit_id, $aperture, $targetid) = split(' ',$dithers_id{$key});
#
    if(! exists($visit{$visit_id})) {next;}
#    
    my @dithers = split(' ',$dithers{$key});
    for (my $ii = 0; $ii <=0 ; $ii++) {
	my($ra, $dec, $pa) = split('_',$dithers[$ii]);
	if($aperture =~ m/NRS/) {
	    my $colour  = 'red';
	    my($ra_nrc, $dec_nrc) = 
		translate_nirspec_to_nircam($ra, $dec, $pa);
	    $ra = $ra_nrc;
	    $dec = $dec_nrc;
	    nrc_regions($ra, $dec, $pa, $outline, $colour);
	} else {
	    @regions = split('#',$regions{$key});
	    for (my $ii = 0 ; $ii <= $#regions ; $ii++){
		my @junk = split(' ',$regions[$ii]);
		my $coords = 'fk5;polygon(';
		for(my $jj =2; $jj <= $#junk; $jj++) {
		    $coords = join(' ',$coords, $junk[$jj]);
		}
		$coords = $coords.')';
		print REG $coords,"\n";
	    }
	}
    }
}
close(REG);
exit(0);
#    
#-----------------------------------------------------------------------
#
# Read the file exported via the export -> VisitCoverage tab on APT.
# this will provide the (RA,DEC) positions for each major dither.
# 
sub get_apt_csv{
    my($file) = @_;
    my(@junk);
    my(@dithers);
    my(%dithers, %dithers_id, %regions);
    my(%dither) ;
    open(FILE,"<$file") || die "file $file not found";
    while(<FILE>) {
	chop $_;
#	print "get_apt_csv.pl : $_\n";
	@junk = split('\,',$_);
	my $visit_name  = $junk[0];
	$visit_name     =~ s/\s//g;
	if($visit_name eq 'VisitID') {next;}
	my $move        = $junk[1];
	my $aperture    = $junk[2];
	my $targetid    = $junk[4];
	my $pa          = $junk[5];
	my $ra          = $junk[6];
	my $dec         = $junk[7];
	my $reg         = $junk[8];
#
#  change hash reference to visit_name (2020-03-06)
#
	$targetid       = $visit_name;
	$dithers_id{$targetid} = join(' ', $visit_name, $aperture, $junk[4]);
	
	if(exists($dithers{$targetid})) {
	    $dithers{$targetid} = 
		join(' ', $dithers{$targetid},join('_',$ra,$dec,$pa,$move)); 
	} else {
	    $dithers{$targetid} = join('_',$ra,$dec,$pa,$move); 
	}
#
	if(exists($regions{$targetid})) {
	    next;
	    $regions{$targetid} = join('#',$regions{$targetid},$reg);
	} else {
	    $regions{$targetid} = $reg;
	}
    }
    close(FILE);
    return \%dithers_id, \%dithers, \%regions;
}

