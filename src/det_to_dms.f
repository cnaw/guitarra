      subroutine det_to_dms(org_array, dms_array,
     &     nnn, nz, naxis1, naxis2, level,
     &     det_sci_parity, det_sign, x_det_ref, y_det_ref,
     &     x_sci_ref, y_sci_ref, x_sci_size, y_sci_size,
     &     verbose)
      implicit none
      integer det_sci_parity, naxis1, naxis2, nnn,level, nz, verbose
      double precision  x_sci_size, y_sci_size
      integer org_array, dms_array
      double precision x_det_ref, y_det_ref, x_sci_ref, y_sci_ref,
     &     det_sign
      integer ii, jj, i, j, mm, nn, colcornr, rowcornr
c
      dimension org_array(nnn,nnn,nz), dms_array(nnn, nnn)
      
      colcornr = x_det_ref - x_sci_size/2.d0 + 1
      rowcornr = y_det_ref - y_sci_size/2.d0 + 1
c
      do jj = 1, naxis2
         j = jj + rowcornr - 1
         nn = int(det_sign*(j-y_det_ref)+y_sci_ref)
         do ii = 1, naxis1
            i = ii + colcornr -1
            mm= int(det_sci_parity*det_sign*(i-x_det_ref)+x_sci_ref)
            dms_array(mm, nn) = org_array(i, j, level)
         end do
      end do
      return
      end
      
