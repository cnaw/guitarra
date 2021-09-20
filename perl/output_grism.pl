#
#----------------------------------------------------------------------------------
#
#use strict;
#
sub output_grism{
    my($testing, 
       $target_number, $targprop, $archive_name, $proposal_title, $label,
       $proposal_id, $proposal_category, $expripar, $parallel_instrument, 
       $ra_obs, $dec_obs, $pa_v3, $primary_instrument,
       $observation_number, $visit_n,$aperture, $dithers_ref,
       $grism_ref, $grism_imaging_ref, $grism_spectroscopy_ref, $sequence_ref,
       $exptype_ref, $imagfile, $specfile) = @_;
    my $grism_name;
    my $module;
    my $ndithers;
    my $subarray;
    my $line;
    my $long_filter;
    my $long_pupil;
    my $short_filter;
    my $short_pupil;
    my $readout_pattern;
    my $ngroups;
    my $nints;
    my $primary_dither_type;
    my $primary_dithers;
    my $subpixel_dither_type;
    my $subpixel_dither;
    my $write_full_params;
#
    my @dithers = @$dithers_ref;
    my @visit_setup_header = ('ShortFilter', 'LongFilter','ReadoutPattern','Groups','Nints');
#
    my @junk;
    my @setup=();
    my @imag_setup =();
    my @spec_setup =();
#
    my %match;
    my %nexp;
    my %grism              = %$grism_ref;
    my %grism_imaging      = %$grism_imaging_ref;
    my %grism_spectroscopy = %$grism_spectroscopy_ref;
    my %exptype  = %$exptype_ref;
    my %sequence = %$sequence_ref;
    my %type;
####
    $ndithers = scalar(@dithers);
    print "output_grism.pl : at line : ",__LINE__," visit is $visit_n ndithers : $ndithers\n";
# match sequence number with pointing, exposure type and dither position    
    
    foreach my $key (sort(keys(%sequence))) {
	if($key =~ m/$visit_n/) {
	    if(exists($exptype{$key})) {
		if($testing == 1) {
		    print "output_grism.pl at line : ",__LINE__," $key $sequence{$key} $exptype{$key}\n";
		}
	    } else {
		print "output_grism.pl at line : ",__LINE__," $key $sequence{$key} no exptype\n";
		die;
	    }
	}
    }
#
    if($testing == 1) {
	print "output_grism.pl at line : ",__LINE__," Grism : $visit_n:\n\n$grism{$visit_n}\n";
    }
    @junk = split(' ',$grism{$visit_n});
    $short_pupil   = 'CLEAR';
    $long_pupil    = $grism_name;

    @spec =();
    @spec_setup = ();
    @imag_setup = ();
    $short_pupil = 'CLEAR';
    $long_pupil = 'CLEAR';
    for(my $ll = 0 ; $ll <= $#junk; $ll++) {
	my($par, $var) = split('=',$junk[$ll]);
	$par =~ s/ncwfss://g;
	if(lc($par) =~ m/module/) {$module = $var};
#	push(@setup, 'MODULE');
#	push(@imag_setup, $var);
#	push(@spec_setup, $var);
#
	if(lc($par) =~ m/subarray/) {$subarray = $var;}
#	push(@setup, 'SUBARRAY');
#	push(@imag_setup, $var);
#	push(@spec_setup, $var);

	print "output_grism.pl at line : ",__LINE__," par: $par, var: $var\n";
	if($par eq 'Grism')  {
	    $long_pupil = $var;
	    $grism_name = $var;
	}
	if(lc($par) =~ m/grismexposure/) {
	    if(lc($par) =~ m/shortfilter/) {
		if($var =~ m/\+/) {
		    ($short_pupil,$junk) = split('\+',$var);
		    push(@setup, 'ShortPupil');
		    push(@spec_setup, $short_pupil);
		    push(@setup, 'ShortFilter');
		    push(@spec_setup, $junk);
		} else {
		    push(@setup, 'ShortPupil');
		    push(@spec_setup, 'CLEAR');
		    push(@spec_setup, 'LongFilter');
		    push(@spec_setup, $var);
		}
	    }
	    if(lc($par) =~ m/longfilter/){ 
		push(@setup, 'LongPupil');
		push(@spec_setup, $grism_name);
		push(@setup, 'LongFilter');
		push(@spec_setup, $var);
	    }
	    if(lc($par) =~ m/readoutpattern/) {
		$readout_pattern = $var;
		push(@setup, 'ReadoutPattern') ;
		push(@spec_setup, $var);
	    }
	    if(lc($par) =~ m/groups/) {
		$ngroups = $var;
		push(@setup, 'Groups') ;
		push(@spec_setup, $var);
	    }
	    if(lc($par) =~ m/integrations/) {
		$ngroups = $var;
		push(@setup, 'Nints') ;
		push(@spec_setup, $var);
	    }
	}
# direct imaging
	if(lc($par) =~ m/diexposure/) {
	    if(lc($par) =~ m/diexposure:shortfilter/) {
		if($var =~ m/\+/) {
		    ($short_pupil,$junk) = split('\+',$var);
		    push(@setup, 'ShortPupil');
		    push(@imag_setup, $short_pupil);
		    push(@setup, 'ShortFilter');
		    push(@imag_setup, $junk);
		} else {
		    push(@setup, 'ShortPupil');
		    push(@imag_setup, 'CLEAR');
		    push(@setup, 'ShortFilter');
		    push(@imag_setup, $var);
		}
	    }
	    if(lc($par) =~ m/longfilter/){ 
		push(@setup, 'LongPupil');
		push(@imag_setup, 'CLEAR');
		push(@setup, 'LongFilter');
		push(@imag_setup, $var);
	    }
	    if(lc($par) =~ m/readoutpattern/) {
		$readout_pattern = $var;
		push(@setup, 'ReadoutPattern') ;
		push(@imag_setup, $var);
	    }
	    if(lc($par) =~ m/groups/) {
		$ngroups = $var;
		push(@setup, 'Groups') ;
		push(@imag_setup, $var);
	    }
	    if(lc($par) =~ m/integrations/) {
		$ngroups = $var;
		push(@setup, 'Nints') ;
		push(@imag_setup, $var);
	    }
	}
	if($par =~ m/PrimaryDitherType/) {$primary_dither_type = $var;}
	if($par =~ m/PrimaryDithers/)    {$primary_dithers = $var;}
	if($par =~ m/SubpixelPositions/) {$subpixel_dither = $var;}
    }
#
# Fix subpixel
#
    if(looks_like_number($subpixel_dither)){
	$subpixel_positions = $subpixel_dither;
    } else {
	$subpixel_dither_type = $subpixel_dither ;
	$subpixel_positions = substr($subpixel_dither,0,1);
    }	
######################################################################
#
#   output results - will require 2 files - one for spectroscopy, one
#   
# in the (one) case of GRISM, spectroscopic observations are labeled as "science"
#
    my $counter = 0;
    foreach my $key (sort(keys(%exptype))) {
	if($key =~ m/$visit_n/) {
	    if(lc($exptype{$key}) eq 'science') {
		$counter++;
	    }
	}
    }
    $ndithers = $counter;
    open(OUT,">$specfile") || die "cannot open $specfile at output_grism.pl";
    $write_full_params = 1;
    output_header($target_number, $targprop, $archive_name, $proposal_title, $label,
		  $proposal_id, $proposal_category, $expripar, $parallel_instrument, 
		  $ra_obs, $dec_obs, $pa_v3,$primary_instrument,
		  $module, $aperture, $primary_dither_type,
		  $primary_dithers,$subpixel_dither_type,$subpixel_positions,$subarray,
		  $visit_n, $observation_number, $ndithers,
		  \@setup, \@spec_setup, $testing, $write_full_params);
    
    
    for (my $ll = 0 ; $ll < $ndithers; $ll++) {
	@junk = split('_',$dithers[$ll]);
	$line = $junk[0];
	for(my $ii = 1; $ii <= $#junk; $ii++) {
	    $line = join(' ',$line, $junk[$ii]);
	}
	if($testing == 1) {
	    print "output_grism.pl at line : ",__LINE__," $line\n";
	}
	print OUT $line,"\n";
    }
    close(OUT);
#=======================================================================
# now imaging
#
    $primary_dither_type  = 'none';
    $primary_dithers      = 3;
    $subpixel_dither_type = 'none';
    $subpixel_positions   = 1 ;
    $long_pupil           = 'CLEAR';

    $counter = 0;
    foreach my $key (sort(keys(%exptype))) {
	if($key =~ m/$visit_n/) {
	    if(lc($exptype{$key}) ne 'science') {
		$counter++;
	    }
	}
    }
    $ndithers = $counter;
    open(OUT,">$imagfile") || die "cannot open $imagfile at output_grism.pl";
    $write_full_params = 0;
    output_header($target_number, $targprop, $archive_name, $proposal_title, $label,
		  $proposal_id, $proposal_category, $expripar, $parallel_instrument, 
		  $ra_obs, $dec_obs, $pa_v3,$primary_instrument,
		  $module, $aperture, $primary_dither_type,
		  $primary_dithers,$subpixel_dither_type,$subpixel_positions,$subarray,
		  $visit_n, $observation_number, $ndithers,
		  \@setup, \@imag_setup, $testing, $write_full_params);
#
#    $line = sprintf("%-20s %30d\n",'ndithers', $counter);
#    if($testing == 1) {print "output_grism.pl at line : ",__LINE__," $line";}
#    if($write_full_params == 1) {print OUT1 $line;}
#    print OUT $line;
    
    for (my $ll = $#dithers-$counter+1 ; $ll <= $#dithers; $ll++) {
	@junk = split('_',$dithers[$ll]);
	$line = $junk[0];
	for(my $ii = 1; $ii <= $#junk; $ii++) {
	    $line = join(' ',$line, $junk[$ii]);
	}
	if($testing == 1) {
	    print "output_grism.pl at line : ",__LINE__," $line\n";
	}
	print OUT1 $line,"\n";
	print OUT $line,"\n";
    }
#
    close(OUT);
    return;
}
#-----------------------------------------------------------------------
sub output_header{
    my($target_number, $targprop, $archive_name, $proposal_title, $label,
       $proposal_id, $proposal_category, $expripar, $parallel_instrument, 
       $ra_obs, $dec_obs, $pa_v3,$primary_instrument,
       $module, $aperture, $primary_dither_type, $primary_dithers,
       $subpixel_dither_type,$subpixel_positions,$subarray,
       $visit_n, $observation_number, $ndithers,
       $setup_ref, $var_ref, $testing, $write_full_params) = @_;
    my $line;
    my @setup = @$setup_ref;
    my @spec_setup = @$var_ref;

    $line = sprintf("%-20s %30s\n", 'Target_Number',$target_number);
    if($testing == 1) {print "output_grism.pl at line : ",__LINE__," $line";}
    print OUT $line;
    if($write_full_params == 1) {print OUT1 $line;}
#
    $line = sprintf("%-20s %30s\n", 'TARGPROP',$targprop);
    if($testing == 1) {print "output_grism.pl at line : ",__LINE__," $line";}
    print OUT $line;
    if($write_full_params == 1) {print OUT1 $line;}
#
    $line = sprintf("%-20s %30s\n", 'TargetArchiveName',$archive_name);
    if($testing == 1) {print "output_grism.pl at line : ",__LINE__," $line";}
    print OUT $line;
    if($write_full_params == 1) {print OUT1 $line;}
#
    $line = sprintf("%-20s %30s\n", 'TITLE',$proposal_title);
    if($testing == 1) {print "output_grism.pl at line : ",__LINE__," $line";}
    print OUT $line;
    if($write_full_params == 1) {print OUT1 $line;}
#
    $line = sprintf("%-20s %30s\n", 'Label',$label);
    if($testing == 1) {print "output_grism.pl at line : ",__LINE__," $line";}
    print OUT $line;
    if($write_full_params == 1) {print OUT1 $line;}
#
    $line = sprintf("%-20s %30s\n", 'PROGRAM',$proposal_id);
    if($testing == 1) {print "output_grism.pl at line : ",__LINE__," $line";}
    print OUT $line;
    if($write_full_params == 1) {print OUT1 $line;}
#
    $line = sprintf("%-20s %30s\n", 'CATEGORY',$proposal_category);
    if($testing == 1) {print "output_grism.pl at line : ",__LINE__," $line";}
    print OUT $line;
    if($write_full_params == 1) {print OUT1 $line;}
#
    $expripar = 'PRIME';
    $line = sprintf("%-20s %30s\n", 'EXPRIPAR',$expripar);
    if($testing == 1) {print "output_grism.pl at line : ",__LINE__," $line";}
    print OUT $line;
    if($write_full_params == 1) {print OUT1 $line;}
#

    $line = sprintf("%-20s %30s\n",'ParallelInstrument',$parallel_instrument);
    if($testing == 1) {print "output_grism.pl at line : ",__LINE__," $line";}
    print OUT $line;
    if($write_full_params == 1) {print OUT1 $line;}
#
    $line = sprintf("%-20s %30.8f\n", 'RA',$ra_obs);
    if($testing == 1) {print "at line : ",__LINE__," $line";}
    print OUT $line;
#
    $line = sprintf("%-20s %30.8f\n", 'Declination',$dec_obs);
    if($testing == 1) {print "at line : ",__LINE__," $line";}
    print OUT $line;
    
    $line = sprintf("%-20s %30s\n",'PA_V3',$pa_v3);
    if($testing == 1) {print "output_grism.pl at line : ",__LINE__," $line";}
    print OUT $line;
#
    $line = sprintf("%-20s %30s\n",'MODULE',$module);
    if($testing == 1) {print "output_grism.pl at line : ",__LINE__," $line";}
    print OUT $line;
    if($write_full_params == 1) {print OUT1 $line;}
#
    if($module eq 'A' && $aperture eq 'NRCALL_FULL') {
	$aperture = 'NRCAS_FULL';
    }
    if($module eq 'B' && $aperture eq 'NRCALL_FULL') {
	$aperture = 'NRCBS_FULL';
    }
    $line = sprintf("%-20s %30s\n",'APERNAME',$aperture);
    if($testing == 1) {print "output_grism.pl at line : ",__LINE__," $line";}
    if($write_full_params == 1) {print OUT1 $line;}
    print OUT $line;
#
#    $line = sprintf("%-20s %30s\n",'LongPupil',$long_pupil);
#    if($testing == 1) {print "output_grism.pl at line : ",__LINE__," $line";}
#    if($write_full_params == 1) {print OUT1 $line;}
#    print OUT $line;
#    
    $line = sprintf("%-20s %30s\n",'PATTTYPE', $primary_dither_type);
    if($testing == 1) {print "output_grism.pl at line : ",__LINE__," $line";}
    if($write_full_params == 1) {print OUT1 $line;}
    print OUT $line;
#
    $line = sprintf("%-20s %30s\n",'NUMDTHPT', $primary_dithers);
    if($testing == 1) {print "output_grism.pl at line : ",__LINE__," $line";}
    if($write_full_params == 1) {print OUT1 $line;}
    print OUT $line;
#
    $line = sprintf("%-20s %30s\n",'SubPixelDitherType', $subpixel_dither_type);
    if($testing == 1) {print "output_grism.pl at line : ",__LINE__," $line";}
    if($write_full_params == 1) {print OUT1 $line;}
    print OUT $line;
#
    $line = sprintf("%-20s %30s\n",'SUBPXPNS', $subpixel_positions);
    if($testing == 1) {print "output_grism.pl at line : ",__LINE__," $line";}
    if($write_full_params == 1) {print OUT1 $line;}
    print OUT $line;
# Subarray
    $line = sprintf("%-20s %30s\n",'SUBARRAY', $subarray);
    if($testing == 1) {print "output_grism.pl at line : ",__LINE__," $line";}
    if($write_full_params == 1) {print OUT1 $line;}
    print OUT $line;
#
# Visit information :
# 'ShortFilter', 'LongFilter','ReadoutPattern','Groups','Nints');
#
    $line = sprintf("%-20s %30s\n",'VISIT_ID', $visit_n);
    if($testing == 1) {print "output_grism.pl at line : ",__LINE__," $line";}
    print OUT $line;
    if($write_full_params == 1) {print OUT1 $line;}
    
    $line = sprintf("%-20s %30s\n",'OBSERVTN', $observation_number);
    if($testing == 1) {print "output_grism.pl at line : ",__LINE__," $line";}
    print OUT $line;
    if($write_full_params == 1) {print OUT1 $line;}

    $line = sprintf("%-20s %30s\n",'PrimaryInstrument',$primary_instrument);
    if($testing == 1) {print "output_grism.pl at line : ",__LINE__," $line";}
    print OUT $line;
    if($write_full_params == 1) {print OUT1 $line;}
#
    for (my $ii = 0 ; $ii <= $#spec_setup ; $ii++) {
	$line = sprintf("%-20s %30s\n",$setup[$ii], $spec_setup[$ii]);
	if($testing == 1) {print "output_grism.pl at line : ",__LINE__," $line";}
	if($write_full_params == 1) {print OUT1 $line;}
	print OUT $line;
    }
#
    $line = sprintf("%-20s %30s\n",'ndithers',$ndithers);
    if($testing == 1) {print "output_grism.pl at line : ",__LINE__," $line";}
    print OUT $line;
    if($write_full_params == 1) {print OUT1 $line;}
    return;
}
1;
