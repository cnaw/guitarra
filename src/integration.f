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
      print *,'integration: npts, nxy ', npts, nxny
      return
      end
c
c----------------------------------------------------------------------
c
      subroutine copy_frame(k)
      real    image, accum
      parameter (nnn=2048)
      dimension accum(nnn,nnn), image(nnn,nnn)
c
      common /images/ accum, image, n_image_x, n_image_y
c     
c      do i = 1, n_image_x
c         do j = 1, n_image_y
c            cube(i,j,k) = nint(accum(i,j))
c         end do
c      end do
      return
      end
c
