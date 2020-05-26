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
print "host is $host\nguitarra_home is $guitarra_home\n";
#
# Additional routines to read APT outputs
require $perl_dir.'get_apt_csv.pl';
require $perl_dir.'get_apt_pointing.pl';
# Translate coordinates from primary instrument into NIRCam coordinates
require $perl_dir.'translate_instruments.pl';


print "use is\nread_apt_output.pl proposal_number:\nread_apt_output.pl 1180\n";

my(@list, $xml_file, $pointings_file, $csv_file, $file);
my $prefix;
#
$prefix = $ARGV[0];
#$prefix = '1180_full_pa_41';
#$prefix = 'data_challenge2';
#$prefix = '1180_2020.1.2';
#$prefix = '1176';
#$prefix = '1180_pa_41';
#$prefix  = '1181_2019_04_23';
my ($proposal, $junk) = split('_',$prefix);
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

##########################################################################
#
# Debugging parameters for the XML file reading. The XML file has up to 9
# levels of nesting and this shows the level where some parameters are
# stored. The list is not exhaustive.
#
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
my($print_mi)     = 0;
my($print_msa)    = 0;
my($print_nsmos)  = 0;

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

# Define variables
#
my $reference_orientation;
my(%v3pa_reference);
#$v3pa_reference{'Deep_Pointing_1_Part_1_(Obs_7)'}  = 41.0;
#$v3pa_reference{'Deep_Pointing_3_Part_1_(Obs_13)'} = 46.0;
my(%v3pa);

my $auto_target;
my $expripar;
my $fixed_target_number;
my $hash_key;
my $info_ref;
my $keyword ;
# Name used in the Pointings file 
my $label;
my $mode_count = 0;
my $number;
my $number_pointings;
my $observation_number;
my $proposal_category;
my $proposal_id;
my $proposal_title;
my $obs_counter = 0;
my $some_number;
my $target_number; 
my $targetid;
my $targetname ;
my $value;
my $visit_counter = 0;
my $visit_id_hash;
my $visit_n ;
my $visit_par ;

my(@level4_parameters)      = ('TargetName','TargetArchiveName','TargetID','Epoch');
my(@level5_parameters)      = ('Instrument');
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
my %cross_id;
my %fixed_target_parameters;
my %nirspec_setup ;
my %orientation;
my %same_orientation;
my %subarray;
my %target_parameters;
my %target_observations;
#
my %visit_coords;
my %visit_id;
my %visit_label;
my %visit_label_inv;
my %visit_number;
my %visit_orient;
my %visit_orient_ref;
my %visit_setup;
my %subpixel_positions ;
my %visit_mosaic;
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
#
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
# at this point the visit_id has not been defined for most of the visits, thus use th
# label as identifier (here called "key")
#
		    if($key2->nodeName eq 'OrientFromLink' && $key1->nodeName eq 'LinkingRequirements') {
			my ($key, $rr);
			for ($rr =0 ; $rr <= $#orient_attributes;$rr++) {
			    $keyword = $orient_attributes[$rr];
			    $value   = $key2->getAttribute($keyword);
			    $value   =~ s/\s/\_/g;
			    $value =~ s/_Degrees//g;
# use primary observation as key
			    if($rr == 0) { 
				$key = $value;
				$orientation{$key} = $key;
			    } else {
				$orientation{$key} = join(' ',$orientation{$key},$value);
			    }
			    if($keyword eq 'OrientFromObs') {$visit_orient_ref{$key} = $value;}
#			    print "at ", __LINE__,"rr: $rr, key is $key, Orientation is $keyword, value is  $value\n";
			}
# This will only identify those visits that have a direct reference visit. Other visits may be linked to these
# under the "same orientation" case 
			
#			$visit_orient{$visit_id_hash}  = $orientation{$key};
#			print " ",__LINE__," visit_orient $visit_orient{'01176361001'}\n";
#			print "at line ",__LINE__," $visit_id_hash : key: $key; visit_orient: $orientation{$key}\n";
		    }

		    $keyword  = $key2->nodeName;
		    $value    = $key2->textContent;
		    $keyword  =~ s/nci://g;
#
# <VisitStatus>  contains the visit number (== observation_number; will go into FITS header)
# and number of pointings (i.e., dithers+sub-pixel dithers)
#
#<VisitStatus VisitId="01176111001" Status="IMPLEMENTATION" NumPointings="24"/>
		    if($keyword eq 'VisitStatus') {
			$visit_counter++;
			$keyword = 'VisitId';
			$value   = $key2->getAttribute($keyword);
			$hash_key = $value;
			$visit_id_hash = $value;
# observation number (order in APT)
			my $obs = sprintf("%d",substr($value,5,3));
# the reverse look-up: visit_id as function of observation number not unique...
			if(exists($visit_id{$obs})) {
			    print "at line ",__LINE__," for $value obs $obs visit_id $visit_id{$obs} exists\n";
			    print "using $visit_id{$obs}\n";
#			    $visit_id{$obs} = join(' ',$visit_id{$obs},$hash_key);
			} else {
			    $visit_id{$obs} = $hash_key;
			}
# number of dithers
			$keyword  = 'NumPointings';
			$value    = $key2->getAttribute($keyword);
#			print "line ", __LINE__," visit_id{$obs} is $visit_id_hash, ndithers : $value\n"; 
#			<STDIN>;
		    }
