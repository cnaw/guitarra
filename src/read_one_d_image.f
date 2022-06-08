c
c--------------------------------------------------------------------
c
      subroutine read_one_d_image(filename, filter, one_d, nxny, npts,
     &     ra, dec, redshift, magnitude, zp_filter,
     &     scale_0, scale_z, nx, ny,
     &     source_filter, wl_source_filter,verbose)
      implicit none
      double precision one_d, scale_0, scale_z, ra, dec, redshift,
     &     magnitude, dnull, zp_filter, wl_source_filter
      integer nxny, npts, nx, ny, verbose, hdutype, extver
      character filename*(*), comment*40, filter*(*), extname*20,
     &     string*6, source_filter*(*)
      logical simple, extend, chabu
c
      integer naxis, naxes, bitpix, block, fpixel, group, 
     &     status, unit, readwrite, hdunum, ii
c
      dimension naxes(1), one_d(nxny)
c
      dnull     = -999.d0
      fpixel    =   1
      group     =   0
      status    =   0
      readwrite =   0
      hdutype   =   0
      extver    =   0
      ra        =  0.d0
      dec       =  0.d0
      redshift  =  0.d0
      magnitude =  0.d0
      zp_filter =  0.d0
      scale_z   =  0.d0
      nx        =  0
      ny        =  0
      if(verbose.ge.1)  print *, 'read_one_d_image ', filename
      call openfits(unit, readwrite, filename)
c
c      call ftgkys(unit,'FILTER',string,comment,status)
c      if (status .gt. 0) then
c         print *, 'ftgkys '
c         call printerror(status)
c         stop
c      end if
c      if(trim(string) .eq. trim(filter)) then
c         if(verbose.ge.1)
c     &        print *,'read_one_d_image ',string, ' ', filter
c         go to 60
c      else
c         call ftthdu(unit, hdunum, status)
c         do ii = 1, hdunum-1
c            print *, 'read_one_d_image: ii ', ii
c            call ftmrhd(unit,1,  hdutype,status)
c            print *, ii, hdutype, status
c            call ftgkys(unit,'FILTER',string,comment,status)
c            if (status .gt. 0) then
c               print *, 'ftgkys '
c               call printerror(status)
c               stop
c            endif
c         end do
c         print *,'read_one_d_image ',string, ' ', filter
c      end if
c     
 60   continue
c      call ftmnhd(unit, hdutype, extname, extver, status)
c      if (status .gt. 0) then
c         call printerror(status)
c         if(status.eq. 301) then
c            print 30,  extname , trim(filename)
c 30         format('filter', a6,2x,'not contained in ',A)
c            call closefits(unit)
c            return
c         else
c            print *, 'ftmnhd', hdutype
c         end if
c      end if

      call ftgipr(unit,2, bitpix, naxis, naxes, status)
      if(verbose.ge.1) then
         print *,'read_one_d_image ', bitpix, naxis, naxes, status
      end if

      npts = naxes(1)
      call ftgkyj(unit,'NX',nx,comment,status)
      if (status .gt. 0) then
         print *, 'nx'
         call printerror(status)
         print *, 'nx'
         stop
      end if
      if(verbose.ge.1) print *,'read_one_d_image: NX ', NX
c
      call ftgkyj(unit,'NY',ny,comment,status)
      if (status .gt. 0) then
         print *, 'ny'
         call printerror(status)
         print *, 'ny'
         stop
      end if
      if(verbose.ge.1) print *,'read_one_d_image: NX ', NY
c
      call ftgkyd(unit,'RA',ra,comment,status)
      if (status .gt. 0) then
         print *, 'ra'
         call printerror(status)
         status = 0
      end if
      if(verbose.ge.1) print *,'read_one_d_image: RA ', ra, status
c
      call ftgkyd(unit,'DEC',dec,comment,status)
      if (status .gt. 0) then
         print *, 'dec'
         call printerror(status)
         status = 0
      end if
      if(verbose.ge.1) print *,'read_one_d_image: DEC ', dec, status
c
      call ftgkyd(unit,'REDSHIFT',redshift,comment,status)
      if (status .gt. 0) then
         print *, 'redshift'
         call printerror(status)
         status = 0
      end if
      if(verbose.ge.1) print *,'read_one_d_image: REDSHIFT ', redshift
c
      call ftgkyd(unit,'MAGNITUDE',magnitude,comment,status)
      if (status .gt. 0) then
         print *, 'magnitude'
         call printerror(status)
         status = 0
      end if
      if(verbose.ge.1)
     &     print *,'read_one_d_image: MAGNITUDE ', magnitude, status
c
      call ftgkyd(unit,'SCALE_0',scale_0,comment,status)
      if (status .gt. 0) then
         print *, 'scale_0'
         call printerror(status)
         print *, 'scale_0'
         stop
      end if
cc  
c      call ftgkyd(unit,'SCALE_Z',scale_z,comment,status)
c      if (status .gt. 0) then
c         print *, 'scale_z'
c         call printerror(status)
c         print *, 'scale_z'
c         stop
c      end if
cc
c      call ftgkyd(unit,'WL_SFILT',wl_source_filter,comment,status)
c      if (status .gt. 0) then
c         print *, 'read_one_d_image: WL_SFILT'
c         call printerror(status)
c         stop
c      end if
c!
c      call ftgkyd(unit,'ZP',zp_filter,comment, status)
c      if (status .gt. 0) then
c         print *, 'read_one_d_image : zp_filter'
c         call printerror(status)
c         stop
c      end if
cc
c      call ftgkys(unit,'SFILT',source_filter,comment,status)
c      if (status .gt. 0) then
c         print *, 'read_one_d_image: source_filter: SFILT'
c         call printerror(status)
c         stop
c      end if
cc
      call ftgpvd(unit,group,fpixel,npts,dnull,one_d,chabu,status)
      if (status .gt. 0) then
         print *, 'ftgpvd'
         call printerror(status)
         stop
      end if
c
      call closefits(unit)
      return
      end
