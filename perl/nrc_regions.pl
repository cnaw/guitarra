#!/usr/bin/perl -w
use strict;
sub nrc_regions {
    my($ra_c, $dec_c, $pa, $outline, $colour) =@_;
    my $pi = 4.0 * atan2(1.,1.) ;
    my $q  = $pi/180.0;
    my $sca;
    my %xcoords;
    my %ycoords;
    my (@xideal, @yideal);
#   siaf_PRDOPSSOC-027
    my $v2ref =   -0.32762888671022240;
    my $v3ref = -492.96588887005885;

    my $cospa = cos(($pa)*$q);
    my $sinpa = sin(($pa)*$q);
#    print "$cospa, $sinpa\n";
    open(CAT,"<$outline") ||die  "cannot find $outline";
    while(<CAT>) {
	chop $_;
	my($xx, $yy, $xc, $yc, $sca) = split(' ',$_);
	if($xc != 1024.5 && $yc != 1024.5) {
	    push(@{$xcoords{$sca}}, $xx);
	    push(@{$ycoords{$sca}}, $yy);
	} else {
	    next;
	}
    }
    close(CAT);
#    open(REG,">$regions_file") || die "cannot find $regions_file";
    foreach $sca (sort(keys(%xcoords))) {
#    if($sca == 485 || $sca == 490 ) {
#	print "$sca\n";

	@xideal =@{$xcoords{$sca}};
	@yideal =@{$ycoords{$sca}};
	my $polygon = 'fk5; polygon(';
	for (my $ii = 0 ; $ii <= $#xideal; $ii++) {
	    my $dx = ($xideal[$ii] - $v2ref)/3600.0;
	    my $dy = ($yideal[$ii] - $v3ref)/3600.0;
	    my $dec = $dec_c - $dx * $sinpa + $dy * $cospa;
	    my $cosdec = cos($dec*$q);
	    my $ra  = $ra_c  + ($dx * $cospa + $dy * $sinpa)/$cosdec;
	    $polygon = join(' ',$polygon, $ra, $dec);
	}
	$polygon = $polygon.') # color= '.$colour;
	print REG $polygon,"\n";
    }
#    close(REG);
    return ;
}
1;
