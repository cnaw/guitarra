c
c----------------------------------------------------------------------
c
      subroutine coadd
      implicit none
      real    image, accum, new_counts
      integer n_image_x, n_image_y, nnn, i, j
      parameter (nnn=2048)
      dimension accum(nnn,nnn), image(nnn,nnn)
c
      common /images/ accum, image, n_image_x, n_image_y
c
      do j = 1, n_image_y
         do i = 1, n_image_x
            accum(i,j) = accum(i,j) + image(i,j)
         end do
      end do
      return
      end
