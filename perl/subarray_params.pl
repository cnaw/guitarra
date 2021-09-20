#!/usr/bin/perl -w
use strict;
#my $sca = 490;
#my $subarray = 'SUB64P';
#my ($colcornr, $rowcornr, $ncolumns, $nrows) = subarray_params($sca, $subarray);
#print "$colcornr, $rowcornr, $ncolumns, $nrows\n";

#-------------------------------------------------------------------
sub subarray_params{
    my($sca, $subarray) = @_;
    my $guitarra_aux =$ENV{GUITARRA_AUX};
    my $file = $guitarra_aux.'nircam_subarrays.ascii';
    my $colcornr;
    my $rowcornr;
    my $columns;
    my $rows;
    my $sci_colcornr;
    my $sci_rowcornr;
    my @junk;
    open(CAT,"<$file") || die "at subarray_params.pl: cannot find $file";
    while(<CAT>) {
	chop $_;
	@junk = split(' ',$_);
	if($junk[1] eq $subarray && $junk[3] == $sca) {
	    $rowcornr = $junk[4];
	    $colcornr = $junk[5];
	    $rows     = $junk[6];
	    $columns  = $junk[7];
	    $sci_rowcornr = $junk[8];
	    $sci_colcornr = $junk[9];
	    return $colcornr,$rowcornr,$columns,$rows,$sci_colcornr,$sci_rowcornr;
	}
    }
    print "subarray_params.pl: subarray $subarray not found for sca $sca\n";
    exit(0);
}
1;
