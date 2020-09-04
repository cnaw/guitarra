c
c     Create  WCS keywords from  SIAF coefficients for a 
c     given SCA. This uses files translated from the SIAF
c     excel sheet which comes with the pysiaf code.
c     cnaw@as.arizona.edu
c     2020-05-08
c
      subroutine prep_wcs(
     &     sci_to_ideal_x, sci_to_ideal_y, sci_to_ideal_degree,
     &     ideal_to_sci_x, ideal_to_sci_y, ideal_to_sci_degree,
     &     x_sci_scale, y_sci_scale,
     &     x_det_ref, y_det_ref, x_sci_ref, y_sci_ref,
     &     det_sci_yangle, det_sci_parity,
     &     v3_idl_yang, v_idl_parity, v2_ref, v3_ref,
     &     nrcall_v3idlyangle,nrcall_v2,nrcall_v3,
     &     crpix1, crpix2,
     &     crval1, crval2,
     &     ctype1, ctype2,
     &     cunit1, cunit2,
     &     cd1_1, cd1_2, cd2_1, cd2_2,
     &     ra_ref, dec_ref, pa_v3,
     &     a_order, aa, b_order, bb,
     &     ap_order, ap, bp_order, bp,
     &     attitude_dir, attitude_inv, 
     &     ra_sca, dec_sca,
     &     cor1_1, cor1_2, cor2_1, cor2_2,
     &     verbose)
c
      implicit none
c
      double precision x_det_ref, y_det_ref
      double precision x_sci_ref, y_sci_ref, det_sci_yangle
      double precision 
     &     sci_to_ideal_x,sci_to_ideal_y,
     &     ideal_to_sci_x, ideal_to_sci_y,
     &     x_sci_scale, y_sci_scale,
     &     v3_sci_x_angle,v3_sci_y_angle,
     &     v3_idl_yang

      double precision v2_offset, v3_offset
      integer ideal_to_sci_degree, v_idl_parity,
     &     sci_to_ideal_degree, det_sci_parity
      character coeff_name*10
      dimension 
     &     sci_to_ideal_x(6,6), sci_to_ideal_y(6,6), 
     &     ideal_to_sci_x(6,6), ideal_to_sci_y(6,6)
c
      double precision c11, c12, c21, c22
      double precision new_coeff, det_sign
      double precision aa, bb, ap, bp
      integer a_order, b_order, ap_order, bp_order
c
      double precision crpix1, crpix2, crval1, crval2,
     &     cd1_1, cd1_2, cd2_1, cd2_2,
     &     cor1_1, cor1_2, cor2_1, cor2_2
      character ctype1*(*), ctype2*(*)
      character cunit1*40,cunit2*40
c
      double precision attitude_dir, attitude_inv, attitude_nrc
      integer verbose, ii, jj, kk, ll, precise
      double precision v2_ref, v3_ref, ra_ref, dec_ref
      double precision v2, v3, ra, dec, pa_v3, q,
     &     ra_rad, dec_rad, pa_rad,
     &     v2_rad, v3_rad
      double precision ra_sca, dec_sca
      double precision nrcall_v2, nrcall_v3, nrcall_v3idlyangle
      integer iexp, jexp
c
      dimension aa(9,9), bb(9,9), ap(9,9), bp(9,9)
      dimension attitude_dir(3,3), attitude_inv(3,3), attitude_nrc(3,3)
c
      q          = dacos(-1.0d0)/180.0d0
c
c     for more precise V2,V3/Ideal set to "1".
c
      precise    = 0
c
      a_order  = 5
      b_order  = 5
      ap_order = 5
      bp_order = 5
c
      do jj = 1, 9
         do ii = 1, 9
            aa(ii,jj) = 0.0d0
            bb(ii,jj) = 0.0d0
            ap(ii,jj) = 0.0d0
            bp(ii,jj) = 0.0d0
         end do
      end do
