#!/usr/bin/perl -w
#
# write_jades_parameters is specifically designed to write inputs
# for a JWST proposal. The sequence of observations is derived from
# the APT output (e.g. the xml, visit coverage and pointings in the
# APT export tag).
# Environment variables
#
$host          = $ENV{HOST};
$guitarra_home = $ENV{GUITARRA_HOME};
$guitarra_aux  = $ENV{GUITARRA_AUX};
$python_dir    = $ENV{PYTHON_DIR};
#
# This makes life easier for debugging
# if not defined
#
#$guitarra_home = "~/guitarra"      unless defined $guitarra_home;
#$guitarra_aux  = "~/guitarra/data/" unless defined $guitarra_aux;
$guitarra_home = "."      unless defined $guitarra_home;
$guitarra_aux  = "./data/" unless defined $guitarra_aux;
#
print "host is $host\nguitarra_home is $guitarra_home\n";
my $perl_dir      = $guitarra_home.'/perl/';
my $results_path  = $guitarra_home.'/results/';

require $perl_dir."print_batch.pl";
require $perl_dir."read_visit_parameters.pl";
require $perl_dir."set_readout_parameters.pl";
#

my($debug) = 0;

#
# Input parameters
my $aptcat;
$aptcat  =  $results_path.'1180_POINTINGONE-B_params.dat';
#
#$star_catalogue              = $guitarra_aux.'star_many.cat';
$star_catalogue              = 'none';
$galaxy_catalogue            = $guitarra_aux.'star_many.cat';
$galaxy_catalogue            = $guitarra_aux.'gal_many.cat';
#


#
# this is the directory where the parameter and input files to guitarra 
# are written
#
$path = $guitarra_home.'/results/';
print "$path\n";
#
# File background estimates calculated using the JWST tool
#
$background_file       = $guitarra_aux.'/jwst_bkg/goods_s_2019_12_21.txt'; 
#$background_file       = $guitarra_aux.'/jwst_bkg/goods_n_2022_02_10.txt'; 
#
# create parameter files
#
#
# Write file with parameters to be read by simulator
#
# For really basic test, set to 1:
#
$brain_dead_test    = 0 ;
#
# Verbose ?
#
$verbose = 0;
#
#
# survey_mode:  fake fields (0)  use APT output (1)
#
#$survey_mode     =  1 ;

# Random numbers - use system clock (0) or a deterministic sequence(1)
$seed           =  1;

# add FOV distortion (1)
$distortion     =  1;
#
#     sources to include
#
$ngal   = 200;
$nstars = 200;
$include_stars               = 1;
$include_galaxies            = 1;
$include_cloned_galaxies     = 0;
#
# subarray mode
#
#$subarray ='GR160';
$subarray ='FULL    ';
#     
#  these should be input parameters in case subarrays are being used
#
if($subarray eq '.true') {
    $colcornr = 333;  # start of sub-array ("x")
    $rowcornr = 338;  # start of sub-array ("y")
    $naxis1   = 320;  # sub-array length in "x"
    $naxis2   = 320;  # sub_array length in "y"
} else {
    $colcornr =    0;
    $rowcornr =    0;
    $naxis1   = 2048;
    $naxis2   = 2048;
}
#
# List of point spread functions
#
$string = $guitarra_aux.'WebbPSF_NIRCam_PSFs/*.fits';
@psf = `ls $string`;
#
#-----------------------------------------------------------
#
# Instrumental signatures to include
#

$noiseless = 0 ;

if($noiseless == 1) {
    $include_bias       =  0 ;
    $include_ktc        =  0 ;
    $include_ipc        =  0 ;
    $include_dark       =  0 ;
    $include_dark_ramp  =  0 ;
    $include_latents    =  0 ;
    $include_non_linear =  0 ;
    $include_flat       =  0 ;
    $include_readnoise  =  0 ;
    $include_reference  =  0 ;
    $include_1_over_f   =  0 ;
} else {
    $include_bias       =  1 ;
    $include_ktc        =  1 ;
    $include_ipc        =  0 ;
    $include_dark       =  0 ;
    $include_dark_ramp  =  1 ;
    $include_latents    =  0 ;
    $include_non_linear =  1 ;
    $include_flat       =  0 ;
    $include_readnoise  =  0 ;
    $include_reference  =  0 ;
    $include_1_over_f   =  0 ;
}
# 2020-05-10 if dark ramps are included, need to change some settings:
if($include_dark_ramp == 1) {
    $include_ktc        = 0;
    $include_bias       = 0;
    $include_dark       = 0;
    $include_reference  = 0;
    $include_one_over_f = 0;
}
#------------------------------------------------------------
#  External sources of noise
#
# Background
#
$include_bg            = 0   ;
#------------------------------------------------------------
#
# Cosmic rays
#     cr_mode:
#     0         -  Use ACS observed counts for rate and energy levels
#     1         -  Use M. Robberto models for quiet Sun
#     2         -  Use M. Robberto models for active Sun
#     3         -  Use M. Robberto models for solar flare (saturates)
#
$include_cr        = 1 ;
$cr_mode           = 2 ;
#
# list of NIRCam filters,
#
# to use a filter set value to 1
# This should use a combination of filters
# available in the catalogue with those in 
# the setup.
#
my ($use_filter_ref) = initialise_filters();
my (%use_filter) = %$use_filter_ref;

