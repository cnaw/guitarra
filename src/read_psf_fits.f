c
c-----------------------------------------------------------------------
c
      subroutine read_psf_fits(filename, image, nx, ny, 
     &     det_samp, pixel_scale, verbose)
      implicit none
      double precision pixel_scale
      real image
      integer unit, status, bitpix, det_samp, nnn, nx, ny, ncol, nrow,
     &     readwrite, verbose
      character name*20, comment*40
      character filename*(*)
c
      parameter (nnn=2048)
c
      dimension image(nnn,nnn)
c
      status    = 0
      readwrite = 0
      call ftgiou(unit, status)
      if(verbose.gt.1) print *,'read_psf_fits : unit, status',
     &     unit, status
      call openfits(unit, readwrite, filename)
      call ftgkyj(unit,"BITPIX",bitpix,comment, status)
      if(verbose.gt.1) print 40, filename
 40   format('read_psf_fits: reading file ', a80)
      call  ftgkyj(unit,"DET_SAMP",det_samp,comment, status)
      if(status.ne.0) then
         print *,'DET_SAMP'
         call printerror(status)
         det_samp = 0
         status = 0
      end if
c
      call  ftgkyd(unit,"PIXELSCL",pixel_scale,comment, status)
      if(status.ne.0) then
         print *,'PIXELSCL'
         call printerror(status)
         det_samp = 0
         status = 0
      end if
      call getfitsdata2d(unit,image,ncol,nrow, bitpix, verbose)
      call closefits(unit)
      nx = ncol
      ny = nrow
      return
      end
c
      
