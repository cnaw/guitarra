#!/usr/bin/perl -w
#
# This script will read files output from APT using the "File->Export" tab:
# xml file  (e.g. 1180.xml)
# Visit Coverage (1180.csv)  -- NOT the Coverage to MAST one!
# pointing file  (1180.pointings)
# To run this requires having the LibXML library installed.
#
# The script picks out the information needed as input to guitarra:
# target ID, coordinates for individual telescope moves, filters, 
# number of groups and number of integrations at a fixed position. 
# Some parameters that are used as JWST FITS keywords are
# also recovered.
#
# The two key parameters that allow identifying unique visits are 
# visit_ID and TargetName, while Number and TargetID parameters 
# come in two flavours, which makes them non-unique.
#
# The following web-site was critical in getting this to work and much
# of the code is adapted from this source:
# 
# https://grantm.github.io/perl-libxml-by-example/large-docs.html
#
# Data in the XML file are stored in up to 9 hierarchical levels.
# Once the XML file is read, from the visit coverage  and pointings are added 
# after which files corresponding to each NIRCam observation are written.
# 
#  cnaw@as.arizona.edu
#  2019-04-11, 2020-05-23
# This command helps immensely when debugging:
# print "Number at Line: ", __LINE__, "\n";

use XML::LibXML;
use XML::LibXML qw(:libxml);
use XML::LibXML::Reader;
use XML::LibXML::NodeList;

use 5.016;
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
# Debugging parameters for the XML file reading. The XML file has up to 9
# levels of nesting and this shows the level where some parameters are
# stored. The list is not exhaustive.
#
my $testing       = 0;
my($debug)        = 0;
# ProposalInformation, PureParallelSlots
my($print_level1) = 0;
# VisitStatus, VisitID, NumberPointings
my($print_level2) = 0;
# Recover coordinates
my($print_level3) = 0;
# Target Number, TargetName, TargetArchiveName, TargetID, RAProperMOtion,DecProperMotion, 
# RAProperMOtionUnits,DecProperMotionUnits, Epoch,AnnualParallax,Extended,
# Category,Keywords,EquatorialCoordinates,RAUncertainty,DecUncertainty,
# BackgroundTargetReq,
my($print_level4) = 0;
# coordinate uncertainties, units
# Mosaic mode, Rows, Columns, RowOverlapPercent,ColumnOverlapPercent,SkewdegreesX,SkewDegreesY
my($print_level5) = 0;
# Module, Aperture, PrimaryDitherType, PrimaryDithers, SubpixelDitherType:
my($print_level6) = 0;
# Primary Instrument:
my($print_level7) = 0;
# Get TargetID for level 9 parameters:
my($print_level8) = 0;
# Filters, ReadoutPattern, Groups:
my($print_level9) = 0;
#
# Print parameters specific to MIRI (mi), NIRSPEC (msa, nsmos) 
my($print_mi)     = 1;
my($print_msa)    = 0;
my($print_nsmos)  = 1 ;

if($debug == 1){
    $print_level1 = 1;
    $print_level2 = 1;
    $print_level3 = 1;
    $print_level4 = 1;
    $print_level5 = 1;
    $print_level6 = 1;
    $print_level7 = 1;
}
#
#############################################################################
#
# This makes life easier for debugging
# if not defined
#
$guitarra_home = "."      unless defined $guitarra_home;
$guitarra_aux  = "./data/" unless defined $guitarra_aux;
my $perl_dir      = $guitarra_home.'/perl/';
my $results_path  = $guitarra_home.'/results/';
#
print "host is $host\nguitarra_home is $guitarra_home\n";
#
# Additional routines to read APT outputs
# set appropriate path in the case of code development/debugging
my $wd = getcwd;
if($wd eq '/home/cnaw/git_arra/perl' || $wd eq '/home/cnaw/git_arra') {
    print "wd is $wd\n";
    require '/home/cnaw/git_arra/perl/get_apt_csv.pl';
    require '/home/cnaw/git_arra/perl/get_apt_pointing.pl';
    require '/home/cnaw/git_arra/perl/file_prefix_from_dithers.pl';
    require '/home/cnaw/git_arra/perl/output_grism.pl';
    require '/home/cnaw/git_arra/perl/translate_instruments.pl';
} else {
    require $perl_dir.'get_apt_csv.pl';
    require $perl_dir.'get_apt_pointing.pl';
    require $perl_dir.'file_prefix_from_dithers.pl';
    require $perl_dir.'output_grism.pl';
}
# Translate coordinates from primary instrument into NIRCam coordinates
require $perl_dir.'translate_instruments.pl';
#

##########################################################################

# Define variables
#
my $reference_orientation;
my(%v3pa_reference);
my(%v3pa);

my $aperture;
my $auto_target;
my $expripar;
my $hash_key;
my $info_ref;
my $keyword ;
# Name used in the Pointings file 
my $label;
my $mode_count = 0;
my $nircam_grism_mode;
my $nirspec_mode;
my $nrs_aperture;
my $number;
my $number_pointings;
my $observation_number;
my $parallel_instrument;
my $proposal_category;
my $proposal_id;
my $proposal_title;
my $obs;
my $obs_counter = 0;
#my $sequence_ref;
my $some_number;
my $target_number; 
my $targetid;
my $targetname ;
my $value;
my $visit_counter = 0;
my $visit_id_hash;
my $visit_n ;
my $visit_par ;

my @exptype;
my(@level4_parameters)      = ('TargetName','TargetArchiveName','TargetID','Epoch');
my(@level5_parameters)      = ('Instrument');
my(@ncwfss_parameters)      = ('GrismExposure');
# OrientFromObs: this Obs is the reference such that PA(primary) = PA(OrientFromObs) + MxxAngle:
my(@orient_attributes)      = ('PrimaryObs','Mode','OrientFromObs','MinAngle','MaxAngle');
my(@orient_range);
my(@orient_range_attributes)      = ('OrientMin','OrientMax');
my(@visitid) =();
my(@output)  = ();
my(@nsmos_attributes) = ('nsmos:TaMethod','nsmos:AcqMsaAcquisitionConfigFile',
			'nsmos:OptionalConfirmationImage>', 'nsmos:DitherType',
			'nsmos:Plan','nsmos:Plans','nsmos:AperturePA','nsmos:Theta',
			'nsmos:PrimaryCandidateSet','nsmos:SpectralOffsetMap',
			'nsmos:SpectralOffsetThreshold','nsmos:Exposures',
			'nsmos:Grating','nsmos:Filter','nsmos:ReadoutPattern',
			'nsmos:Groups','nsmos:Integrations','nsmos:EtcId',
			'nsmos:Autocal');

my %coordinated_parallel;
my %coordinated_parallel_set;
my %coordinates;
my %cross_id;
my %epoch;
my %fixed_target_parameters;
my %grism;
my %grism_imaging;
my %grism_spectroscopy;
my %instrument;
my %label;
my %miri_setup;
my %mos_data;
my %module;
my %nircam_imaging;
my %nirspec_nod;
my %nirspec_setup ;
my %observation_number;
my %observation_parameters;
my %observation_visits;
my %orientation;
my %parallel;
my %primary_dither_type;
my %primary_dithers;
my %same_orientation;
my %sequence;
my %subarray;
my %subpixel_dither_type;
my %target_archive_name;
my %target_id;
my %target_name;
my %target_observations;
my %target_parameters;
#
my %visit_coords;
my %visit_id;
my %visit_label;
my %visit_label_inv;
my %visit_number;
my %visit_obs_num;
my %visit_orient;
my %visit_orient_ref;
my %visit_parallel;
my %visit_primary;
my %visit_setup;
my %visit_reference;
my %subpixel_positions ;
my %visit_mosaic;

################################################################################
#
#  Read files generated by APT
#
if($#ARGV ==-1) {
    print "use is\nnew_apt_output.pl proposal_number:\nnew_apt_output.pl 1180\n";
    exit(0);
}
my $prefix = $ARGV[0];
my(@list, $xml_file, $pointings_file, $csv_file, $file);
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
################################################################################

# get dither positions from the csv file
#
my ($pointings_ref, $pa_ref, $visit_ref, $exptype_ref, $visit_move_ref) 
    = get_apt_pointing($prefix, $pointings_file, $testing);
my %pointings    = %$pointings_ref;
my %pointings_pa = %$pa_ref;
my %visits       = %$visit_ref;
my %visit_moves  = %$visit_move_ref;
#
my ($dithers_id_ref, $dithers_ref, $sequence_ref)       = get_apt_csv($csv_file);
my (%dithers_id) = %$dithers_id_ref;
my (%dithers)    = %$dithers_ref;

# this allows recovering some additional information from the CSV file
my ($prefix_ref, $visit_content_ref) = file_prefix_from_dithers($dithers_id_ref, $dithers_ref);
my %file_prefix  = %$prefix_ref;
my %visit_content = %$visit_content_ref;
#
# Set cross-reference between observation number and visit ID,
# including cases where a single observation has more than one visit.
# The following data will be retained from here
#$debug = 1;
#$testing = 1;
foreach my $key (sort(keys(%visit_content))) {
    my @junk = split(' ', $visit_content{$key});
    $key  =~ s/\s//g;
    $cross_id{$key} = $junk[$#junk];
    if($testing == 1) {
	print "at line ", __LINE__," visit_id : $key, visit_content: $visit_content{$key}\n";
    }
}

foreach my $key (sort(keys(%visits))){
    my $obs_num;
    ($junk, $obs_num)  = split('\(Obs\_',$key);
    $obs_num =~ s/\)//g;
    $obs_num = sprintf("%03d",$obs_num);
    my @junk = split(' ', $visits{$key});
    $observation_number{$obs_num} = join('#', $key, @junk);
#    $visit_obs_num{$key}  = $obs_num;
    $visit_label_inv{$key}= $visits{$key};
    for(my $ii = 0 ; $ii <= $#junk ; $ii++) {
	if($debug != 0) {
	    print "at line : ",__LINE__," observation label: $key visit: $junk[$ii]\n";
	}
	$visit_label{$junk[$ii]} = $key;
    }
}

foreach my $obs_num (sort(keys(%observation_number))) {
    my ($label, @array) = split('\#',$observation_number{$obs_num});
    my $nv = @array;
    my $nd = 0;
    for(my $ii = 0 ; $ii <= $#array; $ii++) {
	my $key = $array[$ii];
#	print "at line : ",__LINE__," key : $key  visit_content{$key} :$visit_content{$key}\n";
	my @junk = split('\#',$visit_content{$key});
	$visit_obs_num{$key}  = $obs_num;
	$visit_orient{$key} = $junk[2];
	$nd = $nd + @junk;
	if($testing == 1) {
	    for(my $jj=0; $jj<=$#junk ; $jj++) {
		print "at line : ",__LINE__," visit:$key, observation: $obs_num, visit_content: $junk[$jj]\n";
	    }
	}
    }
    print "read_apt_output.pl at line : ",__LINE__," observation number $obs_num label: $label visits: $nv dithers: $nd\n";
}
#die;
#print "pause\n";
if($testing == 1) {
    print "pause\n";
#    <STDIN>;
}
#
#00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
#
#  Initialise the instrument hash
#
$info_ref = initialise_instrument_info();
my %instrument_info = %$info_ref;
#
# Code from 
# 
# https://grantm.github.io/perl-libxml-by-example/large-docs.html
#
# Parse XML file and return a document object
# which contains all elements of the XML document
#
my $reader = XML::LibXML::Reader->new(location => $xml_file,no_blanks => 1 );

my %type_name = (
    &XML_READER_TYPE_ELEMENT                 => 'ELEMENT',
    &XML_READER_TYPE_ATTRIBUTE               => 'ATTRIBUTE',
    &XML_READER_TYPE_TEXT                    => 'TEXT',
    &XML_READER_TYPE_CDATA                   => 'CDATA',
    &XML_READER_TYPE_ENTITY_REFERENCE        => 'ENTITY_REFERENCE',
    &XML_READER_TYPE_ENTITY                  => 'ENTITY',
    &XML_READER_TYPE_PROCESSING_INSTRUCTION  => 'PROCESSING_INSTRUCTION',
    &XML_READER_TYPE_COMMENT                 => 'COMMENT',
    &XML_READER_TYPE_DOCUMENT                => 'DOCUMENT',
    &XML_READER_TYPE_DOCUMENT_TYPE           => 'DOCUMENT_TYPE',
    &XML_READER_TYPE_DOCUMENT_FRAGMENT       => 'DOCUMENT_FRAGMENT',
    &XML_READER_TYPE_NOTATION                => 'NOTATION',
    &XML_READER_TYPE_WHITESPACE              => 'WHITESPACE',
    &XML_READER_TYPE_SIGNIFICANT_WHITESPACE  => 'SIGNIFICANT_WHITESPACE',
    &XML_READER_TYPE_END_ELEMENT             => 'END_ELEMENT',
);
say " Step | Node Type               | Depth | Name";
say "------+-------------------------+-------+-------";

#
######################################################
#
#  Loop through the XML file
#

