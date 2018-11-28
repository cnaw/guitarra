c
c-----------------------------------------------------------------------
c
c     Read linearity image
c     The count level is assumed to be in electrons and should already
c     been subtracted of the bias level counts
c
c     cnaw 2015-04-07
c     Steward Observatory, University of Arizona
c
      subroutine read_linearity(fits_file, linearity, nnn, mmm, nlin,
     *     linearity_gain, order, lincut, wellfact, verbose)
      implicit none
      real linearity, null
      double precision linearity_gain, wellfact, lincut
      double precision ave, disp, n, temp
      integer nnn, mmm, nlin, unit, naxis1, naxis2, naxis3, group,
     *     status, naxes, readwrite, blocksize, nfound, order, nhdu,
     *     hdutype, dq, int_null, i, j, ii, jj, good, verbose
      integer max_order
      character fits_file*120, comment*20
      logical chabu
c
      parameter(max_order = 7)
c
      dimension linearity(nnn,mmm,max_order), naxes(3), dq(2048,2048)
c
      status    = 0
      readwrite = 0
      blocksize = 2880
c
      call ftgiou(unit, status)
      if (status .gt. 0) then
         call printerror(status)
      end if
c
      call ftopen(unit,fits_file,readwrite,blocksize,status)
      if (status .gt. 0) then
         print *, 'error reading linearity table'
         print 10, fits_file
 10      format(a120)
         call printerror(status)
      end if
c
c     read some parameters for header 1
c
      nhdu  = 1
      call ftmahd( unit, nhdu, hdutype, status)
c
c     Starting with CV3 there is no linearity_gain being used
c
c      call ftgkyd(unit,'GAIN',linearity_gain,comment,status)
c      if(status .ne.0) then
c         print *,'GAIN'
c         call printerror(status)
c         status = 0
c         linearity_gain = 2.d0
c      end if
c
      call ftgkyd(unit,'LINCUT',lincut,comment,status)
      if(status .ne.0) then
         print *,'LINCUT'
         call printerror(status)
         status = 0
      end if
c
      call ftgkyd(unit,'WELLFACT',wellfact,comment,status)
      if(status .ne.0) then
         print *,'WELLFACT'
         call printerror(status)
         status = 0
      end if
c
      call ftgkyj(unit,'ORDER',order,comment,status)
      if(status .ne.0) then
         print *,'ORDER'
         call printerror(status)
         status = 0
      end if
c
c     move to header 2, read polynomial coefficients
c     
      nhdu  = 2
      call ftmahd( unit, nhdu, hdutype, status)
c
c     determine the size of the image
c     
      call ftgknj(unit,'NAXIS',1,3,naxes,nfound,status)
      if(status .ne.0) then
         call printerror(status)
      end if
      naxis1 = naxes(1)
      naxis2 = naxes(2)
      naxis3 = naxes(3)
c
      if(verbose.gt.0) then
c         print *,'gain   used in linearity table ', linearity_gain
         print *,'order  used in linearity table ', order
         print *,'naxis3                         ', naxis3
         print *,'lincut used in linearity table ', lincut
      end if
      group = 1
      null  = 0.0
      call ftg3de(unit, group, null, nnn, mmm, naxis1, naxis2,
     *     naxis3, linearity, chabu, status)
      if(chabu .eqv. .true.) then
         print *,'read_linearity: header chabu', nhdu, chabu
      end if
      if(status.ne.0) then
         print *,' read_linearity',status
         call printerror(status)
      end if
c
c     move to header 4, read data quality coefficients
c     
      nhdu  = 4
      call ftmahd( unit, nhdu, hdutype, status)
      int_null = 65
      call ftg2dj(unit, group, int_null, 2048, naxis1, naxis2,
     *     dq, chabu, status)
      if(chabu .eqv. .true.) then
         print *,'read_linearity: header chabu', nhdu, chabu
      end if
      if(status.ne.0) then
         print *,' read_linearity',status
         call printerror(status)
      end if
      do j = 1, naxis2
         do i = 1, naxis1
            linearity(i,j,order+2) = dq(i,j)
         end do
      end do
c
c     close fits file and release logical unit
c
      call ftclos(unit, status)
      call ftfiou(unit, status)
c
c     do some fixing (maybe a bad idea)
c
      do j = 1, naxis2
         do i = 1, naxis1
            good = 1
            temp = linearity(i,j,1)
            if(temp+0.0 .ne. temp) good = 0
            if(temp+1.0 .eq. temp) good = 0
            if(good.eq.0) then
               ave = 0.0d0
               disp = 0.0d0
               n    = 0.0d0
               do jj = j -2, j + 2
                  do ii = i-2, i+ 2
                     good = 1
                     temp = linearity(ii,jj,1)
                     if(temp+0.0 .ne. temp) good = 0
                     if(temp+1.0 .eq. temp) good = 0
                     if(good.eq.1) then
                        ave = ave + temp
                        disp = disp + temp**2
                        n   = n + 1.d0
                     end if
                  end do
               end do
               if(n.ge.1) then
                  ave = ave/n
                  disp = dsqrt(disp/n-ave**2)
                  linearity(i,j,1) = ave
               end if
            end if
         end do
      end do
      return
      end
