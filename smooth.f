c
c----------------------------------------------------------------------
c
      subroutine smooth(npts, org, smoothed, n_smooth, nnn) 
      implicit none
      double precision org, smoothed, sum
      integer npts, n_smooth, nnn, k, kmin, kmax, j, n
      dimension org(nnn), smoothed(nnn)
c
c     boxcar smoothing
c
      do k = 1, npts
         sum = 0.0d0
         kmin = max(k-n_smooth/2,1)
         kmax = min(k+n_smooth/2,npts)
         n = 0
         do j= kmin, kmax
            n = n + 1
            sum = sum + org(j)
         end do
         smoothed(k) = sum/(kmax-kmin)
      end do
      return
      end

