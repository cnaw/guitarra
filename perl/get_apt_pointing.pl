#    
#-------------------------------------------------------------------------------
#
sub get_apt_pointing{
    my($aptid, $file, $verbose) = @_;
    my $exposure;
    my $key;
    my $line = "\n";
    my $moves;
    my($ndithers)  = 0;
    my($nsubpixel) = 0;
    my($observation);
    my($pa_is);
    my $subpixel_dither;
    my $tile;
    my($visit);
    my $setup;
    my $v2;
    my $v3;
    my $xoffset;
    my $yoffset;
    
    my(@junk);
    my @more_junk;
    my(@dithers);

    my %exptype;
    my %visit_hash;
    my %visit_par ;
    my %visit_moves;
    my %visit_angle;
    
    print "get_apt_pointing.pl at line : ",__LINE__," reading pointings file : $file\n";
    open(FILE,"<$file") || die "file $file not found";
    while(<FILE>) {
#	print "$_";
	chop $_;
	@junk = split(' ',$_);
# skip header and blank lines
	if($#junk == -1) { next;}
	if($junk[0] =~ m/#/) {next;}
	if($junk[0] =~ m/=/) {next;} 
	if($junk[0] =~ m/JWST/) {next;}
# skip Target acquisition
	if($_ =~ m/T_ACQ/) {next;}
#
# The observation number will be the key for the %visit_par hash
#
	if(substr($_,0,2)  eq '* ') {
	    $observation = $_;
	    $observation =~ s/\s/\_/g;
	    $observation = substr($observation,2);
	    $obsvis    = 0;
	    $ndithers  = 0;
	    $nsubpixel = 0;
	    $moves     = 0 ;
	    $visit_hash{$observation} = '';
	    next;
	}
#
# "Visit" contains the observation number and 
# visit number within that observation
#
	if(substr($_,0,2)  eq '**') {
	    @more_junk  = split(' ',$_);
	    $visit = $more_junk[$#more_junk];
	    ($obsvis, $visit)  = split(':',$visit);
	    $key = sprintf("%05d%03d%03d",$aptid,$obsvis,$visit);
#	    print "key: $key, obsvis: $obsvis, visit: $visit\n";
	    next;
	}
# read header for pointings 
	if($_ =~ m/Tar/) {
	    my @header = split(' ',$_);
# if this column exists, a position angle is present 
# (under the "Plan" column)
	    if($header[$#header] =~ m/APA/) {
		$pa_is  = 'APA';
	    }else {
		$pa_is = 'None';
		$visit_angle{$observation} = 'None';
	    }
	    next;
	}
# 2021-02-20
#	if($_ =~ m/MIRIM/) { next;}
#	if($_ =~ m/NRS/) {
##	    print "get_apt_pointing : at line : ",__LINE__," $_\n";
#	    if($pa_is eq 'APA') {
#		@junk = split(' ',$_);
#		$visit_angle{$observation} = $junk[$#junk];
#		print "get_apt_pointings : at line : ",__LINE__," $_\n";
#		<STDIN>;
#	    }
#	    next;
#	}
# as we are only counting the number of dithers, 
# skip parallels:
	if($junk[18] eq 'PARALLEL') { next;}
#
	$moves++;
	$new_key = join('_',$key,sprintf("%02d",$moves));
#	if(exists($exptype{$new_key})) {
# 	    $exptype{$new_key} = join(' ',$exptype{$new_key},$junk[18]);
#	    print "get_apt_pointing.pl at line : ",__LINE__," key exists: new_key: $new_key exptype: $exptype{$new_key} $moves\n";
#	}else{
	    $exptype{$new_key} = $junk[18];
#	}
#	if($verbose == 1) {print "get_apt_pointing.pl at line : ",__LINE__," new_key: $new_key exptype: $exptype{$new_key}\n";}
#
# this changes in the case of mosaics:
	$tile      = $junk[1];
# this changes in the case of a different filter at the same position
# or for grism direct image after spectroscopy. It corresponds to the
# number of large moves (i.e., not subpixel samples)
	$exposure  = $junk[2];
	if($junk[2] > $ndithers) {
	    $ndithers  = $junk[2];
	}
# this shows the number of sub-pixel moves
	$subpixel_dither = $junk[3];
	if($junk[3] > $nsubpixel) {
	    $nsubpixel = $junk[3];
	}
# dither offsets (in arc sec)
	$xoffset = $junk[11];
	$yoffset = $junk[12];
	$v2      = $junk[13];
	$v3      = $junk[14];
	$line  = sprintf("%2d %2d %2d %2d %10.5f %10.5f %10.5f %10.5f", $junk[0], $tile, $exposure, $subpixel_dither, $xoffset, $yoffset, $v2, $v3);
#	if($verbose == 1) {print "get_apt_pointing.pl at line : ",__LINE__," $key $line\n";}
	if(exists($visit_moves{$key}) ) {
	    $visit_moves{$key} = join('#',$visit_moves{$key},$line);
	} else {
	    $visit_moves{$key} = $line;
	}
#
# store unique visit IDs contained in this hash
#
	$visit_par{$observation} = join(' ',$key, $obsvis, $ndithers, $nsubpixel,$moves);
# visit_hash contains the visits IDs in a given observation
	if($visit_hash{$observation} =~ m/$key/) { 
	    next;
	} 
	$visit_hash{$observation} = join(' ',$visit_hash{$observation},$key);
    }
    close(FILE);
#
# visit_par contains the visit_id, observation number, number of visits and sub-pixel 
# dithers for a given observation.
#
    for my $key (sort(keys(%visit_par))){
	($visit_id, $observation, $large_moves, $subpixel, $moves) =
	    split(' ',$visit_par{$key});
	$line = sprintf("observation %3d visit_id %s large dithers %2d subpixel %2d total_moves %3d key %s:", $observation, $visit_id, $large_moves, $subpixel, $moves, $key);
	if($verbose ==1) {
	    my @junk = split('\#', $visit_moves{$visit_id});
	    my $number_of_moves = @junk ;
#	    print "get_apt_pointing.pl at line : ",__LINE__," : $line\n";
#	    print "get_apt_pointing.pl at line : ",__LINE__," :visit_id $visit_id : $visit_moves{$visit_id}\n";
	    print "get_apt_pointing.pl at line : ",__LINE__," :visit_id $visit_id : number of moves : $number_of_moves\n";
	}
    }
    return \%visit_par, \%visit_angle, \%visit_hash, \%exptype, \%visit_moves;
}
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
    my $verbose = 0;
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
1;
