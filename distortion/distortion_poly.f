      double precision function distortion_poly(coeffs, order, xx, yy,
     &     verbose)
      implicit none
      double precision coeffs, xx, yy, c11,c12, c21, c22, sum
      integer order, iexp, jexp, ii, jj, verbose
      character coeff_name*40
      dimension coeffs(order+1,order+1)
      sum = 0.0d0
      do ii = 1, order + 1
         iexp = ii -1
          do jj = 1, order+1 
            jexp = jj - 1
            if(iexp+jexp .le. order) then
               if(verbose.gt.0) then
                  write(coeff_name, 100) iexp, jexp
 100              format('CC_',i1,'_',i1)
                  print 110, coeff_name, coeffs(ii,jj),
     &                 ii, jj, iexp, jexp
 110           format(A15,(2x, e18.11),4(i6))
            end if
            sum = sum + 
     &              coeffs(ii,jj)*(xx**iexp)*(yy**jexp)
            end if
         end do
      end do
      distortion_poly = sum
      return
      end
