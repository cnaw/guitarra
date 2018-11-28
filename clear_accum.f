c
c----------------------------------------------------------------------
c
      subroutine clear_accum
      implicit none
      integer   frame, nnn, i, j, n_image_x, n_image_y
      real     image, accum
      parameter (nnn=2048)
      dimension accum(nnn,nnn), image(nnn,nnn)
c
      common /images/ accum, image, n_image_x, n_image_y
c
      do j = 1, n_image_y
         do i = 1, n_image_x
            accum(i,j) = 0.0000000
         end do
      end do
      return
      end
