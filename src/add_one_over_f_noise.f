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
      subroutine add_one_over_f_noise(filename, level,
     *     subarray,colcornr, rowcornr, ncol, nrow)
c    
      implicit none
      real image, accum
      integer nplane, nnn,n_image_x, n_image_y
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
      dimension accum(nnn,nnn),image(nnn,nnn)
c
      common /images/ accum, image, n_image_x, n_image_y
c
      null   = -1
      status = 0
      call ftgiou(unit, status)
c      print *,'add_one_over_f_noise: ',filename
      call ftopen(unit, filename, 1, block, status)

      call ftgkyj(unit,"BITPIX",bitpix,comment, status)
      call printerror(status)
      status = 0
c      print *,'bitpix ', bitpix
      call ftgkyj(unit,"NAXIS",naxis,comment, status)
      call printerror(status)
      status = 0 
      call ftgknj(unit,'NAXIS',1,3,naxes,nfound,status)
c      print 100, naxes
      call printerror(status)
      status = 0 
c      if(debug .eq.1) print *, bitpix, naxes
      nplane      = naxes(3)
c
c     fpixels and lpixels indicate the locations of the first and
c     and last pixels that must be retrieved
c
      fpixels(1) = 1
      lpixels(1) = naxes(1) 
      incs(1)    = 1
c
      fpixels(2) = 1
      lpixels(2) = naxes(2) 
      incs(2)    = 1
c
      fpixels(3) = level
      lpixels(3) = level
      incs(3)    = 1

      group = 1
      call ftgsvj(unit, group, naxis, naxes,
     *      fpixels, lpixels, incs, null, cube, anyf, status)
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
c     there is a bug in the output from nghxrg when output in e-
c     such that 32678 is added when it should not be
c
      do j = j1, j2
         do i = i1, i2
            accum(i,j) = accum(i,j) + cube(i,j,1)- 32678.d0
c            if(i.eq.1 .and. j.eq.1 ) print *, i, j, level, cube(i,j,1)
         end do
      end do
c
      call closefits(unit)
      return
      end
      
      
