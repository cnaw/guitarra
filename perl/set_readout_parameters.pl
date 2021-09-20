############################################################################
#
# Set parameters that will be used to create 1/f nois
#
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
#
#-----------------------------------------------------------------------
#
sub get_scas{
    my($apername) = @_;
    my(@sca);
    if($apername eq '') {
	print "at set_readout_parameters.pl: ",__LINE__," get_scas: apername not defined\n";
	print "apername is $apername\n";
	print "at set_readout_parameters line : ",__LINE__," issues when reading APT file\n";
	exit(0);
    }

    if($apername eq 'NRCALL_FULL') {
	@sca =(481, 482, 483, 484, 486, 487, 488, 489, 485, 490);
    }
    if($apername eq 'NRCBS_FULL') {
	@sca =(486, 487, 488, 489, 490);
    }
    if($apername eq 'NRCAALL') {
	@sca =(481,482,483,484,485);
    }
    if($apername eq 'NRCAS_FULL') {
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
#
    if($apername =~ m/NRCA1/) {
	    @sca = (481);
    }
    if($apername =~ m/NRCA2/) {
	    @sca = (482);
    }
    if($apername =~ m/NRCA3/) {
	    @sca = (483);
    }
    if($apername =~ m/NRCA4/) {
	    @sca = (484);
    }
    if($apername =~ m/NRCB1/) {
	@sca = (486);
    }
    if($apername =~ m/NRCB2/) {
	@sca = (487);
    }
    if($apername =~ m/NRCB3/) {
	@sca = (488);
    }
    if($apername =~ m/NRCB4/) {
	@sca = (489);
    }
    if($apername eq 'NRCB1_SUB64P') {
	@sca = (486);
    }
    if($apername eq 'NRCB5_SUB160') {
	@sca = (490);
    }
    if($apername =~ m/NRCA5_GRISM/) {
	@sca = (481, 482, 483, 484, 485);
    }
    if($apername =~ m/NRCB5_GRISM/) {
	@sca = (486, 487, 488, 489, 490);
    }
    return \@sca;
}
#
#----------------------------------------------------------------------- 
#
sub initialise_filters{
    my %use_filter;
    $use_filter{'F070W'}  = 0;
    $use_filter{'F090W'}  = 0;
    $use_filter{'F115W'}  = 0;
    $use_filter{'F140M'}  = 0;
    $use_filter{'F150W'}  = 0;
    $use_filter{'F150W2'} = 0;
    $use_filter{'F162M'}  = 0;
    $use_filter{'F164N'}  = 0;
    $use_filter{'F182M'}  = 0;
    $use_filter{'F187N'}  = 0;
    $use_filter{'F200W'}  = 0;
    $use_filter{'F210M'}  = 0;
    $use_filter{'F212N'}  = 0;
# LW
    $use_filter{'F250M'}  = 0;
    $use_filter{'F277W'}  = 0;
    $use_filter{'F300M'}  = 0;
    $use_filter{'F322W2'} = 0;
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
    return \%use_filter;
}
#
#----------------------------------------------------------------------- 
#
sub catalogue_filters{
    my %catalogue_filter;
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
    return \%catalogue_filter;
}
1;

