#!/usr/bin/perl -w

use XML::LibXML;
use XML::LibXML qw(:libxml);
use XML::LibXML::Reader;
use XML::LibXML::NodeList;
use Data::Dumper;

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
require $perl_dir.'file_prefix_from_dithers.pl';
# Translate coordinates from primary instrument into NIRCam coordinates
require $perl_dir.'translate_instruments.pl';
#

if($#ARGV ==-1) {
    print "use is\napt_xml.pl proposal_number:\nnew_apt_output.pl 1180\n";
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
##
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
my $attributes;
my $key;
my $level;
my $text_content;
my $value;
my @att;
my %keywords;
my %levels;
my %values;

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
    say '$list   is an ', ref($list), ' $list->nodeName is ', $list->nodeName;
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

    foreach my $key1 (@level1) {
	my @level2 = grep { $_->nodeType == XML_ELEMENT_NODE } $key1->childNodes;
	my $counter2 = scalar(@level2);

	if ($key1->nodeName() =~ m/msa:CatalogAsCsv/) {next;}
	if ($key1->nodeName() =~ m/Target/) {next;}

	$key      = $key1->nodeName();
	$value    = $key1->textContent;
	$level    = 1 ;
	if(exists($levels{$key})) {
	    $values{$key}   = $values{$key}= join(' ',$values{$key}, $value);
	    $levels{$key}   = $levels{$key}= join(' ',$levels{$key}, $level);
	} else { 
#		$keywords{$key} = $key;
	    $values{$key}   = $value;
	    $levels{$key}   = $level;
	}
	if($counter2 == 0) {
	    say 'key1 nodeName    : ', $key1->nodeName();
	    say 'key1 nodeType    : ', $key1->nodeType;
	    say 'key1 textContent : ', $key1->textContent;
	    say 'key1 toString    ; ', $key1->toString;
#	    $attributes  = $key1->getAttribute($key);
#	    print "key1 : attributes  $attributes\n";
	    print "\n";
	}

	foreach my $key2 (@level2) {
	    my @level3 = grep { $_->nodeType == XML_ELEMENT_NODE } $key2->childNodes;
	    my $counter3 = scalar(@level3);

#	    foreach my $att (my $dom-> findnodes($key2)){
#		print "$att\n";
#	    }
	
	    $key      = $key2->nodeName();
	    $value    = $key2->textContent;
	    $text_content = $key2->textContent();
	    $level    = 2 ;
#	    if($text_content eq '') {
#		my $par = join("\n", $key2->findmodes($key2));
#		print "$par\n";
#		my ($attr) = $key2->findnodes{$par};
#		print "$par->toString(1)\n";
#		my $par = $key2->toString();
#		print "$par\n";
#		my $junk = $key2-> getAttribute($par);
#		print "$junk\n";
#		die;
#	    }
	    if(exists($levels{$key})) {
		$values{$key}   = $values{$key}= join(' ',$values{$key}, $value);
		$levels{$key}   = $levels{$key}= join(' ',$levels{$key}, $level);
	    } else { 
		$keywords{$key} = $key;
		$values{$key}   = $value;
		$levels{$key}   = $level;
	    }
	    
	    if($counter3 == 0) {
		say 'key2 nodeName    : ', $key2->nodeName();
		say 'key2 nodeType    : ', $key2->nodeType();
		say 'key2 textContent : ', $key2->textContent();
		say 'key2 toString    ; ', $key2->toString;
		$value = $key2->hasAttributes();
		if($value == 1) { 
		    my @nodes = $key2->attributes;
		    print "at line ",__LINE__," $#nodes\n";
		    my @names = keys(%$key2);
		    print "names: @names\n";
		    foreach my $keyword (sort(keys(%$key2))) {
			$value = $key2->{$keyword};
			print "$keyword:  $value\n";
		    }
		    @nodes = $key2->attributes;
		    print "nodes : @nodes\n";
#		    print "value is $value\n";
#		    my @nodes = $key2->getElementsByLocalName('*');
#		    print "nodes: @nodes\n";
#		    $value = $key2->getAttribute('Status');
#		    print "$value\n";
#		    <STDIN>;
		}
#		my %nodes_by_id;
#		for (my $node -> getAttribute($key2->toString)){
#		    $nodes_by_id{ $node->getAtribute('STATUS')} = $node;
#		    print "node is $node\n";
#		}
#		if($#att >=0) {
#		    for(my $ii=0 ; $ii <= $#att; $ii++) {
#			my $keyword = $att[$ii];
#			$value = $key2->getAttribute($keyword);
#			print "key2 attributes : $keyword : $value\n";
#		    }
#		}
#		$attributes  = $key2->getAttribute($key);
#		print "key2 : attributes  $attributes\n";
		print "\n";
	    } else {
		foreach my $key3 (@level3) {
		    my @level4 = grep { $_->nodeType == XML_ELEMENT_NODE } $key3->childNodes;
		    my $counter4 = scalar(@level4) ;

		    $key      = $key3->nodeName();
		    $value    = $key3->textContent;
		    $level    = 3 ;
		    if(exists($levels{$key})) {
			$values{$key}   = $values{$key}= join(' ',$values{$key}, $value);
			$levels{$key}   = $levels{$key}= join(' ',$levels{$key}, $level);
		    } else { 
			$keywords{$key} = $key;
			$values{$key}   = $value;
			$levels{$key}   = $level;
		    }
		    if($counter4 == 0) {
			say 'key3 nodeName    : ', $key3->nodeName();
			say 'key3 nodeType    : ', $key3->nodeType;
			if ($key3->nodeName() =~ m/Catalog/) {next;}
			say 'key3 textContent : ', $key3->textContent;
			say 'key3 toString    ; ', $key3->toString;
#			$attributes=$key3->getAttribute($key);
#			print "key3 attributes : $attributes\n";
			print "\n";
		    } else {
			foreach my $key4 (@level4) {
			    my @level5 = grep { $_->nodeType == XML_ELEMENT_NODE } $key4->childNodes;
			    my $counter5 = @level5 ;
			    if ($key4->nodeName() =~ m/msa:CatalogAsCsv/) {next;}
			    $key      = $key4->nodeName();
			    $value    = $key4->textContent;
			    $level    = 4 ;
			    if(exists($levels{$key})) {
				$values{$key}   = $values{$key}= join(' ',$values{$key}, $value);
				$levels{$key}   = $levels{$key}= join(' ',$levels{$key}, $level);
			    } else { 
				$keywords{$key} = $key;
				    $values{$key}   = $value;
				$levels{$key}   = $level;
			    }
			    if($counter5 == 0) {
				print "at line : ",__LINE__," key4 level 4\n";
				say 'key4 nodeName    : ', $key4->nodeName();
				say 'key4 nodeType    : ', $key4->nodeType;
				if ($key4->nodeName() =~ m/msa:CatalogAsCsv/) {next;}
				say 'key4 textContent : ', $key4->textContent;
#				$attributes=$key4->getAttribute($key);
#				print "key4 attributes : $attributes\n";
				print "\n";
			    } else {
				foreach my $key5 (@level5) {
				    my @level6 = grep { $_->nodeType == XML_ELEMENT_NODE } $key5->childNodes;
				    my $counter6 = scalar(@level6) ;
				    $key      = $key5->nodeName();
				    if ($key5->nodeName() =~ m/msa:CatalogAsCsv/) {next;}
				    $value    = $key5->textContent;
				    $text_content =  $key5->textContent();
				    $level    = 5 ;
				    if(exists($levels{$key})) {
					$values{$key}   = $values{$key}= join(' ',$values{$key}, $value);
					$levels{$key}   = $levels{$key}= join(' ',$levels{$key}, $level);
				    } else { 
					    $keywords{$key} = $key;
					    $values{$key}   = $value;
					    $levels{$key}   = $level;
				    }
				    if($counter6 == 0) {
					
					print "at line : ",__LINE__," key5 level 5\n";
					say 'key5 nodeName    : ', $key5->nodeName();
					say 'key5 nodeType    : ', $key5->nodeType;
					say 'key5 textContent : ', $key5->textContent();
					say 'key5 toString    ; ', $key5->toString;
					print "\n";
				    } else {
					foreach my $key6 (@level6) {
					    my @level7 = grep { $_->nodeType == XML_ELEMENT_NODE } $key6->childNodes;
					    my $counter7 = scalar(@level7);
					    $key      = $key6->nodeName();
					    if ($key6->nodeName() =~ m/msa:CatalogAsCsv/) {next;}
					    $value    = $key6->textContent;
					    $level    = 6 ;
					    if(exists($levels{$key})) {
						$values{$key}   = $values{$key}= join(' ',$values{$key}, $value);
						$levels{$key}   = $levels{$key}= join(' ',$levels{$key}, $level);
					    } else { 
						$keywords{$key} = $key;
						    $values{$key}   = $value;
						$levels{$key}   = $level;
					    }
					    if($counter7 == 0) {
						print "at line : ",__LINE__," key6 level 6\n";
						say 'key6 nodeName    : ', $key6->nodeName();
						say 'key6 nodeType    : ', $key6->nodeType;
						say 'key6 textContent : ', $key6->textContent;
						say 'key6 toString    ; ', $key6->toString;
#						$attributes =$key6->getAttribute($key);
#						print "key6 attributes : $attributes\n";
						print "\n";
					    } else {
						foreach my $key7 (@level7) {
						    my @level8 = grep { $_->nodeType == XML_ELEMENT_NODE } $key7->childNodes;
						    my $counter8 = scalar(@level8) ;
						    $key      = $key7->nodeName();
						    $value    = $key7->textContent;
						    $level    = 7 ;
						    if(exists($levels{$key})) {
							$values{$key}   = $values{$key}= join(' ',$values{$key}, $value);
							$levels{$key}   = $levels{$key}= join(' ',$levels{$key}, $level);
						    } else { 
							$keywords{$key} = $key;
							$values{$key}   = $value;
							$levels{$key}   = $level;
						    }
						    if($counter8 == 0) {
							print "at line : ",__LINE__," key7 level7\n";
							say 'key7 nodeName    : ', $key7->nodeName();
							say 'key7 nodeType    : ', $key7->nodeType;
							say 'key7 textContent : ', $key7->textContent;
							say 'key7 toString    ; ', $key7->toString;
#							$attributes=$key7->getAttribute($key);
#							print "key7 attributes : $attributes\n";
							print "\n";
						    } else {
							foreach my $key8 (@level8) {
							    my @level9 = grep { $_->nodeType == XML_ELEMENT_NODE } $key8->childNodes;
							    my $counter9 = @level9 ;
							    $key      = $key8->nodeName();
							    $value    = $key8->textContent;
							    $level    = 8 ;
							    if(exists($levels{$key})) {
								$values{$key}   = $values{$key}= join(' ',$values{$key}, $value);
								$levels{$key}   = $levels{$key}= join(' ',$levels{$key}, $level);
							    } else { 
								$keywords{$key} = $key;
								$values{$key}   = $value;
								$levels{$key}   = $level;
							    }
							    if($counter9 == 0) {
								print "at line : ",__LINE__," key8 level8\n";
								say 'key8 nodeName    : ', $key8->nodeName();
								say 'key8 nodeType    : ', $key8->nodeType;
								say 'key8 textContent : ', $key8->textContent;
								say 'key8 toString    ; ', $key8->toString;
#								$attributes = $key8->getAttribute($key);
#								print "key8 attributes : $attributes\n";
#								print "\n";
							    } else {
								foreach my $key9 (@level9) {
								    my @level10 = grep { $_->nodeType == XML_ELEMENT_NODE } $key9->childNodes;
								    $key      = $key9->nodeName();
								    $value    = $key9->textContent;
								    $level    = 9 ;
								    if(exists($levels{$key})) {
									$values{$key}   = $values{$key}= join(' ',$values{$key}, $value);
									$levels{$key}   = $levels{$key}= join(' ',$levels{$key}, $level);
								    } else { 
									$keywords{$key} = $key;
									$values{$key}   = $value;
									$levels{$key}   = $level;
								    }
								    my $counter10 = scalar(@level10) ;
								    if($counter10 == 0) {
									print "level 9 at Line: ", __LINE__, "\n";
									say 'key9 nodeName    : ', $key9->nodeName();
									say 'key9 nodeType    : ', $key9->nodeType;
									say 'key9 textContent : ', $key9->textContent;
									say 'key9 toString    ; ', $key9->toString;
#									$attributes = $key9->getAttribute($key);
#									print "key9 : attributes $attributes\n";
									print "\n";
								    }
								}
							    } 
							}
######################################################### level 8
						    }
						}
					    }
					}
				    }
				}
			    }
			}
		    }
		}
	    }
	}
    }
    $reader-> next
}
print "\nat line : ",__LINE__," finished reading XML\n\n";
my$nn = 0;
foreach $key(sort(keys(%values))) {
    $nn++;
    my $nnn = sprintf("%4d", $nn);
    print "$nnn key is $key\n";
    print "$nnn key is $key values: $values{$key}\n";
    print "$nnn key is $key levels: $levels{$key}\n\n";
}
