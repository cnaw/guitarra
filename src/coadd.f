c
c----------------------------------------------------------------------
c
c     modified 2020-06-17 commenting lines for the case
c     that include_flat = 1. Flatfield is applied earlier
c     in the code (flat_multiply in add_up_the_ramp)
c     
c
      subroutine coadd(n_image_x, n_image_y)
c      subroutine coadd(include_flat, n_image_x, n_image_y)
      implicit none
      real    image, accum, flat_image
      double precision mean, sigma, deviate, zbqlnor
c      integer include_flat
      integer n_image_x, n_image_y, nnn, i, j
      parameter (nnn=2048)
      dimension accum(nnn,nnn), image(nnn,nnn),flat_image(nnn,nnn,2)
c
      common /accum_/ accum
      common /flat_/ flat_image
      common /image_/ image
c
c      if(include_flat.eq.1) then
c         do j = 1, n_image_y
c            do i = 1, n_image_x
c               mean    = flat_image(i,j,1)
c               sigma   = flat_image(i,j,2)
c               deviate =  zbqlnor(mean, sigma)
c               accum(i,j) = accum(i,j) + image(i,j)* deviate
c            end do
c         end do
c      else
         do j = 1, n_image_y
            do i = 1, n_image_x
               accum(i,j) = accum(i,j) + image(i,j)
            end do
         end do
c      end if
      return
      end