my $step = 1;
while($reader->read) {
    next unless $reader->nodeType == XML_READER_TYPE_ELEMENT;
    printf(
        " %3u  | %-22s  | %4u  | %s\n",
        $step++,
        $type_name{$reader->nodeType},
        $reader->depth,
        $reader->name
	);
#
# does it have any children ?
#
    my $list = $reader->copyCurrentNode(1);
    if($print_level1 == 1) {
	say '$list   is an ', ref($list), ' $list->nodeName is ', $list->nodeName;
    }
    my $ii = 0;
    foreach my $node ($list->childNodes) {
	$ii++;
	if ($node->nodeType == XML_ELEMENT_NODE) {
	    printf(
		" %3u  | %-22s  | %4u  | %s\n",
		$ii, 
		ref($node), 
		$reader->depth,
		$node->nodeName
		);
	}
    }
#    
# go through the  list of children
#
    my @level1 = grep { $_->nodeType == XML_ELEMENT_NODE } $list->childNodes;
    my $counter1 = @level1 ;
    if($print_level1 == 1) {
	say 'level 1 *  counter1 is ',$counter1, " is an ", ref($list), ', name = ', $list->nodeName; 
    }
    my($kk) = 0;
    foreach my $key1 (@level1) {
	my @level2 = grep { $_->nodeType == XML_ELEMENT_NODE } $key1->childNodes;
	my $counter2 = @level2;
	$kk++;
	if($print_level1 == 1) {
	    say 'level 2 *  counter2 is ',$counter2, ' kk ', $kk, ": is an ", ref($key1), ', name = ', $key1->nodeName; 
	}
#
#	if($key1->nodeName eq 'ProposalInformation') {
#	    say "\nskipping: ", $key1->nodeName,"\n";
#	    next;
#	}
#	if($key1->nodeName ne 'ProposalInformation') {
#	    say "\nreading: ", $key1->nodeName,"\n";
#	    next;
#	}
#	if($key1->nodeName ne 'LinkingRequirements') {
#	    say "\n skipping: ", $key1->nodeName,"\n";
#	    next;
#	}
#
	if($counter2 == 0) {
	    if($print_level1 == 1) {
		say 'key1 nodeName    : ', $key1->nodeName();
		say 'key1 nodeType    : ', $key1->nodeType;
		say 'key1 textContent : ', $key1->textContent;
		say 'key1 toString    ; ', $key1->toString;
		print "\n";
	    }
	    $keyword  = $key1->nodeName;
	    $value    = $key1->textContent;
	} else {
# counter2 > 0
	    my $ll = 0;
	    foreach my $key2 (@level2) {
		my @level3 = grep { $_->nodeType == XML_ELEMENT_NODE } $key2->childNodes;
		my $counter3 = @level3 ;

		if($counter3 == 0) {
		    if($print_level2 == 1) {
			say 'level 3 *  counter3 is ',$counter3, ' kk ', $kk, ' ll ', $ll++, ": is an ", ref($key2), ', name = ', $key2->nodeName; 
			say 'key2 nodeName    : ', $key2->nodeName();
			say 'key2 nodeType    : ', $key2->nodeType;
#			say 'key2 textContent : ', $key2->textContent;
#			say 'key2 toString    ; ', $key2->toString;
			print "\n";
		    }
		    if($key2->nodeName eq 'Title') {
			$proposal_title =  $key2->textContent;
			$proposal_title =~ s/\s/_/g;;
			$proposal_title =~ s/\#/Nr./g;;
		    }
		    if($key2->nodeName eq 'ProposalID') {
			$proposal_id =  $key2->textContent;
		    }
		    if($key2->nodeName eq 'ProposalCategory') {
			$proposal_category =  $key2->textContent;
		    }
# Orientation
# at this point the visit_id has not been defined for most of the visits, thus use the
# label as identifier (here called "key")
#
#		    if($key2->nodeName eq 'OrientFromLink' && $key1->nodeName eq 'LinkingRequirements') {
#			my ($key, $rr);
#			for ($rr =0 ; $rr <= $#orient_attributes;$rr++) {
#			    $keyword = $orient_attributes[$rr];
#			    $value   = $key2->getAttribute($keyword);
#			    $value   =~ s/\s/\_/g;
#			    $value =~ s/_Degrees//g;
## use primary observation as key
#			    if($rr == 0) { 
#				$key = $value;
#				$orientation{$key} = $key;
#			    } else {
#				$orientation{$key} = join(' ',$orientation{$key},$value);
#			    }
#			    if($keyword eq 'OrientFromObs') {$visit_orient_ref{$key} = $value;}
##			    print "at ", __LINE__,"rr: $rr, key is $key, Orientation is $keyword, value is  $value\n";
#			}
## This will only identify those visits that have a direct reference visit. Other visits may be linked to these
## under the "same orientation" case 
#			
##			$visit_orient{$visit_id_hash}  = $orientation{$key};
##			print " ",__LINE__," visit_orient $visit_orient{'01176361001'}\n";
##			print "at line ",__LINE__," $visit_id_hash : key: $key; visit_orient: $orientation{$key}\n";
#		    }
#
		    $keyword  = $key2->nodeName;
		    $value    = $key2->textContent;
		    $keyword  =~ s/nci://g;
#
# <VisitStatus>  contains the visit number (== observation_number; will go into FITS header)
# and number of pointings (i.e., dithers+sub-pixel dithers)
#
		    if($keyword eq 'VisitStatus') {
			$visit_counter++;
			$keyword = 'VisitId';
			$value   = $key2->getAttribute($keyword);
			$hash_key = $value;
			$visit_id_hash = $value;
# observation number
			$obs = sprintf("%d",substr($value,5,3));
			my $obs_num = sprintf("%03d",$obs);
			$observation_parameters{$obs_num} = $obs_num;
# there can be more than 1 visit in a given observation
			if(exists($observation_visits{$obs_num})) {
			    $observation_visits{$obs_num} = join(' ',$observation_visits{$obs_num},$hash_key);
			} else {
			    $visit_id{$obs} = $hash_key;
			    $observation_visits{$obs_num} = $hash_key;
			}
# number of dithers
			$keyword  = 'NumPointings';
			$value    = $key2->getAttribute($keyword);
			if(! defined($value))  {
			    $value = 0;
			    print "keyword $keyword at line ",__LINE__," is not defined for  $visit_id_hash; setting ndithers to $value\n";
#			    <STDIN>;
			}
			$observation_parameters{$obs_num} = join('#',$observation_parameters{$obs_num},$keyword.':'.$value);
#			print "line ", __LINE__," visit_id{$obs} is $visit_id_hash, ndithers : $value\n"; 
#			<STDIN>;
		    }
# end of visit ID + number of pointings
		} else {
# counter3 > 0
# Read keywords following <Target xsi:type="FixedTargetType" AutoGenerated="false"></Target>
#3333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
		    my ($mm) = 0;
		    $auto_target = '';
		    foreach my $key3 (@level3) {
			my @level4 = grep { $_->nodeType == XML_ELEMENT_NODE } $key3->childNodes;
			my $counter4 = @level4 ;
			$mm++;
			if($print_level3 == 1) {
			    say 'level 4 %  counter4 is ',$counter4, ' kk ', $kk, ' ll ', $ll,' mm ', $mm, ": is an ", ref($key3), ', name = ', $key3->nodeName; 
			}
		
# this will allow linking objects in the  XML file with those in the  Pointings file 
			if($key3->nodeName eq 'Mode' && $key1->nodeName eq 'LinkingRequirements') {
			    $mode_count++;
			    $same_orientation{$mode_count} = $key3->textContent;
#			    say '244: ',$key3->nodeName,' ',$key3->textContent;
			}
			if($key3->nodeName eq 'Observation' && $counter4 > 0) {
			    my $key   = $key3->nodeName;
			    $keyword  = 'AutoTarget';
			    $auto_target    = $key3->getAttribute($keyword);
#			    print "at ", __LINE__," key is $key  getAttribute is $keyword value is $auto_target\n";
#4444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
			    foreach my $key4 (@level4) {
				$keyword  = $key4->nodeName;
# This value of "Number" refers to the observation number
				if($keyword eq 'Number') {
				    $number = $key4->textContent;
				    $observation_number = sprintf("%03d", $number);
#				    print "at line : ",__LINE__," observation_number is $observation_number\n";
				    $visit_id_hash = $visit_id{$number};
				    my @items = split(' ',$visit_id_hash);
# Kludge in the case an observation has more than one visit - use the first one
				    if($#items > 0) { 
					$visit_id_hash = $items[0];
					$observation_number = $visit_obs_num{$visit_id_hash};
				    }
#				    print "at line : ",__LINE__," key is $key, keyword is $keyword, items @items visit_id_hash is $visit_id_hash\n";
#				    print "at line : ",__LINE__," key is $key, keyword is $keyword, items @items observation_number is $observation_number\n";
#				    print "at line : ",__LINE__," key is $key, keyword is ",$keyword,", value is ",$number,", visit_id is ",$visit_id{$number},"\n";
#				    <STDIN>;
				}
# This is TargetID under "<Target xsi:type>" (XML level (4),  will called
# target_name and seems to be identical to TargetName at the same XMM level. 
# TargetID under "Observation" (XML level #3) will be called target_id,
# and contains the observation number + target name
#				if($keyword eq 'TargetID') {
#				    $value    = $key4->textContent;
#				    ($junk, $targetname) = split(' ',$value);
#				    $target_parameters{$targetname} = join(' ',$number,$targetname);
#				    $observation_parameters{$observation_number}=join('#',$observation_parameters{$observation_number},$keyword.':'.$value);
#				    $target_name{$observation_number} = $value;
#				    if(! exists($visit_id{$number})) {
#					print "number : $number;  visit_id{number} does not exist\n";
#				    }
##				    $cross_id{$targetname} = $visit_id{$number};
##				    $cross_id{$visit_id{$number}} = $targetname;
##				    print "at ",__LINE__," keys is $key, keyword :$keyword, junk :$junk, targetname : $targetname, number: $number, visit_id{number}: $visit_id{$number} visit_id_hash : $visit_id_hash observation_number is $observation_number \n";
#				}
				if($keyword eq 'Label') {
				    $label  = $key4->textContent;
				    $value   = $key4->textContent;
#				    $target_parameters{$targetname} = join(' ',$target_parameters{$targetname},$label);
				    $observation_parameters{$observation_number} = join('#',$observation_parameters{$observation_number},$keyword.':'.$value);
#				    $visit_id_hash = $cross_id{$targetname};
#				    $visit_label{$visit_id_hash} = $label;
#				    print "at ",__LINE__," keys is $key, keyword is $keyword, value is $value, targetname is $targetname, visit_label{$visit_id_hash} is $label\n";
				}
			    }
			}
			if($key3->nodeName eq 'Observation' && $key1->nodeName eq 'LinkingRequirements') {
			    $obs_counter++;
			    $value   = $key3->textContent;
			    $value   =~ s/\s/_/g;
			    my $start = index($value,'Obs_');
			    $visit_n  = substr($value,$start);
			    $visit_n =~ s/Obs_//g;
			    $visit_n =~ s/\)//g;
			    $visit_id_hash = $visit_id{$visit_n};
			    $visit_label{$visit_id_hash} = $value;
			    $targetname   = $cross_id{$visit_id_hash};
			    if(exists($same_orientation{$mode_count})) {
				$same_orientation{$mode_count} = join(' ',$same_orientation{$mode_count},$visit_id_hash);
			    } else {
				$same_orientation{$mode_count} = $visit_id_hash;
			    }
#			    print "at line: ", __LINE__, " visit_n is $visit_n, visit_id_hash is $visit_id_hash, label is $value, targetname is $targetname mode_count is $mode_count\n";
#			    die;
 			}
#
# first instance of NUMBER, which is "Target Number" in the
# "Fixed Targets" list of APT note that in general
#
# target number  != observation number;
#
# Need to use the TargetID as cross-identification reference
# 
			if($key3->nodeName eq 'Number') {
			    $keyword       = $key3->nodeName;
			    $value         = $key3->textContent;
			    $target_number = $value;
			    $fixed_target_parameters{$target_number} = $value;
#			    print "at line : ", __LINE__ ," first instance of number: target_number is $target_number\n";
			}
# this will be identical to "TargetID" under <Target xsi:type>
			if($key3->nodeName eq 'TargetName') {
			    $keyword  = $key3->nodeName;
			    $value    = $key3->textContent;
			    $fixed_target_parameters{$target_number} =join(' ', $fixed_target_parameters{$target_number},$keyword.':'.$value);
			    $target_name{$target_number} = $value;
#			    print "at line : ",__LINE__," fixed_target_parameters for $target_number:  $fixed_target_parameters{$target_number}\n";
			}
#####################			
			if($key3->nodeName eq 'TargetArchiveName') {
			    $keyword  = $key3->nodeName;
			    $value    = $key3->textContent;
			    $fixed_target_parameters{$target_number} =join(' ', $fixed_target_parameters{$target_number}, $keyword.':'.$value);
			    $target_archive_name{$target_number} = $value;
#			    print "at line : ",__LINE__," target_archive_name{$target_number}: $target_archive_name{$target_number}\n";
#			    <STDIN>;
			}
			if($key3->nodeName eq 'TargetId') {
			    $keyword  = $key3->nodeName;
			    $value    = $key3->textContent;
			    $fixed_target_parameters{$target_number} =join(' ', $fixed_target_parameters{$target_number}, $keyword.':'.$value);
#			    $target_id{$target_number} = $value
			}
			if($key3->nodeName eq 'Epoch') {
			    $keyword  = $key3->nodeName;
			    $value    = $key3->textContent;
			    $fixed_target_parameters{$target_number} =join(' ', $fixed_target_parameters{$target_number}, $keyword.':'.$value);
			    $epoch{$target_number} = $value
			}
  			if($key3->nodeName =~ m/EquatorialCoordinates/) {
			    $keyword =  $key3->nodeName();
			    my($coordinates) = $key3->getAttribute('Value');
			    $coordinates =~ s/\s/\,/g;
			    $value = $coordinates;
			    if($print_level3 == 1) {
				say 'key3 nodeName    : ', $keyword;
				say $keyword,': ', $coordinates;
				print "\n";			    
			    }
			    $fixed_target_parameters{$target_number} = join(' ',$fixed_target_parameters{$target_number},$keyword.':'.$value);
			    $coordinates{$target_number} = $value;
#			    print "at line : ",__LINE__," target_number is $target_number fixed_target_parameters: $fixed_target_parameters{$target_number} \n";
#			    <STDIN>;
			}
			if($print_level4 == 1) {
			    say 'key3 nodeName    : ', $key3->nodeName();
			    say 'key3 nodeType    : ', $key3->nodeType;
			    if ($key3->nodeName() =~ m/Catalog/) {next;}
			    say 'key3 textContent : ', $key3->textContent;
			    say 'key3 toString    ; ', $key3->toString;
			    print "\n";
			}
			if($counter4 > 0) {
# counter4 > 0
#5555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
			    my ($nn) = 0;
# follow NIRSpec planner
			    foreach my $key4 (@level4) {
				my @level5 = grep { $_->nodeType == XML_ELEMENT_NODE } $key4->childNodes;
				my $counter5 = @level5 ;
				if($testing == 1 || $debug == 1) {
				    print "at line : ",__LINE__," counter5 is $counter5 key4 is $key4\n";
				}
				$nn++;
				if($print_level4 == 1) {
				    say 'level 5 #  counter5 is ',$counter5, ' kk ', $kk, ' ll ', $ll,' mm ',$mm, ' nn ', $nn, ": is an ", ref($key4), ', name = ', $key4->nodeName; 
				}
#
				if($print_level4 == 1) {
				    print "at line : ",__LINE__," key4 level 4\n";
				    say 'key4 nodeName    : ', $key4->nodeName();
				    say 'key4 nodeType    : ', $key4->nodeType;
				    if ($key4->nodeName() =~ m/msa:CatalogAsCsv/) {next;}
				    say 'key4 textContent : ', $key4->textContent;
				    say __LINE__,' key4 toString    ; ', $key4->toString;
				    print "\n";
				}
				$keyword  = $key4->nodeName;
				$value    = $key4->textContent;
				$keyword  =~ s/nci://g;
#				print "at line ",__LINE__," visit_n: $visit_n visit_id_hash: $visit_id_hash, $keyword, $value\n";
#				my $obs_num = sprintf("%03d", $obs);
				my $obs_num;
#				<STDIN>;
#
# Second instance of Number; here is the observation/visit number and number is consistent with that in visit_id
# need to incorporate observation with multiple visits
				if($keyword eq 'Number') {
				    $observation_number = sprintf("%03d",$value);
				    $visit_n    = $value;
				    $visit_setup{$visit_n} = $visit_n;
				    $visit_id_hash = $visit_id{$visit_n};
#				    print "at line : ", __LINE__, " visit_n is $visit_n visit_id_hash is $visit_id_hash observation_number is $observation_number\n";
#				    <STDIN>;
#
# with current version of APT, NIRSpec prime will not have these parameters set yet;
# this happens at level 8 
				    if(! exists($target_parameters{$visit_id_hash})){
#					print "at Line : ", __LINE__, " second instance of number is $value\n";
					$target_parameters{$visit_id_hash} = $visit_n;
#					die;
				    }
				}

				my @nvisits;
				my $visit_00;
#
# TargetID comes in two flavours - this one under <Observation AutoTarget="false"> another under "Target";
				if($keyword eq 'TargetID') {
				    $targetid = $value;
				    ($some_number, $targetname) = split(' ',$value);
				    if(exists($visit_setup{$visit_id_hash})) {
					$visit_setup{$visit_id_hash} = join(' ',$visit_setup{$visit_id_hash}, $targetid);
				    } else {
					$visit_setup{$visit_id_hash} = $targetid;
				    }
				    $visit_number{$visit_id_hash}    = $visit_n;
				    $observation_number = $visit_obs_num{$visit_id_hash};
				    $target_id{$observation_number}  = $value;
				    $target_observations{$visit_id_hash} = '';
				    if($testing == 1) {
				    print "at line : ", __LINE__," TargetID is $targetid, visit_id_hash is $visit_id_hash, visit_n is $visit_n, targetname is $targetname observation_number is $visit_obs_num{$visit_id_hash}, value is $value\n";
#				    <STDIN>;
				    }
				}
# This is "Label" under <Observation AutoTarget="false">
				if($keyword eq 'Label') {
#				    $visit_id_hash = $visit_id{$visit_n};
				    $value =~ s/\s/_/g;
				    $label = $value.'_(Obs_'.$visit_n.')';
				    $visit_label{$visit_id_hash} = $label;
				    $visit_label_inv{$label} = $visit_id_hash;
				    $observation_number = sprintf("%03d",$visit_n);
				    $label{$observation_number} = $value;
				    if($testing == 1) {
				    print "at line : ",__LINE__," label is $label; visit_id_hash is $visit_id_hash; visit_n is $visit_n\n";
				    }
				}

				if($keyword eq 'Instrument') {
				    $visit_setup{$visit_id_hash} = join(' ',$visit_setup{$visit_id_hash}, $value);
				    $observation_parameters{$observation_number} = join('#',$observation_parameters{$observation_number}, $keyword.':'.$value);
				    $observation_number = $visit_obs_num{$visit_id_hash};
				    $instrument{$observation_number} = $value;
				    if($testing == 1) {
				    print "at line : ", __LINE__," : keyword: $keyword, value is  $value, visit_id_hash is $visit_id_hash observation_number: $observation_number\n";
#				    <STDIN>;
				    }
				}
				if($keyword eq 'CoordinatedParallel') {
				    $coordinated_parallel{$visit_id_hash} = $value;
				    $coordinated_parallel{$observation_number} = $value;
#				    print "at line : ", __LINE__," keyword: $keyword, value is  $value, visit_id_hash is $visit_id_hash observation_number: $observation_number\n";
#				    <STDIN>;
				}
				if($keyword eq 'CoordinatedParallelSet') {
				    $coordinated_parallel_set{$visit_id_hash} = $value;
				    $coordinated_parallel_set{$observation_number} = $value;
				    print "at line : ", __LINE__," keyword: $keyword, visit_id_hash is $visit_id_hash; observation_number is $observation_number,  value is  $value \n";
#				    <STDIN>;
				}
				if($counter5 >   0) {
# counter5 > 0
				    my ($oo) = 0;
				    foreach my $key5 (@level5) {
					my @level6 = grep { $_->nodeType == XML_ELEMENT_NODE } $key5->childNodes;
					my $counter6 = @level6 ;
					if($testing == 1 || $debug == 1) {
					    print "at line : ",__LINE__," counter6 is $counter6 key5 is $key5\n";
					}
					$oo++;
					if($print_level5 == 1) {
					    say 'level 6 :  counter6 is ',$counter6,  ' oo ', $oo, 
					    ": is an ", ref($key5), ', name = ', $key5->nodeName;
					}
					if($counter6 == 0) {
					    $keyword  = $key5->nodeName;
					    $value    = $key5->textContent;
					    if($keyword =~ m/nci/) {
						$keyword =~ s/nci://g;
					    }
					    if($keyword =~ m/ncei/) {
						$keyword =~ s/ncei://g;
					    }
					    if($keyword =~ m/ncwfss/) {
						$keyword =~ s/ncwfss://g;
						print "at line : ",__LINE__," keyword $keyword value $value\n";
						die;
					    }
					    $keyword =~ s/\s//g;
					    if($print_level5 == 1) {
						print "at line : ",__LINE__," key5 level 5\n";
						say 'key5 nodeName    : ', $key5->nodeName();
						say 'key5 nodeType    : ', $key5->nodeType;
						say 'key5 textContent : ', $key5->textContent;
						say 'key5 toString    ; ', $key5->toString;
						print "keyword, value : $keyword $value\n";
						print "\n";
					    }
					    if($key5->nodeName() eq 'OrientRange') {
					    if($print_level5 == 1) {
						print "at line ",__LINE__, " OrientRange:\n";
						say 'key5 nodeName    : ', $key5->nodeName();
						say 'key5 nodeType    : ', $key5->nodeType;
						say 'key5 textContent : ', $key5->textContent;
						say 'key5 toString    ; ', $key5->toString;
					    }
					    my ($key, $rr);

#					    print " ", __LINE__ ,"visit_orient: visit_id_hash is $visit_id_hash label is $visit_label{$visit_id_hash}\n";
					    for ($rr =0 ; $rr <= $#orient_range_attributes;$rr++) {
						$keyword = $orient_range_attributes[$rr];
						$value   = $key5->getAttribute($keyword);
						$value   =~ s/\s/\_/g;
						$reference_orientation = $value;
						push(@orient_range,$value);
#						print " ", __LINE__ ,"visit_orient:$visit_id_hash, $value\n";
						if(exists($visit_orient{$visit_id_hash})) {
						    $visit_orient{$visit_id_hash} = 
							join(' ',$visit_orient{$visit_id_hash}, $value);
						} else {
						    $visit_orient{$visit_id_hash} = $value;
						}
#						print "at line ", __LINE__ ," visit_id_hash is $visit_id_hash, visit_n is $visit_n, keyword is $keyword, value is $value, label is $visit_label{$visit_id_hash} visit_orient is $visit_orient{$visit_id_hash} \n";
#						<STDIN>;
						}
 					    }
					    if($key5->nodeName() eq 'Rows') {
						if($debug == 1 || $print_level5 == 1) {
						    print "visit_id_hash is $visit_id_hash\n";
						    say 'key5 nodeName    : ', $key5->nodeName();
						    say 'key5 nodeType    : ', $key5->nodeType;
						    say 'key5 textContent : ', $key5->textContent;
						    say 'key5 toString    ; ', $key5->toString;
						    print "keyword, value : $keyword $value\n";
						    print "\n";
						}
						if(exists($visit_mosaic{$targetid})) {
						    $visit_mosaic{$visit_id_hash} = join(' ',$visit_mosaic{$visit_id_hash},$value);
						} else {
						    $visit_mosaic{$visit_id_hash} = $value;
						}
						if(exists($visit_mosaic{sprintf("%03d",$obs)})) {
						    $visit_mosaic{sprintf("%03d",$obs)} = join(' ',$visit_mosaic{sprintf("%03d",$obs)},$value);
						} else {
						    $visit_mosaic{sprintf("%03d",$obs)} = $value;
						}
					    }
					    if($key5->nodeName() eq 'Columns') {
						if($debug == 1 || $print_level5 == 1) {
#						    print "at line ", __LINE__," visit_id_hash is $visit_id_hash visit_n is $visit_n\n";
						    say 'key5 nodeName    : ', $key5->nodeName();
						    say 'key5 nodeType    : ', $key5->nodeType;
						    say 'key5 textContent : ', $key5->textContent;
						    say 'key5 toString    ; ', $key5->toString;
						    print "keyword, value : $keyword $value\n";
						    print "\n";
						}
						if(exists($visit_mosaic{$visit_id_hash})) {
						    $visit_mosaic{$visit_id_hash} = join(' ',$visit_mosaic{$visit_id_hash}, $value);
						} else {
						    $visit_mosaic{$visit_id_hash} =$value;
						}
						if(exists($visit_mosaic{sprintf("%03d",$obs)})) {
						    $visit_mosaic{sprintf("%03d",$obs)} = join(' ',$visit_mosaic{sprintf("%03d",$obs)}, $value);
						} else {
						    $visit_mosaic{sprintf("%03d",$obs)} =$value;
						}
					    }


# these are mostly Mosaic-related keywords					    
					    if(exists($instrument_info{$keyword})) {
						$visit_setup{$visit_id_hash} = join(' ',$visit_setup{$visit_id_hash},$value);
					    }
					} else {
					    my ($pp) = 0;
					    foreach my $key6 (@level6) {
						my @level7 = grep { $_->nodeType == XML_ELEMENT_NODE } $key6->childNodes;
						my $counter7 = @level7 ;
						if($testing == 1 || $debug == 1) {
						    print "at line : ",__LINE__," counter7 is $counter7 key6 is $key6\n";
						}
						$pp++;
						if($key6->nodeName =~ m/msa:id/) {
						    say '670 ',$key6->nodeName,' ' ,$key6->textContent;
#						    <STDIN>;
						}
#						if($key6->nodeName =~ m/msa:AperturePositionAngle/) {
#						    say '413 ',$key6->nodeName,' ' ,$key6->textContent;
#						}
# For NIRSpec prime this provides plan name, dither type, plan which could be the targetId, AperturePA (i.e., instrument, not PA_v3)
						if($key6->nodeName =~ m/msa:/ && $print_msa == 0) {next;}
						if($keyword eq 'nsmos:Plan') {
						    my $visit_id = $visit_id{$visit_n};
						    $value =~ s/\s/_/g;
						    $value =~ s/Plan:_//g;
						    my $target_id = $targetid;
						    $target_id =~ s/\s/_/g;
						    $target_parameters{$visit_id} = join(' ', $visit_n,$value,$target_id);
						    print "at line : ",__LINE__," visit_id_hash is $visit_id_hash, visit_id is $visit_id, visit_n is $visit_n, targetid is $targetid, value is $value\n";
#						    <STDIN>;
						}
						if($counter7 == 0) {
						    if($print_level6 == 1) {
							print "at line : ",__LINE__," key6 level 6\n";
							say 'level 6 :  counter7 is ',$counter7,  ' pp ', $pp, ": is an ", ref($key6);
							$keyword  = $key6->nodeName;
							$value    = $key6->textContent;
							print " keyword is $keyword\n";
							print " keyword is $keyword\n";
							print " value   is  $value\n";
							print "visit_n  is  $visit_n\n";
							print "target_id  is  $targetid\n";
							print "visit_id   is $visit_id{$visit_n}\n";
						    }
						    $keyword  = $key6->nodeName;
						    $value    = $key6->textContent;
						    if($testing == 1) {print "at line ",__LINE__," $keyword: $value\n";}
						    $keyword =~ s/\s//g;
						    if(lc($keyword) =~ m/module/){
							$module{$visit_id_hash} = $value;
							if($testing ==1 || $debug >0) {print "at line : ",__LINE__," visit_id_hash: $visit_id_hash,keyword is $keyword  value is $value\n";}
						    }
						    if(lc($keyword) =~ 'nci:' || lc($keyword) =~ 'ncie:' ){
							$value =~ s/\s/_/g ;
#							print "at line : ",__LINE__," keyword: $keyword,value is $value\n";
							if(exists($nircam_imaging{$visit_id_hash})) {
							    $nircam_imaging{$visit_id_hash} = 
								join(' ', $nircam_imaging{$visit_id_hash},$keyword.'='.$value);
							} else {
							    $nircam_imaging{$visit_id_hash} = $keyword.'='.$value;
							}							    
							if($testing ==1 || $debug >0) {print "at line : ",__LINE__," nircam_imaging{$visit_id_hash} : $nircam_imaging{$visit_id_hash}\n";}
						    }
						    if($keyword =~ m/ncwfss:/) {
							if(exists($grism{$visit_id_hash})) {
							    $grism{$visit_id_hash} = join(' ',$grism{$visit_id_hash},$keyword.'='.$value);
							}else { 
							    $grism{$visit_id_hash} = $keyword.'='.$value;
							}
							if($testing ==1 || $debug >0){print "at line : ",__LINE__," grism{$visit_id_hash}: $grism{$visit_id_hash}\n";}
						    }
						    if($keyword eq 'nsifus:DitherType') {
							$value    = $key6->textContent;
							my @junk     = split('-',$value);
							$nirspec_setup{$visit_id_hash} = join(' ',$visit_id_hash,'NRS_IFU');
							$nirspec_setup{$observation_number} = 'NRS_IFU';
							$primary_dither_type{$visit_id_hash} = $value;
							$primary_dither_type{$observation_number} = $value;
							$primary_dithers{$visit_id_hash}      = $junk[0];
							$primary_dithers{$observation_number} = $junk[0];
							$subpixel_dither_type{$visit_id_hash} = 'NONE';
							$subpixel_dither_type{$observation_number} = 'NONE';
							$subpixel_positions{$visit_id_hash}        = 0;
							$subpixel_positions{$observation_number}   = 0;
							print "at line ",__LINE__," $visit_id_hash : PrimaryDitherType is $value observation_number is $observation_number\n";
#							<STDIN>;
						    }
						    if($keyword =~ m/msa/ && $print_msa == 0) {	next;}
						    if($keyword =~ m/nci/) {
							$keyword =~ s/nci://g;
						    } else {
							if($keyword =~ m/ncei/) {
							    $keyword =~ s/ncei://g;
							} else {
							    if($keyword =~ m/ncwfss/) {
#								print "at line : ",__LINE__," keyword $keyword value $value\n";
#								$keyword =~ s/ncwfss://g;
							    } else {
#								next;
							    }
							}
						    }
						    $keyword =~ s/\s//g;
						    if($keyword =~ m/PrimaryDitherType/) {
							$value    = $key6->textContent;
							$primary_dither_type{$visit_id_hash} = $value;
							$primary_dither_type{$observation_number} = $value;
							if($value  eq 'NONE') {
							    $primary_dithers{$visit_id_hash} =0;
							    $primary_dithers{$observation_number} =0;
							}
							if($testing ==1 || $debug >0) {print "at line : ",__LINE__," $visit_id_hash : PrimaryDitherType is $value observation_number is $observation_number\n";}
#							<STDIN>;
						    }
						    $keyword =~ s/\s//g;
#						    if($keyword =~ m/PrimaryDithers/) {
						    if($keyword eq 'PrimaryDithers') {
							$value    = $key6->textContent;
							if(looks_like_number($value)) {
							    $primary_dithers{$visit_id_hash} = $value;
							    $primary_dithers{$observation_number} = $value;
							} else {
# commented 2021-07-15 because it messes up APT 1073 which has dither type FULLBOX and primary_dithers  = 8NIRSPEC 
#							    $primary_dither_type{$visit_id_hash} = $value;
#							    $primary_dither_type{$observation_number} = $value;
#							    $value = substr($value,0,1);
							    $primary_dithers{$visit_id_hash} = $value;
							    $primary_dithers{$observation_number} = $value;
							}
							if($testing == 1) {
							print "at line ",__LINE__," $visit_id_hash : PrimaryDitherType is $primary_dither_type{$visit_id_hash} observation_number is $observation_number\n";
							print "at line ",__LINE__," $visit_id_hash : PrimaryDithers is $primary_dithers{$visit_id_hash}\n";
#							<STDIN>;
							}
						    }
						    $keyword =~ s/\s//g;
						    if($keyword =~ m/SubpixelDitherType/) {
							$value    = $key6->textContent;
							$subpixel_dither_type{$visit_id_hash} = $value;
							$subpixel_dither_type{$observation_number} = $value;
#							print "at line ",__LINE__," $visit_id_hash : SubpixelDitherType is $value\n";
#							<STDIN>;
						    }
						    $keyword =~ s/\s//g;
						    if($keyword =~ m/SubpixelPositions/) {
							$value    = $key6->textContent;
							if(looks_like_number($value)){
							    $subpixel_positions{$visit_id_hash} = $value;
							    $subpixel_positions{$observation_number} = $value;
							} else {
							       $subpixel_dither_type{$visit_id_hash} = $value;
							       $subpixel_positions{$visit_id_hash} = substr($value,0,1);
							       $subpixel_dither_type{$observation_number} = $value;
							       $subpixel_positions{$observation_number} = substr($value,0,1);

							}
#							print "at line ",__LINE__," $visit_id_hash : SubpixelDitherType is $subpixel_dither_type{$visit_id_hash}\n";
#							print "at line ",__LINE__," $visit_id_hash : SubpixelPositions is $subpixel_positions{$visit_id_hash}\n";
							#							<STDIN>;
						    }
							#
						    if($print_level6 == 1) {
							print "level 6 at Line: ", __LINE__, "\n";
							say 'key6 nodeName    : ', $key6->nodeName();
							say 'key6 nodeType    : ', $key6->nodeType;
							say 'key6 textContent : ', $key6->textContent;
							say 'key6 toString    ; ', $key6->toString;
							print "keyword, value : $keyword $value\n";
#							print " ",__LINE__," : visit_id_hash is $visit_id_hash value: $value\n";
							print "\n";				
						    }
						    if(lc($keyword) =~ m/module/){
							$module{$visit_id_hash} = $value;
#							print "at line ",__LINE__," visit_id_hash: $visit_id_hash,keyword is $keyword  value is $value\n";
						    }
						    $target_observations{$visit_id_hash} = join(' ',$target_observations{$visit_id_hash}, $value);
#						    print "at line ",__LINE__," target_observations: $target_observations{$visit_id_hash}\n";
						    if(lc($keyword) eq 'subarray'){
							$subarray{$visit_id_hash} = $key6->textContent;
							$subarray{$observation_number} = $key6->textContent;
						    }
						} else {
#7777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
# level 7
						    my ($qq) = 0;
						    foreach my $key7 (@level7) {
							my @level8 = grep { $_->nodeType == XML_ELEMENT_NODE } $key7->childNodes;
							my $counter8 = @level8 ;
							if($testing == 1 || $debug == 1) {
							    print "at line : ",__LINE__," counter8 is $counter8 key7 is $key7\n";
							}
							$qq++;
							if($counter8 == 0) {
							    $keyword  = $key7->nodeName;
							    $value    = $key7->textContent;
							    if($keyword =~ m/nci/) {
								$keyword =~ s/nci://g;
							    }
# "Nircam Engineering Imaging"
							    if($keyword =~ m/ncei/) {
								$keyword =~ s/ncei://g;
							    }
							    if($keyword =~ m/ncwfss/) {
								print "at line : ",__LINE__," keyword $keyword value $value\n";
								die;
								$keyword =~ s/ncwfss://g;
							    }
							    $keyword =~ s/\s//g;
							    if($print_level7 == 1) {
								print "at line : ",__LINE__," key7 level7\n";
								say 'key7 nodeName    : ', $key7->nodeName();
								say 'key7 nodeType    : ', $key7->nodeType;
								say 'key7 textContent : ', $key7->textContent;
								say 'key7 toString    ; ', $key7->toString;
								print "keyword, value : $keyword $value\n";
								print "\n";
							    }
# 							    $visit_setup{$visit_id_hash} = join(' ',$visit_setup{$visit_id_hash},$value);
#
#							    if($key7->nodeName() =~ m/ns:/){next;}
#							    if($key7->nodeName() =~ m/ns:shutters/){next;}
#							    if($key7->nodeName() =~ m/ns:slitlets/){next;}
#							    if($key7->nodeName() =~ m/ns:primaries/){next;}
#							    if($key7->nodeName() =~ m/ns:fillers/){next;}
							    if($key7->nodeName =~ m/mi:/ && $print_mi == 0) {next;}
							    if($key7->nodeName() !~ m/msa/){
								print "at line : ",__LINE__," chabu at $key7->nodeName()\n";
								print "pause key 7\n";
#								<STDIN>;
							    }
							} else {
#88888888888888888888888888888888888888888888888888888888888888888888888888888888
# Level 8
							    my($rr) = 0;
							    foreach my $key8 (@level8) {
								my @level9 = grep { $_->nodeType == XML_ELEMENT_NODE } $key8->childNodes;
								my $counter9 = @level9 ;
								$keyword = $key8->nodeName();
								$value   = $key8->textContent();
								if($testing == 1 || $debug == 1) {
								    print "at line : ",__LINE__," counter9 is $counter9 key8 is $key8, keyword is $keyword, array:@level9\n";

								}
								$rr++;	
								if($counter9 > 0) {
								    if($testing == 1 || $debug > 0) {print "at line : ",__LINE__," counter9 is $counter9 key8 is $key8, keyword is $keyword\n";}
								    if($keyword eq 'ncwfss:DiExposure' || $keyword eq 'ncwfss:GrismExposure')  {
									if($keyword eq 'ncwfss:DiExposure') {
									    $grism_imaging{$visit_id_hash} = '';
									    $nircam_grism_mode = 'imaging';
									}
									if($keyword eq 'ncwfss:GrismExposure') {
									    $grism_spectroscopy{$visit_id_hash} = '';
									    $nircam_grism_mode = 'spectra';
									}

									foreach my $key9 (@level9) {
									    my $key   = $key9->nodeName();
									    my $value = $key9->textContent();
#									    $key =~ s/ncwfss://g;
									    if($testing ==1 || $debug >0) {print "at line : ",__LINE__," keyword $keyword, level9: key $key value $value\n";}
									    $grism{$visit_id_hash} =join(' ',$grism{$visit_id_hash},$keyword.':'.$key.'='.$value);
									    if($nircam_grism_mode eq 'spectra'){
										$grism_spectroscopy{$visit_id_hash} = 
										    join(' ',$grism_spectroscopy{$visit_id_hash},$key.'='.$value);
									    }
									    if($nircam_grism_mode eq 'imaging'){
										$grism_imaging{$visit_id_hash} = 
										    join(' ',$grism_imaging{$visit_id_hash},$key.'='.$value);
									    }
									}
								    }
								}
								if($print_level8 == 1 && $counter9 > 0) {
								    print "at line : ",__LINE__," level 8 :  counter9 is $counter9\n";
								    print "at line : ",__LINE__," keyword is  $keyword,  value is $value)\n";
								    print "at line : ",__LINE__," rr is  $rr,  ref is ref($key8)\n";
								    print "name is  $key8->nodeName\n";
								}
								if($testing ==1 || $debug >0) {print "at line : ",__LINE__," keyword $keyword value:$value counter9: $counter9\n";}
#								if($key8->nodeName =~ m/mi:/    && $print_mi == 0) {next;}
#								if($key8->nodeName =~ m/nsmos:/ && $print_nsmos == 0) {next;}
#
# This is the nested level where values for filters, readout, groups are recovered
#
								if($counter9 == 0) {
								    $keyword  = $key8->nodeName;
								    $value    = $key8->textContent;
								    my $instrument = 'all';
								    if($keyword =~ m/mi/) {
									$keyword =~ s/mi://g;
									$instrument = 'miri';
								    }
								    if($keyword =~ m/nci/) {
									$keyword =~ s/nci://g;
									$instrument = 'nrc';
								    }
								    if($keyword =~ m/ncei/) {
									$keyword =~ s/ncei://g;
									$instrument = 'nrc';
								    }
								    if($keyword =~ m/ncwfss/) {
									$keyword =~ s/ncwfss://g;
									$instrument = 'ncwfss';
									print "at line : ",__LINE__," keyword $keyword value $value\n";
								    }
								    if($keyword =~ m/nsmos/) {
									$keyword =~ s/nsmos://g;
									$instrument = 'nrs';
									$nirspec_mode = 'NRS_MOS';
								    }
								    if($keyword =~ m/nsifus/) {
									$keyword =~ s/nsifus://g;
									$instrument = 'nrs';
									$nirspec_mode = 'NRS_IFU';
								    }
								    $keyword =~ s/\s//g;
								    if($print_level8 == 1) {
									print "at line : ",__LINE__," key8 level8\n";
									say 'key8 nodeName    : ', $key8->nodeName();
									say 'key8 nodeType    : ', $key8->nodeType;
									say 'key8 textContent : ', $key8->textContent;
									say 'key8 toString    ; ', $key8->toString;
									print "at ",__LINE__," visit_n,keyword,value : $visit_n,$keyword, $value, visit_id_hash is $visit_id_hash\n";
								    }
								    if(lc($keyword) =~ m/pointing/) {
									if( exists($visit_coords{$visit_id_hash})) {
									    $visit_coords{$visit_id_hash}  = join('#',$visit_coords{$visit_id_hash},$key8->textContent);
									} else {
									    $visit_coords{$visit_id_hash}  = $key8->textContent;
									}
#									print "visit_id_hash is $visit_id_hash $visit_coords{$visit_id_hash}\n";
								    }
								    if($instrument eq 'miri') {
									if(! exists($miri_setup{$visit_id_hash})) {
									    $miri_setup{$visit_id_hash} = $visit_id_hash;
									}
									if($keyword eq 'DitherType') {
									    $miri_setup{$visit_id_hash} = 
										join(' ',  $miri_setup{$visit_id_hash}, $value);
									    $primary_dither_type{$visit_id_hash} = $value;
									    $subpixel_dither_type{$visit_n} = 'none';
									    $primary_dithers{$visit_id_hash} = $value;
									    $primary_dithers{$observation_number} = $value;
#									    print "at line : ", __LINE__," pause\n";
#									    <STDIN>;
									}
								    }
# open NIRSpec block level 8
								    if($instrument eq 'nrs') {
									if (! exists($nirspec_setup{$visit_id_hash})) {
									    $nirspec_setup{$visit_id_hash} = join(' ',$visit_id_hash,$nirspec_mode);
									}
									if($keyword eq 'Grating' || $keyword eq 'Filter' || 
									   $keyword eq 'ReadoutPattern' || $keyword eq 'Groups' || 
									   $keyword eq 'Integrations') {
									    $value =~ s/\s/_/g;
									    $nirspec_setup{$visit_id_hash} = join(' ',$nirspec_setup{$visit_id_hash},$value);
									}
									if($testing == 1) {
									print "\n Line ", __LINE__ ," visit_id_hash: $visit_id_hash , nirspec_setup : $nirspec_setup{$visit_id_hash}\n";
									}
									if($keyword eq 'Pointing' || $keyword eq 'NodPattern'){
									    $value =~ s/\s/_/g;
									    if(exists($nirspec_nod{$visit_id_hash})) {
										$nirspec_nod{$visit_id_hash} =  join('#',$nirspec_nod{$visit_id_hash},$value);
									    } else {
										$nirspec_nod{$visit_id_hash} = $value;
									    }
									}
								    } 
# Close NIRSpec block level 8; 
# Open NIRCam block level 8
								    if($instrument eq 'nrc') {
									if($keyword eq 'ShortFilter' || $keyword eq 'LongFilter' || 
									   $keyword eq 'ReadoutPattern' ||
									   $keyword eq 'Groups' || $keyword eq 'Integrations'){
									    $value =~ s/\s/_/g;
									    $observation_number = $visit_obs_num{$visit_id_hash};
									    if(exists($visit_setup{$visit_id_hash})) {
										$visit_setup{$visit_id_hash} = join(' ',$visit_setup{$visit_id_hash},$value);
										$visit_setup{$observation_number} = $visit_setup{$visit_id_hash}
									    } else {
										print "no visit_setup for $visit_id_hash\npause\n";
#										    <STDIN>;
									    }
									    if($testing == 1) {
									    print "at line : ",__LINE__, " visit_id_hash $visit_id_hash visit_setup  $visit_setup{$visit_id_hash}, observation_number: $observation_number\n";
									    }
#										<STDIN>;
									    
									}
								    }
# Close NIRcam block level 8
# Open NIRCam grism block level 8
#								    print "at line : ",__LINE__," key8 is $key8\n";
								    if($instrument eq 'ncwfss'){
									if($keyword eq 'DirectImage') {
									    $nircam_grism_mode = 'direct_imaging';
									}
									if($keyword eq 'GrismExposure') {
									    $nircam_grism_mode = 'spectrocopy';
									}
									print "at line : ",__LINE__," keyword is $keyword value is $value\n";
								    }
								} else {
#9999999999999999999999999999999999999999999999999999999999999999999999999999999999
								    my $ss = 0;
								    if($print_level9 == 1) {
									print "level9 at Line: ", __LINE__, " counter9 is $counter9 \n";
								    }
								    foreach my $key9 (@level9) {
									my @level10 = grep { $_->nodeType == XML_ELEMENT_NODE } $key9->childNodes;
									my $counter10 = @level10 ;
									$ss++;
									if($print_level9 == 1) {
									    print "level 9 at Line: ", __LINE__, "\n";
									    say 'key9 nodeName    : ', $key9->nodeName();
									    say 'key9 nodeType    : ', $key9->nodeType;
									    say 'key9 textContent : ', $key9->textContent;
									    say 'key9 toString    ; ', $key9->toString;
									}
									$keyword  = $key9->nodeName;
									$value    = $key9->textContent;
									my $instrument;
									if($keyword =~ m/ncwfss/) {
									    $instrument = 'ncwfss';
									    	if($testing ==1 || $debug >0){print "at line : ",__LINE__," keyword $keyword value $value\n";}
									}
									
									if($keyword =~ m/ncwfss/) {
#									    print "at line ",__LINE__," visit_id_hash is $visit_id_hash; keyword is $keyword value is $value nircam_grism_mode is $nircam_grism_mode\n";
									    $keyword =~ s/ncwfss://g;
									    if($keyword eq 'grism' ||
									       $keyword eq 'ShortFilter' || $keyword eq 'LongFilter' || 
									       $keyword eq 'ReadoutPattern' ||
									       $keyword eq 'Groups' || $keyword eq 'Integrations'){
										$value =~ s/\s/_/g;
										if(exists($grism{$visit_id_hash})) {
#										    $grism{$visit_id_hash} = join(' ',$grism{$visit_id_hash},$keyword.'='.$value);
										} else {
										    print "no grism for $visit_id_hash\npause\n";
#											    <STDIN>;
										}
#										print "at line ",__LINE__," $visit_id_hash:  $grism{$visit_id_hash} $observation_number\n";
									    }
#########################################################################
									}
								    }
								}
#							    print "pause key 8\n";
#							    <STDIN>;
							    }
							}
						    }
#				    print "pause key 7\n";
#				    <STDIN>;
						}
					    }
#				    print "pause key 6\n";
#				    <STDIN>;
					}
				    }
#				    print "pause key 5\n";
#				    <STDIN>;
				}
			    }
#			    print "pause key 4\n";
#			    <STDIN>;
			}
		    }
#		    print "pause key 3\n";
#		    <STDIN>;
		}
	    }
#	    print "pause key 2\n";
#	    <STDIN>;    	
#	    print " ",__LINE__," visit_orient $visit_orient{'01176361001'}\n";
}
	
#	print "pause key 1\n";
#	<STDIN>;
    }
