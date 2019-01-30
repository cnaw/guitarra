#!/usr/bin/perl -w
#
# Environment variables
#
$host         = $ENV{HOST};
$home         = $ENV{HOME};
$guitarra_home = $ENV{GUITARRA_HOME};
$guitarra_aux = $ENV{GUITARRA_AUX};
$python_dir   = $ENV{PYTHON_DIR};
print "host is $host\n";
# this is the directory where the parameter and input files to guitarra 
# are written
$path = $guitarra_home.'/results/';
print "$path\n";
#<STDIN>;
$out = 'simulator.params';
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
# details relative to "observation"
# sca_id = 0 (modules A+B); 1 (A)  ; 2 (B); 481 ... 490 
#$apername     = 'NRCAALL';
#$apername     = 'ASHORT';
#$apername     = 'BLONG';
$apername     = 'BSHORT';
$apername     = 'NRCB4';
#$apername     = 'NRCBALL';
#$apername     = 'ALONG';
$sca_id     = 0;
#$sca_id    = -1;
#
# survey_mode:  fake fields (0)  use APT output (1)
#
$survey_mode     =  1 ;
$aptcat = $guitarra_aux.'/play_pen/play_pen.input';
#$aptcat = '1180_stsci_v5_2018_02_15_nrc_medium_guitarra.input';

$number_primary  =  1 ;
$number_subpixel =  1 ;
$camera          = 'short';
#$camera          = 'long';
$primary_dither  = 'intrasca';
$subpixel_dither = 'small';

#$dither_arc_sec =  10.0 ;

$custom_dither = 0;

# add FOV distortion (1)
$distortion     =  0;


#
# integration related parameters
#
$readout_pattern    = 'deep8';
$ngroups =     7 ; #  number of groups per ramp
#
#$readout_pattern    = 'medium8';
#$ngroups =     10;
#
#$readout_pattern = 'SHALLOW4';
#$ngroups = 10;

#$readout_pattern    = 'bright2';
#$ngroups  =     10;
#
#$readout_pattern    = 'rapid';
#$ngroups  =     4;

#$readout_pattern    = 'none';
#$ngroups  =   88;

#
#     sources to include
#
$ngal   = 34730;
$ngal   = 61877;
$ngal   = 338818;
$ngal   = 1000000;
$ngal   =     0 ;
$nstars = 0;
$include_stars               = 0;
$include_galaxies            = 1;
$include_cloned_galaxies     = 0;
#
$star_catalogue              = 'star.cat';
$star_catalogue              = 'none';
# JADES mock catalogue 
#$galaxy_catalogue            = $guitarra_aux.'/play_pen/mock_2018_03_13.cat';
$galaxy_catalogue            = $guitarra_aux.'/play_pen/play_pen.cat';
#
# subarray mode
#
$subarray ='GR160';
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
# Instrumental signatures to include
#

$noiseless = 0 ;

