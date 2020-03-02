c     
c     average the accumulated frame by the number of frames that were coadded
c     cnaw 2015-01-27
c     convert into ADU
c     cnaw 2020-02-24
c      
c     Steward Observatory, University of Arizona
c 
      subroutine divide_image(nframe, gain_cv3)
      implicit none
      integer   frame, n_image_x, n_image_y, nnn, i, j, nframe
      real    image, accum, scratch
      double precision gain_cv3
      parameter (nnn=2048)
      dimension accum(nnn,nnn), image(nnn,nnn), scratch(nnn,nnn)
c
      common /scratch_/ scratch
      common /images/ accum, image, n_image_x, n_image_y
c
      if(nframe.eq.1) return
      do j = 1, n_image_y
         do i = 1, n_image_x
            scratch(i,j) = scratch(i,j)/float(nframe)
            scratch(i,j) = scratch(i,j)/gain_cv3 ! e- --> ADU
         end do
      end do
      return
      end