# end of visit ID + number of pointings
		} else {
# counter3 > 0
# Read keywords following <Target xsi:type="FixedTargetType" AutoGenerated="false"></Target>
#
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
#
			    foreach my $key4 (@level4) {
				$keyword  = $key4->nodeName;
# This value of "Number" refers to the observation number (and it may be non-unique)
				if($keyword eq 'Number') {
				    $number = $key4->textContent;
				    $visit_id_hash = $visit_id{$number};
				    my @items = split(' ',$visit_id_hash);
# Kludge in the case an observation has more than one visit - use the first one
				    if($#items > 0) { $visit_id_hash = $items[0];}
#				    print "at ",__LINE__," key is $key, keyword is ",$keyword,", value is ",$number,", visit_id is ",$visit_id{$number},"\n";
				}
# there are two instances of TargetID, one containing only the target name, the other observation number + target number
				if($keyword eq 'TargetID') {
				    $targetid = $key4->textContent;
				    $value    = $key4->textContent;
				    ($junk, $targetname) = split(' ',$value);
				    $target_parameters{$targetname} = join(' ',$number,$targetname);
				    if(! exists($visit_id{$number})) {
					print "number : $number;  visit_id{number} does not exist\n";
					die;
#				    } else {
#					print "number : $number;  $visit_id{$number}\n";
#					print "at ",__LINE__,"\n";
#					<STDIN>
				    }
				    $cross_id{$targetname} = $visit_id{$number};
				    $cross_id{$visit_id{$number}} = $targetname;
#				    print "at ",__LINE__," keys is $key, keyword ",$keyword,", junk is ",$junk,", targetname is ", $targetname,"\n";
				}
				if($keyword eq 'Label') {
				    $label  = $key4->textContent;
				    $value   = $key4->textContent;
				    $target_parameters{$targetname} = join(' ',$target_parameters{$targetname},$label);
				    $visit_id_hash = $cross_id{$targetname};
				    $visit_label{$visit_id_hash} = $label;
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
			    $same_orientation{$mode_count} = join(' ',$same_orientation{$mode_count},$visit_id_hash);
#			    print "at line: ", __LINE__, " visit_n is $visit_n, visit_id_hash is $visit_id_hash, label is $value, targetname is $targetname\n";
#			    die;
 			}
#
# first instance of NUMBER, which is "Target Number" in the
# "Fixed Targets" list of APT; 
# this will not be necessarily equivalent to the observation number;
# Need to use the TargetID as cross-identification reference
# 
			if($key3->nodeName eq 'Number') {
			    $keyword       = $key3->nodeName;
			    $value         = $key3->textContent;
			    $fixed_target_number = $value;
#			    print "line ", __LINE__ ," first instance of number: fixed_target_number is $fixed_target_number\n";
			}
			if($key3->nodeName eq 'TargetName') {
			    $keyword       = $key3->nodeName;
			    $targetname    = $key3->textContent;
#			    print "line ", __LINE__ ," fixed_target_number: $fixed_target_number, targetname is $targetname\n";
			    $fixed_target_parameters{$targetname} =$targetname
			}
			my(@level4_parameters)      = ('TargetName','TargetArchiveName','TargetID','Epoch');
			for (my $tt=1; $tt<= $#level4_parameters; $tt++) {
			    my $hash_value;
			    if($key3->nodeName eq $level4_parameters[$tt]) {
#				say '272 ',$key3->nodeName,' ',$key3->textContent,' ', $level4_parameters[$tt];
				$keyword  = $key3->nodeName;
				$value    = $key3->textContent;
				$value    =~ s/\s/_/g;
				$fixed_target_parameters{$targetname} = 
				    join(' ', $fixed_target_parameters{$targetname}, $value);
			    }
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
			    $fixed_target_parameters{$targetname} = join(' ',$fixed_target_parameters{$targetname},$value);
#			    print "line ", __LINE__ ," targetname ", $targetname," coordinates ", $value,"\n";
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
			    my ($nn) = 0;
# follow NIRSpec planner
			    foreach my $key4 (@level4) {
				my @level5 = grep { $_->nodeType == XML_ELEMENT_NODE } $key4->childNodes;
				my $counter5 = @level5 ;
				$nn++;
				if($print_level4 == 1) {
				    say 'level 5 #  counter5 is ',$counter5, ' kk ', $kk, ' ll ', $ll,' mm ',$mm, ' nn ', $nn, ": is an ", ref($key4), ', name = ', $key4->nodeName; 
				}
#
				if($print_level4 == 1) {
				    say __LINE__,' : key4 nodeName    : ', $key4->nodeName();
				    say 'key4 nodeType    : ', $key4->nodeType;
				    if ($key4->nodeName() =~ m/msa:CatalogAsCsv/) {next;}
				    say 'key4 textContent : ', $key4->textContent;
				    say 'key4 toString    ; ', $key4->toString;
				    print "\n";
				}
				$keyword  = $key4->nodeName;
				$value    = $key4->textContent;
#				print "at line ",__LINE__," $visit_id_hash, $keyword, $value\n";
				$keyword  =~ s/nci://g;
#
# Second instance of Number; here is the observation/visit number and number is consistent with that in visit_id
#
				if($keyword eq 'Number') {
				    $visit_n = $value;
				    $visit_setup{$visit_n} = $visit_n;
				    $visit_id_hash = $visit_id{$visit_n};
#				    print "at Line: ", __LINE__, " visit_n is $visit_n visit_id is $visit_id{$visit_n}\n";
#				    <STDIN>;
#
# with current version of APT, NIRSpec prime will not have these parameters set yet;
# this happens at level 8 
				    if(! exists($target_parameters{$visit_id_hash})){
#					print "at Line: ", __LINE__, " second instance of number is $value\n";
					$target_parameters{$visit_id_hash} = $visit_n;
#					die;
				    }
				}
# TargetID is a string containing  observation_number (actually catalogue number or something) + targetname
# could be unnecessary
				if($keyword eq 'TargetID') {
				    $targetid = $value;
				    ($some_number, $targetname) = split(' ',$value);
				    if(exists($visit_setup{$visit_id_hash})) {
					$visit_setup{$visit_id_hash} = join(' ',$visit_setup{$visit_id_hash}, $targetid);
				    } else {
					$visit_setup{$visit_id_hash} = $targetid;
				    }
				    $visit_number{$visit_id_hash}    = $visit_n;
				    $target_observations{$visit_id_hash} = '';
# 				    print "at line: ", __LINE__," TargetID is $targetid, visit_id_hash is $visit_id_hash, visit_n is $visit_n, targetname is $targetname\n";
#				    die
				}
# The Label keyword seems to be unique
				if($keyword eq 'Label') {
#				    $visit_id_hash = $visit_id{$visit_n};
				    $value =~ s/\s/_/g;
				    $label = $value.'_(Obs_'.$visit_n.')';
				    $visit_label{$visit_id_hash} = $label;
				    $visit_label_inv{$label} = $visit_id_hash;
#				    print "at line ",__LINE__," label is $label; visit_id_hash is $visit_id_hash; visit_n is $visit_n\n";
				}

				if($keyword eq 'Instrument') {
				    $visit_setup{$visit_id_hash} = join(' ',$visit_setup{$visit_id_hash}, $value);
#				    print "at line ", __LINE__," : keyword: $keyword, value is  $value, visit_id_hash is $visit_id_hash\n";
				}
				if($keyword eq 'CoordinatedParallel') {
				    $coordinated_parallel{$visit_id_hash} = $value;
#				    print "at line ", __LINE__," : keyword: $keyword, value is  $value, visit_id_hash is $visit_id_hash\n";
#				    <STDIN>;
				}
				if($counter5 >   0) {
# counter5 > 0
				    my ($oo) = 0;
				    foreach my $key5 (@level5) {
					my @level6 = grep { $_->nodeType == XML_ELEMENT_NODE } $key5->childNodes;
					my $counter6 = @level6 ;
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
					    $keyword =~ s/\s//g;
					    if($print_level5 == 1) {
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
#						print " ", __LINE__ ," visit_id_hash is $visit_id_hash, visit_n is $visit_n, keyword is $keyword, value is $value, label is $visit_label{$visit_id_hash} visit_orient is $visit_orient{$visit_id_hash} \n";
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
						if($print_level6 == 1 && $counter7 == 0) {
						    print "level 6 at Line: ", __LINE__, "\n";
						    say 'level 6 :  counter7 is ',$counter7,  ' pp ', $pp, ": is an ", ref($key6);
						    $keyword  = $key6->nodeName;
						    $value    = $key6->textContent;
						    print "keyword is $keyword\n";
						    print "value   is  $value\n";
						    print "visit_n  is  $visit_n\n";
						    print "target_id  is  $targetid\n";
						    print "visit_id   is $visit_id{$visit_n}\n";
						}
						if($keyword eq 'nsmos:Plan') {
						    my $visit_id = $visit_id{$visit_n};
						    $value =~ s/\s/_/g;
						    $value =~ s/Plan:_//g;
						    my $target_id = $targetid;
						    $target_id =~ s/\s/_/g;
						    $target_parameters{$visit_id} = join(' ', $visit_n,$value,$target_id);
#						    print "at line ",__LINE__," visit_id_hash is $visit_id_hash, visit_id is $visit_id, visit_n is $visit_n, targetid is $targetid, value is $value\n";
						}
						if($counter7 == 0) {
						    $keyword  = $key6->nodeName;
						    $value    = $key6->textContent;
						    if($keyword =~ m/msa/ && $print_msa == 0) {	next;}
						    if($keyword =~ m/nci/) {
							$keyword =~ s/nci://g;
						    } else {
							next;
						    }
						    $keyword =~ s/\s//g;
						    if($keyword =~ m/SubpixelPositions/) {
							$value    = $key6->textContent;
							$subpixel_positions{$visit_id_hash} = $value;
#							print "at line ",__LINE__," $visit_id_hash : SubpixelPositions is $value\n";
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
						    $target_observations{$visit_id_hash} = join(' ',$target_observations{$visit_id_hash}, $value);
						    if(lc($keyword) eq 'subarray'){
							$subarray{$visit_id_hash} = $key6->textContent;
						    }
						} else {
# level 7
						    my ($qq) = 0;
						    foreach my $key7 (@level7) {
							my @level8 = grep { $_->nodeType == XML_ELEMENT_NODE } $key7->childNodes;
							my $counter8 = @level8 ;
							$qq++;
							if($counter8 == 0) {
							    $keyword  = $key7->nodeName;
							    $value    = $key7->textContent;
							    if($keyword =~ m/nci/) {
								$keyword =~ s/nci://g;
							    }
							    $keyword =~ s/\s//g;
							    if($print_level7 == 1) {
								print "level7 at Line: ", __LINE__, "\n";
								say 'key7 nodeName    : ', $key7->nodeName();
								say 'key7 nodeType    : ', $key7->nodeType;
								say 'key7 textContent : ', $key7->textContent;
								say 'key7 toString    ; ', $key7->toString;
								print "keyword, value : $keyword $value\n";
								print "\n";
							    }
# 							    $visit_setup{$visit_id_hash} = join(' ',$visit_setup{$visit_id_hash},$value);
#
							    if($key7->nodeName() =~ m/ns:/){next;}
#							    if($key7->nodeName() =~ m/ns:shutters/){next;}
#							    if($key7->nodeName() =~ m/ns:slitlets/){next;}
#							    if($key7->nodeName() =~ m/ns:primaries/){next;}
#							    if($key7->nodeName() =~ m/ns:fillers/){next;}
							    if($key7->nodeName =~ m/mi:/ && $print_mi == 0) {next;}
							    if($key7->nodeName() !~ m/msa/){
								print "chabu at $key7->nodeName()\n";
								print "pause key 7\n";
#								<STDIN>;
							    }
							} else {
# Level 8
							    my($rr) = 0;
							    foreach my $key8 (@level8) {
								my @level9 = grep { $_->nodeType == XML_ELEMENT_NODE } $key8->childNodes;
								my $counter9 = @level9 ;
								$rr++;	
								if($print_level8 == 1 && $counter9 > 0) {
								    say 'level 8 :  counter9 is ',$counter9;
								    print " rr is  $rr,  ref is ref($key8)\n";
								    print "name is  $key8->nodeName\n";
								}
								if($key8->nodeName =~ m/mi:/    && $print_mi == 0) {next;}
#								if($key8->nodeName =~ m/nsmos:/ && $print_nsmos == 0) {next;}
#
# This is the nested level where values for filters, readout, groups are recovered
#
								if($counter9 == 0) {
								    $keyword  = $key8->nodeName;
								    $value    = $key8->textContent;
								    my $instrument = 'all';
								    if($keyword =~ m/nci/) {
									$keyword =~ s/nci://g;
									$instrument = 'nrc';
								    }
								    if($keyword =~ m/nsmos/) {
									$keyword =~ s/nsmos://g;
									$instrument = 'nrs';
								    }
								    $keyword =~ s/\s//g;
								    if($print_level8 == 1) {
									print "level 8 at Line: ", __LINE__, "\n";
									say 'key8 nodeName    : ', $key8->nodeName();
									say 'key8 nodeType    : ', $key8->nodeType;
									say 'key8 textContent : ', $key8->textContent;
									say 'key8 toString    ; ', $key8->toString;
#									print "at ",__LINE__," visit_n,keyword,value : $visit_n,$keyword, $value, visit_id_hash is $visit_id_hash\n";
								    }
								    if(lc($keyword) =~ m/pointing/) {
									if( exists($visit_coords{$visit_id_hash})) {
									    $visit_coords{$visit_id_hash}  = join('#',$visit_coords{$visit_id_hash},$key8->textContent);
									} else {
									    $visit_coords{$visit_id_hash}  = $key8->textContent;
									}
#									print "visit_id_hash is $visit_id_hash $visit_coords{$visit_id_hash}\n";
								    }
								    if($instrument eq 'nrs') {
									if (! exists($nirspec_setup{$visit_id_hash})) {
									    $nirspec_setup{$visit_id_hash} = $visit_id_hash;
									}
									if($keyword eq 'Grating' || $keyword eq 'Filter' || 
									   $keyword eq 'ReadoutPattern' ||
									   $keyword eq 'Groups' || $keyword eq 'Integrations' || 
									   $keyword eq 'Pointing' || $keyword eq 'NodPattern'){
									    $value =~ s/\s/_/g;
									    $nirspec_setup{$visit_id_hash} = join(' ',$nirspec_setup{$visit_id_hash},$value);
									}
#									print "\n Line ", __LINE__ ," visit_id_hash: $visit_id_hash , $visit_setup{$visit_id_hash}\n";
								    } else {
									if($instrument eq 'nrc') {
									    if($keyword eq 'ShortFilter' || $keyword eq 'LongFilter' || 
									       $keyword eq 'ReadoutPattern' ||
									       $keyword eq 'Groups' || $keyword eq 'Integrations'){
										$value =~ s/\s/_/g;
										if(exists($visit_setup{$visit_id_hash})) {
										    $visit_setup{$visit_id_hash} = join(' ',$visit_setup{$visit_id_hash},$value);
										} else {
										    print "no visit_setup for $visit_id_hash\npause\n";
										    <STDIN>;
										}
									    }
									}
								    }
								} else {
								    if($print_level9 == 1) {
									print "level9 at Line: ", __LINE__, " counter9 is $counter9 \n";
								    }
								}
							    }
#							    print "pause key 8\n";
#							    <STDIN>;
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

    my $reference;
    my %primary_offset;
#    print "\n\nat line ", __LINE__,": orient_range\n";
#    print "@orient_range\n";
#
# add offsets, when PA range of reference is known
#
    foreach $label (sort(keys(%orientation))) {
#	print "at line ",__LINE__," label $label, orientation: $orientation{$label}\n";
	$visit_id_hash  = $visit_label_inv{$label}; 
#	print "at line ",__LINE__," label : $label, visit_id_hash : $visit_id_hash\n";
	my(@junk) = split(' ',$orientation{$label});
	my $pa_min  = $junk[3];
	my $pa_max  = $junk[4];
	$pa_min    =~ s/_Degrees//g;
	$pa_max    =~ s/_Degrees//g;
#
	$reference = $junk[2];
	my $ref    = $visit_label_inv{$reference};
#	print "at line ",__LINE__," reference : $reference, ref : $ref\nat line ",__LINE__," visit_orient{$ref} is $visit_orient{$ref}\n";
	@junk   = split(' ',$visit_orient{$ref});
	my $ref_min = $junk[0];
	my $ref_max = $junk[1];
	$ref_min    =~ s/_Degrees//g;
	$ref_max    =~ s/_Degrees//g;
# add offsets
	my $npa_min = $ref_min + $pa_min;
	my $npa_max = $ref_max + $pa_max;
	$npa_min    = $npa_min.'_Degrees';
	$npa_max    = $npa_max.'_Degrees';
	$visit_orient{$visit_id_hash} = join(' ',$npa_min, $npa_max);
#	print "at line ",__LINE__," $label, $visit_id_hash, $pa_min, $pa_max, $visit_orient{$visit_id_hash} ref: $ref, visit_orient{ref} : $visit_orient{$ref}\n";
    }
#
    foreach $visit_id_hash (sort(keys(%visit_orient))) {
	$label = $visit_label{$visit_id_hash};
	$visit_orient{$visit_id_hash} =~ s/_Degrees//g;
	my ($npa_min, $npa_max)  = split(' ',$visit_orient{$visit_id_hash});
	if(looks_like_number($npa_min) && looks_like_number($npa_max)) {
	    $v3pa{$visit_id_hash} = ($npa_min+$npa_max)/2.0;
	} else {
	    $v3pa{$visit_id_hash} = 0.0;
	}
#	print "at line ",__LINE__," for visit: $visit_id_hash label: $label, visit_orient is $visit_orient{$visit_id_hash}; v3pa is $v3pa{$visit_id_hash} \n";
    }
#    die;
#
    foreach my $key (sort(keys(%orientation))){
	my @links  = split(' ', $orientation{$key});
#	print "key:  $key ; links: @links\n";
	my $primary   = $visit_label_inv{$links[0]};
	my $mode      = $links[1];
	$reference    = $visit_label_inv{$links[2]};
	my $dref_min  = $links[3];
	my $dref_max  = $links[3];
	$dref_min  =~ s/_Degrees//;
	$dref_max  =~ s/_Degrees//;
	my $offset = ($dref_min + $dref_max)/2;
	$primary_offset{$primary} = $offset;
	if( !exists($visit_label_inv{$links[0]})) {
	    print "visit_label_inv does not exist for links[0]:$links[0] ; links[2] is $links[2]\n";
	    print "at line ",__LINE__, " key: $key reference : $reference, primary: $primary, dref(min,max) : $dref_min, $dref_max\n";
	    die;
	}
    }

    my $min = $orient_range[0];
    $min =~ s/_Degrees//g;
    my $max = $orient_range[$#orient_range];
    $max =~ s/_Degrees//g;
    $reference_orientation  = ($min+$max)/2;
#    print "at line ",__LINE__," reference_orientation  is $reference_orientation\n";
    $v3pa_reference{$reference} = $reference_orientation;
    $v3pa{$reference} = $reference_orientation;
    $visit_id_hash = $visit_label_inv{$reference};
#    print "at line ",__LINE__," reference: $reference ,  reference_orientation :  $reference_orientation\n";
#    
# The orientation of several visits can be constrained in APT through the use of linking parameters
#
    foreach my $key (sort(keys(%same_orientation))) {
	my @junk = split(' ',$same_orientation{$key});
	my $mode    = $junk[0];
	my $primary = $junk[1];
	my $pa_v3;
	my $offset = 0;
	if(exists($primary_offset{$primary})) {
	    $offset = $primary_offset{$primary};
	} 
	print "primary is $primary mode is $mode  offset is $offset\n";
	for (my $ii = 1; $ii<= $#junk ; $ii++){
		$pa_v3 = $reference_orientation + $offset;
		$label = $visit_label{$junk[$ii]};
		$visit_id_hash = $junk[$ii];
		$v3pa{$junk[$ii]} = $pa_v3;
		$targetname = $cross_id{$visit_id_hash};
		$visit_orient{$visit_id_hash} = $v3pa{$junk[$ii]};
#		print "at line ",__LINE__," visit $junk[$ii] $v3pa{$junk[$ii]}, label is $label\n";
#		print "at line ",__LINE__," visit $visit_id_hash, targetname $targetname, label $label, primary is $junk[1], pa is $v3pa{$junk[$ii]}\n";
#		print "at line ",__LINE__," visit $visit_id_hash, v3pa is $v3pa{$junk[$ii]}, label is $label, targetname is $targetname,primary is $junk[1]\n";
	}
    }
#    die;
#
# Some observations may have no PA constraint; set to 0.0
#
    foreach $visit_id_hash (sort(keys(%visit_label))) {
	$label = $visit_label{$visit_id_hash};
	if(exists($visit_orient{$visit_id_hash})) {
	    print "at line ",__LINE__," visit_id_hash is $visit_id_hash label is $label, label_inv is $visit_id_hash; visit_orient is $visit_orient{$visit_id_hash}\n";
	} else {
	    print "at line ",__LINE__," visit_id_hash is $visit_id_hash label is $label, label_inv is $visit_id_hash; NO visit_orient\n";
	    $visit_orient{$visit_id_hash} = 0.0;
	    $v3pa{$visit_id_hash}         = 0.0;
	}
    }
    $reader-> next;
}
#
#==========================================================================================================
#
# Now that all (or most) of the information for each visit's dithers have been
# gathered, output  into a format that can be read by guitarra
# This collates data coming from the XML file as well as the "pointing" and
# csv files output by APT
#
print "read pointings\n";
my ($pointings_ref, $pa_ref) = get_apt_pointings($pointings_file);
my (%pointings)              = %$pointings_ref;
my (%pointings_pa)           = %$pa_ref;
#
# get dither positions from the csv file
#
print "read csv:$csv_file\n";
my ($dithers_id_ref, $dithers_ref) = get_apt_csv($csv_file);
my (%dithers_id) = %$dithers_id_ref;
my (%dithers)     = %$dithers_ref;
foreach my $key (keys(%dithers_id)){
    print "key of dithers_id is $key\n";
}
my $count_visit = 0;
foreach $visit_n (sort (keys (%visit_number))) {
    $count_visit++;
    print "visit_n $visit_n, count: $count_visit\n";
}
#print "pause\n";
#<STDIN>;
#
# Concatenate
#
my @parameter_header   = ('Target_number', 'TARGPROP','TargetArchiveName','TargetId','Epoch','Coordinates');
my @observation_header = ('Module','APERNAME','PATTTYPE','NUMDTHPT','SubPixelDitherType','SUBPXPNS');
my @visit_setup_header = ('TargetID', 'OBSERVTN', 'PrimaryInstrument', 'ShortFilter', 'LongFilter','ReadoutPattern','Groups','Nints');

my ($rows, $columns);
my ($jj);
#
# guitarra input requires for each position from APT
# Relation between keywords:
#                            12345678901234567890123456
# OBS_ID   is                V80600013001P0000000002101
# VISIT_ID is OBS_ID[2-12] or 80600013001
# PROGRAM  is OBS_ID[2-6]  or 80600
# OBSERTVN is OBS_ID[7-9]  or      013
# VISIT    is OBS_ID[10-12] or        001
#
#
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
# total number of dithers (i.e., telescope positions)
#
#--
# output data for the full APT file ("complete") and individual visits
#
my $out1 = $results_path.join('_',$proposal,'complete','params.dat');
open(OUT1, ">$out1") || die "cannot open $out1";
my($line);

foreach $visit_n (sort (keys (%visit_number))) {
    my $primary_dithers;
    my $primary_dither_type;
    my $subpixel_dither;
    my $subpixel_dither_type;
#
    my $target = $visit_n;
    my $pa     = $v3pa{$visit_n};
    if(exists($subpixel_positions{$visit_n})) {
	$subpixel_dither = $subpixel_positions{$visit_n};
    }
#
# verify that required parameters have been identified
#
    if( ! exists($visit_number{$visit_n})) {
	print "\nno visit_number for visit $visit_n at line ", __LINE__ ,"\n";
	die;
    }
    $targetname        = $cross_id{$visit_n};
    my $key =  $visit_label{$visit_n};
    my @parameters;
    if(exists( $fixed_target_parameters{$targetname})) {
	@parameters  = split(' ', $fixed_target_parameters{$targetname});
#	    print "at line ", __LINE__, " parameters: @parameters\n";
# targetname, TargetArchiveName, TargetId, Epoch, ra, dec
    } else {
#	    print "at line ", __LINE__, " fixed_target_parameters for visit_n $visit_n targetname $targetname do not exist\npause";
	@parameters = split(' ',$target_parameters{$visit_n});
	<STDIN>;
# visit_number, label, targetid
	if($#parameters == -1) {
	    print "target_parameters for visit_n $visit_n do not exist\n";
	    die ;
	} else {
	    print "for visit_id $visit_n, parameters array is\n@parameters\n";
	}
    }
    my @observation = split(' ', $target_observations{$visit_n});
    my $nobservation = @observation;    
#    print "at line ",__LINE__," visit_id : $visit_n label: $key, observation: $target_observations{$visit_n}\n# of parameters in observation array: $nobservation\n";
    if($#observation == -1) {
	print "at line ",__LINE__," visit $visit_n $cross_id{$visit_n} has no NIRCam\n";
#	    die ;
    }
    if(! exists($dithers{$visit_n})) {
	print "dithers for target - $target - visit_n - $visit_n - were not stored in hash \%dithers\n";
	die;
    }
    
    my @dithers = split(' ',$dithers{$visit_n});
    my $count = @dithers;
    my @setup = split(' ',  $visit_setup{$target});
    my $primary_instrument = $setup[2];
    my $label = $visit_label{$visit_n};
#    print "at line ",__LINE__," $visit_n : $label: primary is $primary_instrument parallel: $coordinated_parallel{$visit_n} \n";
    if($primary_instrument eq 'NIRSPEC' || 
       $primary_instrument eq 'MIRI'    ||
       $primary_instrument eq 'NIRISS') {
	if($coordinated_parallel{$visit_n} eq 'false') {
	    print "at line ",__LINE__," visit $visit_n $cross_id{$visit_n} uses $primary_instrument and coordinated parallel is $coordinated_parallel{$visit_n}\n";
	    next ;
	}
    }
    if(! defined($dithers{$visit_n})) {
	print "at line ", __LINE__ ,"dithers for visit $visit_n do not exist\n"; 
	die;
    }
#    print "at line ",__LINE__," visit $visit_n label $label primary_instrument $primary_instrument\n";
#
# Write to file read by Guitarra
#
# needs a cleaner way to store these values
    
    $observation_number = substr($visit_n,5,3);
    $setup[1] = $observation_number;
    
    ($junk, $target_number)  = split('Obs',$label);
    $target_number =~ s/\)//g;
    $target_number =~ s/\_//g;
    $parameters[0] = $target_number;
    
    my $targprop = $parameters[1];
    $targprop    =~ s/\//_/g;
    $parameters[1] = $targprop;
    $label = $visit_label{$visit_n};
#	my $out = $results_path.join('_',$proposal,$targetname,'params.dat');
    my $out = $results_path.join('_',$visit_n,$targetname,'params.dat');
    print "visit_n: $visit_n ; $visit_label{$visit_n} ; writing $out\n";
    open(OUT, ">$out") || die "cannot open $out";
    for (my $ii = 0 ; $ii <= 2 ; $ii++) {
	if (defined($parameters[$ii])){
	    $line = sprintf("%-20s %30s\n", $parameter_header[$ii],$parameters[$ii]);
	} else {
	    $line = sprintf("%-20s %30s\n", $parameter_header[$ii],'none');
	}
#	    print " at line ",__LINE__," ii is $ii, parameters[$ii] is $parameters[$ii], writing: $line\n";
	print OUT $line;
	print OUT1 $line;
    }
    $line = sprintf("%-20s %30s\n", 'TITLE',$proposal_title);
    print OUT $line;
    print OUT1 $line;
    $line = sprintf("%-20s %30s\n", 'Label',$label);
    print OUT $line;
    print OUT1 $line;
    $line = sprintf("%-20s %30s\n", 'PROGRAM',$proposal_id);
    print OUT $line;
    print OUT1 $line;
    $line = sprintf("%-20s %30s\n", 'CATEGORY',$proposal_category);
    print OUT $line;
    print OUT1 $line;
    my ($ra, $dec);
#
# recover ra and dec of pointing;
# For the new MPA results ra and dec refer
# to the first NIRSpec dither
#
    if($primary_instrument eq 'MIRI') {
	print "primary instrument is $primary_instrument\n";
	<STDIN>;
	next;
    }
    if($primary_instrument eq 'NIRSPEC') {
#	    my($ii) = 4;
#	    my($ii) = 3; # this changed for APT 2020.1.2
	my @stuff ;
# these are the parameters when NIRCam is prime
#	    if(defined($parameters[$ii])) {
#		print "ii, parameters, parameters[$ii]: $ii, @parameters, $parameters[$ii]\n";
#		@stuff = split(',',$parameters[$ii]);
#		die;
#	    } else {
# these are the parameters when NIRSpec prime
	my(@coords) = split('\#',$visit_coords{$visit_n});
	@stuff = split(' ',$coords[0] );
#	    }
	my $rahms  = sprintf("%02d:%02d:%07.4f",$stuff[0],$stuff[1],$stuff[2]);
	my $decdms = sprintf("%03d:%02d:%07.4f",$stuff[3],$stuff[4],$stuff[5]);
	$ra  = dms_to_deg($rahms) * 15.0;
	$dec = dms_to_deg($decdms);
	my($ra_nrc, $dec_nrc) = translate_nirspec_to_nircam($ra, $dec,$pa);
	$ra  = $ra_nrc;
	$dec = $dec_nrc;
	$expripar = 'PARALLEL_COORDINATED';
    }
#
    if($primary_instrument eq 'NIRCAM') {
# proposal 1180 has 4 parameters, 1176 3
#	    if($#parameters == 4) {
	my($ii) = $#parameters;
#	    }
#	    print "at line ",__LINE__," parameters [$ii]:  $parameters[$ii], @parameters\n";
	my @stuff = split(',',$parameters[$ii]);
	my $rahms  = join(':',$stuff[0],$stuff[1],$stuff[2]);
	my $decdms = join(':',$stuff[3],$stuff[4],$stuff[5]);
	$ra  = dms_to_deg($rahms) * 15.0;
	$dec = dms_to_deg($decdms);
	$expripar = 'PRIME';
    }
# indicate whether instrument is prime or parallel, centre coordinates, PA
    $line = sprintf("%-20s %30s\n", 'EXPRIPAR',$expripar);
    print OUT $line;
    print OUT1 $line;
    $line = sprintf("%-20s %30.8f\n", 'RA',$ra);
    print OUT $line;
    print OUT1 $line;
    $line = sprintf("%-20s %29.8f\n", 'Declination',$dec);
    print OUT $line;
    print OUT1 $line;
    $line = sprintf("%-20s %30s\n",'PA_V3',$v3pa{$visit_n});
#	print " at line ",__LINE__," visit_n is  $visit_n, visit_label{$visit_n} is $visit_label{$visit_n} : $line \n";
#	print "at line ",__LINE__," $visit_n,$label,$primary_instrument, $line \n";
    print OUT $line;
    print OUT1 $line;
    
    my ($junk, $aperture)  = split(' ',$dithers_id{$visit_n});
#
# NIRCam is the parallel instrument for NIRSpec observations
#
    if($primary_instrument eq 'NIRSPEC') {
	$primary_dither_type = 'NIRSPEC';
	$subpixel_dither_type = 'NIRSPEC';
	($primary_dithers, $subpixel_dither) = 
	    split(' ',$pointings{$visit_label{$visit_n}});
	$jj = 1;
	$line = sprintf("%-20s %30s\n",$observation_header[$jj], 'NRCALL_FULL');
	print OUT $line;
	print OUT1 $line;
#
	$line = sprintf("%-20s %30s\n",'PATTTYPE', 'NIRSPEC');
	print OUT $line;
	print OUT1 $line;
	$line = sprintf("%-20s %30s\n",'NUMDTHPT', $primary_dithers);
	print OUT $line;
	print OUT1 $line;
	$line = sprintf("%-20s %30s\n",'SubPixelDitherType', 'NIRSPEC');
	print OUT $line;
	print OUT1 $line;
	$line = sprintf("%-20s %30s\n",'SUBPXPNS', $subpixel_dither);
	print OUT $line;
	print OUT1 $line;
    }
#
# NIRCam observation using MOSAIC
#
#    print "at line ",__LINE__," $visit_n, $label, $primary_instrument, observation:@observation\n";
    if($primary_instrument eq 'NIRCAM' && $#observation == 3) {
	$line = sprintf("%-20s %30s\n",$observation_header[1], $aperture);
	print OUT $line;
	print OUT1 $line;
	$jj = 2;
	$primary_dither_type   = 'MOSAIC';
	$line = sprintf("%-20s %30s\n",'PATTTYPE', $primary_dither_type);
	print OUT $line;
	print OUT1 $line;
	if(exists($visit_mosaic{$target})) {
		($rows,$columns) = split(' ',$visit_mosaic{$target});
	}
	$primary_dithers       = $rows*$columns;
	$line = sprintf("%-20s %30s\n",'NUMDTHPT', $primary_dithers);
	print OUT $line;
	print OUT1 $line;
	$jj = 4;
	$subpixel_dither_type  = $observation[3];
	$line = sprintf("%-20s %30s\n",$observation_header[$jj], $subpixel_dither_type);
	print OUT $line;
	print OUT1 $line;
	my (@junk) = split('-',$subpixel_dither_type);
	$subpixel_dither = $junk[0];
	$line = sprintf("%-20s %30s\n",'SUBPXPNS', $subpixel_dither);
	print OUT $line;
	print OUT1 $line;
    } 
#
# NIRCam observation using one of the packaged dither patterns
#
    if($primary_instrument eq 'NIRCAM' && $#observation >= 4) {
	$line = sprintf("%-20s %30s\n",$observation_header[1], $aperture);
	print OUT $line;
	print OUT1 $line;
#
	$primary_dither_type  = $observation[2];
	$primary_dithers      = $observation[3];
	$subpixel_dither_type = $observation[4];
#
### This may need to be expanded for other cases as they occurr.
#
	if($subpixel_dither_type eq 'IMAGING' || 
	   $subpixel_dither_type eq 'STANDARD'){
	    $subpixel_dither = $subpixel_positions{$visit_n};
	} else {
	    my (@junk) = split('-',$subpixel_dither_type);
	    $subpixel_dither = $junk[0];
	}
#
	$jj = 2;
	$line = sprintf("%-20s %30s\n",'PATTTYPE', $primary_dither_type);
	print OUT $line;
	print OUT1 $line;
	$jj = 3;
	$line = sprintf("%-20s %30s\n",'NUMDTHPT', $primary_dithers);
	print OUT $line;
	print OUT1 $line;
	$jj = 4;
	$line = sprintf("%-20s %30s\n",$observation_header[$jj], $subpixel_dither_type);
	    print OUT $line;
	print OUT1 $line;
	$line = sprintf("%-20s %30s\n",'SUBPXPNS', $subpixel_dither);
	print OUT $line;
	print OUT1 $line;
    }
#
# Subarray
#
    $line = sprintf("%-20s %30s\n",'SUBARRAY', $subarray{$target});
    print OUT $line;
    print OUT1 $line;
#
# Visit information :
# 'TargetID', 'OBSERVTN', 'PrimaryInstrument', 'ShortFilter', 'LongFilter','ReadoutPattern','Groups','Nints');
#
    $line = sprintf("%-20s %30s\n",'VISIT_ID', $visit_n);
    print OUT $line;
    print OUT1 $line;
    $jj = 1;
    for (my $ii = 1 ; $ii <= $#setup ; $ii++) {
	if ($jj > $#visit_setup_header) {
	    $jj = 3;
	}
	$line = sprintf("%-20s %30s\n",$visit_setup_header[$jj], $setup[$ii]);
	print OUT $line;
	print OUT1 $line;
	$jj++;
    }
#
#  output individual dither positions; in the case of NIRSpec prime translate
#  coordinates to NIRCam coordinates to create the simulated field
# 
    $line = sprintf("%-20s %30d\n",'ndithers', $count);
    print OUT $line;
    print OUT1 $line;
    my ($primary_order, $subpixel_order);
    for (my $ll = 0 ; $ll <= $#dithers; $ll++) {
	$primary_order  = int($ll) / int($subpixel_dither) + 1;
	$subpixel_order = ($ll % $subpixel_dither) + 1;
	my($ra_dither, $dec_dither, $pa_dither) = split('_',$dithers[$ll]);
	if($primary_instrument eq 'NIRSPEC') {
	    my($ra_nrc, $dec_nrc) = translate_nirspec_to_nircam($ra_dither, $dec_dither,$pa_dither);
	    $ra_dither  = $ra_nrc;
	    $dec_dither = $dec_nrc;
	}
	$line = sprintf("%12.9f %12.9f %8.3f %2d %2d\n", $ra_dither, $dec_dither, $pa_dither, $primary_order, $subpixel_order);
	print OUT $line;
	print OUT1 $line;
    }
# close file associated to this visit
    close(OUT);
}
# close file associated to the entire set of visits
close(OUT1);
exit(0);
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
