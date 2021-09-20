      subroutine int_times_header(unit, mjd_utc, bjd_utc, nint, debug)
c     This refers to each NINT integration
c
      implicit none
c     integration_number
c     int_start_MJD_UTC   59558.01047147E+04
c     int_mid_MJD_UTC     59558.01047147E+04      
c     int_end_MJD_UTC     59558.01047147E+04      
c     int_start_BJD_UTC   59558.01047147E+04
c     int_mid_BJD_UTC     59558.01047147E+04      
c     int_end_BJD_UTC     59558.01047147E+04
c      
      integer integration_number, nint, unit, debug
      double precision mjd_utc, bjd_utc, times
c
      integer bitpix, naxis, naxis1, naxis2, pcount, gcount, tfields,
     &     extver, status, blocksize, ii, jj, varidat, colnum,
     &     nrows, frow, felem
      character extname*18, ttype*40, tform*10, tunit*40, comment*40
c     
      dimension mjd_utc(3,nint), bjd_utc(3,nint), ttype(30), tform(30),
     &     tunit(30), integration_number(nint), times(nint)
c
      extname = 'INT_TIMES'
      extver  = 1
      bitpix  = 8
      tfields = 7
      pcount  = 0
      gcount  = 1
      naxis1  = 52
      naxis2  = 1
c
      ttype(1) = 'integration_number'
      tform(1) = 'J'
      tunit(1) = ' '
c     
      ttype(2) = 'int_start_MJD_UTC'
      ttype(3) = 'int_mid_MJD_UTC'
      ttype(4) = 'int_end_MJD_UTC'
c
      ttype(5) = 'int_start_BJD_TDB'
      ttype(6) = 'int_mid_BJD_TDB'
      ttype(7) = 'int_end_BJD_TDB'
c
      do ii = 2, 7
         tform(ii) = 'D'
         tunit(ii) = 'days'
      end do
c     
      status    = 0
      blocksize = 1
      varidat   = 0
      nrows     = naxis2
c      
c     
c     create new empty HDU
c
      call ftcrhd(unit,status)
      if (status .gt. 0) then
         call printerror(status)
         if(debug.eq.1) print *, 'int_times_header ftcrhd: ',status
         stop
      end if
c     
c
c     FTPHBN writes all the required header keywords which define the
c     structure of the binary table. NROWS and TFIELDS gives the number of
c     rows and columns in the table, and the TTYPE, TFORM, and TUNIT arrays
c     give the column name, format, and units, respectively of each column.
c 
      if(debug.gt.0) 
     *     print *,'entering ftphbn', unit, nrows, tfields, status
      call ftphbn(unit,nrows,tfields,ttype,tform,tunit,
     &            extname,varidat,status)
      if(status .ne. 0) then
         print *, 'ftphbn '
         call printerror(status)
      end if
c
      comment = 'Extension version'
      call ftpkyj(unit,'EXTVER',extver,comment,status)
      if (status .gt. 0) then
         print *,'at EXTVER'
         call printerror(status)
      end if
      if(debug.gt.1) print *,'int_time_header: ftpkyj EXTVER', 
     &     unit, '  ',extver, ' ',status
c
      frow= 1 
      felem=1
c
c     first column is integration number
c
      do jj = 1, nint
         integration_number(jj) = jj
      end do
      colnum = 1                !
      call ftpclj(unit,colnum,frow,felem,nint,integration_number,status)
      if(status.ne.0) then 
         call printerror(status)
         if(debug.eq.1) print *,'status after ftpclj 1', status
         status = 0
      end if
c
c     columns 2-4 : MJD times
c
      do ii=1, 3
         colnum=1+ ii           !
         do jj = 1, nint
            times(jj) = mjd_utc(ii,jj)
         end do
         call ftpcld(unit,colnum,frow,felem,nint,times,status)
         if(status.ne.0) then 
            call printerror(status)
            if(debug.eq.1) print *,'status after ftpclj 2', status
            status = 0
         end if
      end do
c
c     columns 5-7 : barycentric times
c
      do ii=1, 3
         colnum=4+ ii           !
         do jj = 1, nint
            times(jj) = bjd_utc(ii,jj)
         end do
         call ftpcld(unit,colnum,frow,felem,nint,times,status)
         if(status.ne.0) then 
            call printerror(status)
            if(debug.eq.1) print *,'status after ftpclj 2', status
            status = 0
         end if
      end do
      return
      end
      
