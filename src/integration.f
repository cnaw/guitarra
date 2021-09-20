      subroutine integration(two_d, nnn, nx, ny, one_d, nxny, npts, 
     &     verbose)
      implicit none
      double precision  two_d, one_d, sum
      integer nxny, n,nnn
      integer nx, ny, npts, i, j, verbose
c      parameter (nxy = 2048*2048)
c      dimension two_d(2048,2048), one_d(nxy)
      dimension two_d(nnn,nnn), one_d(nxny)
c
      sum = 0.d0
      n   = 0
      do j = 1, ny
         do i = 1, nx
            n = n + 1
            sum = sum + two_d(i,j)
            one_d(n) = sum
         end do
      end do
      if(verbose.gt.1) print *, 'integration: sum ', sum
c      STOP
      npts = n
      if(verbose.gt.0)
     &     print *,'integration: npts, nxy ', npts, nxny,one_d(n)
      return
      end
