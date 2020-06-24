use constant PI => 4*atan2(1,1);

sub translate_nircam_to_nirspec{
    my($ra1, $dec1, $pa) =@_;
    my($ra2, $dec2);
    my($qq) = PI/180.0;
    my($angle) = $pa * $qq;
#
#   V2, V3 (arc min)
#   siaf_PRDOPSSOC-027 values
#
    my $x0_nc  =  -0.3276288867102224/60.0;
    my $y0_nc  = -492.96588887005885/60.0;
# NRS_VIGNETTED_MSA
    my $x0_ns  =   378.574951171875/60.0;
    my $y0_ns  =  -428.3378601074219/60.0;
#
    my $cosa   =  cos($angle) ;
    my $sina   =  sin($angle);
#
    $dx     =   $x0_ns - $x0_nc;
    $dy     =   $y0_ns - $y0_nc;  
#
    $dra    =   $dx * $cosa + $dy * $sina;
    $ddec   =  -$dx * $sina + $dy * $cosa;
#
    $ddec   =  $ddec/60.0;
    $dec2   =  $dec1 + $ddec;
    $cosa   =  cos($qq*($dec2+$dec1)/2.0);
    $dra    =  $dra/(60.0*$cosa);
    $ra2    =  $ra1 + $dra;
    return $ra2, $dec2;
}

#
#-----------------------------------------------------------------------
#
sub translate_nirspec_to_nircam{
    my($ra1, $dec1,$pa) = @_;
    my($ra2, $dec2);
    my($dx, $dy);
    my($qq) = PI/180.0;
    my($angle) = $pa * $qq;
#
#     V2, V3 (arc min)
#
#    my $x0_nc  =  -0.3174307500/60.0;
#    my $y0_nc  = -492.591304080/60.0;
#
#    my $x0_ns  =  6.32340;
#    my $y0_ns  =  0.65220 - 7.80;
#
#   V2, V3 (arc min)
#   siaf_PRDOPSSOC-027 values
#
    my $x0_nc  =  -0.3276288867102224/60.0;
    my $y0_nc  = -492.96588887005885/60.0;
# NRS_VIGNETTED_MSA
    my $x0_ns  =   378.574951171875/60.0;
    my $y0_ns  =  -428.3378601074219/60.0;

#
    my $cosa   = cos($angle) ;
    my $sina   = sin($angle);
#
    $dx     =   $x0_nc - $x0_ns;
    $dy     =   $y0_nc - $y0_ns;  
#
    $dra    =   $dx * $cosa + $dy * $sina;
    $ddec   =  -$dx * $sina + $dy * $cosa;
#
    $ddec   =  $ddec/60.0;
    $dec2   =  $dec1 + $ddec;
    $cosa   =  cos($qq*($dec2+$dec1)/2.0);
    $dra    =  $dra/(60.0*$cosa);
    $ra2    =  $ra1 + $dra;
    return $ra2, $dec2;
}

1;