#
#===========================================================================================================
#
#    foreach $visit_id_hash (sort(keys(%visit_orient))) {
#	$label = $visit_label{$visit_id_hash};
#	print "at line ",__LINE__," $visit_id_hash, $label, $visit_orient{$visit_id_hash}\n";
#    }

####################################
# added 2021-02-16
    foreach $visit_id_hash (sort(keys(%visit_content))) {
#	print "visit:  $visit_id_hash $visit_content{$visit_id_hash}\n";
	my(@junk) = split(' ',$visit_content{$visit_id_hash});
	$visit_orient{$visit_id_hash} = $junk[2];
    }
    $reader-> next;
}
print "\nread_apt_output.pl at line : ",__LINE__," finished reading XML\n\n";

#
##==========================================================================================================
#
# Now that all (or most) of the information for each visit's dithers have been
# gathered, output  into a format that can be read by guitarra
# This collates data coming from the XML file as well as the "pointing" and
# csv files output by APT
#

my @visit_setup_header = ('TargetID', 'OBSERVTN', 'PrimaryInstrument', 'ShortPupil', 'ShortFilter', 'LongPupil', 'LongFilter','ReadoutPattern','Groups','Nints');

my ($rows, $columns);
my ($jj);
##@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
##@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
##@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# guitarra input requires for each position from APT
# Relation between keywords:
#                            12345678901234567890123456
# OBS_ID   is                V80600013001P0000000002101
# VISIT_ID is OBS_ID[2-12] or 80600013001
# PROGRAM  is OBS_ID[2-6]  or 80600
# OBSERTVN is OBS_ID[7-9]  or      013
# VISIT    is OBS_ID[10-12] or        001
# P stands for Parallel. If this is a PRIME observation
# the next for digits are 0. If this is a PARALLEL
# 1-5 contain the primary  PROGRAM id
# 6-8 contain the primary  OBSERTVN id
# Not contained is the EXPOSURE number - this comes from the CSV file and
# is the last parameter for each entry in the %dithers  hash.
# target_number
# targprop
# targetArchiveName
# title
# label
# program
# category
# expripar
# ra
# dec
# pa_v3
# apername
# pattype 
# numdthpt (number of dither points)
# SubPixelDitherType 
# SUBPXPNS  (number of sub-pixel dithers)
# subarray
# visit_ID
# observation ?? Needs fixing for NIRCam prime
# primary instrument
# for each filter:
#   short filter (NIRCam)
#   long filter (NIRCam)
#   readout pattern
#   groups
#   nints
#   total number of dithers (i.e., telescope positions)
#
#  find which instrument is prime and which is parallel
#  
my($line);
foreach my $obs_folder (sort(keys(%visits))){
#    if($obs_folder ne 'FULLBOX_8NIRSpec_(Obs_1)') {next;}
    my $obs_num;
    ($junk, $obs_num)  = split('\(Obs\_',$obs_folder);
    $obs_num =~ s/\)//g;
    $observation_number = sprintf("%03d",$obs_num);
    my @array = split(' ',$visits{$obs_folder});
    for (my $vm= 0 ; $vm <= $#array; $vm++){
	$visit_n = $array[$vm];
	$visit_primary{$visit_n} = $instrument{$observation_number};
	if($coordinated_parallel{$observation_number} eq 'false') {
	    $visit_parallel{$visit_n} = 'none';
	} else {
	    $coordinated_parallel_set{$observation_number} =~ s/-/ /g;
	    my @junk = split(' ',$coordinated_parallel_set{$observation_number});
	    for(my $abc = 1; $abc<= $#junk; $abc++) {
		if(uc($junk[$abc]) =~ m/FGS/ ||
		   uc($junk[$abc]) =~ m/MIRI/ ||
		   uc($junk[$abc]) =~ m/NIRCAM/ ||
		   uc($junk[$abc]) =~ m/NIRISS/){
		    $parallel{$visit_n} = uc($junk[$abc]);
		    $visit_parallel{$visit_n} = uc($junk[$abc]);
		    last;
		}
	    }
	}
	if($visit_parallel{$visit_n} ne 'none'){
	    print  "at line : ",__LINE__," visit $visit_n primary $visit_primary{$visit_n} parallel $visit_parallel{$visit_n}\n";
	}
    }
}
#--
# output data for the full APT file ("complete") and individual visits
#
# rather than output by visit order, output by observation order
# as a single order may comprise several visits
# possible pitfalls : parameters (filters) change for different visits
#
my $one_liner = $results_path.sprintf("%05d",$proposal).'.cat';
open(APTCAT,">$one_liner") || die "cannot open $one_liner";
my $out1 = $results_path.join('_',sprintf("%05d",$proposal),'complete','params.dat');
open(OUT1, ">$out1") || die "cannot open $out1";
foreach my $obs_folder (sort(keys(%visits))){
#    if($obs_folder ne 'FULLBOX_8NIRSpec_(Obs_1)') {next;}
#    if($obs_folder ne 'WFSS_dither_check_SIR3-OTB_(Obs_20)') {next;}
    my $obs_num;
    ($junk, $obs_num)  = split('\(Obs\_',$obs_folder);
    $obs_num =~ s/\)//g;
    $observation_number = sprintf("%03d",$obs_num);
    (my $target_number,$targetname) = split(' ',$target_id{$observation_number});
    $coordinates{$observation_number} = $coordinates{$target_number};
    my @coords  = split('\,',$coordinates{$target_number});
    my $rahms   = sprintf("%02d:%02d:%07.4f",$coords[0],$coords[1],$coords[2]);
    my $decdms  = sprintf("%03d:%02d:%07.4f",$coords[3],$coords[4],$coords[5]);
    my $ra_obs  = dms_to_deg($rahms) * 15.0;
    my $dec_obs = dms_to_deg($decdms);