if($noiseless == 1) {
    $include_ktc        =  0 ;
    $include_dark       =  0 ;
    $include_latents    =  0 ;
    $include_non_linear =  0 ;
    $include_readnoise  =  0 ;
    $include_reference  =  0 ;
    $include_1_over_f   =  0 ;
} else {
    $include_ktc        =  1 ;
    $include_dark       =  1 ;
    $include_latents    =  0 ;
    $include_non_linear =  1 ;
    $include_readnoise  =  1 ;
    $include_reference  =  1 ;
    $include_1_over_f   =  0 ;
}
#
#  External sources of noise
#
# Background
# mode ( 0 = no bkg; 1= JWST calculator )
#
$include_bg            = 1   ;
$bkg_mode              = 1 ;
$background_file       = $guitarra_aux.'/jwst_bkg/goods_s_2019_12_21.txt'; 
# now that we are using the JWST calculator, leave at 1:
$zodiacal_scale_factor = 1.00;
#
# Cosmic rays
#     cr_mode:
#     0         -  Use ACS observed counts for rate and energy levels
#     1         -  Use M. Robberto models for quiet Sun
#     2         -  Use M. Robberto models for active Sun
#     3         -  Use M. Robberto models for solar flare (saturates)
#
$include_cr        = 0 ;
$cr_mode           = 1 ;
#
# list of NIRCam filters,
#
# to use a filter set value to 1
#
$use_filter{'F070W'}  = 1;
$use_filter{'F090W'}  = 1;
$use_filter{'F115W'}  = 1;
$use_filter{'F140M'}  = 0;
$use_filter{'F150W'}  = 1;
$use_filter{'F162M'}  = 0;
$use_filter{'F164N'}  = 0;
$use_filter{'F182M'}  = 0;
$use_filter{'F187N'}  = 0;
$use_filter{'F200W'}  = 1;
$use_filter{'F210M'}  = 0;
$use_filter{'F212N'}  = 0;
# LW
$use_filter{'F250M'}  = 0;
$use_filter{'F277W'}  = 1;
$use_filter{'F300M'}  = 0;
$use_filter{'F323N'}  = 0;
$use_filter{'F335M'}  = 1;
$use_filter{'F356W'}  = 1;
$use_filter{'F360M'}  = 0;
$use_filter{'F405N'}  = 0;
$use_filter{'F410M'}  = 1;
$use_filter{'F430M'}  = 0;
$use_filter{'F444W'}  = 1;
$use_filter{'F460M'}  = 0;
$use_filter{'F466N'}  = 0;
$use_filter{'F470N'}  = 0;
$use_filter{'F480M'}  = 0;
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
#    print "$filter $path{$filter}\n";
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
# NIRCam SW
$catalogue_filter{'F070W'}  = 1;
$catalogue_filter{'F090W'}  = 1;
$catalogue_filter{'F115W'}  = 1;
$catalogue_filter{'F140M'}  = 0;
$catalogue_filter{'F150W'}  = 1;
$catalogue_filter{'F162M'}  = 0;
$catalogue_filter{'F164N'}  = 0;
$catalogue_filter{'F182M'}  = 0;
$catalogue_filter{'F187N'}  = 0;
$catalogue_filter{'F200W'}  = 1;
$catalogue_filter{'F210M'}  = 0;
$catalogue_filter{'F212N'}  = 0;
# NIRCam LW
$catalogue_filter{'F250M'}  = 0;
$catalogue_filter{'F277W'}  = 1;
$catalogue_filter{'F300M'}  = 0;
$catalogue_filter{'F323N'}  = 0;
$catalogue_filter{'F335M'}  = 1;
$catalogue_filter{'F356W'}  = 1;
$catalogue_filter{'F360M'}  = 0;
$catalogue_filter{'F405N'}  = 0;
$catalogue_filter{'F410M'}  = 1;
$catalogue_filter{'F430M'}  = 0;
$catalogue_filter{'F444W'}  = 1;
$catalogue_filter{'F460M'}  = 0;
$catalogue_filter{'F466N'}  = 0;
$catalogue_filter{'F470N'}  = 0;
$catalogue_filter{'F480M'}  = 0;
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
    print "$header\n";
    @column = split(' ',$header);
    for($i = 0 ; $i <= $#column ; $i++) {
	if($column[$i] =~ m/F/) {
	    if($column[$i] =~ m/W/ || $column[$i] =~ m/M/ 
	       || $column[$i] =~ m/N/ ) {
		$filter = $column[$i];
		$catalogue_filter{$filter} = 1;
		$filter_index++;
		$catalogue_filter_index{$filter} = $filter_index;
		print "catalogue contains filter $filter filter index is $filter_index\n";
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
	print "filter to use in simulation $filter\n";
#	$n++;
	push(@filters, $n+1);
	push(@names, $filter);
	push(@cat_filter, $cat_filter_number{$filter});
	$nf++;
    }
}

print "filters used in simulation: $nf\n";

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
#
#  Read file produced by APT, which does not contain filter info
#
#  This is hard-coded for NIRCam Deep/compact
#
@ra_center       = ();
@dec_center      = ();
@pa              = ();
@pos             = ();
@exp             = ();
@move            = ();
@aperture        = ();
@apt_filter      = ();
@apt_readout     = ();
@apt_ngroups     = ();
@primary         = ();
@number_primary    = ();
@number_subpixel   = ();
$one_over_f_naxis3 = ();
$number_dithers  = 0;
open(CAT,"<$aptcat") || die "cannot open $aptcat";
while(<CAT>) {
    chop $_;
    @junk       = split(' ',$_);
    $ra         = $junk[0];
    $dec        = $junk[1];
    $pa_v3      = $junk[2];
    $exposure   = $junk[3];
    $pointing          = $junk[4];
    $order             = $junk[5];
    $aperture          = $junk[6];
    $filter            = $junk[9];
    $readout_pattern   = $junk[10];
    $ngroups    = $junk[11];
    $primary    = $junk[12];
    $nprimary   = $junk[13];
    $nsubpixel  = $junk[14];
#
    push(@ra_center, $ra);
    push(@dec_center, $dec);
    push(@pa, $pa_v3);
    push(@exp, $exposure);
    push(@pos, $pointing);
    push(@move,            $order);
    push(@aperture,        $aperture);     
    push(@apt_filter,      $filter);       
    push(@apt_readout,     $readout_pattern);       
    push(@apt_ngroups,     $ngroups);       
    push(@primary,         $primary);       
    push(@number_primary,  $nprimary);       
    push(@number_subpixel, $nsubpixel);       
#
# These are parameters required to create 1/F noise
#
    ($max_groups, $nframe, $nskip)= set_params($readout_pattern);
    if($ngroups > $max_groups) {
	print "number of groups $ngroups greater than max_groups $max_groups\n";
	exit(0);
    } else {
	push(@one_over_f_naxis3,($ngroups-1) * ($nframe+$nskip) + $nframe);
    }
    $number_dithers++;
}
print "number_dithers is $number_dithers\n";
close(CAT);
#
############################################################################
#
# write out the batch file, looping over filters, SCAs, dithers
#
# This is the output file:
#
$parallel_input = 'batch';
#
#
# If not including the NIRCam FOV distortion use this to make conversions:
#
#if($distortion == 0) {
#    $command = 'make proselytism';
#    system($command);
#}
$n_images = 0;
open(BATCH,">$parallel_input") || die "cannot open $parallel_input";
for ($ii = 0 ; $ii <= $#names ; $ii++ ) {
    $filter_name = $names[$ii];

    $apername = $aperture[0];
    if($apername eq 'NRCALL_FULL') {
	@sca =(485, 490, 481, 482, 483,484,486, 487, 488, 489);
    }
    if($apername eq 'NRCAALL') {
	@sca =(481,482,483,484,485);
    }
    if($apername eq 'ASHORT') {
	@sca =(481,482,483,484);
    }
    if($apername eq 'ALONG') {
	@sca = (485);
    }
    if($apername eq 'NRCBALL') {
	@sca= (486, 487, 488, 489, 490);
    }
    if($apername eq 'BSHORT') {
	@sca= (486, 487, 488, 489);
    }
    if($apername eq 'BLONG') {
	    @sca = (490);
    }
    if($apername eq 'NRCA1') {
	@sca = (481);
    }
    if($apername eq 'NRCA2') {
	@sca = (482);
    }
    if($apername eq 'NRCA3') {
	@sca = (483);
    }
    if($apername eq 'NRCA4') {
	@sca = (484);
    }
    if($apername eq 'NRCB1') {
	@sca = (486);
    }
    if($apername eq 'NRCB2') {
	@sca = (487);
    }
    if($apername eq 'NRCB3') {
	@sca = (488);
    }
    if($apername eq 'NRCB4') {
	@sca = (489);
    }

# loop over SCAs

    for($i = 0 ; $i <= $#sca; $i++) {
	$counter = 0;
	$sca_id = $sca[$i];
	
	if(($sca_id == 485 || $sca_id == 490) && $sw{$filter_name} == 1) {next;}
	if(($sca_id != 485 && $sca_id != 490) && $sw{$filter_name} == 0) {next;}
#
# Loop over dithers    
#
	for($apt = 0 ; $apt < $number_dithers ; $apt++) {
#
# skip if this filter is not being used at this position
#
	    if( $apt_filter[$apt] !~ m/$filter_name/) {next;}   
#
	    $filter_index_in_catalogue = $catalogue_filter_index{$filter_name};
#	    print "$filter_name, $filter_index_in_catalogue, $catalogue_filter_index{$filter_name}\n";
#	    die;
	    $ra0  = $ra_center[$apt];
	    $dec0 = $dec_center[$apt];
	    $pa_degrees = $pa[$apt];
	    $counter++;
#
# this is done to populate some of the new header keywords. Still
# incorrect 2018-03-07
#
	    if($primary[$apt] eq 'NONE') {
		$position  = 1;
		if($apt > 0) {
		    if($pos[$apt] eq $pos[$apt-1]) {
			$subpxnum++;
		    } else {
			$subpxnum = 1;
		    }
		} else {
		    $subpxnum = 1;
		}
	    } else {
		$position  = int($apt / ($number_primary[$apt] * $number_subpixel[$apt])) + 1;
#	    print "$apt, $position\n";
		$subpxnum  = ($apt % $number_subpixel[$apt]) + 1;
	    }
#    print "pos[apt] $apt $pos[$apt],$pos[$apt-1],$subpxnum\n";
#
# 1/F noise
#	    
	    if($include_1_over_f == 1) {
		$noise_file = join('_','ng_hxrg_noise',$filter_name,$sca_id,
				   sprintf("%03d",$counter).'.fits');
		$command = join(' ','python','run_nghxrg.py',$sca_id,$one_over_f_naxis3[$apt], $noise_file);
#		print BATCH $command,"\n";
	    } else {
		$noise_file = 'None';
		$command = 'date'; # serves as a filler 
#		print BATCH $command,"\n";
	    }
#
# name of simulated file
#
	    $output_file = join('_','sim_cube',$filter_name,$sca_id,sprintf("%03d",$counter).'.fits');
#	    $output_file = join('_','bkg_plus_noise_cube',$filter_name,$sca_id,sprintf("%03d",$counter).'.fits');
#	    $output_file = join('_','bkg_plus_noise_plus_1',$filter_name,$sca_id,sprintf("%03d",$counter).'.fits');
#	    $output_file = join('_','no_bkg',$filter_name,$sca_id,sprintf("%03d",$counter).'.fits');
	    $output_file = $path.$output_file;
	    $catalogue_input = join('_','cat',$filter_name,$sca_id,sprintf("%03d",$counter).'.input');
	    $catalogue_input = $path.$catalogue_input;
	    $input = $path.join('_','params',$filter_name,$sca_id,sprintf("%03d",$counter).'.input');
#
# Catalogues with X, and Y positions derived from RA and DEC
#
	    $input_s_catalogue = $star_catalogue;
	    $input_s_catalogue =~ s/.cat//g;
	    $input_s_catalogue = join('_',$input_s_catalogue,$sca_id,sprintf("%03d",$counter).'.cat');
	    $input_g_catalogue = $galaxy_catalogue;
	    $input_g_catalogue =~ s/$guitarra_aux//;
	    $input_g_catalogue =~ s/.cat//g;
	    $input_g_catalogue = $path.join('_',$input_g_catalogue,$sca_id,sprintf("%03d",$counter).'.cat');
#
# Case for no FOV distortion
#
	    if($distortion == 0) {
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
	    } else {
#
# Case for FOV distortion
#
		$input_s_catalogue = $star_catalogue;
		$input_s_catalogue =~ s/.cat//g;
		$input_s_catalogue = $path.join('_',$input_s_catalogue,$sca_id,sprintf("%03d",$counter).'.cat');
		$input_g_catalogue = $galaxy_catalogue;
		$input_g_catalogue =~ s/.cat//g;
		$input_g_catalogue = $path.join('_',$input_g_catalogue,$sca_id,sprintf("%03d",$counter).'.cat');
#
		$python_input = 'distort_catalogue.dat';
		open(PY,">$python_input") || die "cannot open $python_input";
#		print CAT $nfilters,"\n";
		print PY $galaxy_catalogue,"\n";
		print PY $ra0,"\n";
		print PY $dec0, "\n";
		print PY $pa_degrees,"\n";
		print PY $input_g_catalogue,"\n";
		print PY $sca_id,"\n";
		close(PY);
#		$command = join(' ',$command,';','python /home/cnaw/anaconda3/distortion/nrc_distortion_v1.py');
		$command = join(' ',$command,';','python', $python_dir.'/distortion/nrc_distortion_v1.py');
		$first_command = $command;
	    }
	    $n_images++;
#
# parameter file read by the main code with RA0, DEC0
#
	    $ndithers  = $#dithers + 1;
#	    print "INPUT is $input\n";
	    open(INPUT,">$input") || die "cannot open $input";
	    print INPUT $output_file, "\n";
	    print INPUT $noise_file,"\n";
	    print INPUT $ra0,"\n";
	    print INPUT $dec0, "\n";
	    print INPUT $sca_id,"\n";
#	    print INPUT $filter_name,"\n";
# print INPUT $distorted_catalogue,"\n";	    
	    print INPUT $input_s_catalogue,"\n";
	    print INPUT $input_g_catalogue,"\n";
	    print INPUT $filters_in_cat,"\n";
	    $fortran_filter_index  = $filter_index_in_catalogue + 1;
	    print INPUT $fortran_filter_index,"\n";
	    print INPUT $path{$filter_name},"\n";
	    print INPUT $background_file,"\n";
	    print INPUT $verbose,"\n";
	    if($noiseless == 0) {
		$logical = '.false.';
	    } else {
		$logical = '.true.';
	    }
	    print INPUT $logical,"\n";
	    print INPUT $brain_dead_test,"\n";
	    print INPUT $apername,"\n";
	    print INPUT $readout_pattern,"\n";
	    print INPUT $ngroups,"\n";
	    print INPUT $subarray,"\n";
	    print INPUT $colcornr,"\n";
	    print INPUT $rowcornr,"\n";
	    print INPUT $naxis1,"\n";
	    print INPUT $naxis2,"\n";
	    print INPUT $pa_degrees,"\n";
	    print INPUT $include_ktc,"\n";
	    print INPUT $include_dark,"\n";
	    print INPUT $include_readnoise,"\n";
	    print INPUT $include_reference,"\n";
	    print INPUT $include_non_linear,"\n";
	    print INPUT $include_latents,"\n";
	    print INPUT $include_1_over_f,"\n";
	    print INPUT $include_cr,"\n";
	    print INPUT $cr_mode,"\n";
	    print INPUT $include_bg,"\n";
	    print INPUT $include_galaxies,"\n";
	    print INPUT $include_cloned_galaxies,"\n";
#	    print INPUT $cat_filter_number{$filter_name},"\n";
#	    print "filter_index $filter_index\n";
#	    print "filter_name $filter_name\n";
#	    print "filter_index_in_catalogue $filter_index_in_catalogue\n";
#	    print "cat_filter_number $cat_filter_number{$filter_name}\n";
#	    print "$path{$filter_name}\n";
# dither info
	    print INPUT $primary[$apt],"\n";
	    print INPUT $position,"\n";
	    print INPUT $number_primary[$apt],"\n";
	    print INPUT $subpxnum,"\n";
	    print INPUT $number_subpixel[$apt],"\n";
	    close(INPUT);
	    $second_command  = join(' ','/bin/nice -n 19',$guitarra_home.'/bin/guitarra','<',$input);
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

############################################################################
#
# Qui finisce il programma ...
#
############################################################################
sub set_params{
    my($readout_pattern) = @_ ;
    my($nframe, $nskip,$max_groups);
#
    if(lc($readout_pattern) eq 'rapid') {
	$max_groups = 10;
	$nframe     =  1;
	$nskip      =  0;
    }
#
    if(lc($readout_pattern) eq 'bright1') {
	$max_groups = 10;
	$nframe     =  1;
	$nskip      =  1;
    }
#
    if(lc($readout_pattern) eq 'bright2') {
	$max_groups = 10;
	$nframe     =  2;
	$nskip      =  0;
    }
#
    if(lc($readout_pattern) eq 'shallow2') {
	$max_groups = 10;
	$nframe     =  2;
	$nskip      =  3;
    }
#
    if(lc($readout_pattern) eq 'shallow4') {
	$max_groups = 10;
	$nframe     =  4;
	$nskip      =  1;
    }
#
    if(lc($readout_pattern) eq 'medium2') {
	$max_groups = 10;
	$nframe     =  2;
	$nskip      =  8;
    }
#
    if(lc($readout_pattern) eq 'medium8') {
	$max_groups = 10;
	$nframe     =  8;
	$nskip      =  2;
    }
#
    if(lc($readout_pattern) eq 'deep2') {
	$max_groups = 10;
	$nframe     =  2;
	$nskip      = 18;
    }
#
    if(lc($readout_pattern) eq 'deep8') {
	$max_groups = 20;
	$nframe     =  8;
	$nskip      = 12;
    }
    return $max_groups, $nframe, $nskip;
}
