#!/usr/bin/perl -w
#
# IDs for CV 2
#
#$sca{'481'} = 16989;
#$sca{'482'} = 17023;
#$sca{'483'} = 17024;
#$sca{'484'} = 17048;
#$sca{'485'} = 17158;
##
$sca{'486'} = 16991;
$sca{'487'} = 17005;
$sca{'488'} = 17011;
$sca{'489'} = 17047;
$sca{'490'} = 17161;
#
# IDs for CV3
#
$sca{'481'} = 17004;
$sca{'482'} = 17006;
$sca{'483'} = 17012;
$sca{'484'} = 17048;
$sca{'485'} = 17158;
##
$sca{'486'} = 16991;
$sca{'487'} = 17005;
$sca{'488'} = 17011;
$sca{'489'} = 17047;
$sca{'490'} = 17161;
#
@dir   = ('Bias', 'BPM', 'Dark','Gain', 'Linearity', 'WellDepth');
@calib = ('Bias', 'BPM', 'AvgDark_slope','Gain','Linearity','WellDepth');
#
# List files in directory
#
$dhas_dir = '/usr/local/nircamsuite/cal/';
$dhas_dir = '/home/cnaw/cal/';
$dhas_dir = '/data/cal/';
foreach $id (sort(keys(%sca))) {

    $list = $id.'_calib.list';
    open(LIST,">$list") || die "cannot open $list";

#    for ($j= 0; $j <= $#calib ; $j++) {
#	$command = 'locate '.$sca{$id} .' | grep '.$calib[$j];
#	$command = $command. ' | grep '.$dhas_dir;
#	print "$command\n";
#	@junk = `$command`;
#	print "@junk\n";
#	$best = 100000;
#	$keep = 0;
#	if($#junk == -1) { next;}
#	if($#junk >= 0) {
#	    for($i= 0 ; $i <= $#junk ; $i++) {
#		$junk[$i] =~ s/\n//g;
#		my $a  = -M $junk[$i];
#		print "$a $junk[$i]\n";
#		if($a < $best ){
#		    $best = $a;
#		    $keep = $i;
#		}
#	    }
#	    $junk[$keep] = $junk[$keep]."\n";
#	} 
    
    for ($j = 0 ; $j <= $#dir ; $j++) {
	$path = $dhas_dir.$dir[$j].'/*'.$sca{$id}.'*.fits';
	$command = join(' ','ls',$path, '| grep ',$calib[$j]);
	print "$command\n";
	@junk = `$command`;
#	print "@junk\n";
	$best = 100000;
	$keep = 0;
	if($#junk == -1) { 
	    print LIST "none\n";
	    if($dir[$j] eq 'Dark'){
		print LIST "none\n";
	    }
	    next;
	}
	if($#junk >= 0) {
	    for($i= 0 ; $i <= $#junk ; $i++) {
		$junk[$i] =~ s/\n//g;
		my $a  = -M $junk[$i];
#		print "$a $junk[$i]\n";
		if($a < $best ){
		    $best = $a;
		    $keep = $i;
		}
	    }
	    $junk[$keep] = $junk[$keep]."\n";
	} 
	if($calib[$j] =~ m/AvgDark_slope/) {
	    $average = $junk[$keep];
	    $average =~ s/_err.fits/.fits/g;
	    print "$best $average";
	    print LIST $average;
	}
	print "$best $junk[$keep]";
	print LIST $junk[$keep];
    }
    close(LIST);
}