#
    if($testing == 1) {
	print "$target_id{$observation_number}, $target_number\n";
	print "obs_folder                     $obs_folder\n";
        print "label                          $label{$observation_number}\n";
	print "observation number             $observation_number\n";
	print "target_id                      $target_id{$observation_number}\n";
	print "target number                  $target_number\n";
	print "target name                    $targetname\n";
	print "visit(s)                       $visits{$obs_folder}\n";
	print "coordinates                    $coordinates{$observation_number}\n";
	print "coordinated_parallel           $coordinated_parallel{$observation_number}\n";
	print "observation_parameters         $observation_parameters{$observation_number}\n";
	print "pause at line ",__LINE__;
#	<STDIN>;
    }
    my @obs_par = split('\#',$observation_parameters{$observation_number});
    my $primary_instrument = $instrument{$observation_number};
    my $label              = $label{$observation_number};
    $label                 =~ s/#/nr./g;
    $targetid              = $target_id{$observation_number};
#
    my $archive_name;
    if(defined ($target_archive_name{$target_number})) {
	$archive_name       = $target_archive_name{$target_number};
    } else {
	$archive_name       = $targetname;
    }
#
    if($testing == 1) {
	if($coordinated_parallel{$observation_number} eq 'true') {
	    print "coordinated_parallel_set $coordinated_parallel_set{$observation_number}\n";
	}
    }
