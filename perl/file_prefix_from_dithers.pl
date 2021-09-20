#!/usr/bin/perl -w
use strict;
sub file_prefix_from_dithers{
    my ($dithers_id_ref, $dithers_ref) = @_;
    my (%dithers_id)  = %$dithers_id_ref;
    my (%dithers)     = %$dithers_ref;
    my $aperture;
    my $dec;
    my $exposure_number;
    my $image_id ;
    my $info;
    my $new_id ;
    my $pa;
    my $ra;
    my $targetid;
    my $visit_id;
#
    my $proposal;
    my $visit;
    my $observation;
#
    my @dithers;
#
    my %file_prefix ;
    my %visit_content;
#
    foreach my $key (sort(keys(%dithers_id))){
	($visit_id, $aperture, $targetid) = split(' ', $dithers_id{$key});
	@dithers = split(' ', $dithers{$key});
	$visit_id    =~ s/\s//g;
	$proposal    = substr($visit_id,0,5);
	$observation = substr($visit_id,5,3);
	$visit       = substr($visit_id,8,3);
#	print "\n\n$visit_id\n";
#	print "\nfile_prefix_from_dither: key:$key; dithers: $#dithers ";
#	print "$visit_id  $proposal  $observation $visit $aperture $targetid \n";
	for(my $ii = 0 ; $ii <= $#dithers ; $ii++) {
	    ($ra, $dec, $pa, $exposure_number) = split('_', $dithers[$ii]);
	    my $line = sprintf("%12.8f %12.8f %6.2f %04d", $ra, $dec, $pa, $exposure_number);
	    $line = join(' ',$line, $proposal, $observation, $visit, $targetid, $aperture);
#	    print "file_prefix_from_dithers.pl: $ii $line\n";
	    $image_id = 'jw'.$visit_id.sprintf("_%04d",$exposure_number);
#
	    if(exists($file_prefix{$image_id})) {
		$new_id = 'jw'.$visit_id.sprintf("_%04d",$exposure_number+1000);
		$file_prefix{$new_id} = $line;
	    } else {
		$new_id = 'jw'.$visit_id.sprintf("_%04d",$exposure_number);
		$file_prefix{$new_id} = $line;
	    }
#
	    if(exists($visit_content{$visit_id})){
		$visit_content{$visit_id} = join('#',$visit_content{$visit_id}, $line);
	    } else {
		$visit_content{$visit_id} = $line;
	    }
#	    print "$new_id: $file_prefix{$new_id}\n$line\n";
#	    die;
	}
#	print "\nfile_prefix_from_dither: visit_id: $visit_id, $visit_content{$visit_id}\n\n";
#	print "$visit_id  $visit_content{$visit_id}\n";

    }
    return \%file_prefix, \%visit_content;
}
1;
