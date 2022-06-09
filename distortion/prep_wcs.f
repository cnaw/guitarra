c-----------------------------------------------------------------------
c     Create  WCS keywords from  SIAF coefficients for a 
c     given SCA. This uses files translated from the SIAF
c     excel sheet which comes with the pysiaf code.
c     cnaw@as.arizona.edu
c     2020-05-08
c     modified so CDi_j are consistent between the full
c     SIP polynomials and linear transformation only.
c     2021-02-05/09, 2021-03-25, 2021-07-08, 2021-07-12, 2021-07-13
c
      subroutine prep_wcs(
     &     sci_to_ideal_x, sci_to_ideal_y, sci_to_ideal_degree,
     &     ideal_to_sci_x, ideal_to_sci_y, ideal_to_sci_degree,
     &     x_sci_scale, y_sci_scale,
     &     x_det_ref, y_det_ref, x_sci_ref, y_sci_ref,
     &     det_sci_yangle, det_sci_parity,det_sign,
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
     &     pc1_1, pc1_2, pc2_1, pc2_2,
     &     cdelt1, cdelt2,
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
      double precision new_coeff, new_b_coeff, det_sign
      double precision aa, bb, ap, bp
      integer a_order, b_order, ap_order, bp_order
c
      double precision crpix1, crpix2, crval1, crval2,
     &     cd1_1, cd1_2, cd2_1, cd2_2
      double precision pc1_1, pc1_2, pc2_1, pc2_2, cdelt1, cdelt2
      character ctype1*(*), ctype2*(*)
      character cunit1*40,cunit2*40
c
      double precision attitude_dir, attitude_inv, attitude_nrc
      integer verbose, ii, jj, kk, ll, pp, qq, precise
      double precision v2_ref, v3_ref, ra_ref, dec_ref
      double precision v2, v3, ra, dec, pa_v3, q,
     &     ra_rad, dec_rad, pa_rad,
     &     v2_rad, v3_rad
      double precision ra_sca, dec_sca
      double precision nrcall_v2, nrcall_v3, nrcall_v3idlyangle
      integer iexp, jexp, nc
      double precision var
c
      dimension aa(9,9), bb(9,9), ap(9,9), bp(9,9)
      dimension attitude_dir(3,3), attitude_inv(3,3), attitude_nrc(3,3)
c
      q          = dacos(-1.0d0)/180.0d0
      nc         = 9
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
      if(verbose.eq.1) then
         print *, 'prep_wcs: attitude 1 (NRCALL -> SCA)'
         print 100 ,((attitude_nrc(ii,jj),ii=1,3),jj=1,3)
 100     format(3(2x,e21.10))
      end if
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
      if(verbose.eq.1) then
         print *, 'prep_wcs: attitude 2 (SCA)'
         print 100 ,((attitude_dir(ii,jj),ii=1,3),jj=1,3)
      end if
c
c
c     |dra  |   | PC1_1 PC1_2| |  idl_par*cosY  sinY | | CDELT1   0    | | det_parity*det_sign     0     | | dx +f(dx,dy) |
c     |     | = |            | |                     | |               | |                               | |              |
c     |ddec |   | PC2_1 PC2_2| | -idl_par*sinY  cosY | |   0    CDELT2 | |            0         det_sign | | dy +g(dx,dy) |
c
c     Science-detector rotation
      det_sign  = dcos(q*det_sci_yangle)

      x_sci_scale = sci_to_ideal_x(2,1)
      y_sci_scale = sci_to_ideal_y(2,2)
c
c     composite rotation
c
      cd1_1 = v_idl_parity*det_sci_parity*det_sign*x_sci_scale/3600.d0
      cd1_1 = cd1_1 * cos((pa_v3+ v3_idl_yang)*q)
c
c
      cd1_2 = det_sign * y_sci_scale/3600.d0
      cd1_2 = cd1_2 * sin((pa_v3+ v3_idl_yang)*q)
c
      cd2_1 = v_idl_parity*det_sci_parity*det_sign*x_sci_scale/3600.d0
      cd2_1 = -cd2_1 * sin((pa_v3+ v3_idl_yang)*q)
c
      cd2_2 = det_sign * y_sci_scale/3600.d0
      cd2_2 = cd2_2 * cos((pa_v3+ v3_idl_yang)*q)
c
      pc1_1 = v_idl_parity*det_sci_parity*det_sign
      pc1_1 = pc1_1 *cos((pa_v3+ v3_idl_yang)*q)
c
      pc1_2 = det_sign * sin((pa_v3+ v3_idl_yang)*q)
c
      pc2_1 = v_idl_parity*det_sci_parity*det_sign
      pc2_1 = -pc2_1 * sin((pa_v3+ v3_idl_yang)*q)
c
      pc2_2 = det_sign * cos((pa_v3+ v3_idl_yang)*q)
c
      cdelt1 = x_sci_scale/3600.d0
      cdelt2 = y_sci_scale/3600.d0
      if(verbose.gt.0) then 
         print *,'prep_wcs: cd1_1 ', cd1_1
         print *,'prep_wcs: cd1_2 ', cd1_2
         print *,'prep_wcs: cd2_1 ', cd2_1
         print *,'prep_wcs: cd2_2 ', cd2_2
         
         print *,'prep_wcs: cdelt1, cdelt2',cdelt1, cdelt2
         print *,'prep_wcs: pc1_1 ', pc1_1, pc1_1 * cdelt1
         print *,'prep_wcs: pc1_2 ', pc1_2, pc1_2 * cdelt2
         print *,'prep_wcs: pc2_1 ', pc2_1, pc2_1 * cdelt1
         print *,'prep_wcs: pc2_2 ', pc2_2, pc2_2 * cdelt2
      end if
c
c     set first group of WCS keywords
c
      ctype1  = 'RA---TAN-SIP'
      ctype2  = 'DEC--TAN-SIP'
      crpix1  = x_det_ref
      crpix2  = y_det_ref
      crval1  = ra_sca
      crval2  = dec_sca
      cunit1  = 'degrees'
      cunit2  = 'degrees'
c
c     Calculate the direct (detector-> sky) coefficients
c
      call  apq(aa, sci_to_ideal_x, sci_to_ideal_degree, nc, 
     &     det_sci_yangle, det_sci_parity, x_sci_scale, verbose)

      call  apq(bb, sci_to_ideal_y, sci_to_ideal_degree, nc, 
     &     det_sci_yangle, det_sci_parity, y_sci_scale, verbose)
c
c     This allows keeping the same CDi_j for no distortion or
c     full distortion
c
      do jj = 1, nc
         do ii = 1, nc
            aa(ii,jj) = aa(ii,jj)/(det_sci_parity*det_sign)
            bb(ii,jj) = bb(ii,jj)/det_sign
         end do
      end do
c
c     Calculate the inverse coefficients (sky-> detector)
c     To make results consistent with WCSToocls sky2xy one has to
c     1. divide coefficients by the pixel scale to the p*q power;
c        the scale coefficients are ideal_to_sci_x(2,1) and ideal_to_sci_y(2,2).
c     2. multiply coefficients by detector parity and/or cos(det_y_angle)
c     
      do qq = 0, ap_order
         do pp = 0, ap_order
            ap(pp+1, qq+1) = 0.0d0
            bp(pp+1, qq+1) = 0.0d0
            if(pp+qq.le.ap_order) then
               iexp = pp+qq
               jexp = qq
               ii   = iexp + 1  ! fortran indices run from [1..)
               jj   = jexp + 1
               new_coeff = ideal_to_sci_x(ii,jj)
               new_coeff = new_coeff * v_idl_parity**(pp-1)
               new_coeff = new_coeff * (det_sign)**(pp+qq+1)
               new_coeff = new_coeff/(ideal_to_sci_x(2,1)**(pp+qq))
               ap(pp+1, qq+1) = new_coeff
c
               new_coeff = ideal_to_sci_y(ii,jj)
               new_coeff = new_coeff * v_idl_parity**pp
               new_coeff = new_coeff * det_sign**(pp+qq-1)
               new_coeff = new_coeff/(ideal_to_sci_y(2,2)**(pp+qq))
               bp(pp+1,qq+1) = new_coeff
c               print *, ' pp , qq, ii, jj ',pp , qq, ii, jj,
c     &              ap(pp+1, qq+1), bp(pp+1,qq+1)
            end if
         end do
      end do
c
c     The SIAF file also contains a zero-term which the procedure 
c     outlined in JWST-STScI-001550,SM-12 does not account for.
c     These are included for completeness.
c
      aa(2,1) = aa(2,1) - 1.d0  !  aa_1_0
      bb(1,2) = bb(1,2) - 1.d0  !  bb_0_1
      ap(2,1) = ap(2,1) - 1.d0  !  ap_1_0
      bp(1,2) = bp(1,2) - 1.d0  !  bp_0_1
c     These are at 0th power so scale**0 = 1:
      ap(1,1) = ideal_to_sci_x(1,1) ! ap_0_0
      bp(1,1) = ideal_to_sci_y(1,1) ! bp_0_0
c
c     debug:
c
      if(verbose.gt.0) then
         print *,'prep_wcs: v_idl_parity, v3_idl_yang', 
     &        v_idl_parity, v3_idl_yang
         print *, 'prep_wcs: det_sci_parity, det_sci_yangle',
     &        det_sci_parity,idint(det_sci_yangle),
     &        det_sci_parity*cos(det_sci_yangle*q)
         print *,'prep_wcs: pc1_1,pc1_2', pc1_1, pc1_2
         print *,'prep_wcs: pc2_1,pc2_2', pc2_1, pc2_2
         print *, ' '
         print *,'prep_wcs  cd1_1   cd1_2', cd1_1,cd1_2
         print *,'prep_wcs  cd2_1   cd2_2', cd2_1,cd2_2
         print *,'x_sci_scale == sci_to_ideal_x(2,1) ', 
     &        sci_to_ideal_x(2,1)
         print *,'y_sci_scale == sci_to_ideal_y(2,2) ', 
     &        sci_to_ideal_y(2,2)
c     
         print 10, ctype1, ctype2, crval1, crval2, crpix1,crpix2,
     &        cd1_1,cd1_2,cd2_1,cd2_2
 10      format('prep_wcs:',/,
     &        'CTYPE1  = ',A15,/,
     &        'CTYPE2  = ',A15,/,
     &        'CRVAL1  = ',f15.8,/,
     &        'CRPIX2  = ',f15.8,/,
     &        'CRPIX1  = ',f15.3,/,
     &        'CRPIX2  = ',f15.3,/,
     &        'CD1_1   = ',e15.8,/,
     &        'CD1_2   = ',e15.8,/,
     &        'CD2_1   = ',e15.8,/,
     &        'CD2_2   = ',e15.8)
      end if
c
      return
      end