#
    my @array = split(' ',$visits{$obs_folder});
#
    for (my $vm= 0 ; $vm <= $#array; $vm++){
	my $grism_name;
	my $module;
	my $subarray;
	my $long_filter;
	my $long_pupil = 'CLEAR';
	my $short_filter;
	my $short_pupil = 'CLEAR';
	my $readout_pattern;
	my $ngroups;
	my $nints;
	my $primary_dither_type;
	my $primary_dithers;
	my $subpixel_dither_type;
	my $subpixel_dither;
	my @junk;
	my @setup;
	$parallel_instrument = 'NONE';
     	$visit_n = $array[$vm];
	$visit_n =~ s/\s//g;
# For grism debugging
#	if($visit_n =~ m/00766020001/) { 
#	} else {
#	    next;
#	}
#
#	if(exists($nircam_imaging{$visit_n})) {
#	    print "at line : ",__LINE__," NIRCam imaging : $visit_n: $nircam_imaging{$visit_n}\n";
#	}
#
# NIRCam GRISM
#
	if(exists($grism{$visit_n})) {
#	    print "at line : ",__LINE__," Grism : $visit_n: $grism{$visit_n}\n";
	    @junk = split(' ',$grism{$visit_n});
	    $short_pupil   = 'CLEAR';
	    $long_pupil    = $grism_name;
	    for(my $ll = 0 ; $ll <= $#junk; $ll++) {
		my($par, $var) = split('=',$junk[$ll]);
		if($par =~ m/Module/) {$module = $var};
		if($par =~ m/Subarray/) {$subarray = $var;}
		if($par =~ m/Grism/)  {
		    $long_pupil = $var;
		    $grism_name = $var;
		}
		if($par =~ m/PrimaryDitherType/) {$primary_dither_type = $var;}
		if($par =~ m/PrimaryDithers/)    {$primary_dithers = $var;}
		if($par =~ m/SubpixelPositions/) {$subpixel_dither = $var;}
		if($par =~ m/ShortFilter/){
		    $short_filter = $var;
		    if($var =~ m/\+/) {
			($short_pupil,$junk) = split('\+',$var);
		    }
		}
		if($par =~ m/LongFilter/){ $long_filter = $var;}
		if($par =~ m/ReadoutPattern/) {$readout_pattern = $var;}
		if($par =~ m/Groups/) {$ngroups = $var;}
		if($par =~ m/Integrations/) {$nints = $var;}
	    }
	}
# Data in %grism_spectroscopy already contained in %grism
#	if(exists($grism_spectroscopy{$visit_n})) {
#	    print "at line : ",__LINE__," spectroscopy        : $visit_n: $grism_spectroscopy{$visit_n}\n";
#	}
	if(exists($grism_imaging{$visit_n})) {
	    @junk = split(' ',$grism_imaging{$visit_n});
	    if($testing == 1) {
		print "at line : ",__LINE__," Grism direct imaging: $visit_n: $grism_imaging{$visit_n}\n";
	    }
	    for(my $ll = 0 ; $ll <= $#junk; $ll++) {
		my($par, $var) = split('=',$junk[$ll]);
		if($par =~ m/PrimaryDitherType/) {$primary_dither_type = $var;}
		if($par =~ m/PrimaryDithers/)    {$primary_dithers = $var;}
		if($par =~ m/SubpixelPositions/) {$subpixel_dither = $var;}
		if($par =~ m/ShortFilter/){
		    $short_filter = $var;
		    if($var =~ m/\+/) {
			($short_pupil,$junk) = split('\+',$var);
		    }
		}
		if($par =~ m/LongFilter/){ $long_filter = $var;}
		if($par =~ m/ReadoutPattern/) {$readout_pattern = $var;}
		if($par =~ m/Groups/) {$ngroups = $var;}
		if($par =~ m/Integrations/) {$nints = $var;}
	    }
	}
# end of NIRCam GRISM
#
#	$visit_number{$visit_n}= $obs_num;
	if( ! exists($visit_number{$visit_n})) {
	    print "\nread_apt_output.pl at line : ", __LINE__ ," ****no visit_number hash for visit $visit_n  -- using first visit's ($array[0]) setup data****\n";
	    $visit_reference{$visit_n} = $array[0];
	    $module{$visit_n}          = $module{$array[0]};
#	    <STDIN>;
	}
#
	if(! defined($visit_setup{$visit_n})) {
	    @setup = split(' ',  $visit_setup{$array[0]});
	    if($testing == 1) {print "at line : ",__LINE__," $array[0], $visit_setup{$array[0]},\n";}
	} else {
	    @setup = split(' ',  $visit_setup{$visit_n});
	}
	if($testing == 1) {
	    if(defined($visit_setup{$visit_n})) {
		print "at line : ",__LINE__," $visit_n, $visit_setup{$visit_n}\n";
	    }else {
		print "at line : ",__LINE__," $visit_n, visit_setup not defined\n";
	    }
	}
	my $target = $visit_n;
	my $pa_v3  = $visit_orient{$visit_n};
	my @telescope_moves = split('\#', $visit_content{$visit_n});
	my ($ra, $dec, $pa, $obs, $visit, $junk); 
	if($testing == 1) {
	    for(my $ii = 0 ; $ii <= $#telescope_moves ; $ii++) {
		print "at line : ",__LINE__," visit_n $visit_n $telescope_moves[$ii]\n"; 
		($ra, $dec, $pa, $obs, $visit, $junk, $aperture) = split(' ',$telescope_moves[$ii]);
	    }
	}
#
# verify that required parameters have been identified
#
#	
	my @dithers = split(' ',$dithers{$visit_n});
	my $ndithers = @dithers;
	if($testing == 1) {
	    print "at line : ",__LINE__," ndithers: $ndithers dithers: @dithers\n";
	}
#
# sorting out the parallel instrument
#
	if(!defined($primary_dither_type{$visit_n})) {
	    $primary_dither_type = $primary_dither_type{$observation_number};
	    $primary_dithers     = $primary_dithers{$observation_number};
	} else {
	    $primary_dither_type  = $primary_dither_type{$visit_n};
	    $primary_dithers      = $primary_dithers{$visit_n};
	    print "read_apt_output.pl at line : ",__LINE__," visit  : $visit_n primary_dither_type is $primary_dither_type,$primary_dithers\n";
	    print "primary_instrument : $primary_instrument\n";
	    if($primary_dithers eq '') {die;}
	}
	if(!defined($subpixel_dither_type{$visit_n})) {
	    $subpixel_dither_type = $subpixel_dither_type{$observation_number};
	    $subpixel_dither      = $subpixel_positions{$observation_number};
	} else {
	    $subpixel_dither_type = $subpixel_dither_type{$visit_n};
	    $subpixel_dither      = $subpixel_positions{$visit_n};
	}
#
# if this is a parallel observation the dither pattern may be determined
# by the prime instrument
#
	if(lc($primary_instrument) eq 'nircam') {
	    if($primary_dither_type eq 'NONE'){
		$primary_dithers = 0;
	    }
	} else {
	    if($coordinated_parallel{$observation_number} eq 'true') {
		$primary_dither_type = 'NONE';
		$primary_dithers = 0;
	    }
	}

	if($testing == 1) {
	    print "at line : ",__LINE__," $visit_n : $label: primary is $primary_instrument parallel: $coordinated_parallel{$observation_number}\n";
	}
	if(exists($coordinated_parallel_set{$observation_number})) { 
#	    print "at line ",__LINE__," coordinated parallel:\n$coordinated_parallel_set{$observation_number}\n";
#    print "\n";
	    if($primary_instrument eq 'NIRSPEC' || 
	       $primary_instrument eq 'MIRI'    ||
	       $primary_instrument eq 'NIRISS') {
		if($coordinated_parallel{$observation_number} eq 'false') {
	 	    print "at line ",__LINE__," visit $visit_n $cross_id{$visit_n} uses $primary_instrument and coordinated parallel is $coordinated_parallel{$observation_number}\n";
#		    <STDIN>;
#		    next ;
		} else {
		    $coordinated_parallel_set{$observation_number} =~ s/-/ /g;
		    my @junk = split(' ',$coordinated_parallel_set{$observation_number});
		    for(my $abc = 1; $abc<= $#junk; $abc++) {
			if(uc($junk[$abc]) =~ m/MIRI/ ||
			   uc($junk[$abc]) =~ m/NIRCAM/ ||
			   uc($junk[$abc]) =~ m/NIRISS/){
			    $parallel{$visit_n} = uc($junk[$abc]);
#		    print  "at line ",__LINE__," parallel for visit $visit_n is $parallel{$visit_n}\n";
			    $parallel_instrument = uc($junk[$abc]);
			    last;
			}
		    }
		    $primary_dither_type = $primary_instrument;
		    $primary_dithers     = 0;
		}
	    } else {
# NIRCam prime
		$coordinated_parallel_set{$observation_number} =~ s/-/ /g;
		my @junk = split(' ',$coordinated_parallel_set{$observation_number});
		for(my $abc = 0; $abc<= $#junk; $abc++) {
		    if(uc($junk[$abc]) =~ m/MIRI/ ||
		       uc($junk[$abc]) =~ m/NIRISS/){
			$parallel{$visit_n} = uc($junk[$abc]);
			$parallel_instrument = uc($junk[$abc]);
			last;
		    }
		}
		if($testing == 1) {
		    print  "at line ",__LINE__," parallel for visit $visit_n is $parallel{$visit_n}\n";
		}
	    }
	} else {
# no coordinated parallels
	    $parallel{$visit_n} ='NONE';
	    $parallel_instrument = 'NONE';
	}
	if(! defined($dithers{$visit_n})) {
	    print "at line ", __LINE__ ," dithers for visit $visit_n do not exist\n"; 
	    die;
	}
#
# Write to file read by Guitarra
#
# needs a cleaner way to store these values
	my @parameters;
	my @observation;
	push(@parameters, $target_number);
	my $targprop = $targetid;
	$targprop =~ s/\s/\_/g;
	push(@parameters, $targprop);
	$label = $visit_label{$visit_n};
	$label =~ s/#/nr./g;
#
# Kludge for proposal 1180
#
	if($targetname =~ m/TINYCAT/) {
	    my @junk = split('\(',$visit_label{$visit_n});
	    $targetname = $junk[0];	
	    chop $targetname;
	    $targetname =~ s/\//_/g;
#	print "at line ",__LINE__," targetname is $targetname visit_label is $visit_label{$visit_n}\n";
	    $parameters[1]= $targetname;
	    $parameters[2]= $targetname;
	}
#
# recover ra and dec of pointing;
# For the new MPA results ra and dec refer
# to the first NIRSpec dither
#
	if($primary_instrument eq 'MIRI') {
	    if ($parallel{$visit_n} eq 'NONE') {
#		print "at line : ",__LINE__," no parallel for MIRI\n";
#		<STDIN>;
#		next;
	    } else {
		my($ra_nrc, $dec_nrc) = translate_mirim_to_nircam($ra_obs, $dec_obs,$pa_v3);
		$ra  = $ra_nrc;
		$dec = $dec_nrc;
		$expripar = 'PARALLEL_COORDINATED';
#		print "at line : ",__LINE__," visit_n: $visit_n $miri_setup{$visit_n}\n";
	    }
	}
	if($primary_instrument eq 'NIRSPEC') {
	    if ($parallel{$visit_n} eq 'NONE') {
	    } else{
		my($ra_nrc, $dec_nrc) = translate_nirspec_to_nircam($ra_obs, $dec_obs,$pa_v3);
		$ra  = $ra_nrc;
		$dec = $dec_nrc;
		$expripar = 'PARALLEL_COORDINATED';
	    }
	}
#########################################
	my $out      = $results_path.join('_',$visit_n,$targetname,'params.dat');
	my $imagfile = $out;
	my $specfile = $results_path.join('_',$visit_n,$targetname,'spec_params.dat');
	print "read_apt_output.pl at line : ",__LINE__," visit_n: $visit_n ; writing $out : $visit_label{$visit_n}\n";
	if($testing == 1) {print "\n\nat line : ",__LINE__," opening file $out\n";}
	open(OUT, ">$out") || die "cannot open $out";
	$line = sprintf("%-20s %30s\n", 'Target_Number',$target_number);
	if($testing == 1) {print "at line : ",__LINE__," $line";}
	print OUT $line;
	print OUT1 $line;
#
	$line = sprintf("%-20s %30s\n", 'TARGPROP',$targprop);
	if($testing == 1) {print "at line : ",__LINE__," $line";}
	print OUT $line;
	print OUT1 $line;

#
	$line = sprintf("%-20s %30s\n", 'TargetArchiveName',$archive_name);
	if($testing == 1) {print "at line : ",__LINE__," $line";}
	print OUT $line;
	print OUT1 $line;
#
	$line = sprintf("%-20s %30s\n", 'TITLE',$proposal_title);
	if($testing == 1) {print "at line : ",__LINE__," $line";}
	print OUT $line;
	print OUT1 $line;
#
	$line = sprintf("%-20s %30s\n", 'Label',$label);
	if($testing == 1) {print "at line : ",__LINE__," $line";}
	print OUT $line;
	print OUT1 $line;
#
	$line = sprintf("%-20s %30s\n", 'PROGRAM',$proposal_id);
	if($testing == 1) {print "at line : ",__LINE__," $line";}
	print OUT $line;
	print OUT1 $line;
#
	$line = sprintf("%-20s %30s\n", 'CATEGORY',$proposal_category);
	if($testing == 1) {print "at line : ",__LINE__," $line";}
	print OUT $line;
	print OUT1 $line;
#
	$expripar = 'PRIME';
	$line = sprintf("%-20s %30s\n", 'EXPRIPAR',$expripar);
	if($testing == 1) {print "at line : ",__LINE__," $line";}
	print OUT $line;
	print OUT1 $line;
#
	if(exists($parallel{$visit_n})) {
	    $line = sprintf("%-20s %30s\n",'ParallelInstrument',$parallel{$visit_n});
	} else {
	    $line = sprintf("%-20s %30s\n",'ParallelInstrument','None');
	}
	if($testing == 1) {print "at line : ",__LINE__," $line";}
	print OUT $line;
	print OUT1 $line;
#
	$line = sprintf("%-20s %30.8f\n", 'RA',$ra_obs);
	if($testing == 1) {print "at line : ",__LINE__," $line";}
	print OUT $line;
	print OUT1 $line;
#
	$line = sprintf("%-20s %30.8f\n", 'Declination',$dec_obs);
	if($testing == 1) {print "at line : ",__LINE__," $line";}
	print OUT $line;
	print OUT1 $line;
	
	$line = sprintf("%-20s %30s\n",'PA_V3',$pa_v3);
	if($testing == 1) {print "at line : ",__LINE__," $line";}
	print OUT $line;
	print OUT1 $line;
	
	if(lc($primary_instrument) eq 'nircam') {
	    if(! exists($module{$visit_n})) {
		print "visit_n $visit_n has no module defined\n";
		die;
	    }
	    $line = sprintf("%-20s %30s\n",'MODULE',$module{$visit_n});
	    if($testing == 1) {print "at line : ",__LINE__," $line";}
	    print OUT $line;
	    print OUT1 $line;
	    (my $junk, $aperture)  = split(' ',$dithers_id{$visit_n});
	    if($module{$visit_n} eq 'A' && $aperture eq 'NRCALL_FULL') {
		$aperture = 'NRCAS_FULL';
	    }
	    if($module{$visit_n} eq 'B' && $aperture eq 'NRCALL_FULL') {
		$aperture = 'NRCBS_FULL';
	    }
	    $line = sprintf("%-20s %30s\n",'APERNAME',$aperture);
	    if($testing == 1) {print "at line : ",__LINE__," $line";}
	    print OUT $line;
	    print OUT1 $line;
#
#	    if(! defined($long_pupil)) {$long_pupil ='CLEAR';}
#	    $line = sprintf("%-20s %30s\n",'LongPupil',$long_pupil);
#	    if($testing == 1) {print "at line : ",__LINE__," $line";}
#	    print OUT $line;
#	    print OUT1 $line;
	}
#
# MIRI prime 
#
	if($primary_instrument eq 'MIRI') {
## Kludge
	    $subarray{$visit_n} = 'FULL';
##
	    if($parallel{$visit_n} eq 'NONE') {
		if(exists($primary_dither_type{$visit_n})) {
		    $primary_dither_type = $primary_dither_type{$visit_n};
		    print "at line : ",__LINE__," $primary_instrument $visit_n primary_dither_type is $primary_dither_type{$visit_n}\n" ;
		    @junk = split('-',$primary_dither_type{$visit_n});
		    $primary_dither_type = $primary_dither_type{$visit_n};
		    $primary_dithers = $junk[0];
		    $subpixel_dither_type = 'NONE';
		    $subpixel_dither      = 0;
		} else {
		    print "at line : ",__LINE__," $primary_instrument $visit_n primary_dither_type is undefined\n" ;
		    <STDIN>;
		}
	    } else {
		if($parallel{$visit_n} eq 'NIRCAM') {
		    if(exists($primary_dither_type{$visit_n})) {
			$primary_dither_type = $primary_dither_type{$visit_n};
			@junk = split('-',$primary_dither_type{$visit_n});
			$primary_dither_type = $primary_dither_type{$visit_n};
			$primary_dithers = $junk[0];
			$subpixel_dither_type = 'NONE';
			$subpixel_dither      = 0;
		    }
		} else {
		    print "this parallel for MIRI undefined:$parallel{$visit_n}\n";
			print "at line : ",__LINE__,"pause\n";
		    <STDIN>;
		    next;
		}
	    }
	}
############
# NIRSpec prime : NIRCam assumed as the parallel instrument
#
	if($primary_instrument eq 'NIRSPEC') {
	    if($testing == 1) {
		print "at line : ",__LINE__," visit_n is $visit_n, nirspec_setup is $nirspec_setup{$visit_n}\n";
	    }
	    my %mos_dithers=();
	    my @mos_subdither=();
	    my $number_of_nods = scalar (keys(%nirspec_nod));
	    my %nrs_prime;
	    foreach my $key (sort(keys(%visit_content))){
#		print "at line : ",__LINE__," key $key\n";
		if(uc($visit_primary{$key}) eq 'NIRSPEC') {
		    $nrs_prime{$key} = 'NIRSPEC';
		}
	    }
#
	    my $number_of_visits = scalar (keys(%nrs_prime));
	    my $visit_moves;
	    if($number_of_nods > 0 && $number_of_nods < $number_of_visits) {
		my @nods = sort(keys(%nirspec_nod));
		my @vis  = sort(keys(%visit_content));
		my $first = $vis[0];
		@junk = split('\#',$nirspec_nod{$first});
		$visit_moves  = scalar @junk;
		print "at line : ",__LINE__," number of nods: $number_of_nods != number of visits: $number_of_visits\n";
		print "at line : ",__LINE__," nods defined for @nods\n";
		print "at line : ",__LINE__," visits @vis\n";
		foreach my $key (sort(keys(%visit_content))) {
		    if(exists($nirspec_nod{$key})) {next;}
		    $nirspec_nod{$key} = $nirspec_nod{$first};
		}
	    }
	    if(defined($nirspec_nod{$visit_n})){ 
#		print "at line : ",__LINE__," nirspec_nod{$visit_n}: $nirspec_nod{$visit_n}\n";
		my @junk = split('\#', $nirspec_nod{$visit_n});
		$visit_moves = scalar(@junk)/2;
		for (my $jj = 0; $jj <= $#junk ; $jj=$jj+2) {
		    my $coords = $junk[$jj];
		    if(! exists($mos_dithers{$coords})) {
			$mos_dithers{$coords} = $coords;
		    }
		    push(@mos_subdither,$junk[$jj+1]);
		}
		$mos_data{$visit_n} = \@mos_subdither;
	    }
	    $subpixel_dither_type = $subpixel_dither_type{$visit_n};
	    $subpixel_dither      = $subpixel_positions{$visit_n};
	    if(defined($primary_dither_type{$visit_n})) {
		$primary_dither_type  = $primary_dither_type{$visit_n};
		$primary_dithers      = $primary_dithers{$visit_n};
	    } else {
		$primary_dither_type  = 'NIRSPEC';
		$primary_dithers      = 0;
		if(exists($visit_reference{$visit_n})) {
		    my $reference = $visit_reference{$visit_n};
		    my $mos_subdither_ref = $mos_data{$reference};
		    @mos_subdither =@$mos_subdither_ref;
		}
		$subpixel_dither_type = $mos_subdither[0];
		@junk                 = split('\_',$mos_subdither[0]);
		$subpixel_dither      = $junk[0];
#		$primary_dithers      = $visit_moves/$subpixel_dither;
		print "at line : ", __LINE__," $primary_dither_type,$primary_dithers,$subpixel_dither_type,$subpixel_dither mos_dither\n";
#		($junk, $primary_dithers, $subpixel_dither) = 
#		    split(' ',$pointings{$visit_label{$visit_n}});
#		print "at line : ",__LINE__," $pointings{$visit_label{$visit_n}}\n";
	    }

	    if(! defined($subpixel_dither_type)) {
		$subpixel_dither_type = 'NONE';
		$subpixel_dither      = 0;
	    }
#	    $primary_dithers = $visit_moves/$subpixel_positions{$visit_n};
	    if($testing == 1) {
		print "at line : ",__LINE__," visit_n: $visit_n, visit_moves: $visit_moves, primary_dither_type: $primary_dither_type, $primary_dithers: $primary_dithers,subpixel_dither_type: $subpixel_dither_type, subpixel_dither: $subpixel_dither}\n";
#		<STDIN>;
	    }
# NIRCam parallel to NIRSpec can be Module ='ALL' or Module ='B'
	    if(lc($parallel{$visit_n}) eq 'nircam') {
		if($module{$visit_n} eq 'B') {
		    $aperture =  'NRCBS_FULL';
		} else {
		    $aperture =  'NRCALL_FULL';
		}
#		print "at line : ",__LINE__," module is $module{$visit_n}; aperture is $aperture\n";
#		<STDIN>;
		$line = sprintf("%-20s %30s\n",'MODULE', $module{$visit_n});
		if($testing == 1) {print "at line : ",__LINE__," $line";}
		print OUT $line;
		print OUT1 $line;
#
		$line = sprintf("%-20s %30s\n",'APERNAME', 'NRCALL_FULL');
		if($testing == 1) {print "at line : ",__LINE__," $line";}
		print OUT $line;
		print OUT1 $line;
	    }
# MIRI; need to find what apertures are valid:	    
	    if(lc($parallel{$visit_n}) eq 'miri') {
		$line = sprintf("%-20s %30s\n",'APERNAME', 'MIRIM');
		if($testing == 1) {print "at line : ",__LINE__," $line";}
		print OUT $line;
		print OUT1 $line;
	    }
# NIRISS; need to find what apertures are valid:	    
	    if(lc($parallel{$visit_n}) eq 'niriss') {
		$line = sprintf("%-20s %30s\n",'APERNAME', 'NIRISS');
		if($testing == 1) {print "at line : ",__LINE__," $line";}
		print OUT $line;
		print OUT1 $line;
	    }
# NIRSpec solo
	    if(lc($parallel{$visit_n}) eq 'none') {
#		print "at line : ",__LINE__," visit_n: $visit_n, nirspec_setup: $nirspec_setup{$visit_n}\n";
		@junk = split(' ', $nirspec_setup{$visit_n});
		$nrs_aperture = $junk[1];
		$line = sprintf("%-20s %30s\n",'APERNAME', $nrs_aperture);
		print OUT $line;
		print OUT1 $line;
#
		$line = sprintf("%-20s %30s\n",'PATTTYPE', $primary_dither_type);
		if($testing == 1) {print "at line : ",__LINE__," $line";}
		print OUT $line;
		print OUT1 $line;
#
		$line = sprintf("%-20s %30s\n",'NUMDTHPT', $primary_dithers);
		if($testing == 1) {print "at line : ",__LINE__," $line";}
		print OUT $line;
		print OUT1 $line;
#
		$line = sprintf("%-20s %30s\n",'SubPixelDitherType',$subpixel_dither_type);
		if($testing == 1) {print "at line : ",__LINE__," $line";}
		print OUT $line;
		print OUT1 $line;
#
		$line = sprintf("%-20s %30s\n",'SUBPXPNS', $subpixel_dither);
		if($testing == 1) {print "at line : ",__LINE__," $line";}
		print OUT $line;
		print OUT1 $line;
	    }
	}
#
#########################################
#
# NIRCam observation using MOSAIC
#
# my @observation_header = ('Module','APERNAME','PATTTYPE','NUMDTHPT','SubPixelDitherType','SUBPXPNS');
#    print "at line ",__LINE__," $visit_n, $label, $primary_instrument, #observation $#observation, observation:@observation\n";
#    <STDIN>;
#	if($primary_instrument eq 'NIRCAM' && $#observation == 3) {
#	    $line = sprintf("%-20s %30s\n",$observation_header[1], $aperture);
#	    print "at line : ",__LINE__," $line";
#	    print OUT $line;
#	    print OUT1 $line;
#	    $jj = 2;
#	    $primary_dither_type   = 'MOSAIC';
#	    $line = sprintf("%-20s %30s\n",'PATTTYPE', $primary_dither_type);
#	    print "at line : ",__LINE__," $line";
#	    print OUT $line;
#	    print OUT1 $line;
#	    if(exists($visit_mosaic{$target})) {
#		($rows,$columns) = split(' ',$visit_mosaic{$target});
#	    }
#	    $primary_dithers       = $rows*$columns;
#	    $line = sprintf("%-20s %30s\n",'NUMDTHPT', $primary_dithers);
#	    print "at line : ",__LINE__," $line";
#	    print OUT $line;
#	    print OUT1 $line;
#	    $jj = 4;
#	    $subpixel_dither_type  = $observation[3];
#	    $line = sprintf("%-20s %30s\n",$observation_header[$jj], $subpixel_dither_type);
#	    print "at line : ",__LINE__," $line";
#	    print OUT $line;
#	    print OUT1 $line;
#	    my (@junk) = split('-',$subpixel_dither_type);
#	    $subpixel_dither = $junk[0];
#	    $line = sprintf("%-20s %30s\n",'SUBPXPNS', $subpixel_dither);
#	    print "at line : ",__LINE__," $line";
#	    print OUT $line;
#	    print OUT1 $line;
#	} 
#
# NIRCam observation using one of the packaged dither patterns
#
#	if($primary_instrument eq 'NIRCAM' && $#observation == 4) {
#	    $line = sprintf("%-20s %30s\n",$observation_header[1], $aperture);
#	    print "at line : ",__LINE__," $line";
#	    print OUT $line;
#	    print OUT1 $line;
##
#	    $primary_dither_type  = $observation[2];
#	    $primary_dithers      = 0;
#	    $subpixel_dither_type = $observation[4];
#	}
#	if($primary_instrument eq 'NIRCAM' && $#observation > 4) {
#	    $line = sprintf("%-20s %30s\n",$observation_header[1], $aperture);
#	    print "at line : ",__LINE__," $line";
#	    print OUT $line;
#	    print OUT1 $line;
##
#	    if($observation[2] eq 'INTRASCA') {
#		$primary_dither_type  = $observation[2];
#		$primary_dithers      = $observation[3];
#		$subpixel_dither_type = $observation[5];
#	    } else {
#		$primary_dither_type  = $observation[2];
#		$primary_dithers      = $observation[3];
#		$subpixel_dither_type = $observation[4];
#	    }
#	}
#
### This may need to be expanded for other cases as they occur.
##	
#	if($primary_instrument eq 'NIRCAM' && $#observation >= 4) {
#	    if($subpixel_dither_type eq 'IMAGING' || 
#	       $subpixel_dither_type eq 'STANDARD'){
#		$subpixel_dither = $subpixel_positions{$visit_n};
#	    } else {
#		my (@junk) = split('-',$subpixel_dither_type);
#		$subpixel_dither = $junk[0];
#	    }
#	}
#
####
#	if(exists($nircam_imaging{$visit_n})) {
#	    print "at line : ",__LINE__," NIRCam imaging    : $visit_n: $nircam_imaging{$visit_n}\n";
#	}
	if(exists($grism{$visit_n})) {
	    output_grism($testing,
			 $target_number, $targprop, $archive_name, $proposal_title, $label,
			 $proposal_id, $proposal_category, $expripar, $parallel_instrument, 
			 $ra_obs, $dec_obs, $pa_v3,$primary_instrument,
			 $observation_number, $visit_n,$aperture, \@dithers,
			 \%grism, \%grism_imaging, \%grism_spectroscopy, $sequence_ref, 
			 $exptype_ref, $imagfile, $specfile);
	} else {
	    $line = sprintf("%-20s %30s\n",'PATTTYPE', $primary_dither_type);
	    if($testing == 1) {print "at line : ",__LINE__," $line";}
	    print OUT $line;
	    print OUT1 $line;
#
	    $line = sprintf("%-20s %30s\n",'NMDTHPTS', $primary_dithers);
	    if($testing == 1) {print "at line : ",__LINE__," $line";}
	    print OUT $line;
	    print OUT1 $line;
#
	    if(! looks_like_number($primary_dithers)) {
		$value = substr($primary_dithers,0,1);
		$primary_dithers = $value ;
	    }
	    $line = sprintf("%-20s %30s\n",'NUMDTHPT', $primary_dithers);
	    if($testing == 1) {print "at line : ",__LINE__," $line";}
	    print OUT $line;
	    print OUT1 $line;
#
	    $line = sprintf("%-20s %30s\n",'SubPixelDitherType', $subpixel_dither_type);
	    if($testing == 1) {print "at line : ",__LINE__," $line";}
	    print OUT $line;
	    print OUT1 $line;
#
	    $line = sprintf("%-20s %30s\n",'SUBPXPNS', $subpixel_dither);
	    if($testing == 1) {print "at line : ",__LINE__," $line";}
	    print OUT $line;
	    print OUT1 $line;
# Subarray
	    if(lc($primary_instrument) eq 'nircam' || lc($parallel{$visit_n}) eq 'nircam') {
		$line = sprintf("%-20s %30s\n",'SUBARRAY', $subarray{$observation_number});
		if($testing == 1) {print "at line : ",__LINE__," $line";}
		print OUT $line;
		print OUT1 $line;
	    }
#
# Visit information :
# 'TargetID', 'OBSERVTN', 'PrimaryInstrument', 'ShortPupil','ShortFilter', 'LongPupil','LongFilter','ReadoutPattern','Groups','Nints');
#
	    $line = sprintf("%-20s %30s\n",'VISIT_ID', $visit_n);
	    if($testing == 1) {print "at line : ",__LINE__," $line";}
	    print OUT $line;
	    print OUT1 $line;
	    
	    $line = sprintf("%-20s %30s\n",'OBSERVTN', $observation_number);
	    if($testing == 1) {print "at line : ",__LINE__," $line";}
	    print OUT $line;
	    print OUT1 $line;
	    
	    $line = sprintf("%-20s %30s\n",'PrimaryInstrument', $primary_instrument);
	    if($testing == 1) {print "at line : ",__LINE__," $line";}
	    print OUT $line;
	    print OUT1 $line;
#
	    for (my $ii = 3 ; $ii <= $#setup ; $ii=$ii+5) {

		$short_filter     = $setup[$ii];
		$long_filter      = $setup[$ii+1];
		$readout_pattern  = $setup[$ii+2];
		$ngroups          = $setup[$ii+3];
		$nints            = $setup[$ii+4];
#
		$line = sprintf("%-20s %30s\n",'ShortPupil', $short_pupil);
		if($testing == 1) {print "at line : ",__LINE__," $line";}
		print OUT $line;
		print OUT1 $line;
#
		$line = sprintf("%-20s %30s\n",'ShortFilter', $short_filter);
		if($testing == 1) {print "at line : ",__LINE__," $line";}
		print OUT $line;
		print OUT1 $line;
#
		$line = sprintf("%-20s %30s\n",'LongPupil', $long_pupil);
		if($testing == 1) {print "at line : ",__LINE__," $line";}
		print OUT $line;
		print OUT1 $line;
#
		$line = sprintf("%-20s %30s\n",'LongFilter', $long_filter);
		if($testing == 1) {print "at line : ",__LINE__," $line";}
		print OUT $line;
		print OUT1 $line;
#
		$line = sprintf("%-20s %30s\n",'ReadoutPattern', $readout_pattern);
		if($testing == 1) {print "at line : ",__LINE__," $line";}
		print OUT $line;
		print OUT1 $line;
#
		$line = sprintf("%-20s %30s\n",'Groups', $ngroups);
		if($testing == 1) {print "at line : ",__LINE__," $line";}
		print OUT $line;
		print OUT1 $line;
#
		$line = sprintf("%-20s %30s\n",'Nints', $nints);
		if($testing == 1) {print "at line : ",__LINE__," $line";}
		print OUT $line;
		print OUT1 $line;
	    }
#
#  output individual dither positions; in the case of NIRSpec/MIRI prime translate
#  coordinates to NIRCam coordinates to create the simulated field
# 
	    $line = sprintf("%-20s %30d\n",'ndithers', $ndithers);
	    if($testing == 1) {print "at line : ",__LINE__," $line";}
	    print OUT $line;
	    print OUT1 $line;
	    
	    ($primary_dithers, my $line_ref) = 
		telescope_positions(\@dithers, $subpixel_dither,$primary_instrument, $parallel{$visit_n});
	    print "\nat line : ",__LINE__,"  :visit_moves $visit_moves{$visit_n}\n";
	    print "at line : ",__LINE__," $primary_instrument primary dither $primary_dithers, subpixel_dither $subpixel_dither, targetname $targetname\n";
	    my @lines = @$line_ref;
#
#  @moves contains data from pointings file which describe the observation sequence: 
#  $tar, $tile, $exposure, $subpixel_dither, $xoffset, $yoffset, $v2, $v3
#
	    my @moves = split('\#',$visit_moves{$visit_n});
	    for (my $ll = 0 ; $ll <= $#lines; $ll++) {
		$lines[$ll] =~ s/\n//g;
		if($testing == 1) {
		    print "at line : ",__LINE__," $lines[$ll] $moves[$ll]\n";
		}
		print OUT $lines[$ll], ' ',$moves[$ll],"\n";
		print OUT1 $lines[$ll],' ',$moves[$ll],"\n";
		my($ra_dither, $dec_dither, $pa_degrees, $large, $small) = 
		    split(' ', $lines[$ll]);
		my ($lw,$sw) = in_aperture($aperture);
		my $subsize = 2048;
		if($subarray{$observation_number} ne 'FULL') {
		    $subsize = $subarray{$observation_number};
		    $subsize =~ s/SUB//;
		    $subsize =~ s/P//;
		}
		my $apt_cat_line;
		if($sw == 1) {
		    $apt_cat_line = sprintf("%13.9f %12.8f %6.2f %3d %4d %-9s %-12s %-18s %-18s %-18s %s",$ra_dither, $dec_dither, $pa_degrees,$ngroups, $subsize, $readout_pattern, $short_filter,  $aperture, $visit_n, $subarray{$observation_number}, $label);
		    print APTCAT $apt_cat_line,"\n";
		}
		if($lw == 1) {
		    $apt_cat_line = sprintf("%13.9f %12.8f %6.2f %3d %4d %-9s %-12s %-18s %-18s %-18s %s",$ra_dither, $dec_dither, $pa_degrees,$ngroups, $subsize, $readout_pattern, $long_filter,  $aperture, $visit_n, $subarray{$observation_number}, $label);
		    print APTCAT $apt_cat_line,"\n";
		}
	    }
#	    <STDIN>;
	}
# close file associated to this visit
	close(OUT);
	if($testing == 1) {
	    print "at line ",__LINE__," close(OUT)\npause";
#	    <STDIN>;
	}
    }
}
# close file associated to the entire set of visits
close(OUT1);
close(APTCAT);
exit(0);
#
#------------------------------------------------------------------------------
#
sub telescope_positions{
    my($dithers_ref, $subpixel_dither, $primary_instrument, $parallel_instrument) = @_;
    my($primary_order, $subpixel_order, $ra_dither, $dec_dither, $pa_dither);
    my($line, $ll);
    my @lines =();
    my @dithers  = @$dithers_ref;
    for (my $ll = 0 ; $ll <= $#dithers; $ll++) {
	if($subpixel_dither > 0) {
	    $primary_order  = int($ll / int($subpixel_dither)) + 1;
	    $subpixel_order = ($ll % $subpixel_dither) + 1;
	} else {
	    $primary_order  = int($ll) + 1;
	    $subpixel_order = 0;
	}
	my($ra_dither, $dec_dither, $pa_dither) = split('_',$dithers[$ll]);
	if($primary_instrument eq 'NIRSPEC') {
	    my($ra_nrc, $dec_nrc) = translate_nirspec_to_nircam($ra_dither, $dec_dither,$pa_dither);
	    $ra_dither  = $ra_nrc;
	    $dec_dither = $dec_nrc;
	}
	if($primary_instrument eq 'MIRI') {
#	    print "at line : ", __LINE__," translate MIRI-> NIRCAM\n";
	    my($ra_nrc, $dec_nrc) = translate_mirim_to_nircam($ra_dither, $dec_dither,$pa_dither);
	    $ra_dither  = $ra_nrc;
	    $dec_dither = $dec_nrc;
	}
	$line = sprintf("%12.9f %12.9f %8.3f %2d %2d\n", $ra_dither, $dec_dither, $pa_dither, $primary_order, $subpixel_order);
	push(@lines, $line);
    }
    return($primary_order,\@lines);
}
#
#------------------------------------------------------------------------------
#
sub dms_to_deg{
    my($rahms) = @_ ;
    my( $irh, $irm, $rs) = split(':',$rahms) ;
    my( $ra) ;
    $ra = abs($irh) + ($irm/60.0) + ($rs/3600.0) ;
    if($rahms =~ m/-/){ $ra = -$ra;}
    return $ra ;
}
#    
#-------------------------------------------------------------------------------
#
sub initialise_instrument_info{    
    my %instrument_info = (Number                => '',
			   TargetName            => '',
			   TargetArchiveName     => '',
			   TargetID              => '',
			   Label                 => '',
			   Instrument            => '',
			   DitherType            => '',
			   ShortFilter           => '',
			   LongFilter            => '',
			   ReadoutPattern        => '',
			   Groups                => '',
			   Integrations          => '',
			   Module                => '',
			   Subarray              => '',
			   PrimaryDitherType     => '',
			   PrimaryDithers        => '',
			   SubpixelDitherType    => '',
#			   CoordinatedParallelSubpixelPositions => '',
			   EquatorialCoordinates => '',
			   ProposalId            => '',
			   VisitId               => '',
			   Observation           => '',
			   NumPointings          => ''
	);
    return \%instrument_info;
}
#-------------------------------------------------------------------
sub in_aperture{
    my($aperture) = @_;
    my $lw = 0;
    my $sw = 0;
    
    if($aperture =~ m/NRCALL/){
	$lw = 1;
	$sw = 1;
    }
    if($aperture =~ m/NRCA1/){
	$lw = 0;
	$sw = 1;
    }
    if($aperture =~ m/NRCA2/){
	$lw = 0;
	$sw = 1;
    }
    if($aperture =~ m/NRCA3/){
	$lw = 0;
	$sw = 1;
    }
    if($aperture =~ m/NRCA4/){
	$lw = 0;
	$sw = 1;
    }
#    
    if($aperture =~ m/NRCB1/){
	$lw = 0;
	$sw = 1;
    }
    if($aperture =~ m/NRCB2/){
	$lw = 0;
	$sw = 1;
    }
    if($aperture =~ m/NRCB3/){
	$lw = 0;
	$sw = 1;
    }
    if($aperture =~ m/NRCB4/){
	$lw = 0;
	$sw = 1;
    }
#
    if($aperture =~ m/NRCA5/){
	$lw = 1;
	$sw = 0;
    }
    if($aperture =~ m/NRCB5/){
	$lw = 1;
	$sw = 0;
    }
    return $lw, $sw;
}
