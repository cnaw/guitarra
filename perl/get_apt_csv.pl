#    
#-------------------------------------------------------------------------------
#
# Read the file exported via the export -> VisitCoverage tab on APT.
# this will provide the (RA,DEC) positions for each major dither.
# 
sub get_apt_csv{
    my($file) = @_;
    my(@junk);
    my(@dithers);
    my(%dithers, %dithers_id);
    my(%dither) ;
    open(FILE,"<$file") || die "file $file not found";
    while(<FILE>) {
	chop $_;
#	print "get_apt_csv.pl : $_\n";
	@junk = split('\,',$_);
	my $visit_name  = $junk[0];
	$visit_name     =~ s/\s//g;
	if($visit_name eq 'VisitID') {next;}
	my $move        = $junk[1];
	my $aperture    = $junk[2];
	my $targetid    = $junk[4];
	my $pa          = $junk[5];
	my $ra          = $junk[6];
	my $dec         = $junk[7];
	$dithers_id{$targetid} = join(' ', $visit_name, $aperture);
	
	if(exists($dithers{$targetid})) {
	    $dithers{$targetid} = join(' ', $dithers{$targetid},join('_',$ra,$dec,$pa,$move)); 
	} else {
	    $dithers{$targetid} = join('_',$ra,$dec,$pa,$move); 
	}
#	if(exists($dither{$move})) {
#	    next;
#	} else {
#	    $dithers{$move} = join('_',$ra,$dec,$pa);
#	    push(@dithers, $dithers{$move});
#	    @{$primary_dithers{$targetid}}= @dithers;
#	}
   }
    close(FILE);
    return \%dithers_id, \%dithers,;
}
1;
