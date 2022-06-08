c
c-----------------------------------------------------------------------
c
      subroutine get_wcs(unit, radesys, equinox,
     &     ctype1, cunit1, crpix1, crval1,
     &     ctype2, cunit2, crpix2, crval2,
     &     ctype3, cunit3, crpix3, crval3, 
     &     cd1_1, cd1_2, cd2_1, cd2_2, cd3_3,
     &     debug)
      implicit none
      double precision  equinox, crpix1, crpix2, crval1, crval2,
     *     crpix3, crval3,
     *     cd1_1, cd1_2, cd2_1, cd2_2, cd3_3
      integer unit, status,   debug, wcsaxes, naxis
c
      integer ii, jj, indx, jndx, max_i, max_j
c
      integer flag_202_for_axis_3 
c      
      character cunit1*(*), cunit2*(*), cunit3*(*), radesys*(*),
     *     ctype1*(*),ctype2*(*), ctype3*(*)
      character header*80, keyword*8, value*20, comment*40,
     *     result*20, key*8, comm*40
c
      data flag_202_for_axis_3/0/
      cd1_1 = 0.0d0
      cd1_2 = 0.0d0
      cd2_1 = 0.0d0
      cd2_2 = 0.0d0
      cd3_3 = 0.0d0
c
      IF(DEBUG.gt.0) print *,'get_wcs '
      status =  0
      call ftgkyj(unit,"WCSAXES",wcsaxes,comment, status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'get_wcs: naxis'
      end if
c
      status =  0
      call ftgkyj(unit,"NAXIS",naxis,comment, status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'get_wcs: naxis'
      end if
      if(debug.gt.0) print *,'get_wcs: naxis ', naxis
      call ftgkys(unit,'RADESYS',radesys,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'get_wcs: RADESYS'
      end if
c
      status =  0
      call ftgkyd(unit,'EQUINOX',equinox,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'get_wcs: EQUINOX'
      end if
c
      status=0
      call ftgkys(unit,"CTYPE1",ctype1, comment, status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'get_wcs: CTYPE1'
      end if
c
      status = 0
      call ftgkys(unit,'CUNIT1',cunit1,comment,status)
      if (status .gt. 0) then
         if(debug.gt.1 .or.status.ne.202) then
            call printerror(status)
            print *, 'get_wcs: CUNIT1'
         end if
         CUNIT1 = 'deg'
      end if
c
      status =  0
      call ftgkyd(unit,'CRVAL1',crval1,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'get_wcs: CRVAL1'
      end if
c
      status =  0
      call ftgkyd(unit,'CRPIX1',crpix1,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'get_wcs: CRPIX1'
      end if
c     
      status =  0
      call ftgkys(unit,'CTYPE2',ctype2,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'get_wcs: CTYPE2'
      end if
c     
      status =  0
      call ftgkys(unit,'CUNIT2',cunit2,comment,status)
      if (status .gt. 0) then
         if(debug.gt.1 .or. status.ne.202) then
            call printerror(status)
            print *, 'get_wcs: CUNIT2'
         end if
         CUNIT2 = 'deg'
      end if
c     
      status =  0
      call ftgkyd(unit,'CRVAL2',crval2,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'get_wcs: CRVAL2'
      end if
c
      status =  0
      call ftgkyd(unit,'CRPIX2',crpix2,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'get_wcs: CRPIX2'
      end if
c
      status =  0
      call ftgkyd(unit,'CD1_1',cd1_1,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'get_wcs: CD1_1'
      end if
c
      status =  0
      call ftgkyd(unit,'CD1_2',cd1_2,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'get_wcs: CD1_2'
      end if
c
      status =  0
      call ftgkyd(unit,'CD2_1',cd2_1,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'get_wcs: CD2_1'
      end if
c
      status =  0
      call ftgkyd(unit,'CD2_2',cd2_2,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'get_wcs: CD2_2'
      end if
c
      if(wcsaxes.ge.3) then
         status =  0
         call ftgkyd(unit,'CD3_3',cd3_3,comment,status)
         if (status .gt. 0 .and.naxis.eq.3) then
            print *, 'get_wcs: CD3_3 non-fatal error'
            call printerror(status)
            flag_202_for_axis_3 = 1
            status = 0
         end if
c     
         if(flag_202_for_axis_3.eq.0) then 
            status =  0
            call ftgkys(unit,'CTYPE3',ctype3,comment,status)
            if (status .ne.0 .and.naxis.eq.3) then
               if(status.ne.202) then
                  call printerror(status)
                  print *, 'get_wcs: CTYPE3'
               else
                  ctype3 = ' '
                  status = 0
               end if
            end if
c     
            status =  0
            call ftgkys(unit,'CUNIT3',cunit3,comment,status)
            if (status .gt. 0) then
               if(debug.gt.1 .or.status.ne.202) then
                  call printerror(status)
                  print *, 'get_wcs: CUNIT3'
               end if
               CUNIT3 = ' '
            end if
c     
            status =  0
            call ftgkyd(unit,'CRVAL3',crval3,comment,status)
            if (status .gt. 0  .and. naxis.eq.3) then
               call printerror(status)
               print *, 'get_wcs: CRVAL3'
c     stop
            end if
c     
            status =  0
            call ftgkyd(unit,'CRPIX3',crpix3,comment,status)
            if (status .gt. 0 .and. naxis.eq.3) then
               call printerror(status)
               print *, 'get_wcs: CRPIX3'
c     stop
            end if
         end if
      end if                    ! wcsaxes
c     
      if(debug.gt.0) then
         print *,'get_wcs :', crpix1, crpix2, crval1, crval2
         print *,'get_wcs: ctype1 ', ctype1
         print *,'get_wcs: ctype2 ', ctype2
      end if
      return
      end
