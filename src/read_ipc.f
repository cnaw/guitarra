c      character filename*180
c      double precision ipc
c      integer jj, ii
c      dimension ipc(3,3)
c      filename = '/home/cnaw/guitarra/data/IPC/NRCA1_17004_IPCDeconvolut
c     &ionKernel_2015-09-14.fits'
c      filename = '/home/cnaw/guitarra/data/IPC/NRCA1_17004_IPCDeconvolut
c     &ionKernel_2016-03-18.fits'
c      print 10, filename
c 10   format(a180)
c
c      call read_ipc(filename, ipc)
c      do jj = 1, 3
c         print 20, (ipc(ii,jj),ii=1,3)
c 20      format(3(2x,f12.8))
c      end do
c      stop
c      end
c
c
      subroutine read_ipc(filename, ipc)
      character filename*180, keyword*8, comment*40
      integer unit, status, bitpix, readwrite, block
      double precision alpha, beta, ipc
      dimension ipc(3,3)
c
      status = 0
      readwrite = 0
      call ftgiou(unit, status)
      if(verbose.gt.1) print *,'read_ipc: unit, status',
     &     unit, status
      call openfits(unit, readwrite, filename)
c
      keyword = 'ALPHA'
      call  ftgkyd(unit,keyword,alpha,comment, status)
      if(status.ne.0) then
         print 10, keyword
 10      format('read_ipc :',a10)
         call printerror(status)
         stop
      end if
c
      keyword = 'BETA'
      call  ftgkyd(unit,keyword,beta,comment, status)
      if(status.ne.0) then
         print 10, keyword
         call printerror(status)
         stop
      end if
c
      call closefits(unit)
c
c     now build the IPC matrix
c
      ipc(1,1) = beta
      ipc(2,1) = alpha
      ipc(3,1) = beta
      ipc(1,2) = alpha
      ipc(2,2) = 1.d0 - 4.d0*alpha - 4.d0*beta
      ipc(3,2) = alpha
      ipc(1,3) = beta
      ipc(2,3) = alpha
      ipc(3,3) = beta
c
      return
      end

      
