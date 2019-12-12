c
c----------------------------------------------------------------------
c
      subroutine coadd(include_flat)
      implicit none
      real    image, accum, flat_image
      integer include_flat
      integer n_image_x, n_image_y, nnn, i, j
      parameter (nnn=2048)
      dimension accum(nnn,nnn), image(nnn,nnn),flat_image(nnn,nnn)
c
      common /flat_/ flat_image
      common /images/ accum, image, n_image_x, n_image_y
c
      if(include_flat.eq.1) then
         do j = 1, n_image_y
            do i = 1, n_image_x
               accum(i,j) = accum(i,j) + image(i,j)*flat_image(i,j)
            end do
         end do
      else
         do j = 1, n_image_y
            do i = 1, n_image_x
               accum(i,j) = accum(i,j) + image(i,j)
            end do
         end do
      end if
      return
      end
