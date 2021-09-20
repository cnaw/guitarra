sub read_visit_parameters{
    use Scalar::Util qw(looks_like_number);
    my($visit_file, $debug) = @_;
    my $apername;
    my $module;
    my($parameters_ref);
    my $observation;
    my($targetid);
    my $visit_id;
    my $primary_dither_string;
    my($dither, $subpixel);
#
    my @groups; 
    my @keywords;
    my @nints; 
    my @shortpupil;
    my @longpupil; 
    my @shortwave;
    my @longwave; 
    my @readout; 
#
    my(%parameters);
    my %obs_visits;
    my(%visit_setup);
#
    $parameters_ref = initialise_parameters();
    %parameters     = %$parameters_ref;
    print "read_visit_parameters.pl at line : ",__LINE__," visit_file : $visit_file\n";
    open(FILE,"<$visit_file") || 
	die "cannot open $visit_file at read_visit_parameters";
    print "\n";
    while(<FILE>) {
	chop $_;
	my ($parameter, $value) = split(' ',$_);

	if($parameter eq 'Target_Number') {
	    @keywords = ();
            @shortpupil = ();
	    @longpupil = (); 
            @shortwave = ();
	    @longwave = (); 
	    @readout = (); 
	    @groups = (); 
	    @coords = ();
	    @nints = (); 
	    undef $targetid;
	    undef $module;
	    undef $apername;
	    undef $visit_id;
	    if($debug == 1) {print "\n\n";}
	}
	if($parameter eq 'TARGPROP') {
	    $targetid = $value;
	}
#
	if($parameter eq 'OBSERVTN') {
	    $observation = $value;
	}
#
	if($parameter eq 'MODULE') {
	    $module = $value;
	}
#
	if($parameter eq 'APERNAME') {
	    $apername = $value;
	}
#
	if($parameter eq 'VISIT_ID') {
	    $visit_id = $value;
	}
# Parameters that only show up once
	if(exists($parameters{$parameter})) {
	    if($debug == 1) {
		print "read_visit_parameters.pl at line : ",__LINE__," parameter :$parameter,  value: $value\n";
	    }
	    push(@keywords, $value);
	}
# parameters which may change during a visit
	if(lc($parameter) =~ m/shortpupil/) {
	    push(@shortpupil,$value);
	    if($debug == 1) {
		print "read_visit_parameters.pl at line : ",__LINE__," $parameter:  $value\n";
	    }
	}
	if(lc($parameter) =~ m/longpupil/) {
	    push(@longpupil,$value);
	    if($debug == 1) {
		print "read_visit_parameters.pl at line : ",__LINE__," $parameter:  $value\n";
	    }
	}
	if(lc($parameter) =~ m/shortfilter/) {
	    push(@shortwave,$value);
	    if($debug == 1) {
		print "read_visit_parameters.pl at line : ",__LINE__," $parameter:  $value\n";
	    }
	}
	if($parameter =~  m/LongFilter/) {
	    push(@longwave,$value);
	    if($debug == 1) {
		print "read_visit_parameters.pl at line : ",__LINE__," $parameter:  $value\n";
	    }
	}
	if($parameter eq 'ReadoutPattern') {
	    push(@readout,$value);
	    if($debug == 1) {
		print "read_visit_parameters.pl at line : ",__LINE__," $parameter:  $value\n";
	    }
	}
	if($parameter eq 'Groups') {
	    push(@groups,$value);
	    if($debug == 1) {
		print "read_visit_parameters.pl at line : ",__LINE__," $parameter:  $value\n";
	    }
	}
	if($parameter eq 'Nints') {
	    push(@nints,$value);
	    if($debug == 1) {
		print "read_visit_parameters.pl at line : ",__LINE__," $parameter:  $value\n";
	    }
	}
#        if($parameter eq 'NMDTHPTS') {
#	    $primary_dither_string = $value;
#	    if($debug == 1) {
#		print "read_visit_parameters.pl at line : ",__LINE__," $parameter:  $value\n";
#	    }
#	}

        if($parameter eq 'NUMDTHPT') {
	    if($debug == 1) {
		print "read_visit_parameters.pl at line : ",__LINE__," $parameter:  $value\n";
	    }
            if(looks_like_number($value)){
		$dither = $value;
	    } else {
		$dither = substr($value, 0,1);
		if(! looks_like_number($dither)){
		    $dither = $value;
		    print "read_visit_parameters.pl parameter $parameter has value $value\npause\n";
		    print "read_visit_parameters.pl parameter $parameter dither is $dither\npause";
		    <STDIN>
		}
	    }
        }
#
	if($parameter eq 'SubPixelDitherType') {
	    if($debug == 1) {
		print "read_visit_parameters.pl at line : ",__LINE__," $parameter:  $value\n";
	    }
	    my $end = index($value,'-');
	    $subpixel = substr($value,0,$end);
	}
#
	if($parameter eq 'SUBPXPNS') {
	    if($debug == 1) {
		print "read_visit_parameters.pl at line : ",__LINE__," $parameter:  $value\n";
	    }
            if(looks_like_number($value)){
		$subpixel = $value;
	    } else{
		print "read_visit_parameters.pl parameter $parameter has value $value\n";
		if($value eq '' ) {$subpixel = 1;}
		print "read_visit_parameters.pl parameter $parameter subpixel is $subpixel\npause";
		<STDIN>;
	    }
	}
# Associate the instrument setup (filters, readout) with telescope positions
	if($parameter eq 'ndithers') {
	    if($debug == 1) {
		print "read_visit_parameters.pl at line : ",__LINE__," $parameter:  $value\n";
	    }
	    my $ndithers = $value;
	    my $total_filter = scalar(@shortwave);
# these will be equivalent if PRIME is NIRCam. When
# PRIME is NIRSpec, or this is a NIRCam WFSS observation $perfilter breaks
	    if($dither =~ m/NIRSPEC/) {
		$dither =~ s/NIRSPEC//;
	    }
	    if($total_filter == 0) {
		print "read_visit_parameters.pl at line : ",__LINE__," visit:$visit_id; module: $module; apername: $apername; total_filter is $total_filter;  dither is $dither; ndithers: $ndithers\npause\n";
		$total_filter = 1;
		<STDIN>;
	    }
# this should give the number of telescope moves per filter
	    if($debug == 1) {
		print "read_visit_parameters: at line ",__LINE__," total_filter $total_filter\n";
		print "read_visit_parameters: at line ",__LINE__," dither       $dither\n";
		print "read_visit_parameters: at line ",__LINE__," dither       $subpixel\n";
	    }
	    my $xxxx = $ndithers/$total_filter;
	    if($subpixel eq '' || $subpixel == 0) {
		$subpixel = 1;
	    }
	    my $perfilter = $dither * $subpixel;
	    if($debug == 1) {
		print "read_visit_parameters: perfilter $perfilter xxxx: $xxxx $total_filter, $ndithers, $dither, $subpixel\n";
	    }
	    $perfilter = $xxxx;
	    my $jj = 0;
	    my $line;
	    my(@coords);
	    for (my $ii = 0; $ii < $ndithers; $ii++) {
		$line = <FILE>;
		if($debug == 1 ) {print "read_visit_parameters.pl at line : ",__LINE__," $line";}
		print "read_visit_parameters.pl at line : ",__LINE__," $line";
		chop $line;
#		my($ra,$dec,$pa,$tar, $tile, $exposure, $subpixel_dither, $xoffset, $yoffset, $v2, $v3 ) 
#		    = split(' ',$line);
#		$line = join(',',$ra, $dec,$pa,$shortwave[$jj], $longwave[$jj], $readout[$jj],$groups[$jj], $nints[$jj],$shortpupil[$jj],$longpupil[$jj],$tar, $tile, $exposure, $subpixel_dither, $xoffset, $yoffset, $v2, $v3);
#
		my @junk = split(' ',$line);
		$line = join(',',$junk[0], $junk[1], $junk[2], $shortwave[$jj], $longwave[$jj], $readout[$jj],$groups[$jj], $nints[$jj],$shortpupil[$jj],$longpupil[$jj], $junk[5], $junk[6], $junk[7], $junk[8], $junk[9], $junk[10], $junk[11], $junk[12]);
		if($junk[12] eq '') {
		    print "read_visit_parameters:line too short: @junk\n";
		    die;
		}
		if($debug == 1 ) {print "read_visit_parameters.pl at line : ",__LINE__," $line\n";}
		push(@coords, $line);
#		if($perfilter == 0 || $ii == 0) {
#		print "read_visit_parameters.pl at line : ",__LINE__," visit_id: $visit_id ii: $ii, perfilter: $perfilter ndithers: $ndithers total_filter: $total_filter\n";
#		    $mod =0;
#		} else {
		$mod = $ii % $perfilter;
#		}
		if($mod == $perfilter-1) {$jj++;}
		if($debug == 1 ) {
		    print "read_visit_parameters.pl at line : ",__LINE__," visit_id: $visit_id", sprintf(" %02d",$ii+1)," $line\n";
		}
	    }
#	    $visit_setup{$targetid} = join('#',@keywords,@coords);
#	    $visit_setup{$observation} = join('#',@keywords,@coords);
	    $visit_setup{$visit_id} = join('#',@keywords,@coords);
#	    print "read_visit_parameters.pl at line : ",__LINE__," visit_id: $visit_id, targetid: $targetid  $visit_setup{$targetid}\n";
#	    print "read_visit_parameters.pl at line : ",__LINE__," visit_id: $visit_id, targetid: $targetid, observation : $observation\n";
	    if($debug == 1) {
		print "read_visit_parameters.pl at line : ",__LINE__," visit_setup{$visit_id}: $visit_setup{$visit_id}\n";
		<STDIN>;
	    }
	    print "read_visit_parameters.pl at line : ",__LINE__," visit_id : $visit_id\n";
	}
    }
    close(FILE);
    return \%visit_setup;
}
#
#---------------------------------------------------------------------- 
#
sub initialise_parameters{    
    my %parameters = (Target_Number                => '',
		      TARGPROP              => '',
		      TargetArchiveName     => '',
		      TITLE                 => 'None',
		      Label                 => 'None',
		      PROGRAM               => 'None',
		      CATEGORY              => 'None',
		      EXPRIPAR              => '',
		      ParallelInstrument    => 'None',
		      RA                    => '',
		      Declination           => '',
		      PA_V3                 => '',
		      MODULE                 => '',
		      APERNAME              => '',
		      PATTTYPE              => 'None',
		      NMDTHPTS              => 'None',
		      NUMDTHPT              =>  0,
		      SubPixelDitherType    => 'None',
		      SUBPXPNS              => 'None',
		      SUBARRAY              => '',
		      VISIT_ID              => 'None',
		      OBSERVTN              => 'None',
		      PrimaryInstrument     => '',
		      ndithers              => ''
	);
    return \%parameters;
}
1;
