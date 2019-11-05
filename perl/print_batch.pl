sub print_batch{
    my($input_file,@variables) = @_;
    my $debug = 0;
    my($aperture, 
       $sca_id,
       $subarray,
       $colcornr,
       $rowcornr,
       $naxis1,
       $naxis2,
#
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
       $include_ktc,
       $include_dark,
       $include_readnoise,
       $include_reference,
       $include_non_linear,
       $include_latents,
       $include_1_over_f,
       $include_cr,
       $cr_mode,
       $include_bg,
       $include_galaxies,
       $include_cloned_galaxies,
#
       $target_number, 
       $targetid,
       $targetarchivename,
       $title,
       $label,
       $program,
       $category,
       $visit_id,
       $visit_number,
       $expripar,
#
       $ra0,
       $dec0,
       $pa_degrees,
       $input_s_catalogue,
       $input_g_catalogue,
       $filters_in_cat,
       $fortran_filter_index,
#
       $filter_path,
       $output_file,
       $cr_history,
       $background_file,
       $noise_file,
       $use_psf_ref);
#
    my @header = ('aperture',
		  'sca_id',
		  'subarray',
		  'colcornr',
		  'rowcornr',
		  'naxis1',
		  'naxis2',
#
		  'readout_pattern',
		  'ngroups',
		  'patttype',
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
		  'include_ktc',
		  'include_dark',
		  'include_readnoise',
		  'include_reference',
		  'include_non_linear',
		  'include_latents',
		  'include_1_over_f',
		  'include_cr',
		  'cr_mode',
		  'include_bg',
		  'include_galaxies',
		  'include_cloned_galaxies',
#
		  'target_number', 
		  'targprop',
		  'targetarchivename',
		  'title',
		  'obslabel',
		  'program',
		  'category',
		  'visit_id',
		  'observtn',
		  'expripar',
#
		  'ra_nircam',
		  'dec_nircam',
		  'pa_degrees',
		  'star_subcatalogue',
		  'galaxy_subcatalogue',
		  'filter_in_catalogue',
		  'filter_index',
#
		  'filter_path',
		  'output_file',
		  'cr_history',
		  'background_file',
		  'noise_file',
		  'npsf',
		  'PSF_file');
#
    my(@type) = ('S','I','S','I','I','I','I',
		 'S','I','S','I','I','S','I','I','I',
		 'I','I','I','I','I','I','I','I','I','I','I','I','I','I','I',
		 'S','S','S','S','S','S','S','S','S','S',
		 'E','E','E','S','S','I','I',
		 'S','S','S','S','I','S');
    
    my $debug = 0;
    $use_psf_ref = $variables[$#variables];
    my @psf  = @$use_psf_ref;
    my $npsf = $#psf+1;
#
    my $nlines = @variables;
#    
    open(INPUT,">$input_file") || die "cannot open $input_file";
    
    for( my $ii=0; $ii < ($nlines-1);$ii++) {
	if($debug == 1) {print "$header[$ii], $type[$ii], $variables[$ii]\n";}
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
