sub print_batch{
    my($input_file,@variables) = @_;
    my $debug = 0;
    my($module,
       $aperture, 
       $sca_id,
       $subarray,
       $colcornr,
       $rowcornr,
       $naxis1,
       $naxis2,
       $substrt1,
       $substrt2,
#
       $readout_pattern,
       $ngroups,
       $primary_dither_type,
       $primary_dither_string,
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
       $obs_id,
       $visit_id,
       $visit_number,
       $visit_group,
       $sequence_id,
       $activity_id,
       $exposure_request,
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
       $output_clone_file,
       $filters_in_cat,
       $fortran_filter_index,
#
       $xoffset,
       $yoffset,
       $v2,
       $v3,
#
       $filter_path,
       $pupil,
       $output_file,
       $write_tute,
       $tute_file,
       $cr_history,
       $background_file,
       $noise_file,
       $flat_file,
       $use_psf_ref);
#
    my @header = ('module',
		  'aperture',
		  'sca_id',
		  'subarray',
		  'colcornr',
		  'rowcornr',
		  'naxis1',
		  'naxis2',
		  'substrt1',
		  'substrt2',
#
		  'readout_pattern',
		  'ngroups',
		  'patttype',
		  'nmdthpts',
		  'numdthpt',
		  'patt_num',
		  'subpixel_dither_type',
		  'subpxpns',
		  'subpxnum',
		  'nints',
#
		  'verbose',
		  'noiseless',
		  'brain_dead_test',
		  'include_ipc',
		  'include_bias',
		  'include_ktc',
#
		  'include_dark',
		  'include_dark_ramp',
		  'include_readnoise',
		  'include_reference',
		  'include_non_linear',
		  'include_latents',
#
		  'include_flat',
		  'include_1_over_f',
		  'include_cr',
		  'cr_mode',
		  'include_bg',
		  'include_galaxies',
#
		  'include_cloned_galaxies',
		  'seed',
#
		  'target_number', 
		  'targprop',
		  'targetarchivename',
		  'title',
		  'obslabel',
		  'program',
		  'category',
		  'obs_id',
		  'visit_id',
		  'observtn',
		  'visitgrp',
		  'seq_id',
		  'act_id',
		  'exposure',
		  'expripar',
#
		  'distortion',
		  'SIAF_version',
		  'ra_nircam',
		  'dec_nircam',
		  'pa_degrees',
		  'star_subcatalogue',
		  'galaxy_subcatalogue',
		  'clone_subcatalogue',
		  'output_cloned_cat',
		  'filter_in_catalogue',
		  'filter_index',
#
		  'xoffset',
		  'yoffset',
		  'v2',
		  'v3',
#
		  'filter_path',
		  'pupil',
		  'output_file',
		  'write_tute',
		  'tute_file',
		  'cr_history',
		  'background_file',
		  'flatfield',
		  'noise_file',
		  'npsf',
		  'PSF_file');
#
    my(@type) = ('S','S','I','S','I','I','I','I','I','I',
		 'S','I','S','S', 'I','I','S','I','I','I',
		 'I','I','I','I','I','I',
		 'I','I','I','I','I','I',
		 'I','I','I','I','I','I',
		 'I','I',
		 'S','S','S','S','S','S','S','S','S','S','S','S','S','S','S',
		 'I','S','E','E','E','S','S','S','S','I','I',
		 'E','E','E','E',
		 'S','S','S','S','S','S','S','S','S','I','S');
    
    $debug = 0;
    $use_psf_ref = $variables[$#variables];
    my @psf  = @$use_psf_ref;
    my $npsf = $#psf+1;
#
    my $nlines = @variables;
#    
#    $debug = 1;
    open(INPUT,">$input_file") || die "cannot open $input_file";
#    print INPUT $input_file;    
    for( my $ii=0; $ii < ($nlines-1);$ii++) {
	if($debug == 1) {print "$ii $header[$ii], $type[$ii], $variables[$ii]\n";}
#	print "print_batch.pl: $ii $header[$ii], $type[$ii], $variables[$ii]\n";
	if($type[$ii] eq 'S') {
	    $line = sprintf("%-30s %1s %-180s\n",$header[$ii], $type[$ii], $variables[$ii]);
	} else {
	    $line = sprintf("%-30s %1s %20s\n", $header[$ii], $type[$ii], $variables[$ii]);
	}
	if($debug != 0) {print "$ii: $line";}
	print INPUT $line;
    }
    $line = sprintf("%-30s %1s %20s\n",'npsf', 'I', $npsf);
    if($debug != 0) {print "$line";}
    print INPUT $line;
    
    for (my $ii = 0 ; $ii < $npsf; $ii++) {
	$line = sprintf("%-30s %1s %-180s\n", 'PSF', 'S', $psf[$ii]);
	if($debug != 0) {print "$line";}
	print INPUT $line;
    }
    
    close(INPUT);
       return;
}
1;
