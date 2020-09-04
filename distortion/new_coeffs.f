c
c-----------------------------------------------------------------------
c
      subroutine new_coeffs(degree, parity, det_sign,
     &     poly, new, order, scale, verbose)
      implicit none
      integer parity, degree, verbose
      double precision det_sign, poly, temp_coeff, new, scale,sign
      integer ii, jj, kk, ll, iexp, jexp, order
      character coeff_name*10, org_name*10
      dimension poly(6,6), new(9,9)
      if(verbose.gt.0) then 
         print *,'new_coeffs:  parity : ', parity,' det_sign ', det_sign
         print 10,
 10   format('new_coeffs:',/,1x,'original',7x,'SIAF', 
     &        14x,'new',10x, 'TAN-SIP',10x,' p   q sign')
      end if
      do  ii = 2, degree
         iexp = ii - 1
         do jj = 1, ii
            jexp = jj - 1
c
            kk = iexp-jexp + 1
            ll = jexp      + 1
c
            sign       = (parity**(iexp-jexp)) * (det_sign**iexp) 
            temp_coeff = sign * poly(ii,jj)/scale

            if(kk+ll-2.le.order) then
               new(kk,ll) = temp_coeff
               if(verbose.gt.0) then 
                  write(org_name, 20) iexp, jexp
 20               format('ORG_',i1,'_',i1)
                  write(coeff_name, 30) kk-1, ll-1
c                  write(coeff_name, 30) kk, ll
 30               format('NEW_',i1,'_',i1)
                  print  40, org_name, poly(ii,jj),
     &                 coeff_name, new(kk,ll), iexp-jexp,jexp, sign
 40               format(2(2x,a10,1x,e18.11),2(2x,i2),2x,f3.0)
               end if
            end if
         end do
      end do
      return
      end