c
c     1. Find the corresponding (RA, DEC) for the SCA, when given
c     the RA, DEC, and PA_V3 for a NIRCam pointing. Build the
c     attitude matrix. First convert angles into radians
c
      ra_rad     = ra_ref  * q
      dec_rad    = dec_ref * q
      pa_rad     = pa_v3   * q
      v2_rad     = nrcall_v2 * q/3600.d0
      v3_rad     = nrcall_v3 * q/3600.d0
c
      call attitude( v2_rad, v3_rad, ra_rad, dec_rad, pa_rad,
     *     attitude_nrc)
c
c     2. Find RA, DEC for the SCA (these will be CRVAL1, CRVAl2)
c
      v2_rad     = v2_ref * q/3600.d0
      v3_rad     = v3_ref * q/3600.d0
      call rot_coords(attitude_nrc, v2_rad, v3_rad, ra_rad, dec_rad)
      call coords_to_ra_dec(ra_rad, dec_rad, ra_sca, dec_sca)
c
c     3. Build attitude matrices for this new position.
c     These will be used to calculate (V2, V3) for each object 
c     from the catalogue RA, DEC. Also used when placing photons
c     on focal plane
c
      call attitude( v2_rad, v3_rad, ra_rad, dec_rad, pa_rad,
     *     attitude_dir)
      do jj = 1, 3
         do ii = 1, 3
            attitude_inv(jj,ii) = attitude_dir(ii,jj)
         end do
      end do
c
c     coefficients for
c
c   | dra  |   | cos(pa)   sin(pa)|  | v_idl_parity*cos(v3_idl_yang) sin(v3_idl_yang)| |xidl|
c   |      | = |                  |  |                                               | |    | * 1/3600  
c   | ddec |   |-sin(pa)   cos(pa)|  |-v_idl_parity*sin(v3_idl_yang) cos(v3_idl_yang)| |yidl|
c
c
c     Brant Robertson suggests that one calculates initially:
c
c     | xidl |   | sum(i=0,n,j=0,i)[coeff_x(i,j) * x_sci**i  * y_sci**j] |    (pixels -> arcsec)
c     |      | = |                                                       |
c     | yidl |   | sum(i=0,n,j=0,i)[coeff_y(i,j) * x_sci**i  * y_sci**j] |    (pixels -> arcsec)
c
c     to remain in the spirit of PCi_j, CDELTi, CDELTj transformations.
c
c     | M |    | v_idl_parity*cos(v3_idl_yang) sin(v3_idl_yang)| |xidl |
c     |   | =  |                                               | |     | * 1/3600
c     | N |    |-v_idl_parity*sin(v3_idl_yang) cos(v3_idl_yang)| |yidl |
c   
c     This allows making the standard (flat) transformation:
c
c     | dra  |   | cd1_1     cd1_2  |  | M |
c     |      | = |                  |  |   |
c     | ddec |   | cd2_1     cd2_2  |  | N |
c
c     The downside of this is that it will only work if sin(v3_idl_yang)= 0, whereas its value is 
c     about -0.01 for NIRCam A1. Otherwise the only viable solution, which will work for TAN-SIP
c     is by making
c
c     | cd1_1     cd1_2  |     | cos(pa)   sin(pa)|  | v_idl_parity*cos(v3_idl_yang) sin(v3_idl_yang)|
c     |                  | =   |                  |  |                                               |
c     | cd2_1     cd2_2  |     |-sin(pa)   cos(pa)|  |-v_idl_parity*sin(v3_idl_yang) cos(v3_idl_yang)|
c
c     which is fine since this is a composition of rotations
c
c     this will correct for the rotation betwen ideal and
c     telescope v2, v3 coordinates
c 1000, 1000 pixels
c difference (arc sec)      -4.7999198876967685E-004  2.5100973587655062E-003  w/N12, N21
c difference (arc sec)      -3.2100508939653889E-002  0.43323568923057110     wo/N12, N21
c 11000, 11000 pixels
c difference (arc sec)      -7.2376001240299886E-002  0.48404339664784857  w/N12, N21
c difference (arc sec)      -0.45902900201395869      6.5358311187978302  wo/N12, N21
      cor1_1  =  v_idl_parity*dcos(v3_idl_yang*q)
      cor1_2  =  dsin(v3_idl_yang*q)
      cor2_1  = -v_idl_parity*dsin(v3_idl_yang*q)
      cor2_2  =  dcos(v3_idl_yang*q)
