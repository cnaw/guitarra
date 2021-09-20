c      implicit none
c      double precision aa, bb, coeffx, coeffy,det_sci_yangle
c      integer degree, nc, parity, verbose
cc
c      parameter(nc=9)
cc
c      dimension aa(nc,nc), bb(nc,nc), coeffx(nc,nc), coeffy(nc,nc)
cc
c      verbose = 1
c      degree  = 5
c      call apq(aa, coeffx, degree, nc, det_sci_yangle, parity,
c     &     verbose)
c      stop
c      end
c
c----------------------------------------------------------------------
c
c     aa_(i,j) = coeff_(i+j,j)
c     if i == p, and j == q then
c     i = p-j == p-q  and
c     a_(p,q) = coeff(p-q, q)
c
c     In the case of NIRCam
c
c     X_idl = sum(i=1, order)(sum(j=0,i) {x_(i,j) * [(dx * det_par * det_sign)**(i-j)] *
c                                                   [(dy * det_sign)**j]}
c     then
c     a_(p,q)* u**p * v**q = x_(p-q, q) * [(dx * det_par * det_sign)**(p)] *
c                                         [(dy * det_sign)**q]
c     or
c     a_(p,q) = x_(p-q, q) * det_par**(p) * det_sign**(p+q)* dx**p  * dy*q
c
      subroutine apq(aa, coeff, degree, nc, det_sci_yangle, parity,
     &     scale, verbose)
      implicit none
      double precision aa, coeff, det_sci_yangle, scale
      double precision new_coeff, sign
      integer ii, jj, pp, qq, indx, jndx
      integer degree, nc, parity, verbose
      dimension aa(9,9),  coeff(6,6)
c
      if(nc.gt.9) then
         print *,'apq.f: nc > 9 ', nc
         stop
      end if
c
      if(verbose.gt.0) then
         print *,' APQ !', nc
         print *, 'apq: ',coeff
         print *, 'apq: ',degree, nc,det_sci_yangle, parity,scale 
      end if
c
      do jj = 1, 9
         do ii = 1,9
            aa(ii,jj) = 0.0d0
         end do
      end do
c
      sign = dcos(det_sci_yangle*dacos(-1.0d0)/180.0d0)
c
      if(verbose.ge.1) then
         print 20,
 20      format(5x,' i    j  ',2x,'coeff(i,j)',
     &        10x, 'p    q ', 3x,'new_coeff(p,q)',
     &        1x,' parity',3x, 'sign')
      end if
      do pp = 0, degree-1
         do qq = 0, degree-1
            ii   = pp + qq
            indx = ii + 1       ! fortran array indices start at 1
            jndx = qq + 1       ! fortran array indices start at 1
            if((pp+qq).le.degree-1) then
               new_coeff = (coeff(indx,jndx)/scale) *
     &              ((parity*sign)**pp)*(sign**qq)
               if(verbose.ge.1) then
                  print 100, ii, qq , 
     &                 coeff(indx, jndx), 
     &                 pp, qq, new_coeff,
     &                  parity, sign
 100              format(2(2x,2i5,2x,e16.9),2x, i6,3x,f4.1)
               end if
            else
               new_coeff = 0.0d0
            end if
            aa(pp+1,qq+1) = new_coeff
         end do
      end do
      return
      end

