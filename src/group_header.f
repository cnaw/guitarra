      subroutine group_header(unit, nints, ngroups, columns, rows, gaps,
     &     group_end_time, time_counter, debug)
      implicit none
      double precision bary_shift, helio_shift
      integer unit, nints, ngroups, columns, rows, gaps, time_counter,
     &     debug
      character group_end_time*23
      dimension group_end_time(time_counter)
c
c     integration_number
c     group_number
c     end_day (3 last digits)  %03d
c     end_milliseconds         %06d
c     end submilliseconds      %03d
c                              12345678901234567890123
c                              1234x12x12x12x12x123456     
c     group_end_time           2021-12-10T00:15:26.209
c     number_of_columns
c     number_of_rows
c     number_of_gaps
c     completion_code_number      0
c     completion_code_text     'Normal Completion'
c     bary_end_time            59558.0107200062E+04
c     helio_end_time           59558.0107200062E+04
      double precision end_time
      double precision bary_end_time, helio_end_time
      integer end_millisec, end_submillisec
      integer integration_number
      character temp*23
c
      integer year, month, day, ih, im
      double precision ut, jday, sec, mjd, submilliseconds,
     &     milliseconds
      
      integer bitpix, naxis, naxis1, naxis2, pcount, gcount, tfields,
     &     extver, status, blocksize, ii, varidat, nrows, frow, felem,
     &     colnum, group, jj, kk
      integer ncols, nr,  end_day, code
      character extname*8, ttype*40, tform*10, tunit*40, text*36,
     &     comment*40
      dimension ttype(200), tform(200), tunit(400)
c     
      dimension columns(200), rows(200), gaps(200),end_time(200),
     &     bary_end_time(200),helio_end_time(200), group(200),
     &     integration_number(200), ncols(200),nr(200),
     &     end_day(200), code(200), text(200),end_millisec(200),
     &     end_submillisec(200)
c
c     this is probably variable...
c      
      bary_shift = 0.0d0
c      
      extname = 'GROUP'
      extver  = 1
      bitpix  = 8
      tfields = 13
      pcount  = 0
      gcount  = 1
      naxis2  = ngroups * nints
      naxis1  = 98
      naxis1  = 114
c
      ttype(1) = 'integration_number'
      tform(1) = 'I'
      tunit(1) = ' '
c     
      ttype(2) = 'group_number'
      tform(2) = 'I'
      tunit(2) = ' '
c     
      ttype(3) = 'end_day'
      tform(3) = 'I'
      tunit(3) = ' '

c     
      ttype(4) = 'end_milliseconds'
      tform(4) = 'J'
      tunit(4) = 'milliseconds'
c     
      ttype(5) = 'end_submilliseconds'
      tform(5) = 'I'
      tunit(5) = 'submilliseconds'
c     
      ttype(6) = 'group_end_time'
      tform(6) = '26A'
      tunit(6) = ' '
c
      ttype(7) = 'number_of_columns'
      tform(7) = 'I'
      tunit(7) = 'pixels'
c
      ttype(8) = 'number_of_rows'
      tform(8) = 'I'
      tunit(8) = 'pixels'
c
      ttype(9) = 'number_of_gaps'
      tform(9) = 'I'
      tunit(9) = ' '
c
      ttype(10) = 'completion_code_number'
      tform(10) = 'I'
      tunit(10) = ' '
c
      ttype(11) = 'completion_code_text'
      tform(11) = '36A'
      tunit(11) = ' '
c
      ttype(12) = 'bary_end_time'
      tform(12) = 'D'
      tunit(12) = ' '
c
      ttype(13) = 'helio_end_time'
      tform(13) = 'D'
      tunit(13) = ' '
c     
      status    = 0
      blocksize = 1
      varidat   = 0
      nrows     = naxis2
c
c      print *,'group header ', nints, ngroups
c      print *,(columns(ii),ii=1, naxis2)
c      print *,(rows(ii),ii=1, naxis2)
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
      if(debug.eq.1) 
     *     print *,'entering ftphbn', unit, nrows, tfields, status
      call ftphbn(unit,nrows,tfields,ttype,tform,tunit,
     &            extname,varidat,status)
      if(status .ne. 0) then
         print *, 'ftphbn '
         call printerror(status)
      end if
c     
      extver = 1
      comment = 'Extension version'
      call ftpkyj(unit,'EXTVER',extver,comment,status)
      if (status .gt. 0) then
         print *,'at EXTVER'
         call printerror(status)
      end if
      if(debug.gt.1) print *,'group_header: ftpkyj EXTVER', 
     &     unit, extver, status
c
      kk =  0
      do jj =1 , nints
         do ii = 1, ngroups
            kk = kk + 1
            integration_number(kk) = jj
c
            group(kk) = ii
