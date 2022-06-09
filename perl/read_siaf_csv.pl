#!/usr/bin/perl -w
use strict;
use warnings;
#use localtime;
my $guitarra_aux = $ENV{GUITARRA_AUX};
my $apername;
my $cat;
my $centre;
my $centrepos;
my $command;
my $dumpcat;
my $header1;
my $header2;
my $ii;
my $index_i;
my $index_j;
my $instrument;
my $junk;
my $kk;
my $kk1;
my $line;
my $logfile;
my $mm;
my $outline;
my $sca_number;
my $siaf_dir;
my $siaf_version;
my $symlink;
my $target_dir;
my $value;
my $xx;
my $xlen;
my $xscisize;
my $yscisize;
my $yy;
my $ylen;
my ($v2ref, $v3ref, $detsciyangle);
#
my @head;
my @junk;
my @lines;
#
my %aperture;
my %sca;
my %sca_num;
#
# SIAF parameters
#
my $xdetsize;
my $ydetsize;
my $xdetref;
my $ydetref;
my $xsciref;
my $ysciref;
my $xsciscale;
my $ysciscale;
my $detsciparity;
my $v3scixangle;
my $v3sciyangle;
my $v3idlyangle;
my $vidlparity;
#
my @sci2idlx;
my @sci2idly;
my @idl2scix;
my @idl2sciy;
#
my(@tm) = localtime();
my($date);
$date = sprintf("_%04d_%02d_%02d_%02d_%02d_%02d.fits", $tm[5]+1900, $tm[4]+1, $tm[3], $tm[2], $tm[1],$tm[0]);
print "current date is $date\n";
$logfile = 'read_siaf_csv'.$date.'.log';
open(LOG,">$logfile") || die "cannot open $logfile";
#
$siaf_dir =$guitarra_aux;
$siaf_dir =~ s/data/siaf/;

my @versions = `ls -td $siaf_dir/*/`;

$versions[0] =~ s/$siaf_dir\///;
$versions[0] =~ s/\n//g;
$versions[0] =~ s/\///g;
print"latest SIAF version is : $versions[0]\n";

$siaf_version = 'PRDOPSSOC-045-003';
print "To use this SIAF version press ENTER; otherwise enter the desired version\n";
$siaf_version = <STDIN>;
$siaf_version =~ s/\n//g;
if($siaf_version eq '') {
    $siaf_version = $versions[0];
}
$siaf_dir =  $siaf_dir.$siaf_version;
print "siaf_dir: $siaf_dir\n";
#

$target_dir = $guitarra_aux.$siaf_version;
print "target_dir $target_dir\n";
$symlink = $guitarra_aux.'PRDOPSSOC-latest';
if(-d $target_dir) {
    print "directory exists: $siaf_dir\n";
 } else {
    print "creating directory $target_dir\n";
    $command = join(' ','mkdir',$target_dir);
    system($command);
}
if(-l $symlink) {
    unlink  $symlink;
    $command = join(' ','ln -s',$target_dir, $symlink);
    print "$command\n";
    system($command);
} else {
    $command = join(' ','ln -s',$target_dir, $symlink);
    print "$command\n";
    system($command);
}    
print LOG "siaf version: ", $siaf_version,"\n";
print LOG "siaf_dir    : ", $siaf_dir,"\n";
print LOG "targer_dir  : ", $target_dir,"\n";

$instrument = 'nircam';
#$instrument = 'miri';
#$instrument = 'niriss';
#$instrument = 'nirspec';
if(lc($instrument) eq 'nircam') {
    $cat      = $siaf_dir.'/NIRCam_SIAF.csv';
    $outline  = $target_dir.'/NIRCam_outline.ascii' ;
}
if(lc($instrument) eq 'miri'){
    $cat = $siaf_dir.'/MIRI_SIAF.csv';
    $outline  = $target_dir.'/MIRI_outline.ascii' ;
}
if(lc($instrument) eq 'niriss'){
    $cat = $siaf_dir.$siaf_version.'/NIRISS_SIAF.csv';
    $outline  = $target_dir.'/NIRISS_outline.ascii' ;
}
if(lc($instrument) eq 'nirspec'){
    $cat = $siaf_dir.$siaf_version.'/NIRSpec_SIAF.csv';
    $outline  = $target_dir.'/NIRSPEC_outline.ascii' ;
}
#$cat = 'NIRISS_SIAF.csv';
#$cat = 'NIRSpec_SIAF.csv';

