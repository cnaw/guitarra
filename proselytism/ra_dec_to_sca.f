      subroutine ra_dec_to_sca(sca_id, ra_c, dec_c, ra_cat, dec_cat, 
     *     pa_degrees, xc, yc, osim_scale, x_sca, y_sca)
c
c     convert RA, DEC from a catalogue into into SCA coordinates for 
c     the NIRCam footprint centered at RA_C, DEC_C, using the either 
c     the correct transformation that uses the tangent projection or
c     just using a plane approximation.
c
      implicit none
      integer sca_id
      double precision  ra_cat, dec_cat, ra_c, dec_c, pa_degrees, 
     *    xc, yc, osim_scale, x_sca, y_sca, cosdec, q
      double precision  x_osim, y_osim, deg_to_osim, x, y
      logical correct
      q = dacos(-1.0d0)/180.d0
      deg_to_osim  = 3600.d0/osim_scale
c      correct = .true.
      correct = .false.
      if(correct .eqv. .true.) then
         call ra_dec_xy_osim(ra_c, dec_c, ra_cat, dec_cat, pa_degrees,
     *        xc, yc, osim_scale, x_osim, y_osim)
      else
         cosdec = dcos(dec_cat*q)
         y    = yc + (dec_cat - dec_c) * deg_to_osim
         x    = xc +  (ra_cat - ra_c)* deg_to_osim*cosdec
c         call rotate_coords(xc, yc, x, y, pa_degrees, x_osim, y_osim)
         call rotate_coords(xc, yc, x, y, -pa_degrees, x_osim, y_osim)
      end if
      call sca_coords_from_osim(sca_id, x_osim, y_osim, x_sca, y_sca)
      return
      end