c
            temp = group_end_time(kk)
            read(temp, 10) year, month, day, ih, im, sec
 10         format(i4,1x,i2,1x,i2,1x,i2,1x,i2,1x, f6.3)
            ut = ih + im/60.d0 + sec/3600.d0
            call julian_day(year, month, day, ut, jday, mjd)


            end_day(kk)=idint(((mjd/1000.d0)-idint(mjd/1000.d0))*1000)
            milliseconds = (mjd - idint(mjd)) * 86400.d0 *1000.d0
            end_millisec(kk) = idint(milliseconds)
            submilliseconds = milliseconds - end_millisec(kk)
            end_submillisec(kk) = idint(submilliseconds*1000.d0)
c            print *, mjd, end_day(kk), milliseconds, end_millisec(kk),
c     &           end_submillisec(kk) 
c            
            ncols(kk) = columns(kk)
            nr(kk)    = rows(kk)
            code(kk)  = 0
            text(kk)  = 'Normal Completion'
            bary_end_time(kk)  = mjd + bary_shift
            helio_end_time(kk) = mjd + helio_shift
c            print *,'group_header: group_end_time ',
c     &           kk,integration_number(kk),group(kk), group_end_time(kk)
c     &           , ncols(kk), nr(kk)
            
         end do
      end do
c
      frow= 1 
      felem=1
c
c     first column is integration number
c
      colnum = 1
      call ftpclj(unit,colnum,frow,felem,naxis2,integration_number,
     &     status)
      if(status.ne.0) then 
         call printerror(status)
         if(debug.eq.1) print *,'status after ftpclj 1', status
         status = 0
      end if
c
c     group number
c      
      colnum = 2
      call ftpclj(unit,colnum,frow,felem,naxis2,group,status)
c      print *,(group(ii),ii=1, naxis2)
      if(status.ne.0) then 
         call printerror(status)
         if(debug.eq.1) print *,'status after ftpclj 2', status
         status = 0
      end if
c
c     end day
c      
      colnum = 3
      call ftpclj(unit,colnum,frow,felem,naxis2,end_day,status)
      if(status.ne.0) then 
         call printerror(status)
         if(debug.eq.1) print *,'status after ftpclj 2', status
         status = 0
      end if
c
c     end milliseconds
c      
      colnum = 4
      call ftpclj(unit,colnum,frow,felem,naxis2,end_millisec,status)
      if(status.ne.0) then 
         call printerror(status)
         if(debug.eq.1) print *,'status after ftpclj 2', status
         status = 0
      end if
c
c     end submilliseconds
c      
      colnum = 5
      call ftpclj(unit,colnum,frow,felem,naxis2,end_submillisec,status)
      if(status.ne.0) then 
         call printerror(status)
         if(debug.eq.1) print *,'status after ftpclj 2', status
         status = 0
      end if
c
c     group_end_time
c      
      colnum = 6
      call ftpcls(unit,colnum,frow,felem,naxis2,group_end_time,status)
      if(status.ne.0) then 
         call printerror(status)
         if(debug.eq.1) print *,'status after ftpclj 2', status
         status = 0
      end if
c
c     number of columns
c      
      colnum = 7
      call ftpclj(unit,colnum,frow,felem,naxis2,ncols,status)
c      print *,(ncols(ii),ii=1, naxis2)
      if(status.ne.0) then 
         call printerror(status)
         if(debug.eq.1) print *,'status after ftpclj 2', status
         status = 0
      end if
c
c     number of rows
c      
      colnum = 8
      call ftpclj(unit,colnum,frow,felem,naxis2,nr,status)
c      print *,(nr(ii),ii=1, naxis2)
      if(status.ne.0) then 
         call printerror(status)
         if(debug.eq.1) print *,'status after ftpclj 2', status
         status = 0
      end if
c
c     number of gaps
c      
      colnum = 9
      call ftpclj(unit,colnum,frow,felem,naxis2,gaps,status)
      if(status.ne.0) then 
         call printerror(status)
         if(debug.eq.1) print *,'status after ftpclj 2', status
         status = 0
      end if
c
c     completion code number
c      
      colnum = 10
      call ftpclj(unit,colnum,frow,felem,naxis2,code,status)
      if(status.ne.0) then 
         call printerror(status)
         if(debug.eq.1) print *,'status after ftpclj 2', status
         status = 0
      end if
c
c     completion code text
c      
      colnum = 11
      call ftpcls(unit,colnum,frow,felem,naxis2,text,status)
      if(status.ne.0) then 
         call printerror(status)
         if(debug.eq.1) print *,'status after ftpclj 2', status
         status = 0
      end if
c
c      bary end time
c      
      colnum = 12
      call ftpcld(unit,colnum,frow,felem,naxis2,bary_end_time,status)
      if(status.ne.0) then 
         call printerror(status)
         if(debug.eq.1) print *,'status after ftpclj 2', status
         status = 0
      end if
c
c      helio end time
c      
      colnum = 13
      call ftpcld(unit,colnum,frow,felem,naxis2,helio_end_time,status)
      if(status.ne.0) then 
         call printerror(status)
         if(debug.eq.1) print *,'status after ftpclj 2', status
         status = 0
      end if
c
      return
      end
      
