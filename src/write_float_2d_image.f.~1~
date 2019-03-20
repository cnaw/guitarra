c
c----------------------------------------------------------------------     
c
      subroutine write_float_2d_image(filename, image, 
     *     naxis1, naxis2, bitpix,
     *     nframe, tframe, groupgap, tgroup, ngroup, object, partname, 
     *     sca_id, module, filter, 
     *     subarray, colcornr, rowcornr,job)

c
      implicit none
      character telescop*20, instrume*20, filter*20,
     *     module*20, partname*4,comment*40, object*20      
      real image
      double precision tframe, tgroup
      integer status, bitpix, naxes, naxis, pcount, gcount, block,
     *     groupgap, group, sca_id, nframe, ngroup,
     *     nnn, job, iunit
      logical simple,extend
c      logical subarray
      character subarray*8
      integer colcornr, rowcornr, naxis1, naxis2
      character filename*120
c
      parameter (nnn=2048)
c
      dimension image(nnn,nnn),naxes(2)
c
c     define the required primary array keywords
c
      bitpix   = -32
      simple   = .true.
      extend   = .true.
      naxis    =  2
      naxes(1) = naxis1
      naxes(2) = naxis2
c
      status = 0
      iunit = 91
      call ftgiou(iunit, status)
      if (status .gt. 0) then 
         call printerror(status)
         print *,'iunit ',iunit, status
         stop
      end if
c     
c     delete previous version of the file, if it exists
c
      call ftopen(iunit, filename, 1, block, status)
      if (status .eq. 0) then
         call ftdelt(iunit, status)
      else
c     clear the error message stack
         call ftcmsg
      end if
      status = 0
c
c     create the fits file
c
      call ftinit(iunit, filename, 1, status)
      if (status .gt. 0) then 
         call printerror(status)
         print *,'iunit ',iunit
         print *,'pause: enter return to continue'
         read(*,'(A)')
      endif
      status =  0
c     
      call ftphpr(iunit,simple, bitpix, naxis, naxes, 
     & 0,1,extend,status)
      if (status .gt. 0) then
         print *, 'simple,bitpix,naxis'
         call printerror(status)
      end if
      status =  0
c
c     write more header keywords
c
      call write_nircam_keywords(iunit,nframe, 
     *     real(tframe), groupgap, real(tgroup), 
     *     ngroup, object, partname, sca_id,module, filter, 
     *     subarray, colcornr, rowcornr, naxis1, naxis2, job)
c
c     Write out image
c
      print *,'write float matrix'
      group=0
      call ftp2de(iunit,group,nnn, naxes(1),naxes(2),
     *     image,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'writing images'
      end if
c     
      call closefits(iunit)
      return
      end