c      cor1_2  = 0.0d0
c      cor2_1  = 0.0d0
c
c     rotation matrix for a given position angle
c
      c11     =  dcos(pa_rad)
      c12     =  dsin(pa_rad)
      c21     = -dsin(pa_rad) 
      c22     =  dcos(pa_rad)
c
c     composite
c
      cd1_1   = c11 * cor1_1 + c12 * cor2_1
      cd1_2   = c11 * cor1_2 + c12 * cor2_2
      cd2_1   = c21 * cor1_1 + c22 * cor2_1
      cd2_2   = c21 * cor1_2 + c22 * cor2_2

      x_sci_scale = sci_to_ideal_x(2,1)
      y_sci_scale = sci_to_ideal_y(2,2)
c
c     convert into degrees (per pixel)
c
      cd1_1   = cd1_1 * x_sci_scale/3600.d0
      cd1_2   = cd1_2 * y_sci_scale/3600.d0
      cd2_1   = cd2_1 * x_sci_scale/3600.d0
      cd2_2   = cd2_2 * y_sci_scale/3600.d0
c     
      if(verbose.gt.0) then
         print *,'pre-_wcs: v_idl_parity, v3_idl_yang', 
     &        v_idl_parity, v3_idl_yang
         print *,'prep_wcs: cor1_1,cor1_2', cor1_1, cor1_2
         print *,'prep_wcs: cor2_1,cor2_2', cor2_1, cor2_2
         print *, ' '
         print *,'prep_wcs  c11       c12', c11,c12
         print *,'prep_wcs  c21       c22', c21,c22
         print *, ' '
         print *,'prep_wcs  cd1_1   cd1_2', cd1_1,cd1_2
         print *,'prep_wcs  cd2_1   cd2_2', cd2_1,cd2_2
         print *,'sci_to_ideal_x(2,1)== x_sci_scale ', 
     &        sci_to_ideal_x(2,1)
         print *,'sci_to_ideal_y(2,2)== y_sci_scale ', 
     &        sci_to_ideal_y(2,2)
      end if
c
c     set first group of WCS keywords
c
      ctype1  = 'RA---TAN-SIP'
      ctype2  = 'DEC--TAN-SIP'
      crpix1  = 1024.5d0
      crpix2  = 1024.5d0
      cunit1  = 'degrees'
      cunit2  = 'degrees'
c
      crval1     = ra_sca
      crval2     = dec_sca
c     
c     now prepare the polynomials that make the  composite functions
c     (x_det, y_det) -> (x_sci, y_sci) -> (x_idl, y_idl)
c     such that 
c     (x_det, y_det) -> (x_idl, y_idl)
c
c     calculate the coefficients for the detector to sky conversion
c     

cc     a_order = 5
c      call apq( aa,sci_to_ideal_x, sci_to_ideal_degree,9,
c     &     det_sci_yangle, det_sci_parity,x_sci_scale, 1)
cc      aa(2,1) = 0.0d0
c      b_order = 5
c      call apq( bb,sci_to_ideal_y, sci_to_ideal_degree,9,
c     &     det_sci_yangle, det_sci_parity,y_sci_scale, 1)
c      bb(1,2) = 0.0d0
c
      det_sign  = dcos(q*det_sci_yangle)