$use_filter{'F070W'}  = 0;
$use_filter{'F090W'}  = 1;
$use_filter{'F115W'}  = 1;
$use_filter{'F150W'}  = 1;
$use_filter{'F200W'}  = 1;
$use_filter{'F277W'}  = 1;
$use_filter{'F335M'}  = 1;
$use_filter{'F356W'}  = 1;
$use_filter{'F410M'}  = 1;
$use_filter{'F444W'}  = 1;
#
# Read list of filters
#
$string = $guitarra_aux.'/nircam_filters/*dat';
@filter_path = `ls $string | grep -v w2`;
#print "@filter_path";
foreach $filter (sort(keys(%use_filter))) {
    $a = lc($filter);
    for($i = 0 ; $i <= $#filter_path; $i++) {
	$filter_path[$i] =~ s/\n//g;
	if($filter_path[$i] =~ m/$a/) {
	    $path{$filter} = $filter_path[$i];
	    last;
	}
    }
    print "$filter $path{$filter}\n";
}
#
# these are used to twist the script's arms
#
$sw{'F070W'}  = 1;
$sw{'F090W'}  = 1;
$sw{'F115W'}  = 1;
$sw{'F140M'}  = 1;
$sw{'F150W'}  = 1;
$sw{'F162M'}  = 1;
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
$sw{'F323N'}  = 0;
$sw{'F335M'}  = 0;
$sw{'F356W'}  = 0;
$sw{'F360M'}  = 0;
$sw{'F405N'}  = 0;
$sw{'F410M'}  = 0;
$sw{'F430M'}  = 0;
$sw{'F444W'}  = 0;
$sw{'F460M'}  = 0;
$sw{'F466N'}  = 0;
$sw{'F470N'}  = 0;
$sw{'F480M'}  = 0;
#
# Filters contained in catalogue; need to add HST or other filters
# The galaxy catalogue must have the list of filters in the header.
#
my ($catalogue_filter_ref) = catalogue_filters();
my (%catalogue_filter) = %$catalogue_filter_ref;

#
# read the filter information from the catalogue
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
	if($column[$i] =~ m/F/) {
	    if($column[$i] =~ m/W/ || $column[$i] =~ m/M/ 
	       || $column[$i] =~ m/N/ ) {
		$filter = $column[$i];
		$catalogue_filter{$filter} = 1;
		$filter_index++;
		$catalogue{$filter} = 1;
		$catalogue_filter_index{$filter} = $filter_index;
#		print "catalogue contains filter $filter filter index is $filter_index\n";
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
	print "filter in source catalogue : $filter $filters_in_cat in full set $nc\n";
    }
}
print "number of filters in catalogue : $filters_in_cat\n";
#die;
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
	if($catalogue_filter{$filter} != 1) {
	    print "filter $filter is not contained in source catalogue\n";
	    print "exiting...\n";
	    exit(0);
	}
#	$n++;
	push(@filters, $n+1);
	push(@names, $filter);
	push(@cat_filter, $cat_filter_number{$filter});
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
if($brain_dead_test == 1) {
    $nf                  = 1;
    $use_filter{'F200W'} = 1;
    $include_ktc         = 0;
    $include_dark        = 0;
    $include_readnoise   = 0;
    $include_non_linear  = 0;
    $include_latents     = 0;
    $include_cr          = 0;
    $include_bg          = 0;
    $include_stars       = 0;
} 
#
################################################################################
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
################################################################################
#
#  Organise in such a way that there is this type of nesting:
#  filter -> sca -> dithers
#  Read file produced by APT, which does not contain filter info
#
my($setup_ref) = read_visit_parameters($aptcat, $debug);
my(%visit_setup) = %$setup_ref;
#
$n_images = 0;
#
# Read the output gleaned from APT
#
my($header);
my %by_sca;
my %by_filter;
my %by_coords;
my %by_visit;

