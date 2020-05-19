c
c-------------------------------------------------------------------
c
      subroutine  nircam_wcs(
     &     iunit, wcsaxes, 
     &     crpix1, crpix2, crpix3, 
     &     crval1, crval2, crval3, 
     &     ctype1, ctype2, ctype3,
     &     cunit1, cunit2, cunit3,
     &     cd1_1, cd1_2, cd2_1, cd2_2, cd3_3,
     &     cdelt3,
     &     ra_ref, dec_ref, roll_ref, pa_v3,
     &     equinox, read_patt,
     &     v3i_yang, vparity,
     &     a_order, aa, b_order, bb,
     &     ap_order, ap, bp_order, bp)
      implicit none
      integer iunit, status
      double precision cd1_1, cd1_2, cd2_1, cd2_2, cd3_3,
     &     crpix1, crpix2, crpix3, 
     &     crval1, crval2, crval3, 
     &     ra_ref, dec_ref, roll_ref, pa_v3,
     &     equinox, cdelt3
      double precision v3i_yang, aa, bb, ap, bp
      integer wcsaxes, vparity
      integer a_order, b_order, ap_order, bp_order
      character read_patt*10
      character card*80, comment*40
      character ctype1*15, ctype2*15, ctype3*15
      character cunit1*40, cunit2*40, cunit3*40
c
      integer iexp, jexp, ii, jj
      character coeff_name*8
c
      dimension aa(9,9), bb(9,9), ap(9,9), bp(9,9)
c      dimension aa(a_order+1, a_order+1), bb(b_order+1, b_order+1),
c     &     ap(ap_order+1, ap_order+1), bp(bp_order+1, bp_order+1)
c
c     fake WCS keywords
c 
      card = '                                              '
      call ftprec(iunit,card, status)
      status =  0
      card = '         WCS information                             '
      call ftprec(iunit,card, status)
      status =  0
      card = '                                              '
      call ftprec(iunit,card, status)
      status =  0
