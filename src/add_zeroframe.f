      subroutine add_zeroframe(subarray, colcornr, rowcornr, 
     &     naxis1, naxis2, max_nint, nint, gain_cv3, zero_frames)
      implicit none
c
      double precision gain_cv3
      real  base_image, image,  accum, scratch
      integer zero_frames
c
      integer colcornr, rowcornr, naxis1, naxis2
      integer i, j, nnn, istart, iend, jstart, jend, n_image_x,
     &     n_image_y, indx, ii, jj, max_nint, nint
c     
      character subarray*8
c
      parameter(nnn=2048)
c
c     images
c
      dimension base_image(nnn,nnn), scratch(nnn,nnn),
     &     zero_frames(nnn,nnn,max_nint)
      common /base/ base_image
      common /scratch_/ scratch 
c
      istart = 1 
      iend   = naxis1
      jstart = 1 
      jend   = naxis2 
c
      do j = jstart, jend
         jj = j + rowcornr -1
         do i = istart, iend 
            ii = i + colcornr - 1
            zero_frames(i,j,nint)=
     &           ((scratch(i,j)/gain_cv3)+base_image(ii,jj))+0.5
         end do
      end do
      return
      end
