c
c----------------------------------------------------------------------
c
c     Carry out the three transformations that convert 
c     focal plane coordinates (V2, V3) into detector coordinates
c     v2, v3, v2_ref and v3_ref are in arc seconds,
c     x_det, y_det in pixels
      subroutine v2v3_to_det_linear(
     &     x_det_ref, y_det_ref, 
     &     x_sci_ref, y_sci_ref,
     &     sci_to_ideal_x,sci_to_ideal_y,sci_to_ideal_degree,
     &     ideal_to_sci_x,ideal_to_sci_y,ideal_to_sci_degree,
     &     v3_sci_x_angle,v3_sci_y_angle,
     &     v3_idl_yang, v_idl_parity,
     &     det_sci_yangle,det_sci_parity,
     &     v2_ref, v3_ref,
     &     v2_arcsec, v3_arcsec, x_det, y_det,
     &     precise,verbose)
      implicit none
c
      integer ideal_to_sci_degree, det_sci_parity, v_idl_parity,
     &     sci_to_ideal_degree, exponent
      double precision 
     &     x_det_ref, y_det_ref,
     &     x_sci_ref, y_sci_ref,
     &     sci_to_ideal_x,sci_to_ideal_y,
     &     ideal_to_sci_x, ideal_to_sci_y,
     &     v3_sci_x_angle,v3_sci_y_angle,
     &     v3_idl_yang,
     &     det_sci_yangle
      double precision v2_ref, v3_ref
      
      integer verbose, precise

      double precision v2_arcsec, v3_arcsec, x_ideal, y_ideal,
     &     x_det, y_det,
     &     x_sci, y_sci
c
      dimension 
     &     sci_to_ideal_x(6,6), sci_to_ideal_y(6,6), 
     &     ideal_to_sci_x(6,6), ideal_to_sci_y(6,6)

      call v2v3_to_ideal(x_ideal, y_ideal, v2_arcsec, v3_arcsec,
     &     v2_ref, v3_ref, v_idl_parity, v3_idl_yang,
     &     precise, verbose)

      x_sci = x_sci_ref + (x_ideal/sci_to_ideal_x(2,1))
      y_sci = y_sci_ref + (y_ideal/sci_to_ideal_y(2,2))
c
c      exponent = 2
c      call ideal_to_sci(x_ideal, y_ideal, 
c     &     x_sci, y_sci,  x_sci_ref, y_sci_ref,
c     &     ideal_to_sci_x, ideal_to_sci_y,
c     &     exponent, verbose)
c      print *,'v2v3_to_det_linear b', x_sci, y_sci
cc
      call sci_to_det(x_sci, y_sci, x_det, y_det,
     &     x_det_ref, y_det_ref, x_sci_ref, y_sci_ref, 
     &     det_sci_yangle, det_sci_parity)
      
      if(verbose.gt.1) then
         print *,'v2v3_to_det'
         print 150, v2_arcsec, v3_arcsec, x_ideal, y_ideal
 150     format('v2v3 -> idl',4(2x,f16.10))
c
         print 160,x_ideal, y_ideal, x_sci, y_sci
 160     format('idl -> sci ', 4(2x,f16.10))
c
         print 170,x_sci, y_sci, x_det, y_det
 170     format('sci -> det ', 4(2x,f16.10))
      end if
      return
      end

