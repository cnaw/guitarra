#    
#-------------------------------------------------------------------------------
# 2021-03-12
#
# Read the file exported via the export -> VisitCoverage tab on APT.
# this will provide the (RA,DEC) positions for each major dither.
# sequence and obs keep track of observations with repeated combination
# of visit_name + exposure. The %move hash keeps track of the sequence 
# of observations corresponding to each visit_name + exposure(==1) combination.
# This was encounters on APT 766 where a sequence of 27 grism observations is
# followed by 1 direct image on the field and 2 at an offset position. These
# are _not_ identified as such in the XML output
#
sub get_apt_csv{
    my($file) = @_;
    my(@junk);
    my(@dithers);
    my(%dithers, %dithers_id);
    my(%dither) ;
    my $counter = 0;
    my $previous = 0;
    my $pointing = 0;
    my $verbose  = 0;
    my %obs;
    my %sequence;
    print "get_apt_csv.pl      at line : ",__LINE__," reading csv file       : $file\n";
    open(FILE,"<$file") || die "file $file not found";
    while(<FILE>) {
	chop $_;
#	print "get_apt_csv.pl : $_\n";
	@junk = split('\,',$_);
	my $visit_name  = $junk[0];
	$visit_name          =~ s/\s//g;
	if($visit_name eq 'VisitID') {next;}
	my $exposure_number = $junk[1];
	my $aperture        = $junk[2];
#       exposure time       = junk[3]
	my $targetid        = $junk[4];
	my $pa              = $junk[5];
	my $ra              = $junk[6];
	my $dec             = $junk[7];
#
# keep track of repeated visit+exposure combinations
# sequence and key track each observation as a unique entity
#
	if($visit_name == $previous) {
	    $counter++;
	    $previous = $visit_name;
	} else {
	    $counter = 1;
	    $previous = $visit_name;
	}
#	my $key = join('_',$visit_name,$counter);
	my $key             = join('_',$visit_name,sprintf("%02d",$counter));
#
# obs and move keep track of repeated combinations of visit_name+exposure_number 
# obs will represent the sequence corresponding to each of these repeats, as 
# they may not have the same number of exposures
#
#	my $move            = join('_',$visit_name,$exposure_number);
	my $move  = join('_',$visit_name,sprintf("%02d",$exposure_number));
	if($exposure_number == 1) {
	    if(exists($obs{$move})) {
		$pointing = $pointing+1;
	    } else {
		$pointing = 1;
	    }
	    $obs{$move} = $pointing;
#	    $obs{$move} = sprintf("%02d",$pointing);
	} else {
	    $obs{$move} = $pointing;
#	    $obs{$move} = sprintf("%02d",$pointing);
	}
	$sequence{$key}     = join('_',$move,$obs{$move});
	if($verbose != 0) {
	    print "get_apt_csv at line : ",__LINE__," $key $sequence{$key} $obs{$move}\n";
	}
#
#  change hash reference to visit_name (2020-03-06)
#
	$targetid       = $visit_name;
	$dithers_id{$targetid} = join(' ', $visit_name, $aperture, $junk[4]);
#	print "get_apt_csv.pl at line : ",__LINE__," $ra, $dec, $pa, $exposure_number, $file\n";
	$ra =~ s/\s//g;
	$dec =~ s/\s//g;
	$pa =~ s/\s//g;
	$exposure_number =~ s/\s//g;
	if(exists($dithers{$targetid})) {
	    $dithers{$targetid} = join(' ', $dithers{$targetid},join('_',$ra, $dec, $pa, $exposure_number)); 
	} else {
	    $dithers{$targetid} = join('_',$ra, $dec, $pa, $exposure_number); 
	}
   }
    close(FILE);
    return \%dithers_id, \%dithers, \%sequence;
}
1;
