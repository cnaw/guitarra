use strict;
use warnings;
#-----------------------------------------------------------------------
sub sub_pa_bkg{
    my($ra, $dec, $pa_v3, $field_name, $target_dir, $obs_date) = @_;
#    
    my $visibility_tool = 'jwst_gtvt';
    my $background_tool = 'jwst_backgrounds';
#
    my $year;
    my $month;
    my $date ;
    my $day;
    my $day_in_year;
    my $day_number;
    my $dates_ref;
    my $pa_min_ref;
    my $pa_max_ref;
#
    my $background_file;
    my $command;
    my $instrument = 'nircam';
    my $end_date;
    my $start_date;
    my $visibility_plot;
    my $visibility_table;
    my $wl_filter;
#
    my $pa_min;
    my $pa_max;
    my $range;
#
    my @dates ;
    my @pa_v3_min;
    my @pa_v3_max;
#
    my $guitarra_aux  = $ENV{GUITARRA_AUX};
#
    my $result = `which $background_tool`;
    $result =~ s/\n//g;
    my $len = length($result);
    my $failed = 0;
    if($len == 0) {
	print "at line ",__LINE__," in sub_pa_bkg.pl\n";
	print "need to install the STScI  $background_tool\n";
	$failed++;
    }
#
    $result = `which $visibility_tool`;
    $result =~ s/\n//g;
    $len = length($result);
    if($len == 0) {
	$failed++;
	print "at line ",__LINE__," in sub_pa_bkg.pl\n";
	print "need to install the STScI  $visibility_tool\n";
    }
#
    if($failed !=0 ) {
	$background_file =  $guitarra_aux.'/jwst_bkg/goods_s_2019_12_21.txt';
	print "using generic background file: $background_file \n";
	print "pause: enter return\n";
	<STDIN>;
	return $background_file;
    }
#
    $range  = 12;
    $wl_filter = 3.56;
    $start_date = '2022-03-30';
    $end_date   = '2023-12-31';
#   $start_date = '2022-06-16';
#    $end_date   = '2023-06-15';
#
    $visibility_plot  = join('_',$field_name,$instrument,'visibility.png');
    $visibility_table = join('_',$field_name,$instrument,'visibility.txt');
#
    $visibility_plot  = $target_dir.'jwst_bkg/'.$visibility_plot;
    $visibility_table = $target_dir.'jwst_bkg/'.$visibility_table;
#
    if(! -e $visibility_plot || ! -e $visibility_table || 
       -s $visibility_plot == 0  || -s $visibility_table == 0) { 
	$command = join(' ',$visibility_tool,$ra, $dec, '--v3pa', $pa_v3,'--save_plot',$visibility_plot,'--save_table',$visibility_table,'--instrument', $instrument,'--name',$field_name,'--start_date',$start_date,'--end_date',$end_date);
	print("$command\n");
	system($command);
    } else {
	print "visibility_plot  exists: $visibility_plot\n";
	print "visibility_table exists: $visibility_table\n";
    }
#
# Find field visibility and the date where PA_V3 is optimal for the
# desired orientation
#
    ($date, $pa_min, $pa_max, $dates_ref, $pa_min_ref, $pa_max_ref)
	= read_visibility( $visibility_table, $instrument, $pa_v3, $range,$obs_date);
#
#----------------------------------------
# Calculate the background for the optimal date
# Note that the STScI tools have different formats for the dates:
#
# visibility : 2021-12-18
#
# background : 2021_12_18 
#
    
    print "date is $date\n";
    
    ($year,$month,$day) = split('-',$date);
    $day_number =  day_of_year($year,$month,$day);
    print "day_number:  $day_number\n";
    
    $date = date_from_day_number($day_number, $year);
    print "date is $date\n";
    
    $background_file = join('_',$field_name, $date.'.txt');
    $background_file = $target_dir.'jwst_bkg/'.$background_file;
    
    if(! -e $background_file) {
	$command = join(' ',$background_tool,'--day',$day_number,'--background_file',$background_file,$ra, $dec, $wl_filter);
	print "$command\n";
	system($command);
    } else {
	print "background file exists: $background_file\n";
    }
    return $background_file, $pa_min, $pa_max;
}
    
