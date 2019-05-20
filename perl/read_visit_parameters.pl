sub read_visit_parameters{
    my @keywords;
    my($visit_file, $debug) = @_;
    my($targetid);
#    my($proposal_category, $proposal_id);
    my($parameters_ref) = initialise_parameters();
    my @shortwave;
    my @longwave; 
    my @readout; 
    my @groups; 
    my @nints; 
    my(%parameters) = %$parameters_ref;
    my(%visit_data);
    my(%visit_setup);
    my($dither, $subpixel);
    open(FILE,"<$visit_file") || 
	die "cannot open $visit_file at read_visit_parameters";
    while(<FILE>) {
	chop $_;
	my ($parameter, $value) = split(' ',$_);
	if($debug == 1) {print "read_visit_parameters: $parameter, $value\n";}
	if($parameter eq 'Target_number') {
	    %visit_setup = ();
	    @keywords = ();
            @shortwave = ();
	    @longwave = (); 
	    @readout = (); 
	    @groups = (); 
	    @coords = ();
	    @nints = (); 
	}
	if($parameter eq 'TARGPROP') {
	    $targetid = $value;
	}
# Parameters that only show up once
	if(exists($parameters{$parameter})) {
	    push(@keywords, $value);
	}
# parameters which my change during a visit
	if($parameter eq 'ShortFilter') {
	    push(@shortwave,$value);
	}
	if($parameter eq 'LongFilter') {
	    push(@longwave,$value);
	}
	if($parameter eq 'ReadoutPattern') {
	    push(@readout,$value);
	}
	if($parameter eq 'Groups') {
	    push(@groups,$value);
	}
	if($parameter eq 'Nints') {
	    push(@nints,$value);
	}
        if($parameter eq 'NUMDTHPT') {
            $dither = $value;
        }
	if($parameter eq 'SubPixelDitherType') {
	    my $end = index($value,'-');
	    $subpixel = substr($value,0,$end);
	}
	if($parameter eq 'SUBPXPNS') {
	    $subpixel = $value;
	}
	if($parameter eq 'ndithers') {
	    my $total_filter = $#shortwave + 1;
# these will be equivalent if PRIME is NIRCam. When
# PRIME is NIRSpec, $perfilter breaks
	    my $xxxx = $value/$total_filter;
	    my $perfilter = $dither * $subpixel;
	    if($debug == 1) {
	    print "read_visit_parameters: perfilter $perfilter $xxxx $total_filter\n";
	    }
	    $perfilter = $xxxx;
	    my $jj = 0;
	    my $line;
	    my(@coords);
	    for (my $ii = 0; $ii < $value; $ii++) {
		$line = <FILE>;
		chop $line;
		my($ra,$dec,$pa) = split(' ',$line);
		$line = join(',',$ra, $dec,$pa,$shortwave[$jj], $longwave[$jj], $readout[$jj],$groups[$jj], $nints[$jj]);
		push(@coords, $line);
		$mod = $ii % $perfilter;
		if($mod == $perfilter-1) {$jj++;}
#		print "$ii $line\n";
	    }
	    $visit_data{$targetid} = join('#',@keywords,@coords);
#	    print "$targetid  $visit_data{$targetid}\n";
#	    <STDIN>;
	}
    }
    close(FILE);
    return \%visit_data;
}
#
#---------------------------------------------------------------------- 
#
sub initialise_parameters{    
    my %visit_setup = (Target_number                => '',
		       TARGPROP              => '',
		       TargetArchiveName     => '',
		       TITLE                 => 'None',
		       Label                 => 'None',
		       PROGRAM               => 'None',
		       CATEGORY              => 'None',
		       EXPRIPAR              => '',
		       RA                    => '',
		       Declination           => '',
		       PA_V3                 => '',
		       APERNAME              => '',
		       PATTTYPE              => 'None',
		       NUMDTHPT              => 'None',
		       SubPixelDitherType    => 'None',
		       SUBPXPNS              => 'None',
		       SUBARRAY              => '',
		       VISIT_ID              => 'None',
		       OBSERVTN              => 'None',
		       PrimaryInstrument     => '',
		       ndithers              => ''
	);
    return \%visit_setup;
}
1;
