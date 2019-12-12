#!/usr/bin/perl -w
#
# This script will read files output from APT using the "File->Export" tab:
# xml file
# Visit Coverage (NOT the Coverage to MAST one!)
# pointing file
#
# The script goes through these files and picks out the information needed
# as input to guitarra - namely - target ID, coordinates for individual 
# telescope moves, filters, number of groups and number of integrations at
# a fixed position. Some parameters that are used as JWST FITS keywords are
# also recovered. To run this requires having the LibXML library installed.
#
# The following web-site was critical in getting this to work and much
# of the code is adapted from this source:
# 
# https://grantm.github.io/perl-libxml-by-example/large-docs.html
#
#  cnaw@as.arizona.edu
#  2019-04-11
#

use XML::LibXML;
use XML::LibXML qw(:libxml);
use XML::LibXML::Reader;
use XML::LibXML::NodeList;

use 5.010;
use strict;
use warnings;
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

require $perl_dir.'get_apt_csv.pl';
require $perl_dir.'get_apt_pointing.pl';
require $perl_dir.'translate_instruments.pl';


print "use is\nread_apt_output.pl proposal_number:\nread_apt_output.pl 1180\n";

my(@list, $xml_file, $pointings_file, $csv_file, $file);
my $prefix;
$prefix = '1180_full_pa_41';
#$prefix = '1180_pa_41';
#$prefix  = '1181_2019_04_23';
my ($proposal, $junk) = split('_',$prefix);
#
# Get files that will be read
#
@list = `ls $guitarra_aux$prefix*.xml`;
for (my $ii = 0 ; $ii <= $#list ; $ii++) {
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

# 
# orientation for  observation 7, which is the reference
# This may be critical !
my(%v3pa_reference);
$v3pa_reference{'Deep_Pointing_1_Part_1_(Obs_7)'} = 41.0;
my(%v3pa);

##########################################################################
#
# Debugging parameters for the XML file reading. The XML file has several
# levels of nesting (9!) and this shows at what level which parameters are
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
my($print_mi)     = 0;
my($print_msa)    = 0;
my($print_nsmos)  = 0;
#
#############################################################################
#
# Define variables
#
my $expripar;
my $hash_key;
my $info_ref;
my $keyword ;
# Name used in the Pointings file 
my $label;
my $mode_count = 0;
my $number;
my $number_pointings;
my $proposal_category;
my $proposal_id;
my $proposal_title;
my $obs_counter = 0;
my $tag;
my $target_number; 
my $targetid;
my $targetname ;
my $value;
my $visit_counter = 0;
my $visit_n ;
my $visit_par ;

my(@level4_parameters)      = ('TargetName','TargetArchiveName','TargetID','Epoch');
my(@level5_parameters)      = ('Instrument');
# OrientFromObs: this Obs is the reference such that PA(primary) = PA(OrientFromObs) + MxxAngle:
my(@orient_attributes)      = ('PrimaryObs','Mode','OrientFromObs','MinAngle','MaxAngle');
my(@visitid) =();
my(@output)  = ();

my %array;
my %lengths;
my %orientation;
my %same_orientation;
my %pointing_label;
my %subarray;
my %target_cat;
my %target_parameters;
my %target_observations;
my %visit_cross_id;
my %visit_id;
my %visit_number;
my %visit_setup;
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
			say 'key2 textContent : ', $key2->textContent;
			say 'key2 toString    ; ', $key2->toString;
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
		    if($key2->nodeName eq 'OrientFromLink' && $key1->nodeName eq 'LinkingRequirements') {
			my ($key, $rr);
			for ($rr =0 ; $rr <= $#orient_attributes;$rr++) {
			    $keyword = $orient_attributes[$rr];
			    $value   = $key2->getAttribute($keyword);
			    $value   =~ s/\s/\_/g;
# use primary observation as key
			    if($rr == 0) { 
				$key = $value;
				$orientation{$key} = $key;
			    } else {
				$orientation{$key} = join(' ',$orientation{$key},$value);
			    }
#			    print "216 Orientation $keyword  $value\n";
			}
			print "$orientation{$key}\n";
		    }

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
#			say '214 ',$visit_counter,' ',$keyword, ' ', $key2->getAttribute($keyword) ,' ',$key2->getAttribute('NumPointings'); 
			$hash_key = $value;
			$keyword  = 'NumPointings';
			$value    = $key2->getAttribute($keyword);
			$visit_id{$visit_counter} = join(' ', $visit_counter,$hash_key,$value);
		    }
