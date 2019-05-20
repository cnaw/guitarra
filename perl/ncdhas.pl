#!/usr/bin/perl -w
use warnings;
use Scalar::Util qw(looks_like_number);
use lib '/home/cnaw/Astro-FITS-CFITSIO-1.10';
use Astro::FITS::CFITSIO qw( :longnames :shortnames :constants PerlyUnpacking );
#use Astro::FITS::CFITSIO qw( :longnames :shortnames :constants PerlyUnpacking );
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
if($host eq 'orange.as.arizona.edu') {
    $dhas           = '/home/cnaw/bin/ncdhas';
    $dhas           = '/home/cnaw/ncdhas-v2.0rev106/ncdhas';
    $reduced_dir    = '.';
    $cfg{'481'}  = '../cal/SCAConfig/NRCA1_17004_SW_ISIMCV3.cfg';
    $cfg{'482'}  = '../cal/SCAConfig/NRCA2_17006_SW_ISIMCV3.cfg';
    $cfg{'483'}  = '../cal/SCAConfig/NRCA3_17012_SW_ISIMCV3.cfg';
    $cfg{'484'}  = '../cal/SCAConfig/NRCA4_17048_SW_ISIMCV3.cfg';
    $cfg{'485'}  = '../cal/SCAConfig/NRCA5_17158_LW_ISIMCV3.cfg';
    $cfg{'486'}  = '../cal/SCAConfig/NRCB1_16991_SW_ISIMCV3.cfg';
    $cfg{'487'}  = '../cal/SCAConfig/NRCB2_17005_SW_ISIMCV3.cfg';
    $cfg{'488'}  = '../cal/SCAConfig/NRCB3_17011_SW_ISIMCV3.cfg';
    $cfg{'489'}  = '../cal/SCAConfig/NRCB4_17047_SW_ISIMCV3.cfg';
    $cfg{'490'}  = '../cal/SCAConfig/NRCB5_17161_LW_ISIMCV3.cfg';
    $cfg{'481'}  = '../cal/SCAConfig/NRCA1_17004_SW_ISIMCV3.cfg';
    $cfg{'482'}  = '../cal/SCAConfig/NRCA2_17006_SW_ISIMCV3.cfg';
    $cfg{'483'}  = '../cal/SCAConfig/NRCA3_17012_SW_ISIMCV3.cfg';
    $cfg{'484'}  = '../cal/SCAConfig/NRCA4_17048_SW_ISIMCV3.cfg';
    $cfg{'485'}  = '../cal/SCAConfig/NRCA5_17158_LW_ISIMCV3.cfg';
    $cfg{'486'}  = '../cal/SCAConfig/NRCB1_16991_SW_ISIMCV3.cfg';
    $cfg{'487'}  = '../cal/SCAConfig/NRCB2_17005_SW_ISIMCV3.cfg';
    $cfg{'488'}  = '../cal/SCAConfig/NRCB3_17011_SW_ISIMCV3.cfg';
    $cfg{'489'}  = '../cal/SCAConfig/NRCB4_17047_SW_ISIMCV3.cfg';
    $cfg{'490'}  = '../cal/SCAConfig/NRCB5_17161_LW_ISIMCV3.cfg';
#
    $flat{'481'}  = '../cal/Flat/ISIMCV3/NRCA1_17004_PFlat_';
    $flat{'482'}  = '../cal/Flat/ISIMCV3/NRCA2_17006_PFlat_';
    $flat{'483'}  = '../cal/Flat/ISIMCV3/NRCA3_17012_PFlat_';
    $flat{'484'}  = '../cal/Flat/ISIMCV3/NRCA4_17048_PFlat_';
    $flat{'485'}  = '../cal/Flat/ISIMCV3/NRCA5_17158_PFlat_';
    $flat{'486'}  = '../cal/Flat/ISIMCV3/NRCB1_16991_PFlat_';
    $flat{'487'}  = '../cal/Flat/ISIMCV3/NRCB2_17005_PFlat_';
    $flat{'488'}  = '../cal/Flat/ISIMCV3/NRCB3_17011_PFlat_';
    $flat{'489'}  = '../cal/Flat/ISIMCV3/NRCB4_17047_PFlat_';
    $flat{'490'}  = '../cal/Flat/ISIMCV3/NRCB5_17161_PFlat_';
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
$sca       = 0 ;
# ncdhas flags
#$ncdhas_flags = '+cbp -zi +vb -ipc +cbs +cd +cgm +cs +cl +ow +cfg isimcv2ppg';
#$ncdhas_flags = '-dr +cbp -zi +wi +ws -vb -ipc +cs +cbs +cd +cl -ow +cfg isimcv3';
$ncdhas_flags = '+cbp -zi +wi +ws -vb -ipc +cs +cbs +cd +cl -ow +cfg isimcv3';
#$ncdhas_flags = '-dr -cbp -zi +vb -ipc -cs -cbs -cd -cl +ow +cfg isimcv3';

    
if($#ARGV == -1) {
#    @dirlist = `ls -d $reduced_dir/*/`; 
#    $nt = $#dirlist + 1;
#    print "dirlist is @dirlist\n";
#    print "Going to reduce all files in this directory\n";
#    print "$nt directories to reduce\nCR to continue\n";
#    &pause();
    print "no arguments ! Quitting\n";
 #   print "reduce.pl 123\[4-6]\* debug reprocess sca 490 -df 7 -nf 10 -mf 2 +cl +cs +cd +cf +ow +wi -vb\n";
    exit(0);
} else {
#
# Check if these are run numbers or OTP or test names
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
#    exit(0);
#    @list = () ;
#    if(looks_like_number($ARGV[0])) {
#	push(@list, $ARGV[0]);
#    } else {
#	if($ARGV[0] =~ m/\*/ || $ARGV[0] =~ m/\[/ ) {
#	    print "$ARGV[0]\n";
#	    push(@list, $ARGV[0]);
#	} else {
#	    %otps = get_files_from_otp($ARGV[0]);
#	    foreach $otp (sort(keys(%otps))) {
#		@runs = split(' ',$otps{$otp});
#		for ($j= 0 ; $j <= $#runs ; $j++) {
#		    $run = $runs[$j];
#		    push(@list, $run);
#		}
#	    }
#	}
#    }
#
# Add more flags here as required
#
#    @dirlist = () ;
##    push(@dirlist,`ls -d $reduced_dir/$ARGV[0]/`);
#    for ($i = 0 ; $ i <= $#list ; $i++) {
#	push(@dirlist,`ls -d $reduced_dir/$list[$i]/`);
#    }
#    for($i = 1 ; $i <= $#ARGV ; $i++) {
#	
#	if($ARGV[$i] =~ m/reprocess/) {
#	    $reprocess = 1;
#	    next ;
#	}
#	if($ARGV[$i] =~ m/debug/) {
#	    $debug = 1;
#	    next ;
#	}
#	if(lc($ARGV[$i]) =~ m/sca/) {
#	    $i++;
#	    $sca = $ARGV[$i];
#	    next ;
#	}
#	if($ARGV[$i] =~ m/-df/ || $ARGV[$i] =~ m/\+df/) {
#	    $ncdhas_flags =~ s/-df 0//g;
#	    $i++ ;
#	    $ncdhas_flags = join(' ',$ncdhas_flags,'-df',$ARGV[$i]);
#	    next ;
#	}	    
#	if($ARGV[$i] =~ m/-nf/ || $ARGV[$i] =~ m/\+nf/) {
#	    $i++ ;
#	    $ncdhas_flags = join(' ',$ncdhas_flags,'-nf',$ARGV[$i]);
#	    next ;
#	}
#        if($ARGV[$i] =~ m/-mf/ || $ARGV[$i] =~ m/\+mf/) {
#	    $i++;
#	    $ncdhas_flags = join(' ',$ncdhas_flags,'-mf',$ARGV[$i]);
#            next ;
#        }
#        if($ARGV[$i] =~ m/-cs/ || $ARGV[$i] =~ m/\+cs/) {
#	    $ncdhas_flags = join(' ',$ncdhas_flags,$ARGV[$i]);
#            next ;
#        }
#        if($ARGV[$i] =~ m/-cd/ || $ARGV[$i] =~ m/\+cd/) {
#	    $ncdhas_flags = join(' ',$ncdhas_flags,$ARGV[$i]);
#            next ;
#        }
#	if($ARGV[$i] =~ m/-cf/ || $ARGV[$i] =~ m/\+cf/) {
#	    $ncdhas_flags = join(' ',$ncdhas_flags,$ARGV[$i]);
#            next ;
#        }
#       if($ARGV[$i] =~ m/-cl/ || $ARGV[$i] =~ m/\+cl/) {
#	    $ncdhas_flags = join(' ',$ncdhas_flags,$ARGV[$i]);
#            next ;
#        }
#        if($ARGV[$i] =~ m/-vb/) {
#	    $ncdhas_flags = join(' ',$ncdhas_flags,'-vb');
#            next ;
#        }
#        if($ARGV[$i] =~ m/-ow/ || $ARGV[$i] =~ m/\+ow/) {
#	    $ncdhas_flags = join(' ',$ncdhas_flags,$ARGV[$i]);
#            next ;
#	}
#        if($ARGV[$i] =~ m/-wi/ || $ARGV[$i] =~ m/\+wi/) {
#	    $ncdhas_flags = join(' ',$ncdhas_flags,$ARGV[$i]);
#            next ;
#	}
#        if($ARGV[$i] =~ m/-ws/ || $ARGV[$i] =~ m/\+ws/) {
#	    $ncdhas_flags = join(' ',$ncdhas_flags,$ARGV[$i]);
#            next ;
#	}
#        if($ARGV[$i] =~ m/-wfs/ || $ARGV[$i] =~ m/\+wfs/) {
#	    $ncdhas_flags = join(' ',$ncdhas_flags,$ARGV[$i]);
#            next ;
#	}
#        if($ARGV[$i] =~ m/-hdr/ || $ARGV[$i] =~ m/\+hdr/) {
#	    $ncdhas_flags = join(' ',$ncdhas_flags,$ARGV[$i]);
#            next ;
#	}
#        if($ARGV[$i] =~ m/-cds/ || $ARGV[$i] =~ m/\+cds/) {
#	    $ncdhas_flags = join(' ',$ncdhas_flags,$ARGV[$i]);
#            next ;
#	}
##        if($ARGV[$i] =~ m/-mr/ || $ARGV[$i] =~ m/\+mr/) {
##	    $ncdhas_flags = join(' ',$ncdhas_flags,$ARGV[$i]);
##	    $i++;
##	    $ncdhas_flags = join(' ',$ncdhas_flags,$ARGV[$i]);
# #           next ;
##	} else {
##	    $ncdhas_flags = join(' ',$ncdhas_flags,'-mr 2048');
##	}
#        if($ARGV[$i] =~ m/-g/) {
#	    $ncdhas_flags = join(' ',$ncdhas_flags,$ARGV[$i]);
#	    $i++;
#	    $ncdhas_flags = join(' ',$ncdhas_flags,$ARGV[$i]);
#            next ;
#	}
#	if($ARGV[$i] =~ m/-h/ || $ARGV[$i] =~ m/help/ ) {
#	    print "use is\ncv2_reduce.pl reprocess job_number\ncv2_reduce.pl job_number\n";
#	    print "cv2_reduce.pl 867\\*\ncv2_reduce.pl\n";
#	    exit(0) ;
#	}
#	if($ARGV[$i] =~ m/\-/ || $ARGV[$i] =~ m/\+/) {
#	    $ncdhas_flags = join(' ',$ncdhas_flags,$ARGV[$i]); 
#
## check that there is no parameter associated with this flag
## but first verify if this is the last input argument
##
#	    if($i == $#ARGV) {next;}
##
#	    if($ARGV[$i+1] =~ m/\-/ || $ARGV[$i+1] =~ m/\+/) {
#		next;
#	    }
## if there is, add 1 and save the parameter    
#	    $i++;
#	    $ncdhas_flags = join(' ',$ncdhas_flags,$ARGV[$i]); 
#	    next;
#	}
#    }
#
#  all keywords will have been checked by now
#
#    print "reprocess is $reprocess\n";
#    if($reprocess == 1) { 
#	if($ncdhas_flags =~ m/-ow/) {
#	    $ncdhas_flags =~ s/-ow/\+ow/g;
#	} else {
#	    print "1\n";
#	    if($ncdhas_flags =~ m/\+ow/ ) {
#	    } else {
#		$ncdhas_flags  = join(' ',$ncdhas_flags,'+ow');
#	    }
#	}
#   }
if(! $ncdhas_flags =~ m/-df/) { $ncdhas_flags = join(' ',$ncdhas_flags,'-df 0'); }
if(! $ncdhas_flags =~ m/-mr/) { $ncdhas_flags = join(' ',$ncdhas_flags,'-mr 2048'); }
print "ncdhas flags are $ncdhas_flags\n";
#    print "dirlist is @dirlist\n";
if($debug == 1) {
    print "hit return to proceed\n";
    &pause();
}

#my($ftpr);
#for ($j = 0 ; $j <= $#dirlist; $j++) {
##
## Go to appropriate directory for this run/job
##
#    $path = $dirlist[$j];
##
## remove carriage return if present
##
#    $path =~ s/\n//g; 
##
#    chdir($path);
#    system('pwd');
    $status = 0;
#
# List files, making sure that unbroken files (NINT>1) and
# reduced/diagnostics are ignored
#
#    if($sca eq '0') {
#	$string  = '*.fits';
#    } else {
#	$string  = '*_'.$sca.'_*.fits';
#    }
#    @list = `ls $string | grep -v red | grep -v wfs | grep -v dia | grep -v slp | grep -v zero | grep -v  CDSIm |grep -v _sub`;
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
	    <STDIN>;
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
#	$flat_image   =  $flat{$sca_id}.$filter.'_CLEAR_2016-04-05.fits';
#	$flat_flag    =  '+FFf '.$flat_image;
	if($reprocess == 1 ) {
	    if(-e $slope_image) { unlink $slope_image;}
	    if(-e $wfs_image  ) { unlink $wfs_image  ;}
	    if(-e $diagnostic_image ) { unlink $diagnostic_image  ;}
	    if(-e $reduced_image  ) { unlink $reduced_image  ;}
#	    $command = join(' ',$dhas,$reduce_list[$i],$ncdhas_flags,$gain_flag);
	    $command = join(' ',$dhas,$reduce_list[$i],$ncdhas_flags, $cfg_flag);
#	    $command = join(' ',$dhas,$reduce_list[$i],$ncdhas_flags, $flat_flag);
#	    $command = join(' ','nice ',$dhas,$reduce_list[$i],$ncdhas_flags, '-n 18');
	} else {
	    if(-e $slope_image) { next ;}
	    if(-e $wfs_image  ) { next ;}
	    $command = join(' ',$dhas,$reduce_list[$i],$ncdhas_flags, $cfg_flag);
#	    $command = join(' ',$dhas,$reduce_list[$i],$ncdhas_flags, $cfg_flag, $flat_flag);
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
#
#-------------------------------------------------------------------------------
#
sub get_files_from_otp {
    my($find) = @_ ;
    my($run, $date, $file_id,$otp,$procedure,$step,$test_name);
    my($otp_org, $otp_id, %activity_name, %otps, %info);
    my(@list, $key, @junk, $ndir,$junk);
#
# If an OTP it needs to be identified as such
#
    $find = lc($find);
    if ($find =~ m/otp/) {
	$find =~ s/otp//g;
	$find =~ s/\.//g;
	($find, $junk) = split('_',$find);
    }
    print "get_files_from_otp: $find\n";
#
# read list that associates run numbers with procedures
#
    my($db) = '/home/cnaw/cv2/cv2_run_otp.db';
    open(DB,"<$db") || die "cannot open $db";
    while(<DB>) {
	$_ =~ s/\n//g;
	($run, $date, $file_id, $otp, $procedure, $step, $test_name)
	    = split(' ',$_);
	$otp       = lc($otp);
	$otp       =~ s/\.//g;
	$activity_name{$run} = $test_name;
	$otp_id{$run}        = $otp;
	$info{$run}          = $_ ;
    }
    close(DB);
#
# find run numbers taken for a given activity
#
    @list = ();
    %otps = ();
    foreach $key (sort(keys(%activity_name))) {
	if($activity_name{$key} =~ m/$find/) {
	    push(@list,$key);
	    @junk = split(' ',$info{$key});
	    $otp_org   = $junk[3];
	    $otp       = lc($otp_org);
	    $otp       =~ s/\.//g;
	    if(! exists($otps{$otp_org})) {
		$otps{$otp_org} = $key;
	    } else {
		$otps{$otp_org} = join(' ', $otps{$otp_org},$key);
	    }
	    $test_name = $junk[6];
	}
	if($otp_id{$key} =~ m/$find/) {
#	print "$find, $otp_id{$key}\n";
#	if($find =~ m/$otp_id{$key}/) {
	    push(@list,$key);
	    @junk = split(' ',$info{$key});
	    $otp_org   = $junk[3];
	    $otp       = lc($otp_org);
	    $otp       =~ s/\.//g;
	    if(! exists($otps{$otp_org})) {
		$otps{$otp_org} = $key;
	    } else {
		$otps{$otp_org} = join(' ', $otps{$otp_org},$key);
	    }
	    $test_name = $junk[6];
	}
    }
    $ndir = $#list + 1;
    print "$find is found in  $ndir runs\n";
    if($ndir <= 0 ) { exit(0);}
#    print "@list\n";
    return %otps ;
}