c
      comment='                                       '
      call ftpkyj(iunit,'WCSAXES',wcsaxes,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'WCSAXES'
      end if
      status =  0
c     
      comment='Axis 1 coordinate of reference pixel   '
      call ftpkyd(iunit,'CRPIX1',crpix1,-7,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'CRPIX1'
      end if
      status =  0
c     
      comment='Axis 2 coordinate of reference pixel   '
      call ftpkyd(iunit,'CRPIX2',crpix2,-7,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'CRPIX2'
      end if
      status =  0
c     
      if(wcsaxes.eq.3) then
         comment='Axis 3 coordinate of reference pixel   '
         if(read_patt .eq. 'RAPID') then
            call ftpkyd(iunit,'CRPIX3',crpix3,-7,comment,status)
         else
            call ftpkyd(iunit,'CRPIX3',crpix3/2.d0,-7,comment,status)
         end if
         if (status .gt. 0) then
            call printerror(status)
            print *, 'CRPIX3'
         end if
         status =  0
      end if
c      
      comment='RA at reference pixel (degrees)        '
      call ftpkyd(iunit,'CRVAL1',crval1,-12,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'CRVAL1'
      end if
      status =  0
c     
      comment='DEC at reference pixel (degrees)       '
      call ftpkyd(iunit,'CRVAL2',crval2,-12,comment,status)
      if (status .gt. 0) then
         call printerror(status)
          print *, 'CRVAL2'
       end if
       status =  0
c     
       if(wcsaxes .eq. 3) then
          comment='T at reference pixel (seconds)       '
          call ftpkyd(iunit,'CRVAL3',crval3,-12,comment,status)
          if (status .gt. 0) then
             call printerror(status)
             print *, 'CRVAL3'
          end if
          status =  0
       end if
c     
      comment='Projection type                        '
      call ftpkys(iunit,'CTYPE1',ctype1,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'CTYPE1'
      end if
      status =  0
c     
      call ftpkys(iunit,'CTYPE2',ctype2,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'CTYPE2'
      end if
      status =  0
c     
      if(wcsaxes .eq. 3) then
         call ftpkys(iunit,'CTYPE3','',comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print *, 'CTYPE3'
         end if
         status =  0
      end if
c
      cunit1 = 'deg'
      comment='First axis units                       '
      call ftpkys(iunit,'CUNIT1',cunit1,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'CUNIT1'
      end if
      status =  0
c     
      cunit2 = 'deg'
      comment='Second axis units                      '
      call ftpkys(iunit,'CUNIT2',cunit2,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'CUNIT2'
      end if
      status =  0
c     
      if(wcsaxes .eq. 3) then
         cunit3 = 'sec'
         comment='Third axis units                      '
         call ftpkys(iunit,'CUNIT3',cunit3,comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print *, 'CUNIT3'
         end if
         status =  0
      end if
c     
      comment='RA  of the reference point (deg)'
      call ftpkyd(iunit,'RA_REF',ra_ref,-16,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'ra_ref'
      end if
      status =  0
c     
      comment='Dec of the reference point (deg)'
      call ftpkyd(iunit,'DEC_REF',dec_ref,-16,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'dec_ref'
      end if
      status =  0
c     
      comment='Telescope roll angle of V3 at ref point'
      call ftpkyd(iunit,'ROLL_REF',roll_ref,-8,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'roll_ref'
      end if
      status =  0
c     
      comment='Relative sense of rotation between Ideal xy and V2V3 '
      call ftpkyj(iunit,'VPARITY',vparity,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'vparity'
      end if
      status =  0
c     
      comment='Angle from V3 axis to Ideal y axis (deg)'
      call ftpkyd(iunit,'V3I_YANG',v3i_yang,4,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'V3I_YANG'
      end if
      status =  0
c     
c     These are non-STScI standard
c     
c     
c      if(naxis .eq.4) then
c         comment='Axis 4 coordinate of reference pixel   '
c         call ftpkyd(iunit,'CRPIX4',1.d0,-7,comment,status)
c         if (status .gt. 0) then
c            call printerror(status)
c            print *, 'CRPIX4'
c         end if
c         status =  0
c         comment='4th dimension at reference pixel (pixel)   '
c         call ftpkyd(iunit,'CRVAL4',1.d0,-7,comment,status)
c         if (status .gt. 0) then
c            call printerror(status)
c            print *, 'CRVAL3'
c         end if
c         
c         status =  0
c         comment='Fourth axis increment per pixel         '      
c         call ftpkyd(iunit,'CDELT4',1.d0,12,comment,status)
c         if (status .gt. 0) then
c            call printerror(status)
c            print *, 'CDELT4'
c         end if
c         status =  0
c      end if
c
      comment='                                       '
      call ftpkyd(iunit,'EQUINOX',equinox,-7,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'EQUINOX'
      end if
      status =  0
c
      comment='                                       '
      call ftpkyd(iunit,'CD1_1',cd1_1,10,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'CD1_1'
      end if
      status =  0
c     
      comment='                                       '
      call ftpkyd(iunit,'CD1_2',cd1_2,10,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'CD1_2'
      end if
      status =  0
c     
      comment='                                       '
      call ftpkyd(iunit,'CD2_1',cd2_1,10,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'CD2_1'
      end if
      status =  0
c     
      comment='                                       '
      call ftpkyd(iunit,'CD2_2',cd2_2,10,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'CD2_2'
      end if
      status =  0
c     
      if(wcsaxes .eq. 3) then
         comment='                                       '
         cd3_3  = cdelt3
         call ftpkyd(iunit,'CD3_3',cd3_3,10,comment,status)
         if (status .gt. 0) then
            call printerror(status)
            print *, 'CD3_3'
         end if
         status =  0
      end if
c     
      card = 'WCS derived from SIAF coefficients'
      call ftpcom(iunit,card,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'ftpcom'
      end if
      status =  0
c
      comment='polynomial order axis 1, detector to sky'
      call ftpkyj(iunit,'A_ORDER',a_order,comment,status)
      if (status .gt. 0) then
         print *, 'A_ORDER'
         call printerror(status)
      end if
      status =  0
c     
      comment='distortion coefficient'
      do ii = 1, a_order+1
         iexp = ii - 1
         do jj = 1, a_order+1
            jexp = jj - 1
            if(iexp+jexp.le.a_order .and.aa(ii,jj).ne.0.0d0) then
               write(coeff_name, 100) iexp, jexp
 100           format('A_',i1,'_',i1)
               call ftpkyd(iunit,coeff_name,aa(ii,jj),10,comment,
     &              status)
 115           format(a10,2x,e15.8)
               if (status .gt. 0) then
                  print 130,coeff_name, aa(ii,jj)
 130              format(a8,2x,e15.8)
                  call printerror(status)
               end if
               status =  0
            end if
         end do
      end do
c
      comment='polynomial order axis 2, detector to sky'
      call ftpkyj(iunit,'B_ORDER',b_order,comment,status)
      if (status .gt. 0) then
         print *, 'B_ORDER'
         call printerror(status)
      end if
      status =  0
c     
      comment='distortion coefficient'
      do ii = 1, b_order+1
         iexp = ii - 1
         do jj = 1, b_order+1
            jexp = jj - 1
            if(iexp+jexp.le.b_order.and.bb(ii,jj).ne.0.0d0) then
               write(coeff_name, 140) iexp, jexp
 140           format('B_',i1,'_',i1)
               call ftpkyd(iunit,coeff_name,bb(ii,jj),10,comment,
     &              status)
c     print 115, coeff_name, bb(ii,jj)
               if (status .gt. 0) then
                  print 130,coeff_name, bb(ii,jj)
                  call printerror(status)
               end if
               status =  0
            end if
         end do
      end do
c
c     inverse 
c
      comment='polynomial order axis 1, sky to detector'
      call ftpkyj(iunit,'AP_ORDER',ap_order,comment,status)
      if (status .gt. 0) then
         print *, 'AP_ORDER'
         call printerror(status)
      end if
      status =  0
c     
      comment='distortion coefficient'
      do ii = 1, ap_order+1
         iexp = ii - 1
         do jj = 1, ap_order+1
            jexp = jj - 1
            if(iexp+jexp.le.ap_order.and.ap(ii,jj).ne.0.0d0) then
               write(coeff_name, 150) iexp, jexp
 150           format('AP_',i1,'_',i1)
               call ftpkyd(iunit,coeff_name,ap(ii,jj),10,comment,
     &              status)
c     print 115, coeff_name, ap(ii,jj)
               if (status .gt. 0) then
                  print 130,coeff_name, ap(ii,jj)
                  call printerror(status)
               end if
               status =  0
            end if
         end do
      end do
      
      comment='polynomial order axis 2, sky to detector'
      call ftpkyj(iunit,'BP_ORDER',bp_order,comment,status)
      if (status .gt. 0) then
         print *, 'BP_ORDER'
         call printerror(status)
      end if
      status =  0
c     
      comment='distortion coefficient'
      do ii = 1, bp_order+1
         iexp = ii - 1
         do jj = 1, bp_order+1
            jexp = jj - 1
            if(iexp+jexp.le.bp_order.and.bp(ii,jj).ne.0.0d0) then
               write(coeff_name, 160) iexp, jexp
 160           format('BP_',i1,'_',i1)
               call ftpkyd(iunit,coeff_name,bp(ii,jj),10,comment,
     &              status)
c     print 115, coeff_name, bp(ii,jj)
               if (status .gt. 0) then
                  print 130,coeff_name, bp(ii,jj)
                  call printerror(status)
               end if
               status =  0
            end if
         end do
      end do
      return
      end
