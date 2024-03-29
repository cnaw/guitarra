      subroutine write_zero_frame(unit, extnum, naxis1, naxis2,
     *      nints, nnn, max_nint, int_image, zero_frames,
     *     det_sci_parity, det_sign, 
     &     x_det_ref, y_det_ref,
     &     x_sci_ref, y_sci_ref, x_sci_size, y_sci_size,
     &     dms, verbose)
      implicit none
      double precision bscale, bzero
      integer unit, extnum, naxis1, naxis2, nints, nnn, max_nint,verbose
      integer zero_frames,  int_image
      integer bitpix, naxes, naxis, status, nullval, pcount, group,
     &      hdn, nhdu, hdutype
      integer k, j, i, ii, jj, ll, mm, nn
      integer fpixels, lpixels
      logical dms, simple, extend
      integer det_sci_parity,colcornr, rowcornr
      double precision det_sign,  x_sci_size, y_sci_size,
     &     x_det_ref, y_det_ref, x_sci_ref, y_sci_ref
      character extname*20, comment*40, keyword*8, value*60
c
      dimension fpixels(3), lpixels(3), naxes(3),
     &     int_image(nnn,nnn,nints), zero_frames(nnn,nnn, max_nint)
      
      if(verbose.gt.0) print *,'write_zero_frame'
      bscale  =      1.d0
      bzero   =  32768.d0
      extname = 'ZEROFRAME'
      simple  = .true.
      extend  = .true.
      bitpix    = 16
      naxes(1)  = naxis1
      naxes(2)  = naxis2
      naxes(3)  = nints
      naxis     = 3
c
      pcount     = 0
      group      = 1
      nullval    = 0
      fpixels(1) = 1
      fpixels(2) = 1
      fpixels(3) = 1
      lpixels(1) = nnn
      lpixels(2) = nnn
      lpixels(3) = naxes(3)
c
      colcornr = x_det_ref - x_sci_size/2.d0 + 1
      rowcornr = y_det_ref - y_sci_size/2.d0 + 1

      do k = 1, nints
         do j = 1, naxes(2)
            jj = j + rowcornr -1
            do i = 1, naxes(1)
               if(dms .eqv. .true.) then
                  ii = i + colcornr -1
                  nn =int(det_sign*(jj-y_det_ref)+y_sci_ref)
                  mm =
     &          int(det_sci_parity*det_sign*(ii-x_det_ref)+x_sci_ref)
               else
                  mm = i
                  nn = j
               end if
               int_image(mm,nn,k) = zero_frames(i, j, k)
               if(int_image(mm,nn, k) .gt. 65535) then
                  int_image(mm,nn,k) = 65535
               end if
               if(int_image(mm,nn,k) .lt.0) then
                  int_image(mm,nn,k) = 0
               end if
            end do
         end do
      end do
c     
c     create a new image extension
c     
      status = 0
c
      
      call ftthdu(unit, nhdu, status)
      if(status.ne.0) then
         print *,'write_zero_frame: ftthdu ', status
         call printerror(status)
      end if
      call ftmahd(unit,nhdu, hdutype,status)
      print *,'write_zero_frame:dms unit, nhdu ', unit, nhdu, hdutype,
     &     status
c
      call ftcrhd(unit, status)
      if(status.ne.0) then
         print *,'write_zero_frame: ftcrhd ', status
         call printerror(status)
         stop
      end if
      
      call ftphpr(unit,simple,bitpix,naxis,naxes,
     &     pcount,group,extend, status)
      if(status.ne.0) then
         print *,'write_zero_frame: ftphpr ',status
         call printerror(status)
         stop
      end if
      comment = 'ZEROFRAME'
c
      call ftthdu(unit, nhdu, status)
      extnum = nhdu
      keyword = 'EXTNUM'
      call ftpkyj(unit,keyword, extnum, comment, status)
      if (status .gt. 0) then
         print *,'write_zero_frame : ftpkyj ', keyword,' ',status
         call printerror(status)
         stop
      end if
c
      keyword = 'EXTNAME'
      call ftpkys(unit,keyword, extname, comment, status)
      if (status .gt. 0) then
         print *,'write_zero_frame : ftpkys ', keyword,' ',status
         call printerror(status)
         stop
      end if
c     
      call ftpkyd(unit,'BSCALE',bscale,-7,comment,status)
      if (status .gt. 0) then
         print *,'write_zero_frame BSCALE'
         call printerror(status)
      end if
      status = 0
c     
      call ftpkyd(unit,'BZERO',bzero,-7,comment,status)
      if (status .gt. 0) then
         print *,'write_zero_frame BZERO'
         call printerror(status)
      end if
c
      status = 0
      call ftpscl(unit, bscale, bzero,status)
      if (status .gt. 0) then
         print *,'write_zero_frame at ftpscl ', status
         call printerror(status)
      end if
c     
      if(nints .eq.1) then
         call ftp2dj(unit, group, nnn, naxes(1),
     &        naxes(2), int_image, status)
      else
         call ftp3dj(unit, group, nnn, nnn, naxes(1),
     &        naxes(2), naxes(3),int_image, status)
      end if
      if (status .gt. 0) then
         print *,'write_zero_frame at ftp2dj/ftp3dj ', status
         call printerror(status)
         stop
      end if
      return
      end
