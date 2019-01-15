      subroutine data_model_fits(iunit,filename, verbose)
c
c     Open fits file FILENAME. If file exists and clobber it.
c     
c     cnaw@as.arizona.edu
c     2017-04-27
c
      implicit none
      integer iunit, status, block, readwrite, verbose
      character filename*(*)
c
c     Get an unused Logical Unit Number to use to open the FITS file
c
      status = 0
      call ftgiou(iunit, status)
      if (status .gt. 0) call printerror(status)
      if(verbose.ge.2) then
         print *,'data_model_fits iunit', iunit
         print 10, filename
 10      format(a180)
      end if
c
c     delete previous version of the file, if it exists
c
      if(verbose.ge.2) print *,'data_model_fits ftopen'
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
      if(verbose.ge.2) print *,'data_model_fits ftinit'
      call ftinit(iunit, filename, 1, status)
      if (status .gt. 0) then 
         call printerror(status)
         print *,'pause: enter return to continue'
         read(*,'(A)')
      endif
c
      if(status.ne.0) stop
      return
      end
