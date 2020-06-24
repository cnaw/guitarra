#!/usr/bin/perl -w
use strict ;
my $cat;
my $dec;
my $guitarra_home = $ENV{GUITARRA_HOME};
my $header;
my $line ;
my $mag ;
my $ncol;
my $ra ;
my $reg;
my $xpix;
my $ypix;
#
my (@columns);

if($#ARGV == -1) {
    print "recanters.pl star_many_F356W_490_412.cat\n";
    exit(0);
}
$cat = $guitarra_home.'/results/'.$ARGV[0];
$reg = $cat;
$reg =~ s/.cat/.reg/;
open(CAT, "<$cat") || die "cannot find $cat";
open(REG, ">$reg") || die "cannot find $reg";
$header = <CAT>;
chop $header;
$header =~ s/#//g;
@columns = split(' ', $header);
while(<CAT>) {
    chop $_;
    @columns = split(' ',$_);
    $ncol    = $#columns;
    my $id      = $columns[0];
    $ra      = $columns[1];
    $dec     = $columns[2];
    $mag     = $columns[13];
    $xpix    = $columns[$ncol-1];
    $ypix    = $columns[$ncol];
    $line    = 'fk5;point('.$ra.','.$dec.') # point=box color=red text={'.$id.'}';
    print  REG $line,"\n";
    $line    = 'image;point('.$xpix.','.$ypix.') # point=circle color=green text={'.$id.'}';
    print  REG $line,"\n";
}
close(CAT);
close(REG);
print "regions file is $reg\n";
