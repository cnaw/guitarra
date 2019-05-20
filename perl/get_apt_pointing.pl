#    
#-------------------------------------------------------------------------------
#
sub get_apt_v2_v3{
    my($pointing) = @_;
    my($dither_v2, $dither_v3);
    my($dither_x, $dither_y);
    my($ii,$jj);
    my($v2, $v3);
    my($v2_base, $v3_base);
    my(@v2_position, @v3_position);
    my($exposure, $dither);
    my @junk = split('#',$pointing);

    for ($ii = 0; $ii <= $#junk ; $ii++) {
	my @stuff  = split(' ',$junk[$ii]);
	$exposure = $stuff[2];
	$dither   = $stuff[3];
	if($junk[$ii] =~ m/base/) {
#	    print "$junk[$ii]\n";
	    $v2_base  = $stuff[13];
	    $v3_base  = $stuff[14];
	}
	if($exposure > 0 && $dither > 0) {
	    push(@v2_position, $stuff[13]);
	    push(@v3_position, $stuff[14]);
	    $dither_x  = $stuff[11];
	    $dither_y  = $stuff[12];
	    $dither_v2 = -$dither_x;
	    $dither_v3 = $dither_y;
	    $v2        = $stuff[13];
	    $v3        = $stuff[14];
	}
    }
    return \@v2_position, \@v3_position;
}
#    
#-------------------------------------------------------------------------------
#
sub get_apt_pointings{
    my($file) = @_;
    my($ndithers)  = 0;
    my($nsubpixel) = 0;
    my($observation);
    my($pa_is);
    my($visit);
    
    my(@junk);
    my(@dithers);
    
    my %visit_par ;
    my %visit_angle;
    
    open(FILE,"<$file") || die "file $file not found";
    while(<FILE>) {
	chop $_;
	if($_ =~ m/T_ACQ/) {next;}
	@junk = split(' ',$_);
	if($#junk == -1) { next;}
	if($junk[0] =~ m/#/) {next;}
	if($junk[0] =~ m/=/) {next;} 
	if($junk[0] =~ m/JWST/) {next;}
#
# This will be the key for the %visit_par hash
#
	if(substr($_,0,2)  eq '* ') {
	    $observation = $_;
	    $observation =~ s/\s/\_/g;
	    $observation = substr($observation,2);
	    $ndithers  = 0;
	    $nsubpixel = 0;
	    next;
	}
#
# This provides the visit == observation number
#
	if(substr($_,0,2)  eq '**') {
	    $visit = $_;
	    $visit =~ s/\s/\_/g;
	    $visit = substr($visit,3);
	    next;
	}
	if($_ =~ m/Tar/) {
	    my @header = split(' ',$_);
	    if($header[$#header] =~ m/APA/) {
		$pa_is  = 'APA';
	    }else {
		$pa_is = 'None';
		$visit_angle{$observation} = 'None';
	    }
	    next;
	}
	if($_ =~ m/MIRIM/) { next;}
	if($_ =~ m/NRS/) {
	    if($pa_is eq 'APA') {
		@junk = split(' ',$_);
		$visit_angle{$observation} = $junk[$#junk];
	    }
	    next;
	}
	if($junk[2] > $ndithers) {
	    $ndithers  = $junk[2];
	}
	if($junk[3] > $nsubpixel) {
	    $nsubpixel = $junk[3];
	}
#
	$visit_par{$observation} = join(' ',$ndithers, $nsubpixel);
#	print "get_pointings: $observation $visit_par{$observation}\n";
    }
    close(FILE);
#    for my $key (sort(keys(%visit_par))){
#	print "$key,$visit_par{$key}\n";
#    }
#    <STDIN>;
    return \%visit_par, \%visit_angle;
}
1;