c
      call new_coeffs(sci_to_ideal_degree, det_sci_parity, det_sign,
     &     sci_to_ideal_x, aa, a_order, x_sci_scale, verbose)
c
      call new_coeffs(sci_to_ideal_degree, det_sci_parity, det_sign,
     &     sci_to_ideal_y, bb, b_order, y_sci_scale, verbose)
c
c     Inverse coefficients (sky-> detector)
c     the scale coefficients are ideal_to_sci_x(2,1) and ideal_to_sci_y(2,2)
c
      do ii = 2, ideal_to_sci_degree
         iexp = ii - 1
         do jj = 1, ii
            jexp = jj - 1
            new_coeff = ideal_to_sci_x(ii,jj) *(-det_sign)
            kk = iexp-jexp + 1
            ll = jexp      + 1
            if(kk+ll-2 .le.ap_order) then
               ap(kk,ll) = new_coeff
            end if
         end do
      end do
c     
      do ii = 2, ideal_to_sci_degree
         iexp = ii - 1
         do jj = 1, ii
            jexp = jj - 1
            new_coeff = ideal_to_sci_y(ii,jj) *det_sign
            kk = iexp-jexp + 1
            ll = jexp      + 1
            if(kk+ll-2 .le.bp_order) then
               bp(kk,ll) = new_coeff
            end if
         end do
      end do
c
c     SIP formalism has 
c
c     x = |cdij| * (u + sum_ij Aij* u**i * v**j)
c     y = |cdij| * (v + sum_ij Bij* u**i * v**j)
c
c     This means that
c     x_idl = (u + sum_ij Aij* u**i * v**j) = sum(i=1,Degree,j=0,i) (Sci_to_ideal_x_i_j * dx**(i-j) *dy**j)
c     or
c     sum_ij Aij* u**i * v**j = sum(i=1,Degree,j=0,i) (Sci_to_ideal_x_i_j * dx**(i-j) *dy**j) - u
c
c     This means  that one has to correct one of the coefficients such that
c
c     aa_1_0_corr = aa_1_0 - 1   (this is the  u**1 v**0 term)
c
c     The SIAF file also contains a zero-term which the procedure 
c     outlined in JWST-STScI-001550,SM-12 does not account for.
c     These are included for completeness
c
      aa(2,1) = aa(2,1) - 1.d0  !  aa_1_0
      bb(1,2) = bb(1,2) - 1.d0  !  bb_0_1
      ap(2,1) = ap(2,1) - 1.d0  !  ap_1_0
      bp(1,2) = bp(1,2) - 1.d0  !  bp_0_1
      ap(1,1) = ideal_to_sci_x(1,1)
      bp(1,1) = ideal_to_sci_y(1,1) * det_sign
c
c      do ii = 2, ideal_to_sci_degree
c         do jj = 1, ii
c            aa(ii,jj) = aa(ii,jj)/aa(2, 1)
c            bb(ii,jj) = aa(ii,jj)/bb(1, 2)
c            ap(ii,jj) = aa(ii,jj)*ap(2, 1)
c            bp(ii,jj) = aa(ii,jj)*bp(1, 2)
c         end do
c      end do

      if(verbose.gt.0) then
         print 10, ctype1, ctype2, crval1, crval2, crpix1,crpix2,
     &        cd1_1,cd1_2,cd2_1,cd2_2
 10      format(
     &        'CTYPE1  = ',A15,/,
     &        'CTYPE2  = ',A15,/,
     &        'CRVAL1  = ',f15.8,/,
     &        'CRPIX2  = ',f15.8,/,
     &        'CRPIX1  = ',f15.3,/,
     &        'CRPIX2  = ',f15.3,/,
     &        'CD1_1   = ',e15.8,/,
     &        'CD1_1   = ',e15.8,/,
     &        'CD2_1   = ',e15.8,/,
     &        'CD2_2   = ',e15.8)
      end if
c
      return
      end
