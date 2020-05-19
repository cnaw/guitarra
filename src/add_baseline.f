c
c     Add baseline counts (Bias + kTC noise) to a frame before
c     writing out. This keeps the calculation of the linearity 
c     correction cleaner. Input and output units must be in ADU
c     not electrons.
c     
c     "scratch" is the image that contains the accumulated counts
c     corrected for linearity (i.e., made non-linear) [ADU]
c     base_image contains the bias and ktc noise in [ADU]
c
c     Christopher Willmer
c     Steward Observatory
c     cnaw@as.arizona.edu
c     2016-06-30
c
      subroutine add_baseline(subarray, colcornr, rowcornr, 
     &     naxis1, naxis2)
      implicit none
c
      double precision even_odd
      real  base_image, image,  accum, scratch
c
      integer colcornr, rowcornr, naxis1, naxis2
      integer i, j, nnn, istart, iend, jstart, jend, n_image_x,
     &     n_image_y, indx
c     
c      logical subarray
      character subarray*8
c
      parameter(nnn=2048)
c
c     images
c
      dimension base_image(nnn,nnn), scratch(nnn,nnn), even_odd(8)
      common /base/ base_image
      common /scratch_/ scratch 
c      even_odd(1) = 1.d0
c      even_odd(2) = 1.d0
c      even_odd(3) = 1.00682d0
c      even_odd(4) = 1.00682d0
c      even_odd(5) = 0.983038d0
c      even_odd(6) = 0.983038d0
c      even_odd(7) = 1.01164d0
c      even_odd(8) = 1.01164d0
c
c     2018-06-05
      istart = 1
      iend   = naxis1
      jstart = 1
      jend   = naxis2
c
      do j = jstart, jend
         do i = istart, iend 
            scratch(i,j) = scratch(i,j) + base_image(i,j)
c
c     Uncomment if even/odd must be enabled
c
c            indx = 1
c            if(i.gt.1536) indx = 7
c            if(i.gt.1024 .and. i.le.1536) indx = 5
c            if(i.gt. 512 .and. i.le.1024) indx = 3
c            if(mod(i,2).eq.0) indx = indx + 1
c            scratch(i,j) = scratch(i,j) * even_odd(indx)
         end do
      end do
      return
      end