#sed 's/\r/\n/g' < NIRCam_SIAF_2016-09-29.csv > lixo
#$cat = 'lixo';

open(CAT,"<$cat") || die "cannot find $cat";
$header1 = <CAT>;
chop $header1;
@lines = split('\r',$header1);
for($ii= 0 ; $ii <= $#lines ; $ii++) {
#    print "$ii: $lines[$ii]\n";
}

@head = split('\,',$header1);
for ($ii = 0; $ii <= $#head ; $ii++){
#    print "$ii $head[$ii]\n";
}
$header2 = <CAT>;
$header2 =~ s/\r\n//g;
$header2 =~ s/\n//g;
@head = split('\,',$header2);
for ($ii = 0; $ii <= $#head ; $ii++){
#    print "$ii $head[$ii]\n";
}
#print "pause\n";
#<STDIN>;
while(<CAT>) {
    chop $_;
    @junk = split('\,',$_);
    $instrument = $junk[0];
    $apername = $junk[1];
    $aperture{$apername} = $_;
    my $junk = $junk[1];
    @junk    = split('_',$junk);
#    $sca     = $junk[0];
    $sca{$apername} = $apername;
#    print "$instrument, $sca, $apername\n";
}
close(CAT);
if($instrument eq 'NIRCAM') {
    $xx = 2040;
    $yy = 2040;
    foreach $apername (sort(keys(%sca))){
	$sca_num{$apername} = get_sca_number($apername);
#	print "$sca{$apername}: $apername $sca_num{$apername}\n";
	$line = sprintf("%-30s : %-30s  %3d ",$sca{$apername}, $apername, $sca_num{$apername});
	print LOG $line,"\n";
    }
}
if($instrument eq 'NIRSPEC') {
    $sca{'NRS_VIGNETTED_MSA'}   = 'NRS_VIGNETED_MSA';
    $sca{'NRS1_FULL'}  = 'NRS1_FULL';
    $sca{'NRS2_FULL'}  = 'NRS2_FULL';
    $sca_num{'NRS1_FULL'}  = 491;
    $sca_num{'NRS2_FULL'}  = 492;
}
if($instrument eq 'NIRISS') {
    $sca{'NIS_CEN'}        = 'NIS_CEN';
    $sca_num{'NIS_CEN'}  = 480;
}
if($instrument eq 'MIRI'){
    $xlen =  668;
    $ylen = 1024;
    $sca_num{'MIRIM_ILLUM'} = 201;
    $sca{'MIRIM_ILLUM'} = 'MIRIM_ILLUM';
}

