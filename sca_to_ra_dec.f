      subroutine sca_to_ra_dec(sca_id, ra_c, dec_c, ra_cat, dec_cat, 
     *     pa_degrees, xc, yc, osim_scale, x_sca, y_sca)
c
c     convert SCA coordinates into  RA, DEC from a catalogue assuming
c     the NIRCam footprint centered at RA_C, DEC_C, using the either 
c     using a plane approximation. The correct transformation gives
c     worse residuals towards higher declinations ~0.13 arc sec at |dec|=85
c     and ~ 3.3 arc sec at |dec| = 89.8. This is probably because of
c     because of round-off errors in  the arc tangent calculation for
c     high declinations.
c
      implicit none
      integer sca_id
      double precision  ra_cat, dec_cat, ra_c, dec_c, pa_degrees, 
     *    xc, yc, osim_scale, x_sca, y_sca, cosdec, q
      double precision  x_osim, y_osim, deg_to_osim, x, y
      logical correct
      q            = dacos(-1.0d0)/180.d0
      deg_to_osim  = 3600.d0/osim_scale
c      correct = .true.
      correct = .false.
      call osim_coords_from_sca(sca_id, x_sca, y_sca, x_osim, y_osim)
      if(correct .eqv. .true.) then
         call xy_osim_ra_dec(ra_c, dec_c,  ra_cat, dec_cat, pa_degrees,
     *        xc, yc, osim_scale, x_osim, y_osim)
      else
c         call rotate_coords(xc, yc, x_osim, y_osim, -pa_degrees, x, y)
         call rotate_coords(xc, yc, x_osim, y_osim,  pa_degrees, x, y)
         dec_cat = dec_c + (y -yc)/deg_to_osim
         cosdec  = dcos(dec_cat*q)
         ra_cat  = ra_c  + (x -xc)/deg_to_osim/cosdec
c         print 10, x_osim, y_osim, x_sca, y_sca, ra_cat, dec_cat
 10      format('sca_to_ra_dec: osim,sca, ra,dec ',6(1x,f20.15))
       end if
      return
      end
