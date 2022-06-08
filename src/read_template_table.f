      subroutine read_template_table(unit, filter, wl_filter,
     &     magnitude, zp, source,nf, nnn, hdu, verbose)
      implicit none
      character filter*6
      integer nf, nnn, verbose
      double precision wl_filter, magnitude, zp
c
      logical anynull
      character ttype*16, tform*16, tunit*16
      character comment*40, nullstr*1, source*120
      integer hdu, hdutype, naxis2, nfound, status, tfields, tsize,unit
      integer colnum, felem, nelems, ii, irow, nullj
      double precision nulld
c
      parameter(tsize=30)
c
      dimension ttype(tsize),tform(tsize), tunit(tsize)
      dimension filter(nnn), wl_filter(nnn), magnitude(nnn), zp(nnn),
     &     source(nnn)

c     
c     Move to the desired extension
c
      status = 0
      call ftmahd(unit,hdu,hdutype,status)
c      print *,'read_template_table:hdu,hdutype',hdu, hdutype
c
c     read the number of parameters
c     
      call ftgkyj(unit,'TFIELDS', tfields, comment, status)
c      print *,'read_template_table:tfields',tfields
      call ftgkyj(unit,'NAXIS2', naxis2, comment, status)
      if(verbose.gt.0) then
         print *, 'read_fits_table:there are ', naxis2, ' lines with ', 
     *        tfields,' parameters', status
      end if
c
c     Read the TTYPEn keywords, which give the names of the columns
c
      if(verbose.ge. 1) then
         call ftgkns(unit,'TTYPE',1,tfields,ttype,nfound,status)
         print  2000, (ii, ttype(ii), ii = 1, nfound)
 2000    format(2x,"read_template_table: Row   ",i3,2x,a10)
      end if
c
c  Read the data, one row at a time, and print them out
c
      felem=1
      nelems=naxis2
      nullstr=' '
      nulld = 0.0d0
      status = 0
c
      nf = naxis2
c
      irow   = 1
      colnum = 1
      call ftgcvs(unit,colnum,irow,felem,nelems,nullstr,
     &     filter, anynull,status)
      if (status .gt. 0) then
         print *,'read_template_table: ftgcvs column 1'
         call printerror(status)
         stop
      end if
c     
      colnum=2
      call ftgcvd(unit,colnum,irow,felem,nelems,nulld,
     &     wl_filter, anynull,status)
      if (status .gt. 0) then
         print *,'read_template_table: ftgcvd 2'
         call printerror(status)
      end if
c
      if(verbose.ge.1) then
         print *,'read_template_table',(wl_filter(ii),ii=1,nelems)
      end if
c
      colnum = 3
      call ftgcvd(unit,colnum,irow,felem,nelems,nulld,
     &     magnitude, anynull,status)
      if (status .gt. 0) then
         print *,'read_template_table: ftgcvd 3'
         call printerror(status)
      end if
c      
      colnum = 4
      call ftgcvd(unit,colnum,irow,felem,nelems,nulld,
     &     zp, anynull,status)
      if (status .gt. 0) then
         print *,'read_template_table: ftgcvd 4'
         call printerror(status)
      end if
c      
c      
      colnum = 5
      call ftgcvs(unit,colnum,irow,felem,nelems,nullstr,
     &     source, anynull,status)
      if (status .gt. 0) then
         print *,'read_template_table: ftgcvd 4'
         call printerror(status)
      end if
c      
      return
      end
