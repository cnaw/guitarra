c-----------------------------------------------------------------------
      subroutine closefits(unit)
      integer unit, status
 1    status=0

C     close the file, 
 9    call ftclos(unit, status)
c     release this logical unit
      call ftfiou(unit,status)

 10   if (status .gt. 0) call printerror(status)
      return
      end
