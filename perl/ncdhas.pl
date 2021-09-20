#!/usr/bin/perl -w
use warnings;
use Scalar::Util qw(looks_like_number);
use Astro::FITS::CFITSIO qw( :longnames :shortnames :constants PerlyUnpacking );
use Carp ;

$host =  $ENV{HOST};
if(! defined($host) ) {
    $host =  $ENV{HOSTNAME};
}
#if(! defined($host)) {
#    print "this must be run under tcsh\n\nplease type\n\ntcsh\n\n";
#    exit(0);
#}
print "host is $host\n";
if($host eq 'surtr.as.arizona.edu') {
# Path to the ncdhas
    $dhas           = '/usr/local/nircamsuite/ncdhas/ncdhas';
# Location of raw data (links)
# Where are we going to put reduced data
    $reduced_dir       = '.';
#
    $cfg{'481'}  = '/usr/local/nircamsuite/cal/SCAConfig/NRCA1_17004_AZ.cfg';
    $cfg{'482'}  = '/usr/local/nircamsuite/cal/SCAConfig/NRCA2_17006_AZ.cfg';
    $cfg{'482'}  = '../cal/SCAConfig/NRCA2_17006_AZ.cfg';
    $cfg{'483'}  = '/usr/local/nircamsuite/cal/SCAConfig/NRCA3_17012_AZ.cfg';
    $cfg{'484'}  = '/usr/local/nircamsuite/cal/SCAConfig/NRCA4_17048_SW_ISIMCV2.cfg';
    $cfg{'485'}  = '/usr/local/nircamsuite/cal/SCAConfig/NRCA5_17158_LW_ISIMCV2.cfg';
    $cfg{'486'}  = '/usr/local/nircamsuite/cal/SCAConfig/NRCB1_16991_SW_ISIMCV2.cfg';
    $cfg{'487'}  = '/usr/local/nircamsuite/cal/SCAConfig/NRCB2_17005_SW_ISIMCV2.cfg';
    $cfg{'488'}  = '/usr/local/nircamsuite/cal/SCAConfig/NRCB3_17011_SW_ISIMCV2.cfg';
    $cfg{'489'}  = '/usr/local/nircamsuite/cal/SCAConfig/NRCB4_17047_SW_ISIMCV2.cfg';
    $cfg{'490'}  = '/usr/local/nircamsuite/cal/SCAConfig/NRCB5_17161_LW_ISIMCV2.cfg';
} 
if($host eq 'ninimma.as.arizona.edu') {
    $dhas           = '/opt/ncdhas/ncdhas';
    $reduced_dir    = '.';
    $cfg{'481'}  = '/data/cal/SCAConfig/NRCA1_17004_SW_ISIMCV3.cfg';
    $cfg{'482'}  = '/data/cal/SCAConfig/NRCA2_17006_SW_ISIMCV3.cfg';
    $cfg{'483'}  = '/data/cal/SCAConfig/NRCA3_17012_SW_ISIMCV3.cfg';
    $cfg{'484'}  = '/data/cal/SCAConfig/NRCA4_17048_SW_ISIMCV3.cfg';
    $cfg{'485'}  = '/data/cal/SCAConfig/NRCA5_17158_LW_ISIMCV3.cfg';
    $cfg{'486'}  = '/data/cal/SCAConfig/NRCB1_16991_SW_ISIMCV3.cfg';
    $cfg{'487'}  = '/data/cal/SCAConfig/NRCB2_17005_SW_ISIMCV3.cfg';
    $cfg{'488'}  = '/data/cal/SCAConfig/NRCB3_17011_SW_ISIMCV3.cfg';
    $cfg{'489'}  = '/data/cal/SCAConfig/NRCB4_17047_SW_ISIMCV3.cfg';
    $cfg{'490'}  = '/data/cal/SCAConfig/NRCB5_17161_LW_ISIMCV3.cfg';
}
if($host eq 'orange.as.arizona.edu' || $host eq 'ema.as.arizona.edu') {
    if($host eq 'orange.as.arizona.edu' ) { $dhas= 'ncdhas';}
    if($host eq 'ema.as.arizona.edu' ) {
	$dhas = '/usr/local/nircamsuite/ncdhas/ncdhas';
    }
    $cal_path    = '/usr/local/nircamsuite/cal/';
    $reduced_dir = '.';
    $cfg{'481'}  = $cal_path.'SCAConfig/NRCA1_17004_SW_ISIMCV3.cfg';
    $cfg{'482'}  = $cal_path.'SCAConfig/NRCA2_17006_SW_ISIMCV3.cfg';
    $cfg{'483'}  = $cal_path.'SCAConfig/NRCA3_17012_SW_ISIMCV3.cfg';
    $cfg{'484'}  = $cal_path.'SCAConfig/NRCA4_17048_SW_ISIMCV3.cfg';
    $cfg{'485'}  = $cal_path.'SCAConfig/NRCA5_17158_LW_ISIMCV3.cfg';
    $cfg{'486'}  = $cal_path.'SCAConfig/NRCB1_16991_SW_ISIMCV3.cfg';
    $cfg{'487'}  = $cal_path.'SCAConfig/NRCB2_17005_SW_ISIMCV3.cfg';
    $cfg{'488'}  = $cal_path.'SCAConfig/NRCB3_17011_SW_ISIMCV3.cfg';
    $cfg{'489'}  = $cal_path.'SCAConfig/NRCB4_17047_SW_ISIMCV3.cfg';
    $cfg{'490'}  = $cal_path.'SCAConfig/NRCB5_17161_LW_ISIMCV3.cfg';
    $cfg{'481'}  = $cal_path.'SCAConfig/NRCA1_17004_SW_ISIMCV3.cfg';
    $cfg{'482'}  = $cal_path.'SCAConfig/NRCA2_17006_SW_ISIMCV3.cfg';
    $cfg{'483'}  = $cal_path.'SCAConfig/NRCA3_17012_SW_ISIMCV3.cfg';
    $cfg{'484'}  = $cal_path.'SCAConfig/NRCA4_17048_SW_ISIMCV3.cfg';
    $cfg{'485'}  = $cal_path.'SCAConfig/NRCA5_17158_LW_ISIMCV3.cfg';
    $cfg{'486'}  = $cal_path.'SCAConfig/NRCB1_16991_SW_ISIMCV3.cfg';
    $cfg{'487'}  = $cal_path.'SCAConfig/NRCB2_17005_SW_ISIMCV3.cfg';
    $cfg{'488'}  = $cal_path.'SCAConfig/NRCB3_17011_SW_ISIMCV3.cfg';
    $cfg{'489'}  = $cal_path.'SCAConfig/NRCB4_17047_SW_ISIMCV3.cfg';
    $cfg{'490'}  = $cal_path.'SCAConfig/NRCB5_17161_LW_ISIMCV3.cfg';
#
    $flat{'481'}  = $cal_path.'Flat/ISIMCV3/NRCA1_17004_PFlat_';
    $flat{'482'}  = $cal_path.'Flat/ISIMCV3/NRCA2_17006_PFlat_';
    $flat{'483'}  = $cal_path.'Flat/ISIMCV3/NRCA3_17012_PFlat_';
    $flat{'484'}  = $cal_path.'Flat/ISIMCV3/NRCA4_17048_PFlat_';
    $flat{'485'}  = $cal_path.'Flat/ISIMCV3/NRCA5_17158_PFlat_';
    $flat{'486'}  = $cal_path.'Flat/ISIMCV3/NRCB1_16991_PFlat_';
    $flat{'487'}  = $cal_path.'Flat/ISIMCV3/NRCB2_17005_PFlat_';
    $flat{'488'}  = $cal_path.'Flat/ISIMCV3/NRCB3_17011_PFlat_';
    $flat{'489'}  = $cal_path.'Flat/ISIMCV3/NRCB4_17047_PFlat_';
    $flat{'490'}  = $cal_path.'Flat/ISIMCV3/NRCB5_17161_PFlat_';
}