# end of visit ID + number of pointings
		} else {
# counter3 > 0
# Read keywords following <Target xsi:type="FixedTargetType" AutoGenerated="false"></Target>
#
		    my ($mm) = 0;
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
			if($key3->nodeName eq 'Observation' && $key1->nodeName eq 'LinkingRequirements') {
			    $obs_counter++;
			    $value   = $key3->textContent;
			    $value   =~ s/\s/_/g;
			    my $start = index($value,'Obs_');
			    my $junk  = substr($value,$start);
			    $junk =~ s/Obs_//g;
			    $junk =~ s/\)//g;
			    $visit_n = $junk;
			    $pointing_label{$visit_n} = $value;
			    $visit_cross_id{$visit_n} = $obs_counter;
			    $same_orientation{$mode_count} = join(' ',$same_orientation{$mode_count},$value);
#			    say '258 ', $mode_count,' ', $same_orientation{$mode_count};
#			    say '257: ',$key3->nodeName,' ',$key3->textContent,' ',$visit_n,' ',$obs_counter;
			}
#
# first instance of NUMBER, which is "Target Number" in the
# "Fixed Targets" of APT
# 
			if($key3->nodeName eq 'Number') {
			    $keyword       = $key3->nodeName;
			    $value         = $key3->textContent;
			    $target_number = $value;
 			    $target_parameters{$target_number} = $target_number;
			}
			if($key3->nodeName eq 'TargetName') {
#			    print "$key3->nodeName at level3\n";
			    $keyword       = $key3->nodeName;
			    $value        = $key3->textContent;
			    $targetname   = $value;
#			    $target_parameters{$target_number} = $value;
			    $target_cat{$value}         = $target_number;
			}
#    my(@level4_parameters)      = ('TargetName','TargetArchiveName','TargetID','Epoch');
			for (my $tt=0; $tt<= $#level4_parameters; $tt++) {
			    if($key3->nodeName eq $level4_parameters[$tt]) {
#				say '272 ',$key3->nodeName,' ',$key3->textContent,' ', $level4_parameters[$tt];
				$keyword  = $key3->nodeName;
				$value    = $key3->textContent;
				$value    =~ s/\s/_/g;
				$target_parameters{$target_number} = 
				    join(' ', $target_parameters{$target_number}, $value);
#				print "278: target_number: $target_number $target_parameters{$target_number}\n";
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
			    $target_parameters{$target_number} = 
				join(' ', $target_parameters{$target_number}, $value);
			}
			if($print_level4 == 1) {
			    say 'key3 nodeName    : ', $key3->nodeName();
			    say 'key3 nodeType    : ', $key3->nodeType;
			    say 'key3 textContent : ', $key3->textContent;
			    say 'key3 toString    ; ', $key3->toString;
			    print "\n";
			}
			$keyword  = $key3->nodeName;
			$value    = $key3->textContent;
			$keyword  =~ s/nci://g;
			$value    =~ s/\s/\_/g;
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
				    say '344: key4 nodeName    : ', $key4->nodeName();
				    say 'key4 nodeType    : ', $key4->nodeType;
				    say 'key4 textContent : ', $key4->textContent;
				    say 'key4 toString    ; ', $key4->toString;
				    print "\n";
				}
				$keyword  = $key4->nodeName;
				$value    = $key4->textContent;
				$keyword  =~ s/nci://g;
