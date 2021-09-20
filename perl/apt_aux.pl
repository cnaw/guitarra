#!/usr/bin/perl -w
use strict;
use warnings;
use Scalar::Util qw(looks_like_number);
use Cwd qw(cwd getcwd);
#
# Environment variables
#
my $host          = $ENV{HOST};
my $guitarra_home = $ENV{GUITARRA_HOME};
my $guitarra_aux  = $ENV{GUITARRA_AUX};
#
# This makes life easier for debugging
# if not defined
#
$guitarra_home = "."      unless defined $guitarra_home;
$guitarra_aux  = "./data/" unless defined $guitarra_aux;
my $perl_dir      = $guitarra_home.'/perl/';
my $results_path  = $guitarra_home.'/results/';
#
my $wd = getcwd;
if($wd eq '/home/cnaw/git_arra/perl' || $wd eq '/home/cnaw/git_arra') {
    print "wd is $wd\n";
    require "/home/cnaw/git_arra/perl/print_batch.pl";
    require "/home/cnaw/git_arra/perl/read_visit_parameters.pl";
    require "/home/cnaw/git_arra/perl/subarray_params.pl";
    require "/home/cnaw/git_arra/perl/set_readout_parameters.pl";
    require "/home/cnaw/git_arra/perl/get_apt_csv.pl";
    require "/home/cnaw/git_arra/perl/get_apt_pointing.pl";
    require "/home/cnaw/git_arra/perl/translate_instruments.pl";
    require "/home/cnaw/git_arra/perl/file_prefix_from_dithers.pl";
} else {
    require $perl_dir.'get_apt_csv.pl';
    require $perl_dir.'get_apt_pointing.pl';
    require $perl_dir."print_batch.pl";
    require $perl_dir."read_visit_parameters.pl";
    require $perl_dir."subarray_params.pl";
    require $perl_dir."set_readout_parameters.pl";
    require $perl_dir.'translate_instruments.pl';
    require $perl_dir.'file_prefix_from_dithers.pl';
}
#
#
# Additional routines to read APT outputs
# Translate coordinates from primary instrument into NIRCam coordinates

#print "use is\nread_apt_output.pl proposal_number:\nread_apt_output.pl 1180\n";

my(@list, $xml_file, $pointings_file, $csv_file, $file);
my $prefix;
#
$prefix  = 1073;
#$prefix = $ARGV[0];
#$prefix = '1180_full_pa_41';
#$prefix = 'data_challenge2';
#$prefix = '1180_2020.1.2';
#$prefix = '1176';
#$prefix = '1180_pa_41';
#$prefix  = '1181_2019_04_23';
#my ($proposal, $junk) = split('_',$prefix);
my ($proposal, $junk) = split('\.',$prefix);
#
# Get files that will be read
#
@list = `ls $guitarra_aux$prefix*.xml`;
for (my $ii = 0 ; $ii <= $#list ; $ii++) {
    print "$list[$ii]";
    $file = $list[$ii];
    chop $file;
}
print "using $file\n";
$xml_file = $file;
@list = `ls $guitarra_aux$prefix*.pointing`;
for (my $ii = 0 ; $ii <= $#list ; $ii++) {
    $file = $list[$ii];
    chop $file;
}
print "using $file\n";
$pointings_file = $file;

@list = `ls $guitarra_aux$prefix*.csv`;
for (my $ii = 0 ; $ii <= $#list ; $ii++) {
    $file = $list[$ii];
    chop $file;
}
print "using $file\n";
$csv_file = $file;
#print "pause\n";
#<STDIN>;
#
#########
my $aperture;
my $dec;
my $exposure_number;
my $image_id ;
my $new_id ;
my $pa;
my $ra;
my $targetid;
my $visit_id;
#
my $visit;
my $nvisits;
my $observation;
#
my @dithers;
my @junk;
#
my %image ;
my %visit_label;
my %visit_label_inv;
#
#==========================================================================================================
#
# Now that all (or most) of the information for each visit's dithers have been
# gathered, output  into a format that can be read by guitarra
# This collates data coming from the XML file as well as the "pointing" and
# csv files output by APT
#
print "read pointings : $pointings_file\n";
my ($pointings_ref, $pa_ref, $visit_ref, $exptype_ref, $visit_move_ref)
    = get_apt_pointings($prefix, $pointings_file);
my (%pointings)              = %$pointings_ref;
my (%pointings_pa)           = %$pa_ref;
my (%visits)                 = %$visit_ref;
my (%visit_moves)            = %$visit_move_ref;
#
# These are used for NIRSpec prime, NIRCam parallel
#
foreach my $key (sort(keys(%pointings))){
    print "pointings: $key $pointings{$key}\n";
    @junk = split(' ', $pointings{$key});
    print "@junk \n";
}

foreach my $key (sort(keys(%visits))){
    @junk = split(' ', $visits{$key});
    $visit_label_inv{$key}= $visits{$key};
    for(my $ii = 0 ; $ii <= $#junk ; $ii++) {
	print "key 1: $key $junk[$ii]\n";
	$visit_label{$junk[$ii]} = $key;
    }
}
foreach my $key (sort(keys(%visit_label))){
    print "key 2: $key $visit_label{$key}\n";
}
foreach my $key (sort(keys(%visit_moves))){
    print "key 3: $key $visit_moves{$key}\n";
}
die;
#
# get dither positions from the csv file
#
print "read csv:$csv_file\n";
my ($dithers_id_ref, $dithers_ref) = get_apt_csv($csv_file);
my (%dithers_id) = %$dithers_id_ref;
my (%dithers)    = %$dithers_ref;

my ($prefix_ref, $visit_content_ref) = file_prefix_from_dithers($dithers_id_ref, $dithers_ref);
my %file_prefix  = %$prefix_ref;
my %visit_content = %$visit_content_ref;
#die;
foreach my $key (sort(keys(%file_prefix))){
    print "$key  $file_prefix{$key}\n";
}
foreach my $key (sort(keys(%visit_content))){
    print "$key: $visit_content{$key}\n";
} 

