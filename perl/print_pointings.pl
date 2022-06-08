#!/usr/bin/perl -w
use strict;
use warnings;
my $apt;
my $filter;
my $ii;
my $jj;
my $line;
my $pointing;
my $reg;
my $root_dir;
my $sca;
my $string;
#
my $ra;
my $dec;
my $expnumber;
#
my @junk;
my @list;
#
$root_dir = '/home/cnaw/guitarra/results/';
$apt = '1180';
$filter = 'F444W';
$sca    = '485';
$string = $root_dir.'params_apt_'.sprintf("%05d",$apt).'*_'.$filter.'*'.$sca.'*.input';
$reg  = $root_dir.sprintf("apt_%05d",$apt).'_'.$sca.'_'.$filter.'.reg';
open(REG,">$reg") || die "cannot open regions file $reg";
@list = `ls $string`;
for($ii =0; $ii <= $#list ; $ii++) {
    $list[$ii] =~ s/\n//g;
    @junk = split('\_',$list[$ii]);
    $pointing = $junk[$#junk];
    $pointing =~ s/.input//g;
    open(CAT, "<$list[$ii]") || die "cannot open $list[$ii]";
    $line = 'fk5; point (';
    while(<CAT>) {
	chop $_;
	@junk = split(' ',$_);
#	print "$#junk @junk\n";
	if($junk[0] eq 'ra_nircam') {
	    $line = $line.$junk[2].',';
	}
	if($junk[0] eq 'dec_nircam') {
	    $line = $line.$junk[2].') # point=box color=yellow';
	    $line = $line.' text={'.$pointing.'}';
#	    <STDIN>;
	    last;
	}
    }
    close(CAT);
    print REG $line,"\n";
}
print "regions file is $reg\n";

	
       
