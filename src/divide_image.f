c     
c     average the accumulated frame by the number of frames that were coadded
c
c     cnaw 2015-01-27
c
c     Steward Observatory, University of Arizona
c 
      subroutine divide_image(nframe)
      implicit none
      integer   frame, n_image_x, n_image_y, nnn, i, j, nframe
      real    image, accum
      parameter (nnn=2048)
      dimension accum(nnn,nnn), image(nnn,nnn)
c
      common /images/ accum, image, n_image_x, n_image_y
c
      if(nframe.eq.1) return
      do j = 1, n_image_y
         do i = 1, n_image_x
            accum(i,j) = accum(i,j)/float(nframe)
         end do
      end do
      return
      end
