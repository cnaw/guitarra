#!/usr/bin/perl -w
#
# write_jades_parameters is specifically designed to write inputs
# for a JWST proposal. The sequence of observations is derived from
# the APT output (e.g. the xml, visit coverage and pointings in the
# APT export tag).
use strict;
use warnings;
use Scalar::Util qw(looks_like_number);
use Cwd qw(cwd getcwd);

# Environment variables
#
#my $host          = $ENV{HOST};
my $guitarra_home = $ENV{GUITARRA_HOME};
my $guitarra_aux  = $ENV{GUITARRA_AUX};
my $python_dir    = $ENV{PYTHON_DIR};
#
# This makes life easier for debugging
# if not defined
#
#$guitarra_home = "~/guitarra"      unless defined $guitarra_home;
#$guitarra_aux  = "~/guitarra/data/" unless defined $guitarra_aux;
$guitarra_home = "."      unless defined $guitarra_home;
$guitarra_aux  = "./data/" unless defined $guitarra_aux;
#
#print "host is $host\nguitarra_home is $guitarra_home\n";
print "guitarra_home is $guitarra_home\n";
my $perl_dir      = $guitarra_home.'/perl/';
my $results_path  = $guitarra_home.'/results/';
#
# This changes everytime pysiaf gets updated:
my $siaf_link  = $guitarra_aux.'PRDOPSSOC-latest';
my $siaf_version = `ls -l $siaf_link`;
print "$siaf_version\n";
my @junk = split(' ',$siaf_version);
$siaf_version = $junk[$#junk];
@junk = split('\/',$siaf_version);
$siaf_version = $junk[$#junk];

my $aptid     = $ARGV[0];
my $galaxy_catalogue = $guitarra_aux.$ARGV[1];
my $list      = 'none';

####################################
# set appropriate path in the case of code development/debugging
#
# this is the directory where the parameter and input files to guitarra 
# are written
#
my $path = $results_path;
print "$path\n";
my $wd = getcwd;
my $read_apt_output;

###################################
if($wd eq '/home/cnaw/git_arra/perl' || $wd eq '/home/cnaw/git_arra') {
    print "wd is $wd\n";
    $read_apt_output= "/home/cnaw/git_arra/perl/read_apt_output.pl";
    require "/home/cnaw/git_arra/perl/print_batch.pl";
    require "/home/cnaw/git_arra/perl/read_visit_parameters.pl";
    require "/home/cnaw/git_arra/perl/subarray_params.pl";
    require "/home/cnaw/git_arra/perl/set_readout_parameters.pl";
    require "/home/cnaw/git_arra/perl/sub_pa_bkg.pl";
} else {
    $read_apt_output= $perl_dir."read_apt_output.pl";
    require $perl_dir."print_batch.pl";
    require $perl_dir."read_visit_parameters.pl";
    require $perl_dir."subarray_params.pl";
    require $perl_dir."set_readout_parameters.pl";
    require $perl_dir."sub_pa_bkg.pl";
}
#
#------------------------------------------------------------------------------------
# 
my $activity_id = 1;
my $aperture;
my $aptcat;
my $at_least_one;
my $biglist;
my $brain_dead_test = 0;
my $cat;
my $catalogue_filter_index;
my $catalogue_input;
my $category;
my $columns;
my $command;
my $coords;
my $counter;
my $cr_history;
my $date;
my $debug = 0 ;
my $dec;
my $dec0;
my $distortion;
my $colcornr;
my $expripar;
my $exposure_request;
my $filter;
my $filter_index;
my $filters_in_cat;
my $first_command;
my $flatfield;
my $header;
my $hst_filter = 'F606W';
my $i;
my $input;
my $input_clone_catalogue = 'none';
my $input_g_catalogue;
my $input_s_catalogue;
my $key;
my $label;
my $line;
my $long_filter;
my $long_pupil;
my $max_groups;
my $module;
my $n_images;
my $naxis1;
my $naxis2;
my $n;
my $nc;
my $ndithers;
my $nf;
my $nframe;
my $ngroups;
my $nints;
my $nn;
my $noise_file;
my $noiseless;
my $nskip;
my $obs_date;
my $observation_number;
my $output_file;
my $output_clone_cat = 'none';
my $parallel_input;
my $parallel_instrument;
my $parameter_file;
my $patt_num;
my $pa_degrees;
my $pa_v3;
my $pa_v3_max;
my $pa_v3_min;
my $position;
my $ppp;
my $primary_dithers;
my $primary_dither_string;
my $primary_dither_type;
my $primary_instrument;
my $program;
my $pupil;
my $ra;
my $ra0;
my $readout_pattern;
my $regions_rd;
my $regions_xy;
my $rows;
my $rowcornr;
my $sca_id;
my $sca_ref;
my $second_command;
my $seed;
my $sequence_id ;
my $set_pa = 0;
my $star_catalogue;
my $short_filter;
my $short_pupil;
my $subarray;
my $subpixel;
my $subpixel_dither_type;
my $subpxnum;
my ($substrt1,$substrt2);
my $sw_ref;
my $targprop;
my $targetarchivename;
my $target_dir ;
my $target_number;
my $targetid;
my $third_command;
my $title;
my $tute_file;
my $dms_name;
my $total_moves = 0;
my $use_filter_ref;
my $verbose = 0;
my $visit;
my $visit_id;
my $visit_group = 1;
my ($tar, $tile, $exposure, $subpixel_dither, $xoffset, $yoffset, $v2, $v3);

my $include_bias       =  0 ;
my $include_ktc        =  0 ;
my $include_dark       =  0 ;
my $include_dark_ramp  =  0 ;
my $include_flat       =  0 ;
my $include_latents    =  0 ;
my $include_non_linear =  0 ;
my $include_readnoise  =  0 ;
my $include_reference  =  0 ;
my $include_1_over_f   =  0 ;
my $include_ipc        =  0 ;
#
my @aptcats;
my @column;
my @coords;
my @filters;
my @names;
my @sca;
my @use_psf;
my @values;
#
my %background;
my %cat_filter_number;
my %catalogue_filter_index;
my %exptype;
my %full_filter_set_number;
my %images_per_filter;
my %path;
my %pa_adopted;
my %sca_name;
my %sequence;
my %sw;
my %use_filter;
$sca_name{'481'} = 'NRCA1';
$sca_name{'482'} = 'NRCA2';
$sca_name{'483'} = 'NRCA3';
$sca_name{'484'} = 'NRCA4';
$sca_name{'485'} = 'NRCA5';
$sca_name{'486'} = 'NRCB1';
$sca_name{'487'} = 'NRCB2';
$sca_name{'488'} = 'NRCB3';
$sca_name{'489'} = 'NRCB4';
$sca_name{'490'} = 'NRCB5';
#
$sw_ref         = initialise_channel_filters();
%sw           = %$sw_ref;
$use_filter_ref = initialise_filters();
%use_filter   = %$use_filter_ref;

#
# Input parameters
# add FOV distortion (1)
my $ngal   = 0 ;
my $nstars = 0;
my $include_galaxies            = 1;
my $include_cloned_galaxies     = 0;
$distortion     =  1;
my $faint       = 32.0;
my $bright      = 11.0;
# File background estimates calculated using the JWST tools
# (should be an input parameter)
my $background_file  = $guitarra_aux.'/jwst_bkg/'.'goods_s_2019_12_21.txt'; 

if($#ARGV < 1) {
    print "if using a background file it must be located in  $guitarra_aux/jwst_bkg/\n";
    print "use is\n from_apt_to_guitarra.pl apt_number catalogue_name -d distortion -f faint_limit -b bright_limit -date obs_date -set_pa  obs_pa -background goods_s_2019_12_21.txt\n";
    print "use is\n from_apt_to_guitarra.pl apt_number catalogue_name -d distortion -f faint_limit -b bright_limit -date obs_date -set_pa  obs_pa clone\n";
    print "use is\n from_apt_to_guitarra.pl apt_number catalogue_name -d 1 -f 30 -b 10 -date 2022-06-16 -set_pa 120. clone\n";
    print "use is\n from_apt_to_guitarra.pl apt_number catalogue_name -d distortion -f faint_limit -b bright_limit -l list\n";
    print "from_apt_to_guitarra.pl 1180 combined_data_challenge2_2020_10_08_nokids.cat 2 21 17 data_challenge_2.list\n";
    exit(0);
}

if(! -e $background_file) {
    print "guitarra will need a background file calculated using the STScI background tool\n";
    print "which needs to be placed in the $guitarra_aux/jwst_bkg directory\n";
    exit(0);
}

$aptid     = $ARGV[0];
$galaxy_catalogue = $guitarra_aux.$ARGV[1];
$list      = 'none';
$target_dir = $guitarra_aux;
$distortion = 1;
$faint      = 31;
$bright     =  8;
$obs_date   = 'none';
$set_pa     = -999 ;
for (my $ii = 2 ; $ii <= $#ARGV; $ii++) {
    if($ARGV[$ii] eq '-f' || $ARGV[$ii] eq '--f' || 
       $ARGV[$ii] eq '-faint' || $ARGV[$ii] eq '--faint'){
	$ii++;
	$faint = $ARGV[$ii];
    }
    if($ARGV[$ii] eq '-b' || $ARGV[$ii] eq '--b' || 
       $ARGV[$ii] eq '-bright' || $ARGV[$ii] eq '--bright'){
	$ii++;
	$bright = $ARGV[$ii];
    }
    if($ARGV[$ii] eq '-pa' || $ARGV[$ii] eq '-pa' || 
       $ARGV[$ii] eq '-set_pa' || $ARGV[$ii] eq '--set_pa'){
	$ii++;
	$set_pa = $ARGV[$ii];
    }
    if(lc($ARGV[$ii]) eq '-hst_filter' ||
       lc($ARGV[$ii]) eq '--hst_filter'){
	$ii++;
	$hst_filter = $ARGV[$ii];
    }
    if($ARGV[$ii] eq '-date' || $ARGV[$ii] eq '--date'){
	$ii++;
	$obs_date = $ARGV[$ii];
	$obs_date =~ s/_/-/g;
#	$set_pa   = 1000;
#	my ($year, $month, $day) = split('-',$obs_date);
#	if($year <= $day ) {
#	    print "\n\n******  ERROR ******\n\n";
#	    print "date should be in the form year-month-day: e.g., -date 2021_12_21\n";
#	    print "this constraint is imposed by the STScI Background calculation tool\n";
#	    print "please try again\n";
#	    exit(0);
    }
    if($ARGV[$ii] eq '-bg' || $ARGV[$ii] eq '-background' || $ARGV[$ii] eq '-bkg'){
	$ii++;
	$background_file = $guitarra_aux.'/jwst_bkg/'.$ARGV[$ii];
    }
#
    if($ARGV[$ii] eq '-d' || $ARGV[$ii] eq '--d' ||
       $ARGV[$ii] eq '-distortion' || $ARGV[$ii] eq '--distortion'){
	$ii++;
	$distortion = $ARGV[$ii];
    }
# a single aptcat ?
    if($ARGV[$ii] eq '-l' || $ARGV[$ii] eq '--l' ||
       $ARGV[$ii] eq '-list' || $ARGV[$ii] eq '--list'){
	$ii++;
	$list = $ARGV[$ii];
    }
#   include clone 
    if(lc($ARGV[$ii]) =~ m/clone/){
	$include_cloned_galaxies = 1;
    }
#   exclude models
    if(lc($ARGV[$ii]) eq '-no_model'){
	$include_galaxies = 0;
    }
}
if($include_cloned_galaxies == 1) {
    $input_clone_catalogue  = $galaxy_catalogue;
    $input_clone_catalogue  =~ s/.cat/_clone.cat/;
    $galaxy_catalogue =~ s/.cat/_noclone.cat/;
}
print "at line : ",__LINE__,"\n";
print "from_apt_to_guitarra.pl\n\naptid                  : $aptid\ncatalogue              : $galaxy_catalogue\ndistortion (yes==1)    : $distortion\nfaint limit            : $faint\nbright limit           : $bright\ndate                   : $obs_date\ninclude_galaxies       : $include_galaxies\ninclude_cloned_galaxies: $include_cloned_galaxies\nbackground file        : $background_file\nset_pa                 : $set_pa\nSIAF version           : $siaf_version\n";
$command = join(' ', $read_apt_output, $aptid);
print "executing:\n$command\n";
my $result = system($command);
#
print "exit read_apt_output\npause";
<STDIN>;
#

#
if($list eq 'none') {
    my $var =  $results_path.sprintf("%05d*params.dat",$aptid);
    print "\n\nfrom_apt_to_guitarra.pl at line : ",__LINE__," var : $var\n";
    @aptcats = `ls $var | grep -v complete`;
} else {
    @aptcats = ();
    my $var = $guitarra_aux.'/'.$list;
    print "var : $var\n";
    open(LIST,"<$var") || die "cannot open $var";
    while(<LIST>) {
	chop $_;
	push(@aptcats,$results_path.'/'.$_);
    }
}
print "from_apt_to_guitarra.pl at line : ",__LINE__,"   aptcats:\n@aptcats\n";

#my @aptcats = `ls $var | grep Medium_HST`;
# the list of NIRCam filters should be read from the APT
$biglist  = $results_path.sprintf("%04d_complete_params.dat",$aptid);

open(FULL_LIST,">$biglist") || die" cannot open $biglist";
for(my $ii = 0 ; $ii <= $#aptcats ; $ii++) {
    $aptcats[$ii] =~ s/\n//g;
    $aptcat = $aptcats[$ii];
    if($aptcat =~ m/spec/) {next;}
    print "at line : ",__LINE__," aptcat is $aptcat\n";
    open(CAT,"<$aptcat") || die "cannot open $aptcat";
    while(<CAT>) {
	print FULL_LIST $_;
	print "$_";
	chop $_;
	@junk = split(' ',$_);
	if(lc($junk[0]) eq  'ra') {
	    $ra = $junk[1];
	}
	if(lc($junk[0]) eq  'declination') {
	    $dec = $junk[1];
	}
	if(lc($junk[0]) eq  'pa_v3') {
	    $pa_v3 = $junk[1];
	}
	if(lc($junk[0]) eq  'visit_id') {
	    $visit_id = $junk[1];
	}
	# to use a filter set value to 1
	if(lc($junk[0]) =~ m/filter/){
	    $filter = $junk[1];
	    if($filter =~ m/\+/) {
		print "at line : ",__LINE__," splitting combined filter: $_\n";
		my @combined = split('\+',$filter);
		$filter = $combined[0];
	    }
	    $use_filter{$filter} = 1;
	}
    }
    close(CAT);
#    print "at line : ",__LINE__," ra, dec, pa_v3, visit: $ra $dec $pa_v3 $visit_id\n";
    $pa_adopted{$visit_id} = $pa_v3;
#    $background_file = 'none';
    #    ($background_file,$pa_v3_min, $pa_v3_max) = sub_pa_bkg( $ra, $dec, $pa_v3, $visit_id, $target_dir, $obs_date);
    $background{$visit_id} = $background_file;
#    if(defined($pa_v3_min) && defined($pa_v3_max)) {
#	$set_pa = ($pa_v3_min + $pa_v3_max)/2.0;
#	$pa_adopted{$visit_id} = $set_pa;
#    } else {
##    if($set_pa == 1000.) {
#	$pa_adopted{$visit_id} = $pa_v3;
#    }
#    print "at line : ", __LINE__," visit $visit_id pa_adopted: $pa_adopted{$visit_id}\n";
#    print "at line : ",__LINE__," pause";
#    <STDIN>;
}
close(FULL_LIST);
$aptcat    = $biglist;
$star_catalogue              = 'none';

#
# Read list of filters
#
my $string = $guitarra_aux.'/nircam_filters/*dat';
#my @filter_path = `ls $string | grep -v w2`;
my @filter_path = `ls $string`;
#print "@filter_path";
foreach $filter (sort(keys(%use_filter))) {
    if($use_filter{$filter} == 0) {next;}
    $a = lc($filter);
    for($i = 0 ; $i <= $#filter_path; $i++) {
	$filter_path[$i] =~ s/\n//g;
	if($filter_path[$i] =~ m/$a/) {
	    $path{$filter} = $filter_path[$i];
	    last;
	}
    }
    if($verbose == 1) {
	print "at line : ",__LINE__," using $filter $path{$filter}\n";
    }
}
#die;
#
# Write file with parameters to be read by simulator
# Random numbers - use system clock (0) or a deterministic sequence(1)
$seed           =  0;
#
# Write "stsci" style output?
my $write_tute = 1;
#     sources to include
#
#
# subarray mode
#
#$subarray ='FULL';
#     
#$colcornr =    1;
#$rowcornr =    1;
#$naxis1   = 2048;
#$naxis2   = 2048;
#
# List of point spread functions
#
$string = $guitarra_aux.'WebbPSF_NIRCam_PSFs/*.fits';
my @psf = `ls $string`;
#print "@psf\n";
#
#-----------------------------------------------------------
#
# Instrumental signatures to include
#

$noiseless = 0 ;

if($noiseless != 1) {
    $include_bias       =  1 ;
    $include_ktc        =  1 ;
    $include_dark       =  0 ;
    $include_dark_ramp  =  0 ;
    $include_latents    =  0 ;
    $include_non_linear =  1 ;
    $include_readnoise  =  1 ;
    $include_reference  =  1 ;
    $include_1_over_f   =  0 ;
    $include_ipc        =  1 ;
    $include_flat       =  1 ;
}
# 2020-05-10 if dark ramps are included, need to change some settings:
if($include_dark_ramp == 1) {
    $include_ktc        = 0;
    $include_bias       = 0;
    $include_dark       = 0;
    $include_reference  = 0;
    $include_1_over_f   = 0;
}

#------------------------------------------------------------
#  External sources of noise
#
# Background
#
my $include_bg            = 1   ;
#------------------------------------------------------------
#
# Cosmic rays
#     cr_mode:
#     0         -  Use ACS observed counts for rate and energy levels
#     1         -  Use M. Robberto models for quiet Sun
#     2         -  Use M. Robberto models for active Sun
#     3         -  Use M. Robberto models for solar flare (saturates)
#
my $include_cr        = 1 ;
my $cr_mode           = 2 ;
#
#
#
# Filters contained in catalogue; need to add HST or other filters
# The galaxy catalogue must have the list of filters in the header.
#
my ($catalogue_filter_ref) = catalogue_filters();
my (%catalogue_filter) = %$catalogue_filter_ref;
#
# read filter information from the catalogue
# check that at least one filter exists in the catalogue. If not
# prompt user to add a header with filter names
#
open(CAT,"<$galaxy_catalogue") || die "cannot open $galaxy_catalogue";
$header = <CAT>;
close(CAT);
$at_least_one = 0;
$filter_index = -1;
if($header =~ m/#/) {
#    print "$header\n";
    @column = split(' ',$header);
    for($i = 0 ; $i <= $#column ; $i++) {
	$column[$i] =~ s/NIRCAM_//;
	if($column[$i] =~ m/F/) {
	    if($column[$i] =~ m/W/ || $column[$i] =~ m/M/ 
	       || $column[$i] =~ m/N/ ) {
		$filter = $column[$i];
		$catalogue_filter{$filter} = 1;
		$filter_index++;
#		$catalogue{$filter} = 1;
		$catalogue_filter_index{$filter} = $filter_index;
		if($verbose == 1) {
		    print "at line : ",__LINE__," catalogue contains filter $filter filter index is $filter_index\n";
		}
		$at_least_one++;
	    }
	}
    }
}
if($at_least_one == 0){
    print "filters not identified in catalogue file.\n";
    print "Need to add header to catalogue identifying filter columns\n";
    exit(0);
}
#
# Go through list of filters in catalogue and set
# $catalogue_filter{filter} = 1
# This is done so guitarra reads the correct
# list of calibrated filters
#
%full_filter_set_number = ();
%cat_filter_number  = () ;
$nc                 = 0;
$filters_in_cat     = 0;
foreach $filter (sort(keys(%catalogue_filter))) {
# nc is the position of this filter in the list of filters (includes all filters)
    $nc++;
    if($catalogue_filter{$filter} == 1) {
# this is the position of filter in catalogue
	$filters_in_cat++;
	$full_filter_set_number{$filter} = $nc ;
	$cat_filter_number{$filter} = $filters_in_cat;
	if($verbose == 1) {
	    print "at line : ",__LINE__," filter in source catalogue : $filter $filters_in_cat in full set $nc\n";
	}
    }
}
print "number of filters in catalogue : $filters_in_cat\n";
#
# go through list of filters for which simulated data are
# being requested. If a filter is being requested that does
# not exist in the database exit (one could change to skip it 
# instead)
#
$nf    =  0;
$n     = -1;
@filters = () ;
@names   = () ;
foreach $filter (sort(keys(%use_filter))) {
    $n++;
    if($use_filter{$filter} == 1) {
	if(! exists($catalogue_filter{$filter}) || $catalogue_filter{$filter} != 1) {
	    print "at line : ",__LINE__," filter $filter is not contained in source catalogue\n";
	    print "skipping...\npause";
	    $use_filter{$filter} = 0;
	    #	    print "exiting...\n";
	    #	    exit(0);
	    next;
	}
#	$n++;
	push(@filters, $n+1);
	push(@names, $filter);
#	push(@cat_filter, $cat_filter_number{$filter});
	$nf++;
    }
}

print "filters used in simulation: $nf\n";
#
#####################################################################
# if($nstars > 0 && $star_catalogue eq 'none') {
#    print "inconsistent catalogue for stellar sources: $nstars, $star_catalogue\n";
#    exit(0);
# }

if($ngal > 0 && $galaxy_catalogue eq 'none') {
    print "inconsistent catalogue for galaxies: $ngal, $galaxy_catalogue\n";
    exit(0);
}
#
#####################################################################
#
# From here start processing
#
################################################################################
#
#  Organise in such a way that there is this type of nesting:
#  filter -> sca -> dithers
#
if($verbose > 0) {print "at line : ",__LINE__,"\n";}
print "at line : ",__LINE__, " aptcat is $aptcat\n";
my($setup_ref) = read_visit_parameters($aptcat, $debug);
my(%visit_setup) = %$setup_ref;
my @keys = sort(keys % { $setup_ref });
if($verbose > 0) {print "at line : ", __LINE__," keys : @keys\n";}
foreach $visit (sort(keys(%visit_setup))){
    if($verbose > 0) {
	print "at line : ",__LINE__," visit : $visit $visit_setup{$visit}\n";
    }
    @values = split('#',$visit_setup{$visit});
    if($debug == 1||$verbose > 0) {
	for(my $ll = 0 ; $ll <= $#values ; $ll++){
	    print "at line : ",__LINE__," target_number: $visit, line:  $ll $values[$ll]\n";
	}
#	<STDIN>;
    }
}
#
$n_images = 0;
#
# Read the output gleaned from APT
#
my %by_sca;
my %by_filter;
my %by_coords;
my %by_visit;

foreach $visit (sort(keys(%visit_setup))){
    if($verbose > 0) {print "\nat line : ",__LINE__," visit : $visit\n";}
#

    @values = split('#',$visit_setup{$visit});
#    if($verbose > 0) {
#    print "at line : ",__LINE__, " visit:  $visit_setup{$visit}\n";
#	print "at line : ",__LINE__,"values : @values\n";
#    }
    if($debug == 1 || $verbose > 0) {
	for(my $jj = 0 ; $jj <= $#values ; $jj++){
	    print "at line : ",__LINE__, " $jj $values[$jj]\n";
	} 
	my $n_moves = @values;
	$n_moves = $n_moves - 24;
	$total_moves = $total_moves + $n_moves;
	print "pause at line ", __LINE__," n_moves: $n_moves total_moves : $total_moves\n";
#	<STDIN>;
#    } else{
#	for(my $jj = 0 ; $jj < 22 ; $jj++){
#	    print "at line : ",__LINE__, " $jj $values[$jj]\n";
#	}
#	<STDIN>;
    }
#
# Recover (mainly) header parameters
#
    my $jj = 0;
    $target_number        = $values[$jj];
    $jj++;
    $targetid             = $values[$jj];
    $jj++;
    $targetarchivename    = $values[$jj];
    $jj++;
    $title                = $values[$jj];
    $jj++;
    $label                = $values[$jj];
    $jj++;
    $program              = $values[$jj];
    $jj++;
    $category             = $values[$jj];
    $jj++;
    $expripar             = $values[$jj];
    $jj++;
    $parallel_instrument  = $values[$jj];
    $jj++;
#
    $ra                   = $values[$jj];
    $jj++;
    $dec                  = $values[$jj];
    $jj++;
    $pa_v3                = $values[$jj];
    $jj++;
#
    $module               = $values[$jj];
    $jj++;
    $aperture             = $values[$jj];
    $jj++;
    $primary_dither_type  = $values[$jj];
    $jj++;
    $primary_dither_string= $values[$jj];
    $jj++;
    $primary_dithers      = $values[$jj];
    $jj++;
    $subpixel_dither_type = $values[$jj];
    $jj++;
    $subpixel             = $values[$jj];
    $jj++;
    $subarray             = $values[$jj];
    $jj++;
#
    $visit_id             = $values[$jj];
    $jj++;
    $observation_number   = $values[$jj];
    $jj++;
    $primary_instrument   = $values[$jj];
    $jj++;
    $ndithers             = $values[$jj];
    $jj++;
#
    if($verbose > 0) {print "at line: ",__LINE__," ndithers is $ndithers\n";}
#
#
    my @setup = split('_',$aperture);
#    print "at line : ",__LINE__," visit is $visit; aperture is $aperture\n";
#    $apername = $setup[0];
    if($setup[$#setup] eq 'FULL') {
	$subarray = $setup[$#setup];
    }
#
# These are parameters that get written to the header
#
    my $ii = 0;
    $header = $values[$ii];
    $line = __LINE__ + 1;
    if($verbose > 0){
	printf("at line : %d  %3d  %-30s\n", $line,$ii,$values[$ii]);
    }
    for($ii = 1; $ii< $jj-1; $ii++) {
# make sure there are no commas in strings!
	$values[$ii] =~ s/\,/\_/g;
	$header=join(',',$header, $values[$ii]);
	$line = __LINE__ + 1;
	if($verbose > 0) {
	    printf("at line : %d  %3d  %-30s\n",$line, $ii,$values[$ii]);
	}
    }
#
# These are the dither positions
#
    @coords  = ();
    my $nn =1;
    for (my $ii=$jj ; $ii <= $#values ; $ii++) {
	push(@coords, $values[$ii]);
	if($verbose > 0) {
	    print "at line : ",__LINE__," dither # $nn $ii $values[$ii]\n";
	}
	$nn++;
    }
    if($verbose == 1 || $debug > 0) {
	print "at line : ",__LINE__," pause\n";
	<STDIN>;
    }
#
# Get list of SCAs for this aperture
#
#    print "at line : ",__LINE__," visit is $visit; aperture is $aperture\n";
    $sca_ref = get_scas($aperture);
    @sca     = @$sca_ref;
    my $nsca = @sca ;
    if($nsca <= 0) {
	print "at line : ", __LINE__," the number of SCAS is nsca = $nsca\n";
	print "at line : ", __LINE__," aperture: $aperture ; scas: @sca\n";
	if($parallel_instrument eq 'NIRCAM') {
	    print "at line : ", __LINE__," parallel_instrument : $parallel_instrument\n";
	    $aperture = 'NRCALL';
	    $sca_ref = get_scas($aperture);
	    @sca     = @$sca_ref;
	    $nsca = @sca ;
	} else {
	    print "skipping this exposure\n";
#	    <STDIN>;
	    next;
	}
    }
#
# loop over filters being simulated
#
    foreach $filter (sort(keys(%use_filter))) {
	if($use_filter{$filter} != 1) {next;}
	if($verbose > 0) {print "at line : ",__LINE__," filter is $filter\n";}
#    for (my $jj = 0 ; $jj <= $#sca; $jj++) {
#	$sca_id = $sca[$jj];
	$counter = 0;
#
# Loop over dither positions
#
	for (my $kk = 0 ; $kk <= $#coords ; $kk++) {
	    $coords[$kk] =~ s/\s//g;
#
# This is to prevent cases of "undefined short and long" filters in case of NIRSPEC prime
#
	    my @junk = split('\,',$coords[$kk]);
	    if($#junk == 0) { next;}
	    my $kk1 = $kk+1;
	    if($debug >0 || $verbose == 1){print "at line ",__LINE__,"  $kk1 $coords[$kk]\n";}
	    ($ra, $dec, $pa_v3, $short_filter, $long_filter,$readout_pattern, $ngroups,$nints,$short_pupil, $long_pupil,$tar, $tile, $exposure, $subpixel_dither, $xoffset, $yoffset, $v2, $v3)
		=split('\,',$coords[$kk]);
# random assignment:
	    $visit_group = $exposure;
	    # 
	    if($short_filter eq '' || $long_filter eq '') {
		print "at line ",__LINE__,"\nvisit is $visit\nshort_filter is: $short_filter;\nlong_filter is: $long_filter;\n";
		print "kk is $kk coords[$kk] is $coords[$kk] #junk is $#junk\npause\n";
		<STDIN>;
	    }
#
# Loop over SCAs
#
#	    foreach $filter (sort(keys(%use_filter))) {
#		if($use_filter{$filter} != 1) {next;}
	    for (my $jj = 0 ; $jj <= $#sca; $jj++) {
		$sca_id = $sca[$jj];
		if($sca_id ==  485 || $sca_id == 490) {
		    $pupil = $long_pupil;
		} else {
		    $pupil = $short_pupil;
		}
#
# test that the filter and SCA being simulated are consistent
#
		if(($sca_id == 485 || $sca_id == 490) && $sw{$filter} == 1) {next;}
		if(($sca_id != 485 && $sca_id != 490) && $sw{$filter} == 0) {next;}
#
#		print "at line : ",__LINE__," filter is $filter short_filter is $short_filter long_filter is $long_filter\n";
#		if($short_filter eq $filter || $long_filter eq $filter) {
#      Kludge so F164N+F150W2 can run.  Line above should be the correct text
		if($short_filter =~ m/$filter/ || $long_filter =~ m/$filter/) {
#		print "at line : ",__LINE__," filter is $filter short_filter is $short_filter long_filter is $long_filter\n";		    $counter++;
		    $n_images++;

#
# These are different options to organise the simulations
#
#		    if(exists($by_visit{$visit})) {
#			$by_visit{$visit} = join(' ',$by_visit{$visit},join('#',$visit, $sca_id, $filter,$header,$coords[$kk]));
#		    } else {
#			$by_visit{$visit} = join('#',$visit, $sca_id, $filter,$header,$coords[$kk]);
#		    }
		    
		    if(exists($by_filter{$filter})) {
			$by_filter{$filter} = join(' ',$by_filter{$filter},join('#',$visit, $sca_id, $filter,$pupil,$header,$coords[$kk]));
#			printf("3  %-30s %-20s %s\n",$targetid, $expripar, $aperture);
		    } else {
			$by_filter{$filter} = join('#',$visit, $sca_id, $filter,$pupil,$header,$coords[$kk]);
		    }
		    
		    if(exists($by_sca{$sca_id})) {
			$by_sca{$sca_id} = join(' ',$by_sca{$sca_id},join('#',$visit, $sca_id, $filter,$pupil,$header,$coords[$kk]));
		    } else {
			$by_sca{$sca_id} = join('#',$visit, $sca_id, $filter,$pupil,$header,$coords[$kk]);
		    }
#
#		    if(exists($by_coords{$coords[$kk]})) {
#			$by_coords{$coords[$kk]} = join(' ',$by_coords{$coords[$kk]},join('#',$visit, $sca_id, $filter,$header,$coords[$kk]));
#		    } else {
#			$by_coords{$coords[$kk]} = join('#',$visit, $sca_id, $filter,$header,$coords[$kk]);
#		    }
		}
	    } # close loop over filter
	} # close loop over dither positions
    } # close loop over SCAs
} # close loop over visit
#
############################################################################
#
# write out the batch file, looping over filters, SCAs, dithers
#
# This is the output file:
#
$parallel_input = 'batch';
#
$n_images = 0;
my $translation = $aptid.'_mirage_guitarra.dat';
$translation = $guitarra_home.'/results/'.$translation;
open(TRANS,">$translation") || die "cannot open $translation";
open(BATCH,">$parallel_input") || die "cannot open $parallel_input";
$nn = 0 ;
$counter = 0;
my(@exposures);

print "at line : " ,__LINE__," writing input files to guitarra in file: $parallel_input\n";
foreach $key (sort(keys(%by_filter))) {
    @exposures = split(' ', $by_filter{$key});
#foreach $key (sort(keys(%by_visit))) {
#    @exposures = split(' ', $by_visit{$key});
    my $nexp = scalar(@exposures);
    if(exists($images_per_filter{$key})) {
	$images_per_filter{$key} = $images_per_filter{$key}+$nexp;
    } else {
	$images_per_filter{$key} = $nexp;
    }
    if($verbose == 1) {print "at line : ",__LINE__," key $key number of exposures: $nexp\n";}
    print "at line : ",__LINE__," key $key number of exposures: $nexp\n";
#    next;
    my %sca_exp;
    for (my $ii = 0 ; $ii <= $#exposures ; $ii++) {
	($visit, $sca_id, $filter,$pupil, $header, $coords) = split('#',$exposures[$ii]);
	$nn++;
	$counter++;

	($target_number, $targetid, $targetarchivename,$title, $label, 
	 $program, $category, $expripar, $parallel_instrument,
	 $ra, $dec, $pa_v3, $module, $aperture, 
	 $primary_dither_type, $primary_dither_string,$primary_dithers,$subpixel_dither_type,$subpixel,
#	 $primary_dither_type, $primary_dithers,$subpixel_dither_type,$subpixel,
	 $subarray, $visit_id,$observation_number,$primary_instrument) = split('\,',$header);
# These are the actual coordinates used for pointing
	($ra0, $dec0, $pa_degrees, $short_filter, $long_filter, $readout_pattern, $ngroups, $nints, $short_pupil, $long_pupil,$tar, $tile, $exposure, $subpixel_dither, $xoffset, $yoffset, $v2, $v3)
	    = split('\,',$coords); 
#
	($colcornr, $rowcornr, $naxis1, $naxis2,$substrt1,$substrt2) = 
	    subarray_params($sca_id, $subarray);
	if($verbose == 1 || $debug > 0){
	    print "at line : ",__LINE__," visit: $visit sca : $sca_id, subarray: $subarray limits: $colcornr, $rowcornr, $naxis1, $naxis2\n";
	    print "at line : ",__LINE__, "  $coords\npause";
	    <STDIN>;
	}
	# This seems to be the correct definition
	if($expripar eq 'PRIME') {
	    $sequence_id = 1;
	} else {
	    $sequence_id = 3;
	}
# this is the patt_num keyword, corresponding to the position number 
# in primary pattern. The code below is incorrect showing the dither number
# (large+small)
	my $key = join('_',$filter,$sca_id,$visit_id);
	if(exists($sequence{$key})) {
	    $sequence{$key} = $sequence{$key} + 1;
	} else {
	    $sequence{$key} = 1;
	}
#	
# this is done to populate some of the JWST keywords. These refer to the
# order  within a dither sequence. Needs verification
#
# MOSAIC has 0 (!!) primary dither positions
#
	$position  = $ii;
	$subpxnum = 1;
 	if($primary_dithers == 0) {
 	    $position = 0;
# 2021-06-22 : to make compatible with mirage
	    $primary_dithers = 1;
	    $position        = 1;
	} else {
	    $position  = int(0.50+($sequence{$key} / $subpixel)) ;
#	    $position  = int(($sequence{$key} / $subpixel)) ;
	}
	$subpxnum  = int($sequence{$key} % $subpixel);
	if($subpxnum == 0) {$subpxnum = $subpixel;}

	#
#	if($sca_id == 485) {
#	    print "at line : ",__LINE__," $nn,  $ii, $visit, $sca_id, $filter,$header, $sequence{$key} $ra0, $dec0\n";
# 	    print "at line : ",__LINE__," key: $key, $sca_id, $filter, $visit_id, $observation_number, sequence: $sequence{$key}, primary_dither_type $primary_dither_type $primary_dithers, subpixel_Type $subpixel,  dither: $position, subpixel: $subpxnum\n";
#	    <STDIN>;
#	}
	# These are parameters required to create 1/F noise
#
	($max_groups, $nframe, $nskip)= set_params($readout_pattern);
	if($ngroups > $max_groups) {
	    print "number of groups $ngroups greater than max_groups $max_groups\npause\n";
#	    exit(0);
	    <STDIN>;
	}
# 1/F noise
#	    
	if($include_1_over_f == 1) {
	    my($one_over_f_naxis3) =($ngroups-1) * ($nframe+$nskip) + $nframe;
	    $noise_file = join('_','ng_hxrg_noise',$filter,$sca_id,
			       sprintf("%04d",$counter).'.fits');
	    $command = join(' ','python','run_nghxrg.py',$sca_id,$one_over_f_naxis3, $noise_file);
#		print BATCH $command,"\n";
	} else {
	    $noise_file = 'None';
	    $command = 'date'; # serves as a filler 
	    #		print BATCH $command,"\n";
	}
	
	
#
# name of simulated file
#	$output_file = join('_','apt',sprintf("%05d",$aptid),$filter,$sca_id,sprintf("%04d",$counter).'.fits');
	$output_file = join('_','apt',$visit_id,$filter,$sca_id,sprintf("%04d",$counter).'.fits');
#	$output_file = join('_','xxx',sprintf("%05d",$aptid),$filter,$sca_id,sprintf("%04d",$counter).'.fits');
	$output_file = $path.$output_file;
#	$catalogue_input = join('_','cat',$filter,$sca_id,sprintf("%04d",$counter).'.input');
	$catalogue_input = join('_','cat',$visit_id,$filter,$sca_id,sprintf("%04d",$counter).'.input');
	$catalogue_input = $path.$catalogue_input;
#	$input = $path.join('_','params','apt',sprintf("%05d",$aptid),$filter,$sca_id,sprintf("%04d",$counter).'.input');
	$input = $path.join('_','params','apt',$visit_id,$filter,$sca_id,sprintf("%04d",$counter).'.input');
#
# Catalogues with X, and Y positions derived from RA and DEC
#
	$input_s_catalogue = $star_catalogue;
	$input_s_catalogue =~ s/.cat//g;
	$input_s_catalogue = join('_',$input_s_catalogue,'apt',sprintf("%05d",$aptid),$filter,$sca_id,sprintf("%04d",$counter).'.cat');
	$input_g_catalogue = $galaxy_catalogue;
	$input_g_catalogue =~ s/$guitarra_aux//;
	$input_g_catalogue =~ s/.cat//g;
#	$input_g_catalogue = $path.join('_',$input_g_catalogue,'apt',sprintf("%05d",$aptid),$filter,$sca_id,sprintf("%04d",$counter).'.cat');
	$input_g_catalogue = $path.join('_',$input_g_catalogue,'apt',$visit_id,$filter,$sca_id,sprintf("%04d",$counter).'.cat');
#
# output catalogue
#
	$regions_rd = $output_file;
	$regions_rd =~ s/.fits/_rd.reg/;
	$regions_xy = $output_file;
	$regions_xy =~ s/.fits/_xy.reg/;
	$cat = $catalogue_input;
	if($pa_adopted{$visit_id} eq '') {
	    $pa_adopted{$visit_id} = $pa_v3;
	    print "setting pa_adopted{$visit_id} to $pa_v3\n";
	    <STDIN>;
	}
	if($pa_adopted{$visit_id} > -900) {
	    $pa_degrees = $pa_adopted{$visit_id};
	}
#  clone catalogue
	if($include_cloned_galaxies == 1) {
#	    $galaxy_catalogue =~ s/.cat/_noclone.cat/;
#	    $input_clone_catalogue  = $galaxy_catalogue;
#	    $input_clone_catalogue  =~ s/.cat/_clone.cat/;
	    $output_clone_cat      = $input_g_catalogue;
	    $output_clone_cat      =~ s/noclone/clone/;
	}
#-------------------------------------------------------------------	
#
#	Input to Proselytism
#	
#	print "at line : ",__LINE__," apt cat $visit_id, $pa_degrees, $pa_adopted{$visit_id}\n";
#	<STDIN>;
	open(CAT,">$cat") || die "cannot open $cat";
	print CAT $filters_in_cat,"\n";
	$line = join(' ',$ra0, $dec0,$pa_degrees);
	print CAT $line,"\n";
	print CAT $sca_id,"\n";
	print CAT $star_catalogue,"\n";
	print CAT $input_s_catalogue,"\n";
	print CAT $galaxy_catalogue,"\n";
	print CAT $input_g_catalogue,"\n"; 
	print CAT $distortion,"\n";
	print CAT $siaf_version,"\n";
	print CAT $regions_rd,"\n";
	print CAT $regions_xy,"\n";
	print CAT $aperture,"\n";
	print CAT $subarray,"\n";
	print CAT $bright,"\n";
	print CAT $faint,"\n";
	print CAT $include_cloned_galaxies,"\n";
	print CAT $input_clone_catalogue,"\n";
	print CAT $output_clone_cat,"\n";
	print CAT $hst_filter,"\n";
	close(CAT);

#-------------------------------------------------------------------	

	$command = join(' ',$command,';',$guitarra_home.'/bin/proselytism','<',$catalogue_input);
#		print "$command\n";
	$first_command = $command;
	$n_images++;
#
# Get PSF file
#
	@use_psf = ();
	for($ppp = 0 ; $ppp <= $#psf ; $ppp++) {
	    if($filter =~ m/W2/) {
		if($psf[$ppp] =~ m/$filter/) {
		    push(@use_psf,$psf[$ppp]);
		}
	    } else {   
		if($psf[$ppp] =~ m/$filter/ && $psf[$ppp] !~ m/W2/ ) {
		    push(@use_psf,$psf[$ppp])
		}
	    }
	}
	if($#use_psf == -1) {
	    print "No PSFs have been associated to this filter: $filter\n";
	    die;
	}
#
# parameter file read by the main code with RA0, DEC0
#
#	$parameter_file = 
#	    $results_path.output_name('apt_'.sprintf("%05d",$aptid).'_'.$filter, $sca_id, $counter);
	$parameter_file = 
	    $results_path.output_name('apt_'.$visit_id.'_'.$filter, $sca_id, $counter);

# official naming convention: 
	# programme number   %05d
	# observation number %03d
	# visit number       %03d
	# visitgrp           %02d group within visit "usually starts at 03"
	# seqid               %1d sequence # within visit group 1=prime 2-5=parallel, "usually 1".
	# actid              %02d activity number within the visit sequence. "Usually starts at 01. Base 36".
	# exposure           %04d exposure number within the activity. Starts at 1, increments for NExp, dithers, filters.
	# detector ID "nrca1"
	# product type: for raw files "uncal"
	# segment number for very large files
	#   pppppoooovvggsaa_eeeee
	#   -----xxxx||--x|| 
	# jw01073007001_01101_00008_nrcb2_uncal.fits
	# --> apt/obsrvtn/visit_visitgrp/seq_id/act_id_exposure_request
	# --> 01073/007/001_01/1/01_00008
	#
	my $visit_number = substr($visit_id,8);
	my $suffix = '_'.$filter.'_'.$sca_id.'_'.sprintf("%04d",$counter).'.fits';

	my $mirage_prefix =  sprintf("jw%05d%03d%03d_%02d%1d%02d_%s",$aptid,$observation_number, $visit_number,$visit_group, $sequence_id, $activity_id,$sca_name{$sca_id});				   
	if(exists($sca_exp{$mirage_prefix})) {
	    $sca_exp{$mirage_prefix}++;
	}else {
	    $sca_exp{$mirage_prefix} = 1;
	}
	$exposure_request = $sca_exp{$mirage_prefix};

# patt_num may need fixing;
	if($sca_id == 485 || $sca_id ==490) {
	    if($primary_dithers > 1) {
		my $int_ratio = int($exposure_request/$primary_dithers);
		my $flt_ratio = $exposure_request/$primary_dithers;
#	print "$int_ratio,$flt_ratio,$exposure_request,$primary_dithers\n";
		if(($flt_ratio - $int_ratio) > 0 && ($flt_ratio - $int_ratio)<= 0.5) {
		    $patt_num = $int_ratio+1;
		} else {
		    $patt_num = int(0.49+$flt_ratio);
		}
	    }else {
		$patt_num = 1;
	    }
	} else {
	    $patt_num = $position;
	}

	my $mirage_name = sprintf("jw%05d%03d%03d_%02d%1d%02d_%05d_%s_uncal.fits",$aptid,$observation_number, $visit_number,$visit_group, $sequence_id, $activity_id,$exposure_request,lc($sca_name{$sca_id}));
	$dms_name = $mirage_name;
#	$dms_name = sprintf("jw%05d%03d%03d_%02d%1d%02d_%05d_%s_%s_%02d_%02d_uncal.fits",$aptid,$observation_number, $visit_number,$visit_group, $sequence_id, $activity_id,$exposure_request,lc($sca_name{$sca_id}),$filter,$patt_num,,$subpxnum);

#	$dms_name = 'jw_'.$aptid.'_'.$observation_number.'_'.$visit_number.'_'.sprintf("%02d_%02d",$position,$subpxnum).$suffix;
#	if($verbose == 1) {print "at line : ",__LINE__," mirage_name : $mirage_name  dms_name   : $dms_name  patt_num is $patt_numm\n";

#	print "at line : ",__LINE__," mirage_name : $mirage_name  dms_name   : $dms_name  patt_num is $patt_num position is $position subpxnum is $subpxnum\n";
#	<STDIN>;
	print TRANS $output_file," ",$mirage_name," ",$dms_name," obs ",$observation_number," visit ", $visit_number," patt_num ", $patt_num," subpxnum ",$subpxnum, "\n";
#	    $dms_name  ='jw'.$visit_id._.$observation_number.sprintf("%02d",$position).'_'.sprintf("%05d",$subpxnum).'.fits';	       
#	    print "at line : ",__LINE__," targetid: $targetid, aptid: $aptid, observation_number: $observation_number, filter: $filter, sca_id: $sca_id, counter: $counter\n";
#	    $dms_name  = join('_','jw'.sprintf("%05d",$aptid), sprintf("%04d",$observation_number),$filter,$sca_id,sprintf("%04d",$counter).'.fits');
#	    $dms_name  ='jw'.sprintf("%05d",$aptid).'_'.sprintf("%04d",$observation_number).'_'.sprintf("%02d",$position).'_'.$filter.$sca_id,sprintf("%04d",$counter).'.fits';
#	    $dms_name  ='jw_'.$visit_id.'_'.sprintf("%02d",$position).'_'.$filter.'_'.$sca_id.'_'.sprintf("%05d",$counter).'.fits';
	$tute_file  =$results_path.$dms_name;

	if($verbose > 0) {
	print "at line : " ,__LINE__," write file $parameter_file : $visit_id $observation_number $visit_number $position $subpxnum $targetid $dms_name $ra0 $dec0\n";
	}

	$cr_history = $parameter_file;
	$cr_history =~ s/params/cr_list/;
	$cr_history =~ s/.input/.dat/;
#
	$flatfield = find_flatfield($sca_id, $filter);
#
#	my $apt_cat_line = sprintf("%13.9f %12.8f %6.2f %3d %3d %9s %6s %18s",
#				$ra0, $dec0, $pa_degrees,$sca_id, $ngroups, $readout_pattern, $filter,  $aperture);
#	print APTCAT $apt_cat_line,"\n";
	#                      1         2
	#             12345678901234567890123456
	#             V01072001001P0000000001101
	#             V 01072 001 001 P 00000 000 01 1 01
	my $obs_id = 'V'.$visit_id.'P00000'.'000'.'01'.'1'.'01';
	$program   = sprintf("%05d",$program);
	print_batch($parameter_file,
		    $module,
		    $aperture, 
		    $sca_id,
		    $subarray,
		    $colcornr,
		    $rowcornr,
		    $naxis1,
		    $naxis2,
		    $substrt1,
		    $substrt2,
		    
		    $readout_pattern,
		    $ngroups,
		    $primary_dither_type,       # patttype
		    $primary_dither_string,     # nmdthpts
		    $primary_dithers,           # numdthpt
		    $sequence{$key},            # patt_num
#		    $position,                  
		    $subpixel_dither_type,      # subpixel_dither_type
		    $subpixel,                  # subpxpns
		    $subpxnum,                  # subpxnum
		    $nints,
#	
		    $verbose,
		    $noiseless,
		    $brain_dead_test,
		    $include_ipc,
		    $include_bias,
		    $include_ktc,
		    $include_dark,
		    $include_dark_ramp,
		    $include_readnoise,
		    $include_reference,
		    $include_non_linear,
		    $include_latents,
		    $include_flat,
		    $include_1_over_f,
		    $include_cr,
		    $cr_mode,
		    $include_bg,
		    $include_galaxies,
		    $include_cloned_galaxies,
		    $seed,
#  
		    $target_number, 
		    $targetid,
		    $targetarchivename,
		    $title,
		    $label,
		    $program,
		    $category,
		    $obs_id,
		    $visit_id,
		    $observation_number,
		    sprintf("%02d",$visit_group),
                    $sequence_id,
		    sprintf("%02d",$activity_id),
		    sprintf("%05d",$exposure_request),
		    $expripar,
#
		    $distortion,
		    $siaf_version,
		    $ra0,
		    $dec0,
		    $pa_degrees,
		    $input_s_catalogue,
		    $input_g_catalogue,
		    $input_clone_catalogue,
		    $output_clone_cat,
		    $filters_in_cat,
		    $catalogue_filter_index{$filter}+1,
#
		    $xoffset,
		    $yoffset,
		    $v2,
		    $v3,
#
		    $path{$filter},
		    $pupil,
		    $output_file,
		    $write_tute,
		    $tute_file,
		    $cr_history,
		    $background{$visit_id},
			$flatfield, 
		    $noise_file,
		    \@use_psf);
	$second_command = ' ';
	$third_command = ' ';
	$second_command  = join(' ','/bin/nice -n 19',$guitarra_home.'/bin/guitarra','<',$input);
#	$third_command = join(' ',$guitarra_home.'/perl/ncdhas_dms.pl',$output_file);
	$third_command = join(' ',$guitarra_home.'/perl/ncdhas_dms.pl',$path.$dms_name);
	$command = $first_command.' ; '.$second_command.' ; '.$third_command;
	print BATCH $command,"\n";
    }
#	    <STDIN>;
}
close(BATCH);
close(TRANS);
#close(APTCAT);
print "number of images $n_images\n";
my $total = 0;
foreach $key (sort(keys(%images_per_filter))) {
    $total = $total + $images_per_filter{$key};
    print " filter : $key ; number of exposures $images_per_filter{$key}; total : $total\n";
}
print "execution completed at line ",__LINE__,"\n";
#print "Are APT programmers graduates from the IRS?\n";
exit(0);
#$command = 'make guitarra';
#print "$command\n";
#system($command);
#
#------------------------------------------
#
sub output_name{
    my($filter, $sca, $counter) =@_;
    my $output_file = join('_','params',$filter,$sca_id,sprintf("%04d",$counter).'.input');
    return $output_file;
}
##<STDIN>;
#$nn = 0 ;
#my(@exposures);
#foreach $key (sort(keys(%by_visit))) {
#    @exposures = split(' ', $by_visit{$key});
#    print "$key : $#exposures\n";
#    for (my $ii = 0 ; $ii <= $#exposures ; $ii++) {
#	($visit, $sca_id, $filter,$header, $coords) = split('#',$exposures[$ii]);
#	$nn++;
##	print "$nn $filter, $sca_id, $visit, $coords\n";
#    }
#}
#print "$nn\n";
#<STDIN>;
#$nn = 0 ;
#my(@exposures);
#foreach $key (sort(keys(%by_sca))) {
#    @exposures = split(' ', $by_sca{$key});
#    print "$key : $#exposures\n";
#    for (my $ii = 0 ; $ii <= $#exposures ; $ii++) {
#	($visit, $sca_id, $filter,$header, $coords) = split('#',$exposures[$ii]);
#	$nn++;
##	print "$nn $filter, $sca_id, $visit, $coords\n";
#    }
#}
#print "$nn\n";
##<STDIN>;
#$nn = 0 ;
#my(@exposures);
#foreach $key (sort(keys(%by_coords))) {
#    @exposures = split(' ', $by_coords{$key});
#    print "$key : $#exposures\n";
#    for (my $ii = 0 ; $ii <= $#exposures ; $ii++) {
#	($visit, $sca_id, $filter,$header, $coords) = split('#',$exposures[$ii]);
#	$nn++;
##	print "$nn $filter, $sca_id, $visit, $coords\n";
#    }
#}
#print "$nn\n";
#die;
sub find_flatfield{
    my($sca, $filter) = @_;
    my($ncdhas_path)  = $ENV{'NCDHAS_PATH'};
    my $calPath       = $ncdhas_path.'/cal/Flat/ISIMCV3/';
    my $prefix;
#    print "ncdhas_path is $ncdhas_path\n";
#
    if($sca == 481) {$prefix = 'NRCA1';}    
    if($sca == 482) {$prefix = 'NRCA2';}
    if($sca == 483) {$prefix = 'NRCA3';}
    if($sca == 484) {$prefix = 'NRCA4';}
    if($sca == 485) {$prefix = 'NRCA5';}
#
    if($sca == 486) {$prefix = 'NRCB1';}    
    if($sca == 487) {$prefix = 'NRCB2';}
    if($sca == 488) {$prefix = 'NRCB3';}
    if($sca == 489) {$prefix = 'NRCB3';}
    if($sca == 490) {$prefix = 'NRCB5';}
#
    if($filter eq 'F070W' or $filter eq 'F090W'){
	$filter = 'F115W';
    }
    my $search_string = $calPath.join('_',$prefix,'*'.$filter,'*.fits');
    my @files = `ls $search_string | grep -v illum`;
#    print "@files\n";
    $flatfield = $files[0];
    $flatfield =~ s/\n//g;
    return $flatfield;
}
#------------------------------------------------------------------------
sub initialise_channel_filters{
    my($junk) =@_;
    #
# these are used to twist the script's arms
# and should not be changed ever
#
    my(%sw) = ();
    $sw{'F070W'}  = 1;
    $sw{'F090W'}  = 1;
    $sw{'F115W'}  = 1;
    $sw{'F140M'}  = 1;
    $sw{'F150W'}  = 1;
    $sw{'F150W2'} = 1;
    $sw{'F162M'}  = 1;
    $sw{'F162M+F150W2'}  = 1;
    $sw{'F164N+F150W2'}  = 1;
    $sw{'F164N'}  = 1;
    $sw{'F182M'}  = 1;
    $sw{'F187N'}  = 1;
    $sw{'F200W'}  = 1;
    $sw{'F210M'}  = 1;
    $sw{'F212N'}  = 1;
    #
    $sw{'F250M'}  = 0;
    $sw{'F277W'}  = 0;
    $sw{'F300M'}  = 0;
    $sw{'F322W2'} = 0;
    $sw{'F323N'}  = 0;
    $sw{'F323N+F322W2'}  = 0;
    $sw{'F335M'}  = 0;
    $sw{'F356W'}  = 0;
    $sw{'F360M'}  = 0;
    $sw{'F405N'}  = 0;
    $sw{'F405N+F444W'}  = 0;
    $sw{'F410M'}  = 0;
    $sw{'F430M'}  = 0;
    $sw{'F444W'}  = 0;
    $sw{'F460M'}  = 0;
    $sw{'F466N'}  = 0;
    $sw{'F466N+F444W'}  = 0;
    $sw{'F470N'}  = 0;
    $sw{'F470N+F444W'}  = 0;
    $sw{'F480M'}  = 0;
    return \%sw;
}