#-------------------------------------------------------------------------------
sub time_date{
    my @tm  = localtime();
    my($date);
    my $second = $tm[0];
    my $minute = $tm[1];
    my $hour   = $tm[2];
    my $mday   = $tm[3];
    my $month  = $tm[4] + 1;
    my $year = $tm[5]+1900.;
    $date = sprintf("%04d_%02d_%02d_%02d_%02d_%02d", $year, $month, $mday, $hour, $minute,$second);
    return $date;
}
#
#-------------------------------------------------------------------------------
#
sub day_of_year{
    my($year, $month, $day) = @_;
    my @days_in_month =(31,28,31,30,31,30,31,31,30,31,30,31);
    my @names =('Sun','Mon','Tue','Wed','Thu','Fri','Sat');
    my ($name, $ii);
    my $day_number = 0;
    if($month == 1) {
	$day_number = $day;
    } else {
	for($ii = 0 ; $ii < $month-1 ; $ii++) {
	    $day_number = $day_number + $days_in_month[$ii];
#
# check for February - is it a Leap year ?
#
	    if ($ii == 2 && $year%4 == 0) {
		$day_number++;
	    }
	}
    $day_number = $day_number + $day;
    }
    return $day_number;
}
#
#-----------------------------------------------------------------------
#
sub date_from_day_number{
    my ($day_number, $year) = @_;
    my @days_in_month =(31,28,31,30,31,30,31,31,30,31,30,31);
    my($month, $day,$ii);
    my($date);
    my($day_in_month);
    my $days_in_year = 0;
    for($ii = 0 ; $ii < 12; $ii++) {
	$days_in_year = $days_in_year+$days_in_month[$ii];
	if ($ii == 1 && $year%4 == 0) {
	    $days_in_year++;
	}
	if($day_number <= $days_in_year) {last;}
    }
    $month = $ii + 1;
    if( $year%4 == 0 && $month == 2){
	$day_in_month = $day_number -$days_in_year +$days_in_month[$ii]+1;
    }else {
	$day_in_month = $day_number -$days_in_year +$days_in_month[$ii];
    }
    $date = sprintf("%04d_%02d_%02d", $year,$month,$day_in_month);
    return $date;
}
#
#-----------------------------------------------------------------------
#
sub read_visibility{
    my ($file, $instrument, $pa_v3, $range, $obs_date) = @_;

    my $best;
    my $best_date;
    my $by_day_number;
    my $dayn;
    my $day_number;
    my $date;
    my $diff;
    my $diff_min;
    my $diff_max;
    my $line;
    my $min = 10000;
    my $max = 10000;
    my $pa_min;
    my $pa_max;
    my $pa_temp;
    my $pa_v3_min;
    my $pa_v3_max;

    my $day;
#    my $dayn;
    my $month;
    my $year;
#
    my @junk;
    my @days;
    my @pa_min;
    my @pa_max;
#
    $by_day_number = 0;
    if(lc($obs_date) ne 'none' && $obs_date ne '') {
	($year, $month, $day) = split('-',$obs_date);
	$day_number = day_of_year($year,$month, $day);
	$by_day_number = 1;
    }
#
    open(CAT,"<$file") || die "read_visibility: cannot read $file\n";
    while(<CAT>) {
	chop $_;
	if($_ eq '') {next;}
	@junk = split(' ',$_);
	if($junk[0] eq 'V3PA') {
	    last;
	}
    }
    <CAT>;
    while(<CAT>) {
	chop $_;
	@junk = split(' ',$_);
	if($#junk <= 1) {next;}
	$date = $junk[0];
	$pa_v3_min = $junk[1];
	$pa_v3_max = $junk[2];
	if($by_day_number == 1) {
	    ($year, $month, $day) = split('-',$date);
	    $dayn = day_of_year($year,$month, $day);
	    if($dayn == $day_number) {
		if($pa_v3_max < $pa_v3_min) {
		    $pa_v3 = ($pa_v3_min + $pa_v3_max+360.0)/2.0;
		} else {
		    $pa_v3 = ($pa_v3_min + $pa_v3_max)/2.0;
		}
		if($pa_v3 >= 360.) {$pa_v3 = $pa_v3 - 360.0;}
		push(@days, $date);
		$pa_min = $pa_v3;
		$pa_max = $pa_v3;
		push(@pa_min, $pa_v3_min);
		push(@pa_max, $pa_v3_max);
		return $date, $pa_min, $pa_max,\@days, \@pa_min, \@pa_max;
	    }
	}
#
#	if($instrument eq 'nircam') {
#	    $pa_min = $junk[3];
#	    $pa_max = $junk[4];
#	}
##
#	if($instrument eq 'nirspec') {
#	    $pa_min = $junk[5];
#	    $pa_max = $junk[6];
#	}
#	if($instrument eq 'niriss') {
#	    $pa_min = $junk[7];
#	    $pa_max = $junk[8];
#	}
#	if($instrument eq 'miri') {
#	    $pa_min = $junk[9];
#	    $pa_max = $junk[10];
#	}
#                0/360
# ----------------|--------------|
#         [               ]             360-range <= x <= range
#     ________|________
#
	if($pa_v3 > $pa_v3_max && $pa_v3_max <= $range) {
	    $pa_temp = $pa_v3_max +360.0;
	    if($pa_temp-$pa_v3 > $range) {next;}
	    $diff_max = ($pa_v3 - $pa_temp)**2;
	} else {
	    if( $pa_v3 > $pa_v3_max) {next;}
	    $diff_max = ($pa_v3 - $pa_v3_max)**2;
	}
	
	if($pa_v3 <= $range && $pa_v3_min >= 360.-$range) {
	    $diff_min = ($pa_v3+360. - $pa_v3_min)**2;
	} else {
	    $diff_min = ($pa_v3 - $pa_v3_min)**2;
	}
	$diff     = sqrt($diff_min + $diff_max);
	if($diff <= $range) {
	    $line = sprintf("%12s pa_v3 %7.2f  pa_min %7.2f  pa_max %7.2f %7.2f", $date, $pa_v3, $pa_v3_min, $pa_v3_max, $diff);

	    push(@days, $date);
	    push(@pa_min, $pa_v3_min);
	    push(@pa_max, $pa_v3_max);
	    print "$line\n";
	    if($diff <= $min) {
		$best_date = $date;
		$min = $diff;
		$pa_min = $pa_v3_min;
		$pa_max = $pa_v3_max;
		$best = sprintf("**%12s pa_v3 %7.2f  pa_min %7.2f  pa_max %7.2f %7.2f %7.2f", $date, $pa_v3, $pa_min, $pa_max, $min, sqrt($diff_min));
	    }
	}
    }
    close(CAT);
    print "$best\n";
    return $best_date, $pa_min, $pa_max,\@days, \@pa_min, \@pa_max;
}
1;		