foreach $visit (sort(keys(%visit_setup))){
    @values = split('#',$visit_setup{$visit});
#    print "$visit_setup{$visit}\n";
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
#
    $ra                   = $values[$jj];
    $jj++;
    $dec                  = $values[$jj];
    $jj++;
    $pa_v3                = $values[$jj];
    $jj++;
#
    $aperture             = $values[$jj];
    $jj++;
    $primary_dither_type  = $values[$jj];
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
# These are parameters that get written to the header
#
    my $ii = 0;
    $header = $values[$ii];
    for($ii = 1; $ii< $jj; $ii++) {
	$header=join(',',$header, $values[$ii]);
#	printf("%3d  %-30s\n",$ii,$values[$ii]);
    }
#
# These are the dither positions
#
    @coords  = ();
    my $nn =1;
    for (my $ii=$jj ; $ii <= $#values ; $ii++) {
	push(@coords, $values[$ii]);
#	print "$ii $values[$ii]\n";
	$nn++;
    }
#    print "pause\n";
#    <STDIN>;
#
# Get list of SCAs for this aperture
#
    $sca_ref = get_scas($aperture);
    @sca     = @$sca_ref;
#
# loop over filters being simulated
#
    foreach $filter (sort(keys(%use_filter))) {
	if($use_filter{$filter} != 1) {next;}
#    for (my $jj = 0 ; $jj <= $#sca; $jj++) {
#	$sca_id = $sca[$jj];
	$counter = 0;
#
# Loop over dither positions
#
	for (my $kk = 0 ; $kk <= $#coords ; $kk++) {
	    $coords[$kk] =~ s/\s//g;
	    ($ra, $dec, $pa_v3, $short_filter, $long_filter,$readout_pattern, $ngroups,$nints)
		=split('\,',$coords[$kk]);
#
# Loop over SCAs
#
#	    foreach $filter (sort(keys(%use_filter))) {
#		if($use_filter{$filter} != 1) {next;}
	    for (my $jj = 0 ; $jj <= $#sca; $jj++) {
		$sca_id = $sca[$jj];
#
# test that the filter and SCA being simulated are consistent
#
		if(($sca_id == 485 || $sca_id == 490) && $sw{$filter} == 1) {next;}
		if(($sca_id != 485 && $sca_id != 490) && $sw{$filter} == 0) {next;}
		if($short_filter eq $filter || $long_filter eq $filter) {
		    $counter++;
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
			$by_filter{$filter} = join(' ',$by_filter{$filter},join('#',$visit, $sca_id, $filter,$header,$coords[$kk]));
#			printf("3  %-30s %-20s %s\n",$targetid, $expripar, $aperture);
		    } else {
			$by_filter{$filter} = join('#',$visit, $sca_id, $filter,$header,$coords[$kk]);
		    }
		    
#		    if(exists($by_sca{$sca_id})) {
#			$by_sca{$sca_id} = join(' ',$by_sca{$sca_id},join('#',$visit, $sca_id, $filter,$header,$coords[$kk]));
#		    } else {
#			$by_sca{$sca_id} = join('#',$visit, $sca_id, $filter,$header,$coords[$kk]);
#		    }
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
open(BATCH,">$parallel_input") || die "cannot open $parallel_input";
$nn = 0 ;
$counter = 0;
my(@exposures);
foreach $key (sort(keys(%by_filter))) {
    @exposures = split(' ', $by_filter{$key});
#    print "$key\n";
    for (my $ii = 0 ; $ii <= $#exposures ; $ii++) {
	($visit, $sca_id, $filter,$header, $coords) = split('#',$exposures[$ii]);
	$nn++;
	$counter++;
	
	($target_number, $targetid,$targetarchivename,$title, $label, $program, $category, $expripar,
	 $ra,$dec, $pa_v3, $aperture, 
	 $primary_dither_type, $primary_dithers,$subpixel_dither_type,$subpixel,
	 $subarray, $visit_id,$observation_number,$primary_instrument) = split('\,',$header);
	($ra0, $dec0, $pa_degrees, $short_filter, $long_filter, $readout_pattern, $ngroups, $nints)
	    = split('\,',$coords); 
#	print "$key, $targetid\n";
#
# this is done to populate some of the JWST keywords. These refer to the
# order  within a dither sequence. Needs verification
#
	$position  = $ii;
	$subpxnum = 1;
	$position  = ( $ii % $primary_dithers) +  1;
	$subpxnum  = ($ii % $subpixel) + 1;
#
# These are parameters required to create 1/F noise
#
	($max_groups, $nframe, $nskip)= set_params($readout_pattern);
	if($ngroups > $max_groups) {
	    print "number of groups $ngroups greater than max_groups $max_groups\n";
	    exit(0);
	} else {
# 1/F noise
#	    
	    if($include_1_over_f == 1) {
		my($one_over_f_naxis3) =($ngroups-1) * ($nframe+$nskip) + $nframe;
		$noise_file = join('_','ng_hxrg_noise',$filter,$sca_id,
				   sprintf("%03d",$counter).'.fits');
		$command = join(' ','python','run_nghxrg.py',$sca_id,$one_over_f_naxis3, $noise_file);
#		print BATCH $command,"\n";
	    } else {
		$noise_file = 'None';
		$command = 'date'; # serves as a filler 
#		print BATCH $command,"\n";
	    }


#
# name of simulated file
#
	    $output_file = join('_','sim_cube',$filter,$sca_id,sprintf("%03d",$counter).'.fits');
	    $output_file = join('_','star_cube_nn',$filter,$sca_id,sprintf("%03d",$counter).'.fits');
#	    $output_file = '/home/marcia/star_test_DC1/no_noise/raw/'.$output_file;
	    $output_file = $path.$output_file;
	    $catalogue_input = join('_','cat',$filter,$sca_id,sprintf("%03d",$counter).'.input');
	    $catalogue_input = $path.$catalogue_input;
	    $input = $path.join('_','params',$filter,$sca_id,sprintf("%03d",$counter).'.input');
#
# Catalogues with X, and Y positions derived from RA and DEC
#
	    $input_s_catalogue = $star_catalogue;
	    $input_s_catalogue =~ s/.cat//g;
	    $input_s_catalogue = join('_',$input_s_catalogue,$filter,$sca_id,sprintf("%03d",$counter).'.cat');
	    $input_g_catalogue = $galaxy_catalogue;
	    $input_g_catalogue =~ s/$guitarra_aux//;
	    $input_g_catalogue =~ s/.cat//g;
	    $input_g_catalogue = $path.join('_',$input_g_catalogue,$filter,$sca_id,sprintf("%03d",$counter).'.cat');
#
# output catalogue
#
	    $cat = $catalogue_input;
	    open(CAT,">$cat") || die "cannot open $cat";
	    print CAT $filters_in_cat,"\n";
	    $line = join(' ',$ra0, $dec0,$pa_degrees);
	    print CAT $line,"\n";
	    print CAT $sca_id,"\n";
	    print CAT $star_catalogue,"\n";
	    print CAT $input_s_catalogue,"\n";
	    print CAT $galaxy_catalogue,"\n";
	    print CAT $input_g_catalogue,"\n";		
	    close(CAT);
	    $command = join(' ',$command,';',$guitarra_home.'/bin/proselytism','<',$catalogue_input);
	    #		print "$command\n";
	    $first_command = $command;
	    $n_images++;
#
# Get PSF file
#
	    @use_psf = ();
	    for($ppp = 0 ; $ppp <= $#psf ; $ppp++) {
		if($psf[$ppp] =~ m/$filter/ && $psf[$ppp] !~ m/W2/ ) {
		    push(@use_psf,$psf[$ppp])
		}
	    }
#
# parameter file read by the main code with RA0, DEC0
#
	    $parameter_file = 
		$results_path.output_name($filter, $sca_id, $counter);
	    print "write file $parameter_file : $visit_id $observation_number $position $subpxnum $targetid\n";
	    $cr_history = $parameter_file;
	    $cr_history =~ s/params/cr_list/;
	    $cr_history =~ s/.input/.dat/;
	    print_batch($parameter_file,
			$aperture, 
			$sca_id,
			$subarray,
			$colcornr,
			$rowcornr,
			$naxis1,
			$naxis2,

			$readout_pattern,
			$ngroups,
			$primary_dither_type,
			$primary_dithers,
			$position,
			$subpixel_dither_type,
			$subpixel,
			$subpxnum,
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
			$visit_id,
			$observation_number,
			$expripar,
			#
			$distortion,
			$ra0,
			$dec0,
			$pa_degrees,
			$input_s_catalogue,
			$input_g_catalogue,
			$filters_in_cat,
			$catalogue_filter_index{$filter}+1,
#
			$path{$filter},
			$output_file,
			$cr_history,
			$background_file,
			$noise_file,
			\@use_psf);
	    $second_command  = join(' ','/bin/nice -n 19',$guitarra_home.'/bin/guitarra','<',$input);
#	    $second_command  = join(' ','/bin/nice -n 19',$guitarra_home.'/bin/guitarron','<',$input);
	    $third_command = join(' ',$guitarra_home.'/perl/ncdhas.pl',$output_file);
	    $command = $first_command.' ; '.$second_command.' ; '.$third_command;
	    print BATCH $command,"\n";
	}
    }
}
close(BATCH);
print "number of images $n_images\n";
#$command = 'make guitarra';
#print "$command\n";
#system($command);
#
#------------------------------------------
#
sub output_name{
    my($filter, $sca, $counter) =@_;
    my $output_file = join('_','params',$filter,$sca_id,sprintf("%03d",$counter).'.input');
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