#
# Second instance of Number which here is the observation/visit number
#
				if($key4->nodeName eq 'Number') {
				    $visit_n = $value;
				    $visit_setup{$visit_n} = $value;
				}
				
				if($keyword eq 'TargetID') {
				    $targetid = $value;
				    my(@stuff) = split(' ',$targetid);
				    my($line) = $stuff[1];
				    for(my($xx) = 2 ; $xx < $#stuff;$xx++){
					$line = join('_',$line,$stuff[$xx]);
				    }		
				    $tag      = $line;
				    $visit_setup{$visit_n} = join(' ',$visit_setup{$visit_n}, $line);
				    $visit_number{$tag} = $visit_n;
				    $target_observations{$tag} = '';
				    $visit_setup{$tag} = $tag.' '.$visit_n;
				}
				if($keyword eq 'Instrument') {
				    $visit_setup{$tag} = join(' ',$visit_setup{$tag}, $value);
#					print "359: keyword: $keyword value: $value tag: $tag targetid : $targetid\n";
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
					    if($key5->nodeName() eq 'Rows') {
#						print "tag is $tag\n";
#						say 'key5 nodeName    : ', $key5->nodeName();
#						say 'key5 nodeType    : ', $key5->nodeType;
#						say 'key5 textContent : ', $key5->textContent;
#						say 'key5 toString    ; ', $key5->toString;
#						print "keyword, value : $keyword $value\n";
#						print "\n";
						if(exists($visit_mosaic{$targetid})) {
						    $visit_mosaic{$tag} = join(' ',$visit_mosaic{$tag},$value);
						} else {
						    $visit_mosaic{$tag} = $value;
						}
					    }
					    if($key5->nodeName() eq 'Columns') {
#						print "tag is $tag\n";
#						say 'key5 nodeName    : ', $key5->nodeName();
#						say 'key5 nodeType    : ', $key5->nodeType;
#						say 'key5 textContent : ', $key5->textContent;
#						say 'key5 toString    ; ', $key5->toString;
#						print "keyword, value : $keyword $value\n";
#						print "\n";
						if(exists($visit_mosaic{$tag})) {
						    $visit_mosaic{$tag} = join(' ',$visit_mosaic{$tag}, $value);
#						    print "$tag  $visit_mosaic{$tag}\n";
						} else {
						    $visit_mosaic{$tag} =$value;
						}
					    }


# these are mostly Mosaic-related keywords					    
					    if(exists($instrument_info{$keyword})) {
						$visit_setup{$tag} = join(' ',$visit_setup{$tag},$value);
					    }
					} else {
					    my ($pp) = 0;
					    foreach my $key6 (@level6) {
						my @level7 = grep { $_->nodeType == XML_ELEMENT_NODE } $key6->childNodes;
						my $counter7 = @level7 ;
						$pp++;
#						if($key6->nodeName =~ m/msa:id/) {
#						    say '410 ',$key6->nodeName,' ' ,$key6->textContent;
#						}
#						if($key6->nodeName =~ m/msa:AperturePositionAngle/) {
#						    say '413 ',$key6->nodeName,' ' ,$key6->textContent;
#						}
						if($key6->nodeName =~ m/msa:/ && $print_msa == 0) {next;}
						if($print_level6 == 1) {
						    say 'level 7 :  counter7 is ',$counter7,  ' pp ', $pp, ": is an ", ref($key6), ', name = ', $key6->nodeName;
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
							next;
#							$keyword = 'SubpixelDitherType';
						    }
						    if($print_level6 == 1) {
							say 'key6 nodeName    : ', $key6->nodeName();
							say 'key6 nodeType    : ', $key6->nodeType;
							say 'key6 textContent : ', $key6->textContent;
							say 'key6 toString    ; ', $key6->toString;
							print "keyword, value : $keyword $value\n";
							print "570 : tag is $tag\n";
							print "\n";

						    }
						    $target_observations{$tag} = join(' ',$target_observations{$tag}, $value);
#						    print "573: $keyword $value\n";
						    if(lc($keyword) eq 'subarray'){
							$subarray{$tag} = $key6->textContent;
#							print "$tag $subarray{$tag}\n";
						    }
						} else {
# level 8
						    
						    my ($qq) = 0;
						    foreach my $key7 (@level7) {
							my @level8 = grep { $_->nodeType == XML_ELEMENT_NODE } $key7->childNodes;
							my $counter8 = @level8 ;
							$qq++;
							if($key7->nodeName =~ m/mi:/ && $print_mi == 0) {next;}
							if($print_level8 == 1) {
							    say 'level 8 :  counter8 is ',$counter8,  ' qq ', $qq, ": is an ", ref($key7), ', name = ', $key7->nodeName;
							}
							if($counter8 == 0) {
							    $keyword  = $key7->nodeName;
							    $value    = $key7->textContent;
							    if($keyword =~ m/nci/) {
								$keyword =~ s/nci://g;
							    }
							    $keyword =~ s/\s//g;
							    if($print_level8 == 1) {
								say 'key7 nodeName    : ', $key7->nodeName();
								say 'key7 nodeType    : ', $key7->nodeType;
								say 'key7 textContent : ', $key7->textContent;
								say 'key7 toString    ; ', $key7->toString;
								print "keyword, value : $keyword $value\n";
								print "\n";
							    }
							    $visit_setup{$tag} = join(' ',$visit_setup{$tag},$value);
#
							    if($key7->nodeName() !~ m/msa/){
								print "chabu at $key7->nodeName()\n";
								print "pause key 7\n";
								<STDIN>;
							    }
							}
							my($rr) = 0;
							foreach my $key8 (@level8) {
							    my @level9 = grep { $_->nodeType == XML_ELEMENT_NODE } $key8->childNodes;
							    my $counter9 = @level9 ;
							    $rr++;
							    if($key8->nodeName =~ m/mi:/    && $print_mi == 0) {next;}
							    if($key8->nodeName =~ m/nsmos:/ && $print_nsmos == 0) {next;}
							    if($print_level9 == 1) {
								say 'level 9 :  counter9 is ',$counter9,  ' rr ', $rr, ": is an ", ref($key8), ', name = ', $key8->nodeName;
							    }
#
# This is the nested level where values for filters, readout, groups are recovered
#
							    if($counter9 == 0) {
								$keyword  = $key8->nodeName;
								$value    = $key8->textContent;
								if($keyword =~ m/nci/) {
								    $keyword =~ s/nci://g;
								}
								$keyword =~ s/\s//g;
								if($print_level9 == 1) {
								    say 'key8 nodeName    : ', $key8->nodeName();
								    say 'key8 nodeType    : ', $key8->nodeType;
								    say 'key8 textContent : ', $key8->textContent;
								    say 'key8 toString    ; ', $key8->toString;
								    print "visit_n, keyword, value : $visit_n,$keyword $value\n";
								    print "tag is $tag\n";
								}
								
								$visit_setup{$tag} = join(' ',$visit_setup{$tag},$value);
#								print "479  tag $tag keyword  $keyword value $value visit_setup\n$visit_setup{$tag}\n";
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
	}
	
#	print "pause key 1\n";
#	<STDIN>;
    }
#
#===========================================================================================================
#
#    print "\n\nsame orientation\n";
    foreach my $key (sort(keys(%same_orientation))) {
	my(@junk) = split(' ',$same_orientation{$key});
	my $primary = $junk[1];
	if(exists($orientation{$primary})) {
	    print "** $orientation{$primary}\n";
	    my ($this_image, $mode, $reference, $offset) = split(' ',$orientation{$primary});
#	    print "primary $this_image\nmode  $mode\nreference $reference\noffset $offset\n";
	    $offset =~ s/_Degrees//g;
	    for (my $ll = 0 ; $ll <= $#junk ; $ll++) {
		$v3pa{$junk[$ll]} = $v3pa_reference{$reference} + $offset;
		print"$junk[$ll] : $v3pa{$junk[$ll]}\n"; 
	    }
	    
	} else {
	    print "\n$key $same_orientation{$key}\nprimary: orientation missing\n";
	    for (my $ll = 0 ; $ll <= $#junk ; $ll++) {
		$v3pa{$junk[$ll]} =  $v3pa_reference{'Deep_Pointing_1_Part_1_(Obs_7)'};
		print"$junk[$ll] : $v3pa{$junk[$ll]}\n"; 
	    }
	}
    }
#
#==========================================================================================================
# get info from pointings file, mainly shifts due to dithers and
# sub-pixel dithers
#
    print "read pointings\n";
    my ($pointings_ref, $pa_ref) =get_apt_pointings($pointings_file);
    my (%pointings)              = %$pointings_ref;
    my (%pointings_pa)           = %$pa_ref;
#
# get dither positions from the csv file
#
    print "read csv\n";
    my ($dithers_id_ref, $dithers_ref) = get_apt_csv($csv_file);
    my (%dithers_id) = %$dithers_id_ref;
#   foreach my $key (keys(%dithers_id)){
#	print "key is $key $dithers_id{$key}\n";
#    }
#    die;
    my (%dithers)     = %$dithers_ref;
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
# targetid
# targetname
# visit_number ( == observation number)
# ra
# dec
# pa
# aperture
# subarray
# filter
# readout mode
# groups
# primary dither type
# number of primary move
# number of primary dithers
# index of subpixel move
# number of subpixel dithers
# nints
#
    my $out1 = $results_path.join('_',$proposal,'complete','params.dat');
    open(OUT1, ">$out1") || die "cannot open $out1";
    my($line);
    foreach my $target (sort (keys (%visit_number))) {
        my $primary_dithers;
	my $primary_dither_type;
	my $subpixel_dither;
	my $subpixel_dither_type;
#
	$visit_n           = $visit_number{$target};
	$target_number     = $target_cat{$target};
	my $cross_id       = $visit_cross_id{$visit_n};

	my $key =  $pointing_label{$visit_n};
		
	print "\ntarget: $target\ntarget_number: $target_number\nvisit: $visit_n\npointing_label: $pointing_label{$visit_n}\ncross_id:$cross_id\nvisit_id $visit_id{$cross_id}\n";

	my @visit_stuff = split(' ',  $visit_id{$cross_id});
	my @parameters  = split(' ', $target_parameters{$target_number});
	my @observation = split(' ', $target_observations{$target});
	print "observation : @observation\n";
	print "target : $target\n";
	print "dithers{$target} : $dithers{$target}\n";

	my @dithers = split(' ',$dithers{$target});
	my $count = @dithers;
	my @setup = split(' ',  $visit_setup{$target});
	my $primary_instrument = $setup[2];
	$label = $pointing_label{$visit_n};
	my $pa = $v3pa{$pointing_label{$visit_n}};
	print "primary_instrument $primary_instrument pa  $pa\n";
	print "@parameters\n";
	if(! defined($dithers{$target})) {
	    die;
	    print "pause";
	    <STDIN>;
	}
#
# Write to file read by Guitarra
#
	my $out = $results_path.join('_',$proposal,$target,'params.dat');
	print "writing $out for :";
	open(OUT, ">$out") || die "cannot open $out";
	for (my $ii = 0 ; $ii <= 2 ; $ii++) {
	    $line = sprintf("%-20s %30s\n", $parameter_header[$ii],$parameters[$ii]);
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
	if($primary_instrument eq 'NIRSPEC') {
	    my($ii) = 4;
	    my @stuff = split(',',$parameters[$ii]);
	    my $rahms  = join(':',$stuff[0],$stuff[1],$stuff[2]);
	    my $decdms = join(':',$stuff[3],$stuff[4],$stuff[5]);
	    $ra  = dms_to_deg($rahms) * 15.0;
	    $dec = dms_to_deg($decdms);
	    my($ra_nrc, $dec_nrc) = translate_nirspec_to_nircam($ra, $dec,$pa);
#	    print "\n\nNS NRC $ra, $dec, $ra_nrc, $dec_nrc\n";
	    $ra  = $ra_nrc;
	    $dec = $dec_nrc;
	    $expripar = 'PARALLEL_COORDINATED';
	}
	if($primary_instrument eq 'NIRCAM') {
	    my($ii) = 5;
	    my @stuff = split(',',$parameters[$ii]);
	    my $rahms  = join(':',$stuff[0],$stuff[1],$stuff[2]);
	    my $decdms = join(':',$stuff[3],$stuff[4],$stuff[5]);
	    $ra  = dms_to_deg($rahms) * 15.0;
	    $dec = dms_to_deg($decdms);
	    $expripar = 'PRIME';
	}
	$line = sprintf("%-20s %30s\n", 'EXPRIPAR',$expripar);
	print OUT $line;
	print OUT1 $line;
	$line = sprintf("%-20s %30.8f\n", 'RA',$ra);
	print OUT $line;
	print OUT1 $line;
	$line = sprintf("%-20s %29.8f\n", 'Declination',$dec);
	print OUT $line;
	print OUT1 $line;
	$line = sprintf("%-20s %30s\n",'PA_V3',$v3pa{$pointing_label{$visit_n}});
	print OUT $line;
	print OUT1 $line;
#	next;
#
#	my $module = $observation[0];
#	$jj = 0;
#	$line = sprintf("%-20s %30s\n",$observation_header[$jj], $module);
#
	my ($junk, $aperture)  = split(' ',$dithers_id{$target});
#	print "\n863: target: $target dithers_id: $dithers_id{$target}\npause";
#	<STDIN>;
#
# NIRCam is the parallel instrument for NIRSpec observations
#
	if($primary_instrument eq 'NIRSPEC') {
	    $primary_dither_type = 'NIRSPEC';
	    $subpixel_dither_type = 'NIRSPEC';
	    ($primary_dithers, $subpixel_dither) = 
		split(' ',$pointings{$pointing_label{$visit_n}});
	    print "$visit_n, $pointing_label{$visit_n},$pointings{$pointing_label{$visit_n}}\n";
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
	if($primary_instrument eq 'NIRCAM' && $#observation == 4) {
	    $line = sprintf("%-20s %30s\n",$observation_header[1], $aperture);
	    print OUT $line;
	    print OUT1 $line;
#
	    $primary_dither_type  = $observation[2];
	    $primary_dithers      = $observation[3];
	    $subpixel_dither_type = $observation[4];
	    my (@junk) = split('-',$subpixel_dither_type);
	    $subpixel_dither = $junk[0];
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
# Visit
#
	$line = sprintf("%-20s %30s\n",'VISIT_ID', $visit_stuff[1]);
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
	close(OUT);
    }
    close(OUT1);
    $reader-> next;
}
exit(0);
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
#-----------------------------------------------------------------------------

