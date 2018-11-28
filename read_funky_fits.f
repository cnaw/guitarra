c
c-----------------------------------------------------------------------
c
      subroutine read_funky_fits(filename, image, nx, ny, nhdu,
     *     verbose)
      real image
      integer unit, status, bitpix, hdutype, verbose, readwrite
      character name*20, comment*80
      character filename*80
c
      parameter (nnn=2048)
c
      dimension image(nnn,nnn)
c
      status = 0
      readwrite = 0
      call ftgiou(unit, status)
      if(verbose.gt.0) print *,'read_fits : unit, status',unit, status
      call openfits(unit, readwrite,filename)
      if(verbose.gt.0) print 40, filename
 40   format('read_funky_fits: reading file ', a80)
c
      call ftmahd( unit, nhdu, hdutype, status)
c
      call ftgkyj(unit,"BITPIX",bitpix,comment, status)
      if(verbose.gt.0) print 50, bitpix
 50   format('read_funky_fits:BITPIX ', i4)
      call getfitsdata2d(unit,image,ncol,nrow, bitpix,verbose)
      call closefits(unit)
c    
      nx = ncol
      ny = nrow
      return
      end