#$outline  = $cat;
#$outline  =~ s/_SIAF.csv/_outline.ascii/;
#print "outline is $outline\n";
open(OUTLINE,">$outline") || die "cannot open $outline";
foreach $apername (sort(keys(%aperture))){
    if(! exists($sca{$apername})) {
	next;
    }

    $mm =-1;
    $dumpcat  = $target_dir.'/'.$sca{$apername}.'.ascii' ;
#    print "dumpcat $dumpcat\n";
    my @det_sci_parity = ();
    my @det_sci_x_angle = ();
    my @det_sci_y_angle = ();
#
    my @sci_to_v2v3 = ( [ 0., 0., 0., 0., 0.],  
			[ 0., 0., 0., 0., 0.],  
			[ 0., 0., 0., 0., 0.],  
			[ 0., 0., 0., 0., 0.],  
			[ 0., 0., 0., 0., 0.]);
    my $coeffs_dir = 'sci_to_ideal_coeffs.dat';
    
    my(@xcoords);
    my(@ycoords);
    @junk = split('\,',$aperture{$apername});
#
#  collect all information
#    
    @sci2idlx = ();
    @sci2idly = ();
    @idl2scix = ();
    @idl2sciy = ();
    for ($ii = 0; $ii <= $#junk; $ii++){
#	print "$ii $head[$ii] $junk[$ii]\n";
# skip first columns (instrument, aperture, DCCname, Apertype,AperShape
	if($ii < 5 ) {next;}
# skip comments
	if($ii == 31 || $ii == 32) {next;}
# detector frame
	if(lc($head[$ii]) eq 'xdetsize') {
	    $xdetsize = $junk[$ii];
	}
	if(lc($head[$ii]) eq 'ydetsize') {
	    $ydetsize = $junk[$ii];
	}
	if(lc($head[$ii]) eq 'xdetref') {
	    $xdetref = $junk[$ii];
	}
	if(lc($head[$ii]) eq 'ydetref') {
	    $ydetref = $junk[$ii];
	}
# Science frame
	if(lc($head[$ii]) eq 'xscisize') {
	    $xscisize = $junk[$ii];
	}
	if(lc($head[$ii]) eq 'yscisize') {
	    $yscisize = $junk[$ii];
	}
	if(lc($head[$ii]) eq 'xsciref') {
	    $xsciref = $junk[$ii];
	}
	if(lc($head[$ii]) eq 'ysciref') {
	    $ysciref = $junk[$ii];
	}

	if(lc($head[$ii]) eq 'xsciscale') {
	    $xsciscale = $junk[$ii];
	}
	if(lc($head[$ii]) eq 'ysciscale') {
	    $ysciscale = $junk[$ii];
	}
	if(lc($head[$ii]) eq 'v2ref'){
	    $v2ref      = $junk[$ii];
	}
	if(lc($head[$ii]) eq 'v3ref'){
	    $v3ref      = $junk[$ii];
	}
	if(lc($head[$ii]) eq 'detsciyangle'){
	    $detsciyangle = $junk[$ii];
	}
	if(lc($head[$ii]) eq 'detsciparity') {
	    $detsciparity  = $junk[$ii];
	}
	if(lc($head[$ii]) eq 'v3scixangle')  {
	    $v3scixangle = $junk[$ii];
	}
	if(lc($head[$ii]) eq 'v3sciyangle')  {
	    $v3sciyangle = $junk[$ii];
	}
	if(lc($head[$ii]) eq 'v3idlyangle')  {
	    $v3idlyangle = $junk[$ii];
	}
	if(lc($head[$ii]) eq 'vidlparity')  {
	    $vidlparity = $junk[$ii];
	}
	if($head[$ii] =~ m/XIdlV/){
	    push(@xcoords,$junk[$ii]);
	}
	if($head[$ii] =~ m/YIdlV/){
	    push(@ycoords,$junk[$ii]);
	}

	if(lc($head[$ii]) =~ m/sci2idlx/) {
	    push(@sci2idlx,$head[$ii]);
	    push(@sci2idlx,$junk[$ii]);
	}
	if(lc($head[$ii]) =~ m/sci2idly/) {
	    push(@sci2idly,$head[$ii]);
	    push(@sci2idly,$junk[$ii]);
	}
	if($head[$ii] =~ m/Idl2SciX/) {
	    push(@idl2scix,$head[$ii]);
	    push(@idl2scix,$junk[$ii]);
	}
	if($head[$ii] =~ m/Idl2SciY/) {
	    push(@idl2sciy,$head[$ii]);
	    push(@idl2sciy,$junk[$ii]);
	}
    }
#    print "\n";
    open(DUMP, ">$dumpcat") || die "cannot open $dumpcat";
#    print "writing $dumpcat\n";    
    $line = sprintf("%-25s  %16s\n", $siaf_version,'SIAF_version');
    print DUMP $line;
    $line = sprintf("%25s  %16s\n", $xdetref, 'x_det_ref');
    print DUMP $line;
    $line = sprintf("%25s  %16s\n", $ydetref, 'y_det_ref');
    print DUMP $line;
    $line = sprintf("%25s  %16s\n", $xscisize, 'x_sci_size');
    print DUMP $line;
    $line = sprintf("%25s  %16s\n", $yscisize, 'y_sci_size');
    print DUMP $line;
    $line = sprintf("%25s  %16s\n", $detsciyangle, 'det_sci_yangle');
    print DUMP $line;
    $line = sprintf("%25s  %16s\n", $detsciparity, 'det_sci_parity');
    print DUMP $line;
    $line = sprintf("%25s  %16s\n", $xsciref, 'x_sci_ref');
    print DUMP $line;
    $line = sprintf("%25s  %16s\n", $ysciref, 'y_sci_ref');
    print DUMP $line;

    $line = sprintf("%25s  %16s\n", $xsciscale, 'x_sci_scale');
    print DUMP $line;
    $line = sprintf("%25s  %16s\n", $ysciscale, 'y_sci_scale');
    print DUMP $line;

    $line = sprintf("%25s  %16s\n",$v3scixangle,'v3_sci_x_angle');
    print DUMP $line;
    $line = sprintf("%25s  %16s\n",$v3sciyangle,'v3_sci_y_angle');
    print DUMP $line;
    $line = sprintf("%25s  %16s\n",$v3idlyangle,'v3_idl_y_angle');
    print DUMP $line;
    $line = sprintf("%25s  %16s\n",$vidlparity,'v_idl_parity');
    print DUMP $line;
    $line = sprintf("%25s  %16s\n",$v2ref,'v2_ref');
    print DUMP $line;
    $line = sprintf("%25s  %16s\n",$v3ref,'v3_ref');
    print DUMP $line;
#
# coefficients
#
    $line = '6 Sci2IdlX';
    print DUMP $line,"\n";
    for($kk = 0 ; $kk < $#sci2idlx; $kk=$kk+2) {
	$kk1 = $kk+1;
	$junk = $sci2idlx[$kk];
	$value = $sci2idlx[$kk1];
	$index_i = substr($junk,-2,1);
	$index_j = substr($junk,-1,1);
	$line = sprintf("%2d %2d %25s %16s", $index_i, $index_j, $value, $junk);
	print DUMP $line,"\n";
    }
#
    $line = '6 Sci2IdlY';
    print DUMP $line,"\n";
    for($kk = 0 ; $kk < $#sci2idly; $kk=$kk+2) {
	$kk1 = $kk+1;
	$junk  = $sci2idly[$kk];
	$value = $sci2idly[$kk1];
	$index_i = substr($junk,-2,1);
	$index_j = substr($junk,-1,1);
	$line = sprintf("%2d %2d %25s %16s", $index_i, $index_j, $value, $junk);
	print DUMP $line,"\n";
    }

    $line = '6 Idl2sciX';
    print DUMP $line,"\n";
    for($kk = 0 ; $kk < $#idl2scix; $kk=$kk+2) {
	$kk1 = $kk+1;
	$junk = $idl2scix[$kk];
	$value = $idl2scix[$kk1];
	$index_i = substr($junk,-2,1);
	$index_j = substr($junk,-1,1);
	$line = sprintf("%2d %2d %25s %16s", $index_i, $index_j, $value, $junk);
	print DUMP $line,"\n";
    }
#
    $line = '6 Idl2sciY';
    print DUMP $line,"\n";
    for($kk = 0 ; $kk < $#idl2sciy; $kk=$kk+2) {
	$kk1 = $kk+1;
	$junk  = $idl2sciy[$kk];
	$value = $idl2sciy[$kk1];
	$index_i = substr($junk,-2,1);
	$index_j = substr($junk,-1,1);
	$line = sprintf("%2d %2d %25s %16s", $index_i, $index_j, $value, $junk);
	print DUMP $line,"\n";
    }


    close(DUMP);
    print LOG  "wrote $dumpcat\n";
    if(lc($instrument) eq 'nircam') {
	if($apername !~ m/FULL/) {next;}
	if($apername =~ m/FULLP/) {next;}
	if($apername =~ m/NRCAS/) {next;}
	if($apername =~ m/NRCBS/) {next;}
	if($apername =~ m/OSS/) {next;}
	if($apername =~ m/WEDGE/) {next;}
	if($apername =~ m/MASK/) {next;}
	$sca_number = $sca_num{$apername};
    }
    if(lc($instrument) eq 'miri') {
	if($apername !~ m/MIRIM_ILLUM/) {next;}
	$sca_number = $sca_num{'MIRIM_ILLUM'};
    }
    if(lc($instrument) eq 'niriss') {
	if($apername ne 'NIS_CEN') {next;}
	$sca_number = $sca_num{'NIS_CEN'};
    }

    if(lc($instrument) eq 'nirspec') {
	if($apername !~ /NRS_VIGNETTED/) {next;}
	$sca_number = $sca_num{$apername};
    }

    my @v2 = ();
    my @v3 = ();
    for(my $ii = 0 ; $ii <= $#xcoords ; $ii++) {
#	print "$ii $xcoords[$ii] $ycoords[$ii]\n";
	push(@v2, $xcoords[$ii]);
	push(@v3, $ycoords[$ii]);
    }
    my ($xx, $yy, $xc, $yc);
    for(my $ii = 0; $ii <= 3; $ii++) {
	my $ff = ($v2ref+$v2[$ii])/60.0;
	my $gg = ($v3ref+$v3[$ii])/60.0;
	my $par;
	$xx = $v2ref + $v2[$ii];
	$yy = $v3ref + $v3[$ii];
#	if($ii == 2) {
	if(lc($instrument) eq 'nircam') {
	    if($apername =~ m/A1/ ||
	       $apername =~ m/A3/ ||
	       $apername =~ m/A5/ ||
	       $apername =~ m/B2/ ||
	       $apername =~ m/B4/) {
		$par = 1;
	    } else {
		$par = 0;
	    }
	    if(($par == 1 && $ii == 0) ||
	       ($par == 0 && $ii == 2)) {
	    $xc = 5;
	    $yc = 5;
	    }
#
	    if(($par == 1 && $ii == 1) ||
	       ($par == 0 && $ii == 3)) {
		$xc = 2044;
	    $yc =    5;
	    }
	    if(($par == 1 && $ii == 2) ||
	       ($par == 0 && $ii == 0)) {
		$xc = 2044;
		$yc = 2044;
	    }
	    if(($par == 1 && $ii == 3) ||
	       ($par == 0 && $ii == 1)) {
		$xc =    5;
		$yc = 2044;
	    }
	}
# these are probably wrong and are used as place-holders 2021-09-04
	if(lc($instrument) eq 'miri') {
	    if($ii == 0) {
		$xc = 1;
		$yc = 1;
	    }
	    if($ii == 1) {
		$xc = 1;
		$yc = $ylen;
	    }
	    if($ii == 2) {
		$xc = $xlen;
		$yc = $ylen;
	    }
	    if($ii == 3) {
		$xc = $xlen;
		$yc = 1;
	    }
	}
	if(lc($instrument) eq 'niriss') {
	    if($ii == 0) {
		$xc = 5;
		$yc = 5;
	    }
	    if($ii == 1) {
		$xc = 5;
		$yc = 2044;
	    }
	    if($ii == 2) {
		$xc = 2044;
		$yc = 2044;
	    }
	    if($ii == 3) {
		$xc = 2044;
		$yc = 5;
	    }
	}

	if(lc($instrument) eq 'nircam' || lc($instrument) eq 'niriss') {
	    $line = sprintf(" %16.10f %16.10f %16.10f %16.10f %5d %s",
			    $xx, $yy, $xc, $yc, $sca_number, $apername);
	    print OUTLINE $line,"\n";
	    $line = sprintf(" %16.10f %16.10f %16.10f %16.10f %5d %s",
			    $xx, $yy, $xc, $yc, $sca_number, $apername);
	} else {
	    $line = sprintf(" %16.10f %16.10f %16.10f %16.10f %5d %s",
			    $xx, $yy, $xc, $yc, $sca_number, $apername);
	    print OUTLINE $line,"\n";
	    $line = sprintf(" %16.10f %16.10f %16.10f %16.10f %5d %s",
			    $xx, $yy, $xc, $yc, $sca_number, $apername);
	}

#	print "$ii, $xx, $yy, $par, $apername\n";
#	print "$line\n";
    }
    if(lc($instrument) eq 'nircam' || lc($instrument) eq 'niriss') {
	$xc = 1024.5;
	$yc = 1024.5;
	$centrepos = join('_',$apername,'cen');
    }
    if(lc($instrument) eq 'miri') {
	$xc = ($xlen+1.)/2.;
	$xc = 334.5; # XSciRef
	$yc = 512.5;
	$sca_number = 201;
	$centrepos = join('_',$apername,'cen');
    }
    $xx = $v2ref;
    $yy = $v3ref;
#    $xx = $v2ref/60.0;
#    $yy = $v3ref/60.0;
#x1234567890123456
#       1234567890
#    -0.3678237159
    if(lc($instrument eq 'nircam')) {
	$line = sprintf(" %16.10f %16.10f %16.10f %16.10f %5d, %s",
			$xx, $yy, $xc, $yc, $sca_number, $centrepos);
    } else {
	$line = sprintf(" %16.10f %16.10f %16.10f %16.10f %5d %s",
			$xx, $yy, $xc, $yc, $sca_number, $centrepos);
    }
    print OUTLINE $line,"\n";
#    print "\n";
}
close(OUTLINE);
print LOG  "outline is $outline\n";
close(LOG) ;
print "Used $siaf_version\n";
print "directory is $target_dir\n";
print "logfile is $logfile\n";
#
#-----------------------------------------------------------------------
#
sub det_to_sci{
    my($det_sci_y_angle, $xx, $yy) =@_;
    my($x_sci, $y_sci);
    print "$det_sci_y_angle, $xx, $yy\n";
    if($det_sci_y_angle == 180.) {
	$x_sci =  $xx;
    } else {
	$x_sci = 2048 - $xx;
    }
    $y_sci =  $yy;
    return $x_sci, $y_sci;
}
#
#-----------------------------------------------------------------------
#
sub rotate{
    my($det_sci_parity, $det_sci_x_angle, $det_sci_y_angle, $xx, $yy) =@_;
    my($pi) = 4.0*atan2(1.0,1.0);
    my($q) = $pi/180.0;
    my($cosa, $sina);
    my($a11, $a12, $a21, $a22);
    my($x_sci, $y_sci);
#
    $cosa = cos(($det_sci_x_angle)*$q);
    $sina = sin(($det_sci_x_angle)*$q);
    $a11  = $cosa;    
    $a12  = $sina;
    $a21  = $sina;
    $a22  = $cosa;
#
    print "$det_sci_parity, $det_sci_x_angle, $det_sci_y_angle, $xx, $yy\n";
    print "$a11, $a12, $a21, $a22\n";
    if($det_sci_y_angle == 180.) {
	$x_sci =  $xx;
    } else {
	$x_sci = 2048 - $xx;
    }
    $y_sci =  $yy;
#
#    $x_sci = 2048 + $det_sci_parity * $xx;
#    $y_sci = $yy;

    return $x_sci, $y_sci;
}
#
#-----------------------------------------------------------------------
#
sub get_sca_number{
    my($aperture) =@_;
    my @junk = split('_',$aperture);
    my $sca = $junk[0];
    my $sca_number;
    if($sca eq 'NRCALL') {$sca_number =   0;}
    if($sca eq 'NRCA1')  {$sca_number = 481;}
    if($sca eq 'NRCA2')  {$sca_number = 482;}
    if($sca eq 'NRCA3')  {$sca_number = 483;}
    if($sca eq 'NRCA4')  {$sca_number = 484;}
    if($sca eq 'NRCA5')  {$sca_number = 485;}
    if($sca eq 'NRCB1')  {$sca_number = 486;}
    if($sca eq 'NRCB2')  {$sca_number = 487;}
    if($sca eq 'NRCB3')  {$sca_number = 488;}
    if($sca eq 'NRCB4')  {$sca_number = 489;}
    if($sca eq 'NRCB5')  {$sca_number = 490;}
#
    if($sca eq 'NRCAS')  {$sca_number = 485;}
    if($sca eq 'NRCBS')  {$sca_number = 490;}
    return $sca_number;
}
