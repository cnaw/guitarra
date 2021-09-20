c
c----------------------------------------------------------------------
c     
c     given the TAN-SIP coefficients, the raw detector X and Y in pixels,
c     calculate the RA and Dec in degrees
c
c     cnaw@as.arizona.edu
c     2020-09-19
c     2021-07-13
c
      subroutine sip_xy_to_rd(x_det, y_det, ra, dec,
     &     crpix1, crpix2, crval1, crval2,
     &     cd1_1, cd1_2, cd2_1, cd2_2,
     &     pc1_1, pc1_2, pc2_1, pc2_2,
     &     aa, a_order, bb, b_order, 
     &     cdelt1, cdelt2, iop,
     &     verbose)
      implicit none
      double precision x_det, y_det, ra, dec, crpix1, crpix2, 
     &     crval1, crval2, cd1_1, cd1_2, cd2_1, cd2_2, aa, bb,
     &     cdelt1, cdelt2, pc1_1, pc1_2, pc2_1, pc2_2
      integer a_order, b_order, verbose, iop
c     
      double precision uu, vv, xsum, ysum, xterm, yterm, q,
     &     cosdec, dx, dy, xpix, ypix
      integer ii, jj, iexp, jexp
      character coeff_name*15
c
      dimension aa(9,9), bb(9,9)
      q = dacos(-1.0d0)/180.d0
c     
c     Using TAN-SIP coefficients
c     
      uu = x_det - crpix1
      vv = y_det - crpix2 
      xsum  = 0.0d0
      ysum  = 0.0d0
c      if(verbose.gt.0) print 99
 99   format('sip_xy_to_rd',/,'Coef',3x,'value', 11x,'uu',9x,'vv',
     &     8x,'term',10x,'sum')
      do ii = 1, a_order + 1
         iexp = ii - 1
         do jj = 1, a_order + 1
            jexp = jj - 1
            if(iexp+jexp.le. a_order) then
               write(coeff_name, 100) iexp, jexp, iexp, jexp
 100           format('A_',i1,'_',i1,2x,'B_',i1,'_',i1)
c               if(verbose.gt.1) then
c                  print 110, coeff_name, aa(ii,jj), bb(ii,jj),
c     &                 ii, jj, iexp, jexp
 110              format(A15,2(2x, e18.11),4(i6))
c               end if
               xterm = aa(ii, jj) * (uu**iexp) * (vv**jexp)
               xsum  = xsum + xterm
               yterm = bb(ii, jj) * (uu**iexp) * (vv**jexp)
               ysum  = ysum + yterm
               if(verbose.gt.1) then
c     print 115, ii-1, jj-1, aa(ii,jj),uu, vv, xterm, xsum
 115              format('aa_',i1,'_',i1,2(1x,e13.6,2(1x,f10.4)))
               end if
            end if
         end do
      end do
c
c     uu, vv are in pixels
c     cdi_j are in degrees/pixel
c
      xpix   =  uu + xsum
      ypix   =  vv + ysum
c
      if(iop.eq.1) then
         dy   =  (cd2_1 * xpix + cd2_2 * ypix)
         dx   =  (cd1_1 * xpix + cd1_2 * ypix)
      else
         dy   =  pc2_1 * cdelt1 * xpix + pc2_2 * cdelt2 * ypix
         dx   =  pc1_1 * cdelt1 * xpix + pc1_2 * cdelt2 * ypix
      end if
      dec = crval2 + dy
      cosdec = dcos(dec*q)
      dx = dx/cosdec
      ra  = crval1 +  dx
         
      return
      end
