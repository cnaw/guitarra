#!/usr/bin/perl -w
#
$host = $ENV{HOST};
print "host is $host\n";
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
$apername     = 'NRCAB4';
#$apername     = 'NRCAALL';
#$apername     = 'BLONG';
#$apername     = 'BSHORT';
#$apername     = 'NRCBALL';
#$apername     = 'ALONG';
$sca_id     = 489;
#$sca_id    = -1;
#
# survey_mode:  fake fields (0)  use APT output (1)
#
$survey_mode     =  0 ;
$number_primary  =  1 ;
$number_subpixel =  2 ;
$camera          = 'short';
#$camera          = 'long';
$primary         = 'intrasca';
$subpixel_dither = 'small';

#$dither_arc_sec =  10.0 ;
$custom_dither = 0;

# add FOV distortion (1)
$distortion     =  0;


#
# integration related parameters
#
$readout_pattern    = 'deep8';
$ngroups =     6 ; #  number of groups per ramp
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
#$ngroups  =     10;

#$readout_pattern    = 'none';
#$ngroups  =   88;

#
#     sources to include
#
$ngal   = 34730;
$ngal   = 61877;
$ngal   = 338818;
$ngal   = 1000000;
$include_stars               = 0;
$include_galaxies            = 1;
$include_cloned_galaxies     = 0;
#
$star_catalogue              = 'star.cat';
$ra0                         = 53.15;
$dec0                        =-27.79;
$pa_degrees                  =  0.00;
#$star_catalogue              = 'none';
# do not use:
#$galaxy_catalogue            = 'candels_nircat.cat';
# instead, creat the catalogue below using test_make_fake_cat option 1
$galaxy_catalogue            = 'candels_with_fake_mag.cat';
#$galaxy_catalogue            = 'cloned_mock_all_mag.cat';
#$galaxy_catalogue            = 'mock_2017_11_03.cat';
#$galaxy_catalogue            = 'mock_2018_03_13.cat';
#$galaxy_catalogue            = 'galaxy.cat';
#$galaxy_catalogue            = 'none';
#
#$star_catalogue            = 'ngc2420.cat';
$star_catalogue            = $galaxy_catalogue;
#$galaxy_catalogue          = $star_catalogue;

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
#################################################################################
#
#
#  External sources of noise
#
# Background
# mode ( 0 = no bkg; 1= JWST calculator )
#
$include_bg            = 0 ;
$bkg_mode              = 1 ;
$background_file       = 'goods_s_2019_12_21.txt'; 
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
$cr_mode           = 2 ;
#
# list of NIRCam filters,
# to use a filter set value to 1
#
$use_filter{'F070W'}  = 0;
$use_filter{'F090W'}  = 0;
$use_filter{'F115W'}  = 0;
$use_filter{'F140M'}  = 0;
$use_filter{'F150W'}  = 0;
$use_filter{'F162M'}  = 0;
$use_filter{'F164N'}  = 0;
$use_filter{'F182M'}  = 0;
$use_filter{'F187N'}  = 0;
$use_filter{'F200W'}  = 1;
$use_filter{'F210M'}  = 0;
$use_filter{'F212N'}  = 0;
# LW
$use_filter{'F250M'}  = 0;
$use_filter{'F277W'}  = 0;
$use_filter{'F300M'}  = 0;
$use_filter{'F323N'}  = 0;
$use_filter{'F335M'}  = 0;
$use_filter{'F356W'}  = 0;
$use_filter{'F360M'}  = 0;
$use_filter{'F405N'}  = 0;
$use_filter{'F410M'}  = 0;
$use_filter{'F430M'}  = 0;
$use_filter{'F444W'}  = 0;
$use_filter{'F460M'}  = 0;
$use_filter{'F466N'}  = 0;
$use_filter{'F470N'}  = 0;
$use_filter{'F480M'}  = 0;
#
@filter_path = `ls /home/cnaw/guitarra/nircam_filters/*dat | grep -v w2`;
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
$catalogue_filter{'F070W'}  = 0;
$catalogue_filter{'F090W'}  = 0;
$catalogue_filter{'F115W'}  = 0;
$catalogue_filter{'F140M'}  = 0;
$catalogue_filter{'F150W'}  = 0;
$catalogue_filter{'F162M'}  = 0;
$catalogue_filter{'F164N'}  = 0;
$catalogue_filter{'F182M'}  = 0;
$catalogue_filter{'F187N'}  = 0;
$catalogue_filter{'F200W'}  = 0;
$catalogue_filter{'F210M'}  = 0;
$catalogue_filter{'F212N'}  = 0;
# NIRCam LW
$catalogue_filter{'F250M'}  = 0;
$catalogue_filter{'F277W'}  = 0;
$catalogue_filter{'F300M'}  = 0;
$catalogue_filter{'F323N'}  = 0;
$catalogue_filter{'F335M'}  = 0;
$catalogue_filter{'F356W'}  = 0;
$catalogue_filter{'F360M'}  = 0;
$catalogue_filter{'F405N'}  = 0;
$catalogue_filter{'F410M'}  = 0;
$catalogue_filter{'F430M'}  = 0;
$catalogue_filter{'F444W'}  = 0;
$catalogue_filter{'F460M'}  = 0;
$catalogue_filter{'F466N'}  = 0;
$catalogue_filter{'F470N'}  = 0;
$catalogue_filter{'F480M'}  = 0;
#
# List of point spread functions
#
$string = $guitarra_aux.'WebbPSF_NIRCam_PSFs/*.fits';
@psf = `ls $string`;
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
		print "use filter $filter\n";
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
%cat_filter_number  = () ;
$nc                 = 0;
$filters_in_cat     = 0;
foreach $filter (sort(keys(%catalogue_filter))) {
    $nc++;
    if($catalogue_filter{$filter} == 1) {
# nc is the position of this filter in the list of filters
	$cat_filter_number{$filter} = $nc;
	$filters_in_cat++;
	print "filter in source catalogue : $nc $filter\n";
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
#   positions to simulate 
#   survey_mode = 0 will require external task
#
@ra_center = ();
@dec_center = ();
@pa         = ();
#
################################################################################
#
# non - APT
#
if($survey_mode == 0) {
    @dither_pattern = ();
    @primary         = ();
    @number_primary = ();
    @number_subpixel = ();
#
#  NGC 2420
#    $star_catalogue              = 'ngc2420.cat';
#    $galaxy_catalogue            = $star_catalogue;
#
#    $ra0  =  7.+ 38.0/60.0 + 23.0/3600.0;
#    $ra0  = $ra0 * 15.0;
#    $ra0  = $ra0 - 1.0/60.0;
#    $dec0 =  21. + 34.0/60.0 + 24.0/3600.0;
#    $pa_degrees     = 0.00;
    push(@ra_center, $ra0);
    push(@dec_center, $dec0);
    push(@pa, $pa_degrees);
    push(@primary, $primary);
    push(@number_subpixel,$number_subpixel);
    
    $dithers = $#pa + 1;
    $dither_par = apt_less_dithers($camera, $primary, $subpixel_dither, $number_primary, $number_subpixel, \@ra_center,\@dec_center, \@pa);
print "number of dithers $dithers\n";
}
#
# If a central position and dither patterns are used, follow this path
#
system ('gfortran configure_dithers.f nircam_dithers.f read_dithers.f dither_arrays.f -o configure_dithers');
system ('configure_dithers');
$file  = 'guitarra_dithers.dat';
open(CAT,"<$file") || die "cannot open $file";
@ra0     = ();
@dec0    = ();
@pa      = ();
@new_ra  = ();
@new_dec = ();
@dx      = ();
@dy      = ();
$subpxnum = 1;
while(<CAT>) {
    chop $_;
    @junk = split(' ',$_);
    push(@ra0,     $junk[1]);
    push(@dec0,    $junk[2]);
    push(@new_ra,  $junk[3]);
    push(@new_dec, $junk[4]);
    push(@dx,      $junk[5]);
    push(@dy,      $junk[6]);
    push(@pa0, $pa_degrees);
}
close(CAT);
$number_dithers = $#dx;
$ndithers =  $number_dithers + 1;
print "number of dithers $ndithers\n";
#
############################################################################
#
# These are parameters required to create 1/F noise
#
($max_groups, $nframe, $nskip)= set_params($readout_pattern);
if($ngroups > $max_groups) {
    print "number of groups $ngroups greater than max_groups $max_groups\n";
    exit(0);
} else {
    $naxis3 = $ngroups * ($nframe+$nskip);
}
if($include_1_over_f == 1) {
    print "\n\n1/F calculation will be made for $naxis3 frames\n";
}
#
############################################################################
#
# write out the batch file, looping over filters, SCAs and dithers
#
# This is the output file:
#
$parallel_input = 'batch';
#

@sca =($sca_id);

# If more than one SCA is desired

if($apername eq 'NRCALL') {
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
#
# The number of jobs (to run in parallel) will (sort of) be the product of
# number_parallel = #(SCA) * #(filters) * #(dithers)
# 

print "apername is $apername\n";
print "scas are @sca\n";
$number_parallel = ($number_dithers +1) * ($#filters + 1) * ($#sca+1);
#print "number_dithers $number_dithers\n";
$nfilters = $#filters + 1;
print "number of filters $nfilters\n";

$nsca  = $#sca + 1;
print "number of SCAs   $nsca\n";
#$parallel_jobs = $number_parallel + 1;
print "number of jobs that need to be run is $number_parallel\n";
#
# If not including the NIRCam FOV distortion use this to make conversions:
#
if($distortion == 0) {
    $command = 'make proselytism';
    system($command);
}
$counter = 0 ;
open(BATCH,">$parallel_input") || die "cannot open $parallel_input";
for($nsca = 0 ; $nsca <= $#sca ; $nsca++) {
    $sca_id = $sca[$nsca];
    print "apername  $apername  sca  $sca_id\n";
#
    for($nf = 0 ; $nf <= $#filters ; $nf++) {
	$key = $names[$nf];
	$key =~ s/\s//g;
	print "$nf, $names[$nf], $key\n";
# check that combination of filter + sca is valid
	if(($sca_id == 485 || $sca_id == 490) && $filters[$nf] < 11) {next;}
	if(($sca_id != 485 && $sca_id != 490) && $filters[$nf] > 10) {next;}
	$position = 0;
	$filter_name = $names[$nf];
	$filter_index_in_catalogue = $catalogue_filter_index{$filter_name};
	print "sca: $sca_id  filter : $filter_index_in_catalogue $filters[$nf] $names[$nf]\n";
#
	for($dither = 0 ; $dither <= $number_dithers ; $dither++) {
#
	    $counter++ ;
	    $position  = $position + 1;
	    $pa_degrees = $pa0[$dither];
	    print "dither, position, $dither, $position\n";
	    
	    if($include_1_over_f == 1) {
		$noise_file = join('_','ng_hxrg_noise',$sca_id,
				   sprintf("%04d",$counter).'.fits');
		$zeroth_command = join(' ','python','run_nghxrg.py',$sca_id,$naxis3, $noise_file);
#		print BATCH $command,"\n";
	    } else {
		$noise_file = 'None';
		$zeroth_command = 'none';
#		$command = 'date'; # serves as a filler 
#		print BATCH $command,"\n";
	    }
#	    print "counter is $counter\n";
#
# name of simulated file
#
	    $output_file = join('_','sim_cube',$names[$nf],$sca_id,sprintf("%03d",$position).'.fits');
	    $catalogue_input = join('_','cat',$names[$nf],$sca_id,sprintf("%03d",$position).'.input');
	    $input = join('_','params',$names[$nf],$sca_id,sprintf("%03d",$position).'.input');
#
# Catalogues with X, and Y positions derived from RA and DEC
#
	    $input_s_catalogue = $star_catalogue;
	    $input_s_catalogue =~ s/.cat//g;
	    $input_s_catalogue = join('_',$input_s_catalogue,$sca_id,sprintf("%03d",$position).'.cat');
	    $input_g_catalogue = $galaxy_catalogue;
	    $input_g_catalogue =~ s/.cat//g;
	    $input_g_catalogue = join('_',$input_g_catalogue,$sca_id,sprintf("%03d",$position).'.cat');
#
# Case for no FOV distortion
#
	    if($distortion == 0) {
		$cat = $catalogue_input;
		open(CAT,">$cat") || die "cannot open $cat";
		print CAT $filters_in_cat,"\n";
		$line = join(' ',$ra0[$dither], $dec0[$dither],$pa_degrees);
		print CAT $line,"\n";
		print CAT $sca_id,"\n";
		print CAT $star_catalogue,"\n";
		print CAT $input_s_catalogue,"\n";
		print CAT $galaxy_catalogue,"\n";
		print CAT $input_g_catalogue,"\n";		
		close(CAT);
		$command = join(' ','proselytism','<',$catalogue_input);
		$first_command = $command;
	    } else {
#
# Case for FOV distortion
#
		$input_s_catalogue = $star_catalogue;
		$input_s_catalogue =~ s/.cat//g;
		$input_s_catalogue = join('_',$input_s_catalogue,$sca_id,sprintf("%03d",$position).'.cat');
		$input_g_catalogue = $galaxy_catalogue;
		$input_g_catalogue =~ s/.cat//g;
		$input_g_catalogue = join('_',$input_g_catalogue,$sca_id,sprintf("%03d",$position).'.cat');
#
		$python_input = 'distort_catalogue.dat';
		open(PY,">$python_input") || die "cannot open $python_input";
#		print CAT $nfilters,"\n";
		print PY $galaxy_catalogue,"\n";
		print PY $ra0[$dither],"\n";
		print PY $dec0[$dither], "\n";
		print PY $pa_degrees,"\n";
		print PY $input_g_catalogue,"\n";
		print PY $sca_id,"\n";
		close(PY);
		$command = 'python /home/cnaw/anaconda3/distortion/nrc_distortion_v1.py';
		$first_command = $command;
	    }
#
# Get PSF file
#
	    @use_psf = ();
	    for($ppp = 0 ; $ppp <= $#psf ; $ppp++) {
		if($psf[$ppp] =~ m/$filter_name/) {
		    push(@use_psf,$psf[$ppp])
		}
	    }
	    $npsf = $#use_psf + 1;
#
# parameter file read by the main code with RA0, DEC0, new dithered centre and
# displacement
#
	    $ndithers  = $#dithers + 1;
	    print "writing  $input\n";
	    open(INPUT,">$input") || die "cannot open $input";
	    print INPUT $output_file, "\n";
	    print INPUT $noise_file,"\n";
	    print INPUT $ra0[$dither],"\n";
	    print INPUT $dec0[$dither], "\n";
	    print INPUT $sca_id,"\n";
#           print INPUT $filter_name,"\n";
# print INPUT $distorted_catalogue,"\n";            
            print INPUT $input_s_catalogue,"\n";
            print INPUT $input_g_catalogue,"\n";
            print INPUT $filters_in_cat,"\n";
            $fortran_filter_index  = $filter_index_in_catalogue + 1;
            print INPUT $fortran_filter_index,"\n";
            print INPUT $path{$filter_name},"\n";
# Include here the path to PSF for this filter (2019-01-30)
	    print INPUT $npsf,"\n";
	    for($ppp = 0 ; $ppp <= $#use_psf ; $ppp++) {
		print INPUT $use_psf[$ppp];
		print "$use_psf[$ppp]";
	    }
            print INPUT $background_file,"\n";
            print INPUT $verbose,"\n";
 	    if($noiseless == 1) {
		print INPUT ".true.\n";
	    }else{
		print INPUT ".false.\n";
	    }
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
#           print INPUT $cat_filter_number{$filter_name},"\n";
#           print "filter_index $filter_index\n";
#           print "filter_name $filter_name\n";
#           print "filter_index_in_catalogue $filter_index_in_catalogue\n";
#           print "cat_filter_number $cat_filter_number{$filter_name}\n";
#           print "$path{$filter_name}\n";
# dither info
 	    print INPUT $primary,"\n";
	    print INPUT $position,"\n";
	    print INPUT $number_primary,"\n";
	    print INPUT $subpxnum,"\n";
	    print INPUT $number_subpixel,"\n";
	    close(INPUT);
	    $second_command  = join(' ','/bin/nice -n 19 guitarra','<',$input);
	    if($noiseless == 1) {
		$ncdhas_flags = '-dr +cbp -cs -cbs -cd -cl -wi +ow +ws -ipc +cfg isimcv3';
		$third_command = join(' ','/home/cnaw/bin/ncdhas',$output_file,$ncdhas_flags);
	    } else {
		$third_command = join(' ','ncdhas.pl',$output_file);
	    }
	    if($zeroth_command eq 'none') {
		$command = $first_command.' ; '.$second_command.' ; '.$third_command;
	    } else {
		$command = join(' ;',$zeroth_command, $first_command,
				$second_command, $third_command);
	    }
	    print BATCH $command,"\n";
	}
    }
}
close(BATCH);
$command = 'make guitarra';
print "$command\n";
system($command);

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
#############################################################
##
sub apt_less_dithers{
    my($camera, $primary_dither, $subpixel_dither, $number_primary, $number_subpixel, $ra_center_pointer, $dec_center_pointer, $pa_pointer) =@_;
    my($dither_par, $ra0, $dec0, $pa_degrees, $moves, $i, $comment, $line);
    my(@ra_center)   = @$ra_center_pointer;
    my(@dec_center)  = @$dec_center_pointer;
    my(@pa)          = @$pa_pointer;

#
#   Configure the dither sequencce
#
# if running a batch, calculate centres of dithered scenes
#
    $dither_par = 'dither.par';
    open(OUT,">$dither_par") || die "cannot open $dither_par";
#
    $comment = ' # Camera ';
    $line = sprintf("%-20s  %s", $camera, $comment);
    print OUT $line,"\n";
#
    $comment = ' # Primary dither ';
    $line = sprintf("%-20s  %s", $primary_dither, $comment);
    print OUT $line,"\n";
#
    $comment = ' # Subpixel dither ';
    $line = sprintf("%-20s  %s", $subpixel_dither, $comment);
    print OUT $line,"\n";
#
    $comment = ' # number of primary dithers';
    $line = sprintf("%12d  %s", $number_primary, $comment);
    print OUT $line,"\n";
#
    $comment = ' # number of subpixel dithers';
    $line = sprintf("%12d  %s", $number_subpixel, $comment);
    print OUT $line,"\n";
#
    $comment = ' # number of large moves';
    $moves   = $#ra_center + 1;
    $line = sprintf("%12d  %s", $moves, $comment);
    
    print OUT $line,"\n";
    for($i = 0 ; $i <= $#ra_center ; $i++) {
	$ra0         = $ra_center[$i];
	$dec0        = $dec_center[$i];
	$pa_degrees  = $pa[$i];
	
	$comment =' # RA (degrees) of center ';
	$line = sprintf("%12.7f  %s", $ra0,$comment);
	print OUT $line,"\n";
#
	$comment =' # Dec (degrees) of center ';
	$line = sprintf("%12.7f  %s", $dec0,$comment);
	print OUT $line,"\n";
#
	$comment =' # Position angle (degrees) of NIRCam short axis (N to E) ';
	$line = sprintf("%12.7f  %s", $pa_degrees,$comment);
	print OUT $line,"\n";
    }
#
    close(OUT);
    return $dither_par;
}
##
## now that the positions have been calculated, read them in;
##
#$file = 'guitarra_dithers.dat';
#unlink $file;
#