#
# This is where we find the zipped files;
# on surtr both zipped and unzipped are in
# the same location.
#
# Original gain values used by NCDHAS
$gain{'481'} = 2.7;      # 16989
$gain{'482'} = 2.6;      # 17023
$gain{'483'} = 2.3;      # 17024
$gain{'484'} = 2.7;      # 17048
$gain{'485'} = 2.9;      # 17158
$gain{'486'} = 2.5;      # 16991
$gain{'487'} = 2.6;      # 17005
$gain{'488'} = 2.3;      # 17011
$gain{'489'} = 2.5;      # 17047
$gain{'490'} = 2.9;      # 17161

# script flags
$debug     = 0 ;
$reprocess = 1 ;

# ncdhas flags
#$ncdhas_flags = '+cbp -zi +vb -ipc +cbs +cd +cgm +cs +cl +ow +cfg isimcv2ppg';
#$ncdhas_flags = '-dr +cbp -zi +wi +ws -vb -ipc +cs +cbs +cd +cl -ow +cfg isimcv3';
$ncdhas_flags = '+cbp -zi -wi +ws -vb +ipc +cs +cbs +cd +cl +cf -ow +cfg isimcv3';
#$ncdhas_flags = '-dr -cbp -zi +vb -ipc -cs -cbs -cd -cl +ow +cfg isimcv3';

    
if($#ARGV == -1) {
    print "no arguments ! Quitting\n";
    exit(0);
} else {
#
#    
    @list = ();
    print "@ARGV\n";
    for($i=0 ; $i <= $#ARGV; $i++) {
	if($ARGV[$i] !~ m/.fits/) {next;}
	if($ARGV[$i] =~ m/slp.fits/) {next;}
	if($ARGV[$i] =~ m/red.fits/) {next;}
	if($ARGV[$i] =~ m/dia.fits/) {next;}
	push(@list, $ARGV[$i]);
    }
$ncdhas_flags = join(' ',$ncdhas_flags,'-df 0');
# Use this value (256) so your colleagues are not unhappy with you
$ncdhas_flags = join(' ',$ncdhas_flags,'-mr 256');
print "ncdhas flags are $ncdhas_flags\n";
#    print "dirlist is @dirlist\n";
if($debug == 1) {
    print "hit return to proceed\n";
    &pause();
}
    $status = 0;
#
# List files, making sure that unbroken files (NINT>1) and
# reduced/diagnostics are ignored
#
    @reduce_list = ();
    @use_gain    = ();
    @use_cfg     = ();
    print "@list\n";
    $nn  = $#list +1;
    print "there are $nn files to reduce\n";
    if($debug == 1) { &pause();}
    for ($i = 0 ; $i <= $#list ; $i++) {
	$list[$i] =~ s/\n//g;
	print "$list[$i]\n";
	my($fits_pointer) = Astro::FITS::CFITSIO::open_file($list[$i],Astro::FITS::CFITSIO::READONLY(),$status);
	check_status($status);
	if($status != 0 ){
	    print "ncdhas.pl: file $list[$i]\npause";
	    <STDIN>;
	}
	ffgkey($fits_pointer,'SCA_ID',$sca_id,$comment, $status);
	if($status != 0) {
	    $status = 0;
	    ffgkey($fits_pointer,'SCA_NUM',$sca_id,$comment, $status);
#	    print "SCA_ID : $status\n";
	}
	ffgkey($fits_pointer,'FILTER',$filter,$comment, $status);
	$filter =~ s/\'//g;
	$filter =~ s/\s//g;
	if($status != 0) {
	    print "no filter keyword for $list[$i] : $status\npause\n";
#	    <STDIN>;
	}
	push(@use_gain,$gain{$sca_id});
	push(@use_cfg, $cfg{$sca_id});
#	ffgkey($fits_pointer,'NINT',$nint,$comment, $status);
	fits_close_file($fits_pointer, $status);
#	if($nint != 1) { 
#	    print "$list[$i] : nint is $nint\n";
#	    next;
#	}
	push(@reduce_list,$list[$i]);
    }
#
# reduce 
#
    for($i= 0 ; $i <= $#reduce_list ; $i++) {
	$slope_image       = $reduce_list[$i];
	$wfs_image         = $reduce_list[$i];
	$diagnostic_image  = $reduce_list[$i];
	$reduced_image     = $reduce_list[$i];
	$slope_image  =~ s/.fits/.slp.fits/g;
	$wfs_image    =~ s/.fits/.wfs.fits/g;
	$diagnostic_image  =~ s/.fits/.dia.fits/g;
	$reduced_image    =~ s/.fits/.red.fits/g;
#	$gain_flag    =  '-g '.$use_gain[$i];
#	$cfg_flag     =  '-P '.$use_cfg[$i];
	$cfg_flag     = ' ';
	if($filter eq 'F070W' || $filter eq 'F090W') {
	    $flat_image   =  $flat{$sca_id}.'F115W_CLEAR_2016-04-05.fits';
	} else {
	    $flat_image   =  $flat{$sca_id}.$filter.'_CLEAR_2016-04-05.fits';
	}
	$flat_flag    =  '+FFf '.$flat_image;
	if($reprocess == 1 ) {
	    if(-e $slope_image) { unlink $slope_image;}
	    if(-e $wfs_image  ) { unlink $wfs_image  ;}
	    if(-e $diagnostic_image ) { unlink $diagnostic_image  ;}
	    if(-e $reduced_image  ) { unlink $reduced_image  ;}
#	    $command = join(' ',$dhas,$reduce_list[$i],$ncdhas_flags,$gain_flag);
	    $command = join(' ',$dhas,$reduce_list[$i],$ncdhas_flags, $cfg_flag);
	    $command = join(' ',$dhas,$reduce_list[$i],$ncdhas_flags, $flat_flag);
#	    $command = join(' ','nice ',$dhas,$reduce_list[$i],$ncdhas_flags, '-n 18');
	} else {
	    if(-e $slope_image) { next ;}
	    if(-e $wfs_image  ) { next ;}
#	    $command = join(' ',$dhas,$reduce_list[$i],$ncdhas_flags, $cfg_flag);
	    $command = join(' ',$dhas,$reduce_list[$i],$ncdhas_flags, $cfg_flag, $flat_flag);
	}
      	system('pwd');
	print "$command\n";
#	<STDIN>;
	system($command);
    }
}

#------------------------------------------------------------------------
sub job_number{
    my($gs_jobid) = @_ ;
    my($job)  ;
    $gs_jobid =~ s/'//g;
    my(@junk)      = split('_', $gs_jobid);
    $job       = sprintf("%06d",$junk[$#junk]);
    return $job;
}
#--------------------------------------------------------------------------------
sub check_status {
    my $s = shift;
    if ($s != 0) {
        my $txt;
        Astro::FITS::CFITSIO::fits_get_errstatus($s,$txt);
        carp "CFITSIO error: $txt";
        return 0;
    }
    return 1;
}
#-------------------------------------------------------------------------------
sub pause{
    print "pause\n";
    <STDIN>;
    return ;
}
