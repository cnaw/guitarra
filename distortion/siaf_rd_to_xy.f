      subroutine siaf_rd_to_xy(
     &     ra, dec,
     &     x_det_ref, y_det_ref,
     &     x_sci_ref, y_sci_ref,
     &     sci_to_ideal_x,sci_to_ideal_y,sci_to_ideal_degree,
     &     ideal_to_sci_x, ideal_to_sci_y,ideal_to_sci_degree,
     &     v3_sci_x_angle,v3_sci_y_angle,
     &     v3_idl_yang,v_idl_parity,
     &     det_sci_yangle,det_sci_parity,
     &     v2_ref, v3_ref,
     &     v2_arcsec, v3_arcsec, x_sca, y_sca,
     &     attitude_dir, attitude_inv,
     &     precise,verbose)
      implicit none
      double precision 
     &     ra, dec,
     &     x_det_ref, y_det_ref,
     &     x_sci_ref, y_sci_ref,
     &     sci_to_ideal_x,sci_to_ideal_y,
     &     ideal_to_sci_x, ideal_to_sci_y,
     &     v3_sci_x_angle,v3_sci_y_angle,
     &     v3_idl_yang,
     &     det_sci_yangle,
     &     v2_ref, v3_ref,
     &     v2_arcsec, v3_arcsec, x_sca, y_sca,
     &     attitude_dir, attitude_inv

      integer sci_to_ideal_degree,ideal_to_sci_degree,v_idl_parity,
     &     det_sci_parity, precise, verbose
      double precision q, v2_rad, v3_rad, ra_rad, dec_rad
c
      dimension attitude_dir(3,3), attitude_inv(3,3)
      q = dacos(-1.0d0)/180.d0
      ra_rad  = ra * q
      dec_rad = dec * q
      call rot_coords(attitude_inv, ra_rad, dec_rad, 
     &     v2_rad, v3_rad)
      call coords_to_v2v3(v2_rad, v3_rad,v2_arcsec,v3_arcsec)
      call v2v3_to_det(
     &     x_det_ref, y_det_ref, 
     &     x_sci_ref, y_sci_ref,
     &     sci_to_ideal_x,sci_to_ideal_y,sci_to_ideal_degree,
     &     ideal_to_sci_x,ideal_to_sci_y,ideal_to_sci_degree,
     &     v3_sci_x_angle,v3_sci_y_angle,
     &     v3_idl_yang, v_idl_parity,
     &     det_sci_yangle, det_sci_parity,
     &     v2_ref, v3_ref,
     &     v2_arcsec, v3_arcsec, x_sca, y_sca,
     &     precise,verbose)

      return
      end
