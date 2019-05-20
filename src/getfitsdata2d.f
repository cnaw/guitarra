c
c-----------------------------------------------------------------------
c
      subroutine getfitsdata2d(unit,x, ncol,nrow, bitpix,verbose)
      implicit none
      integer nnn, nfound, i, j, ncol, nrow
      integer unit, status,naxes(3), group, bitpix, verbose
      logical  chabu
      double precision dx
      real x
      integer ix
      parameter (nnn=2048)
      dimension x(nnn,nnn), ix(nnn,nnn), dx(nnn, nnn)
      status = 0
c     determine the size of the image
      call ftgknj(unit,'NAXIS',1,3,naxes,nfound,status)
      if(status .ne.0) then
         call printerror(status)
      end if

c     check that it found both NAXIS1 and NAXIS2 keywords
c 5    if (nfound .ne. 3) then
      if(verbose.gt.0) then
         print *,' getfitsdata2d:',
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
               x(i,j) = real(ix(i,j))
            end do
         end do
      end if
      if(bitpix.eq.-32) then
         call ftg2de(unit,group,0,nnn,naxes(1),naxes(2),x, 
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
               x(i,j) = real(dx(i,j))
            end do
         end do
      end if
c      print *, bitpix, ncol, nrow, status,x(ncol/2,nrow/2)
c      pause
      return
      end
