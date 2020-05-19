c      implicit none
c      real image, accum
c      integer nnn,n_image_x, n_image_y
c      integer nframe
c      integer colcornr, rowcornr, naxis1, naxis2
c      logical subarray
c      character*120 noise_name
cc
c      parameter(nnn=2048)
cc      
c      dimension accum(nnn,nnn),image(nnn,nnn)
cc
c      common /images/ accum, image, n_image_x, n_image_y
cc   
c      noise_name = 'ex_rdnoise_mp.fits'
c      
c      subarray = .false.
c      colcornr = 1
c      rowcornr = 1
c      naxis1   = 2048
c      naxis2   = 2048
c
c      nframe   = 108
c      
c      
c      call add_one_over_f_noise(noise_name, nframe,
c     *     subarray,colcornr, rowcornr, naxis1, naxis2)
c      stop
c      end
c     
c-----------------------------------------------------------------------
c
      subroutine flat_multiply(subarray,colcornr, rowcornr, ncol, nrow)
c    
      implicit none
      real image, flat_image
      integer nplane, nnn
      integer colcornr, rowcornr, ncol, nrow, level
      integer unit, status, bitpix, naxis,naxes,pcount, gcount,group,
     *     block, colnum, i1, i2, j1, j2, i, j, nfound, debug
      integer frow, felem, fpixels, lpixels, incs
      integer cube, null

      character filename*180, comment*40
      logical anyf
      character subarray*8
c
      parameter(nnn=2048)
c     
      dimension naxes(3), fpixels(3), lpixels(3), incs(3)
      dimension cube(nnn,nnn,1)
      dimension image(nnn,nnn), flat_image(nnn,nnn,2)
c
      common /image_/ image
      common /flat_/ flat_image
c
      if(subarray .ne. 'FULL') then
         i1 = colcornr
         i2 = i1 + ncol
         j1 = rowcornr
         j2 = j1 + nrow
      else
         i1 = 1
         i2 = naxes(1)
         j1 = 1
         j2 = naxes(2)
      end if
c     
      do j = j1, j2
         do i = i1, i2
            image(i,j) = image(i,j) * flat_image(i,j,1)
         end do
      end do
      return
      end
      
      
