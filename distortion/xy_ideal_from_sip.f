      subroutine xy_ideal_from_sip(x_det, y_det, crpix1, crpix2,
     &     aa, a_order, bb, b_order, xsum, ysum, verbose)
      implicit none
      double precision x_det, y_det, crpix1, crpix2, aa, bb
      integer a_order, b_order, verbose
c     
      double precision uu, vv, xsum, ysum, xterm, yterm
      integer ii, jj, iexp, jexp
      character coeff_name*15
c
      dimension aa(9,9), bb(9,9)
c     
c     Using TAN-SIP coefficients
c     
      uu = x_det - crpix1
      vv = y_det - crpix2 
      xsum  = 0.0d0
      ysum  = 0.0d0
c     if(verbose.gt.0) print 99
c      print 99
 99   format('aa or bb',3x,'value', 11x,'uu',9x,'vv',
     &     8x,'term',10x,'sum')
      do ii = 1, a_order + 1
         iexp = ii - 1
         do jj = 1, a_order + 1
            jexp = jj - 1
            if(iexp+jexp.le. a_order) then
               write(coeff_name, 100) iexp, jexp, iexp, jexp
 100           format('A_',i1,'_',i1,2x,'B_',i1,'_',i1)
               if(verbose.gt.1) then
                  print 110, coeff_name, aa(ii,jj), bb(ii,jj),
     &                 ii, jj, iexp, jexp
 110              format(A15,2(2x, e18.11),4(i6))
               end if
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
      return
      end
