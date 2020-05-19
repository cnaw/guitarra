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
     &     x_det_ref, y_det_ref, x_sci_ref, y_sci_ref,
     &     det_sci_yangle, det_sci_parity,
     &     v3_idl_yang, v_idl_parity, v2_ref, v3_ref,
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
     &     cd1_1, cd1_2, cd2_1, cd2_2
      character ctype1*(*), ctype2*(*)
      character cunit1*40,cunit2*40
c
      double precision attitude_dir, attitude_inv
      integer verbose, ii, jj, kk, ll, precise
      double precision v2_ref, v3_ref, ra_ref, dec_ref
      double precision v2, v3, ra, dec, pa_v3, q,
     &     ra_rad, dec_rad, pa_rad,
     &     v2_rad, v3_rad
      double precision ra_sca, dec_sca
      double precision nrcall_v2, nrcall_v3, nrcall_v3idlyangle
      integer iexp, jexp
c
      dimension attitude_dir(3,3), attitude_inv(3,3)
      dimension aa(9,9), bb(9,9), ap(9,9), bp(9,9)
c
c     V2, V3 coordinates of the NRCALL aperture
c
      data nrcall_v2,nrcall_v3,nrcall_v3idlyangle/-0.3276288867102224d0,
     &     -492.96588887005885d0, -0.11255124074467837d0/
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
     *     attitude_dir)
c
c     2. Find RA, DEC for the SCA (these will be CRVAL1, CRVAl2)
c
      v2_rad     = v2_ref * q/3600.d0
      v3_rad     = v3_ref * q/3600.d0
      call rot_coords(attitude_dir, v2_rad, v3_rad, ra_rad, dec_rad)
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
c     ra     | cos(pa)   sin(pa)|  | v_idl_parity*cos(v3_idl_yang) sin(v3_idl_yang)| |xidl|
c          = |                  |  |                                               | |    |
c     dec    |-sin(pa)   cos(pa)|  |-v_idl_parity*sin(v3_idl_yang) cos(v3_idl_yang)| |yidl|
c
      c11 = dcos(pa_rad) * v_idl_parity*dcos(v3_idl_yang*q) + 
     &     dsin(pa_rad) * dsin(v3_idl_yang*q)
c
      c12 = dcos(pa_rad) * dsin(v3_idl_yang*q) +
     &     dsin(pa_rad) * dcos(v3_idl_yang*q)
c
      c21 = -dsin(pa_rad) * v_idl_parity*dcos(v3_idl_yang*q) + 
     &     dcos(pa_rad) * (-v_idl_parity*dsin(v3_idl_yang*q))
c
      c22 = -dsin(pa_rad) * dsin(v3_idl_yang*q) +
     &     dcos(pa_rad) * dcos(v3_idl_yang*q)
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
c     coefficients that transform (x_idl,y_idl) -> (dra,ddec)
c
      cd1_1 = c11/3600.d0
      cd1_2 = c12/3600.d0
      cd2_1 = c21/3600.d0
      cd2_2 = c22/3600.d0
c     
c     now prepare the polynomials that make the  composite functions
c     (x_det, y_det) -> (x_sci, y_sci) -> (x_idl, y_idl)
c     such that 
c     (x_det, y_det) -> (x_idl, y_idl)
c
c     calculate the coefficients for the detector to sky conversion
c     
      det_sign  = dcos(q*det_sci_yangle)
      call new_coeffs(sci_to_ideal_degree, det_sci_parity, det_sign,
     &     sci_to_ideal_x, aa, a_order, verbose)
c
      call new_coeffs(sci_to_ideal_degree, det_sci_parity, det_sign,
     &     sci_to_ideal_y, bb, b_order, verbose)
c
c     Inverse coefficients (sky-> detector)
c
      do ii = 2, ideal_to_sci_degree
         iexp = ii - 1
         do jj = 1, ii
            jexp = jj - 1
            new_coeff = ideal_to_sci_x(ii,jj)
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
c     x = |cdij| * (u + sum_ij Aij* u**i * v**j)
c     y = |cdij| * (v + sum_ij Bij* u**i * v**j)
c     This trick includes the "u" (and "v") term in the sum
c     (as in reality the exponents will be aa(1, 0) and bb(0, 1)
c     The SIAF file also contains a zero-term which the procedure 
c     outlined in JWST-STScI-001550,SM-12 does not account for.
c     These are included for completeness
c
      aa(2,1) = aa(2,1) - 1.d0
      bb(1,2) = bb(1,2) - 1.d0
      ap(2,1) = ap(2,1) - 1.d0
      bp(1,2) = bp(1,2) - 1.d0
      ap(1,1) = ideal_to_sci_x(1,1)
      bp(1,1) = ideal_to_sci_y(1,1) * det_sign

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
