c-----------------------------------------------------------------------
c     given the inverse TAN-SIP coefficients, RA and DEC in degrees,
c     calculate the X, Y positions on the detector
c
c     cnaw@as.arizona.edu
c     2020-09-19; 2021-03-25; 2021-07-13
c
      subroutine sip_rd_to_xy(ra, dec, x_det, y_det,
     &     crpix1, crpix2, crval1, crval2,
     &     cd1_1, cd1_2, cd2_1, cd2_2,
     &     pc1_1, pc1_2, pc2_1, pc2_2,
     &     ap, ap_order, bp, bp_order, 
     &     cdelt1, cdelt2, iop,
     &     verbose)
      implicit none
      double precision x_det, y_det, ra, dec, crpix1, crpix2, 
     &     crval1, crval2, cd1_1, cd1_2, cd2_1, cd2_2, ap, bp,
     &     cdelt1, cdelt2,pc1_1, pc1_2, pc2_1, pc2_2
      integer ap_order, bp_order, verbose, iop
c     
      double precision uu, vv, xsum, ysum, xterm, yterm, q,
     &     cosdec, dx, dy, xidl, yidl !, det_sign
      integer ii, jj, iexp, jexp !, det_sci_parity
      character coeff_name*15
c
      double precision inv1_1, inv1_2, inv2_1, inv2_2, detcd, d_a, d_d,
     &     ww, zz, x_sci_scale, y_sci_scale, u_sum, v_sum, xx, yy
c
      dimension ap(9,9), bp(9,9)
      q = dacos(-1.0d0)/180.d0
c
c     pixel scale
c
      if(iop.eq.1) then
         x_sci_scale =  dsqrt(cd1_1**2 + cd2_1**2)*3600.d0
         y_sci_scale =  dsqrt(cd1_2**2 + cd2_2**2)*3600.d0
c
c     inverse rotation matrix
c
         detcd = (cd1_1*cd2_2) - (cd1_2*cd2_1)
         inv1_1 =  cd2_2/detcd
         inv1_2 = -cd1_2/detcd
         inv2_1 = -cd2_1/detcd
         inv2_2 =  cd1_1/detcd
      else
         x_sci_scale =  cdelt1 * 3600.d0
         y_sci_scale =  cdelt2 * 3600.d0
c
         detcd  = (pc1_1*pc2_2) - (pc1_2*pc2_1)
         inv1_1 =  pc2_2/detcd
         inv1_2 = -pc1_2/detcd
         inv2_1 = -pc2_1/detcd
         inv2_2 =  pc1_1/detcd
c
         inv1_1 =  inv1_1/cdelt1
         inv1_2 =  inv1_2/cdelt1
         inv2_1 =  inv2_1/cdelt2
         inv2_2 =  inv2_2/cdelt2
      end if

      if(verbose.gt.0) then
         print *,'sip_rd_to_xy xscale yscale:', x_sci_scale, y_sci_scale
         print *,'sip_rd_to_xy inv1_1, cd1_1:', inv1_1, cd1_1
         print *,'sip_rd_to_xy inv1_2, cd1_2:', inv1_2, cd1_2
         print *,'sip_rd_to_xy inv2_1, cd2_1:', inv2_1, cd2_1
         print *,'sip_rd_to_xy inv2_2, cd2_2:', inv2_2, cd2_2
      end if
c
      cosdec = dcos(dec*q)
      d_a = (ra   - crval1) * cosdec
      d_d = (dec  - crval2) 
c     
c     calculate the "ideal" coordinates:
c
      xidl  =  inv1_1 * d_a + inv1_2 * d_d
      yidl  =  inv2_1 * d_a + inv2_2 * d_d
      ww    =  xidl 
      zz    =  yidl 
c     
      u_sum = 0.d0
      do ii = 1, ap_order+1
         iexp = ii -1
         do jj = 1, ap_order+1
            jexp = jj - 1
            if(iexp+jexp .le. ap_order) then
               u_sum = u_sum + ap(ii,jj)*(ww**(ii-1))*(zz**(jj-1))
            end if
         end do
      end do
c
      v_sum = 0.d0
      do ii = 1, bp_order+1
         iexp = ii -1
         do jj = 1, bp_order+1 
            jexp = jj - 1
            if(iexp+jexp .le. bp_order) then
               v_sum = v_sum + 
     &              bp(ii,jj)*(ww**(ii-1))*(zz**(jj-1))
               if(verbose.gt.0) then
                  write(coeff_name, 100) iexp, jexp, iexp, jexp
                  print 110, coeff_name, ap(ii,jj), bp(ii,jj),
     &                 ii, jj, iexp, jexp
 100              format('A_',i1,'_',i1,2x,'B_',i1,'_',i1)
 110              format(A15,2(2x, e18.11),4(i6))
               end if
            end if
         end do
      end do
c
      uu     = ww + u_sum
      vv     = zz + v_sum
c
c     this reproduces the output of wcstools sky2xy
c
      x_det  = crpix1 + uu
      y_det  = crpix2 + vv
c
      if(verbose.eq.1) then
         print *,'sip_rd_to_xy:       ww, zz       ', ww, zz
         print *,'sip_rd_to_xy: u_sum, v_sum       ', u_sum, v_sum
         print *,'sip_rd_to_xy: ww+u_sum, zz+v_sum ', uu, vv
         print *,'sip_rd_to_xy: crpix1, crpix2     ',crpix1, crpix2
         print *,'sip_rd_to_xy: x_det, y_det ', x_det, y_det
      end if
      return
      end
c
