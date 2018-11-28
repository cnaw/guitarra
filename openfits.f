c-----------------------------------------------------------------------
      subroutine openfits(unit, readwrite,filename)
      integer unit, status, readwrite, blocksize
      character filename*(*)
      status=0
c
c     Get an unused Logical Unit Number to use to open the FITS file
c
      call ftgiou(unit,status)
c     to write-enable, readwrite = 1
      call ftopen(unit,filename,readwrite,blocksize,status)

 10   if (status .gt. 0) call printerror(status)
      return
      end
