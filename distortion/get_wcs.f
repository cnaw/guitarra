c
c-----------------------------------------------------------------------
c
      subroutine get_guitarra_wcs(unit, radesys, equinox,
     &     ra_ref, dec_ref, roll_ref, pa_v3,
     &     v3i_yang, v_idl_parity, 
     &     ctype1, cunit1, crpix1, crval1, cdelt1, 
     &     ctype2, cunit2, crpix2, crval2, cdelt2,
     &     cd1_1, cd1_2, cd2_1, cd2_2,
     &     a_order, aa, b_order, bb, 
     &     ap_order, ap, bp_order, bp, 
     &     max_i, max_j, debug)
      implicit none
      double precision  equinox, crpix1, crpix2, crval1, crval2,
     *     cdelt1, cdelt2, cd1_1, cd1_2, cd2_1, cd2_2,
     *     aa, bb, ap, bp
      integer unit, status, a_order, b_order, ap_order, bp_order,
     *     debug
      double precision ra_ref, dec_ref, roll_ref, pa_v3,
     &     v3i_yang
      integer v_idl_parity
c
      integer ii, jj, indx, jndx, max_i, max_j
c
      character cunit1*40, cunit2*40, radesys*8,ctype1*(*),ctype2*(*)
      character header*80, keyword*8, value*20, comment*40,
     *     result*20, key*8, comm*40
      character coeff_string*2, order_string*8
c
      dimension aa(max_i, max_j), bb(max_i, max_j),
     &      ap(max_i, max_j), bp(max_i, max_j)
c

      status =  0
      call ftgkys(unit,'RADESYS',radesys,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'RADESYS'
      end if
c
      status =  0
      call ftgkyd(unit,'RA_REF',ra_ref,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'RA_REF'
      end if
c
      status =  0
      call ftgkyd(unit,'DEC_REF',dec_ref,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'DEC_REF'
      end if
c     
      status =  0
      call ftgkyd(unit,'ROLL_REF',roll_ref,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'ROLL_REF'
      end if
c     
      pa_v3 = roll_ref
c     
      status =  0
      call ftgkyd(unit,'V3I_YANG',v3i_yang,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'V3I_YANG'
      end if
c     
      status =  0
      call ftgkyj(unit,'VPARITY',v_idl_parity,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'VPARITY'
      end if
c     
      status =  0
      call ftgkyd(unit,'EQUINOX',equinox,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'EQUINOX'
      end if
c
      status=0
      call ftgkys(unit,"CTYPE1",ctype1, comment, status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'CTYPE1'
      end if
c
      status = 0
      call ftgkys(unit,'CUNIT1',cunit1,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'CUNIT1'
      end if
c
      status =  0
      call ftgkyd(unit,'CRVAL1',crval1,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'CRVAL1'
      end if
c
      status =  0
      call ftgkyd(unit,'CRPIX1',crpix1,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'CRPIX1'
      end if
c     
      status =  0
      call ftgkys(unit,'CTYPE2',ctype2,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'CTYPE2'
      end if
c     
      status =  0
      call ftgkys(unit,'CUNIT2',cunit2,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'CUNIT2'
      end if
c     
      status =  0
      call ftgkyd(unit,'CRVAL2',crval2,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'CRVAL2'
      end if
c
      status =  0
      call ftgkyd(unit,'CRPIX2',crpix2,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'CRPIX2'
      end if
c
      status =  0
      call ftgkyd(unit,'CD1_1',cd1_1,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'CD1_1'
      end if
c
      status =  0
      call ftgkyd(unit,'CD1_2',cd1_2,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'CD1_2'
      end if
c
      status =  0
      call ftgkyd(unit,'CD2_1',cd2_1,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'CD2_1'
      end if
c
      status =  0
      call ftgkyd(unit,'CD2_2',cd2_2,comment,status)
      if (status .gt. 0) then
         call printerror(status)
         print *, 'CD2_2'
      end if
c
c      print *,' ctype1 ', ctype1
c      print *,' ctype2 ', ctype2
      if(ctype1 .eq. 'RA---TAN' .and. ctype2 .eq. 'DEC--TAN') return
c
      if(ctype1 .eq. 'RA---TAN-SIP' .and. 
     &     ctype2 .eq. 'DEC--TAN-SIP') then
c
         order_string = 'A_ORDER'
         call get_sip_coeffs(unit, a_order, aa, max_i, max_j, 
     &        order_string, debug)
c
         order_string = 'B_ORDER'
         call get_sip_coeffs(unit, b_order, bb, max_i, max_j, 
     &        order_string, debug)
c
         order_string = 'AP_ORDER'
         call get_sip_coeffs(unit, ap_order, ap, max_i, max_j, 
     &        order_string, debug)
c
         order_string = 'BP_ORDER'
         call get_sip_coeffs(unit, bp_order, bp, max_i, max_j, 
     &        order_string, debug)
c
      end if
      return
      end
