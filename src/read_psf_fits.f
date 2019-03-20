c
c-----------------------------------------------------------------------
c
      subroutine read_psf_fits(filename, image,dx, ix,  nx, ny, 
     &     det_samp, pixel_scale, nnn,verbose)
      implicit none
      double precision pixel_scale
      double precision dx
      integer ix, naxes
      real image
      integer unit, status, bitpix, det_samp, nnn, nx, ny, ncol, nrow,
     &     readwrite, verbose, group, i, j, nfound
      character name*20, comment*40
      character filename*(*)
      logical chabu
c
      dimension image(nnn,nnn), dx(nnn,nnn), ix(nnn, nnn), naxes(3)

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
c
c     determine the size of the image
c
      call ftgknj(unit,'NAXIS',1,3,naxes,nfound,status)
      if(status .ne.0) then
         call printerror(status)
      end if
c
c     check that it found both NAXIS1 and NAXIS2 keywords
c 5    if (nfound .ne. 3) then
      if(verbose.gt.0) then
         print *,' read_psf_fits:',
     *        'This is the number of NAXISn keywords.', 
     *        nfound, (naxes(i),i=1,nfound)
      end if
      group=1
      ncol = naxes(1)
      nrow = max(1,naxes(2))
      if(bitpix.eq.16 .or.bitpix.eq.32) then
         call ftg2dj(unit,group,0,nnn,naxes(1),naxes(2),ix, 
     *        chabu, status)
         if(status.ne.0) then
            print *,'read_fits:getfitsdata2d :ftg2dj',nnn
            call printerror(status)
         end if
         do i = 1, ncol
            do j = 1, nrow
               image(i,j) = real(ix(i,j))
            end do
         end do
      end if
      if(bitpix.eq.-32) then
         call ftg2de(unit,group,0,nnn,naxes(1),naxes(2),image, 
     *        chabu, status)
         if(status .ne.0) then
            print *,'read_fits:getfitsdata2d :ftg2de',nnn
            call printerror(status)
         end if
      end if
c
      if(bitpix.eq.-64) then
         call ftg2dd(unit,group,0,nnn,naxes(1),naxes(2),dx, 
     *        chabu, status)
         if(status .ne.0) then
            print *,'read_fits:getfitsdata2d :ftg2dd',nnn
            call printerror(status)
         end if
         do i = 1, ncol
            do j = 1, nrow
               image(i,j) = real(dx(i,j))
            end do
         end do
      end if
      call closefits(unit)
      nx = ncol
      ny = nrow
      return
      end
c
      
