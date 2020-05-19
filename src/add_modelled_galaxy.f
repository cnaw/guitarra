c
c-----------------------------------------------------------------------
c
      subroutine add_modelled_galaxy(sca_id, naxis1, naxis2,
     *     ra_dithered, dec_dithered, pa_degrees,
     *     xc, yc, osim_scale, filter_index, 
     *     ngal, scale, 
     *     wavelength, bandwidth, system_transmission, 
     *     mirror_area, abmag, integration_time, seed, in_field, 
     *     noiseless, psf_add, ipc_add, 
     *     distortion, precise, psf_scale, over_sampling_rate,
     *     attitude_inv,
     &     sci_to_ideal_x, sci_to_ideal_y, sci_to_ideal_degree,
     &     ideal_to_sci_x, ideal_to_sci_y, ideal_to_sci_degree,
     &     x_det_ref, y_det_ref, x_sci_ref, y_sci_ref,
     &     det_sci_yangle, det_sci_parity,
     &     v3_idl_yang, v_idl_parity, v2_ref, v3_ref,
     &     debug)

      implicit none
      double precision ra_dithered, dec_dithered, pa_degrees,
     *     xc, yc, osim_scale
      double precision xg, yg, ra, dec,
     *     magnitude, ellipticity, theta, re, nsersic,flux_ratio,
     *     z, scale, 
     *     wavelength, bandwidth, system_transmission, 
     *     mirror_area, abmag,integration_time
      double precision rmax, photons, mag, zp, mzp
      double precision xgal, xhit, ygal, yhit,
     *     x_sca, y_sca, xx, yy, x_osim, y_osim
      
      double precision ab_mag_to_photon_flux
      double precision ra_rad, dec_rad, v2_rad, v3_rad, v2_arcsec,
     &     v3_arcsec, psf_scale, attitude_inv, q
c
      integer distortion, over_sampling_rate, precise
      integer ideal_to_sci_degree, v_idl_parity,
     &     sci_to_ideal_degree, det_sci_parity
      double precision 
     &     x_det_ref, y_det_ref,
     &     x_sci_ref, y_sci_ref,
     &     sci_to_ideal_x, sci_to_ideal_y,
     &     ideal_to_sci_x, ideal_to_sci_y,
     &     v3_sci_x_angle,v3_sci_y_angle,
     &     v3_idl_yang,
     &     det_sci_yangle,
     &     v2_ref, v3_ref
      dimension 
     &     sci_to_ideal_x(6,6), sci_to_ideal_y(6,6), 
     &     ideal_to_sci_x(6,6), ideal_to_sci_y(6,6)
c
      integer max_objects, nnn, nsub, nfilters
      integer ix, iy, seed, debug, ngal, ng,in_field, naxis1, naxis2,
     *     ncomponents,id, i, j, nc, sca_id, filter_index, junk
      logical noiseless, psf_add, ipc_add
c
      parameter (max_objects=50000, nnn = 2048, nfilters=54,nsub=4)
      dimension ra(max_objects), dec(max_objects), z(max_objects),
     *     magnitude(max_objects,nfilters), ncomponents(max_objects), 
     *     id(max_objects),
     *     nsersic(max_objects,nsub),ellipticity(max_objects,nsub), 
     *     re(max_objects, nsub), theta(max_objects,nsub),
     *     flux_ratio(max_objects, nsub)
c
      dimension attitude_inv(3,3)
c
      common /galaxy/ra, dec, z, magnitude, nsersic, ellipticity, re,
     *     theta, flux_ratio, ncomponents,id
      q  = dacos(-1.0d0)/180.d0
c
c      mag    =   0.0d0
c      photons = ab_mag_to_photon_flux (mag, mirror_area,
c     *     wavelength, bandwidth, system_transmission)
c      zp  =photons
c      mzp = -2.5d0*dlog10(zp)
      in_field = 0
      zp   = 0.0d0
c      if(debug.eq.1) 
c     *     print *,'add_modelled_galaxy: ZP ', zp
c
c     Loop over catalogue
c
      if(sca_id.lt.481) then
         junk = 1
      else
         junk = sca_id
      end if

      do ng = 1, ngal
c
c     find SCA coordinates for this object 
c
         if(distortion.eq.0) then
            call ra_dec_to_sca(junk, 
     *           ra_dithered, dec_dithered, 
     *           ra(ng), dec(ng), pa_degrees, 
     *           xc, yc,  osim_scale, xg, yg)
c
         else
c
c     calculate the (V2, V3) coordinates of object centre from RA, DEC
c
            ra_rad  = ra(ng)  * q 
            dec_rad = dec(ng) * q
            if(debug.gt.1) 
     &           print *,'add_modelled_galaxy : ng, ra, dec',
     &           ng, ra(ng), dec(ng), xg, yg
            call rot_coords(attitude_inv, ra_rad, dec_rad, v2_rad,
     &           v3_rad)
            call coords_to_v2_v3(v2_rad, v3_rad, v2_arcsec, v3_arcsec)
            xg = v2_arcsec
            yg = v3_arcsec
         end if
         if(debug.gt.0) then 
            call v2v3_to_det(
     &           x_det_ref, y_det_ref, 
     &           x_sci_ref, y_sci_ref,
     &           sci_to_ideal_x,sci_to_ideal_y,sci_to_ideal_degree,
     &           ideal_to_sci_x,ideal_to_sci_y,ideal_to_sci_degree,
     &           v3_sci_x_angle,v3_sci_y_angle,
     &           v3_idl_yang, v_idl_parity,
     &           det_sci_yangle,
     &           v2_ref, v3_ref,
     &           xg, yg,  xx, yy,
     &           precise,debug)

            print 50,
     &           ra(ng), dec(ng), xg, yg, xx, yy,
     &           magnitude(ng,filter_index), filter_index 
 50         format('add_modelled_galaxy',4(1x,f12.5),
     &           3(1x, f9.3), i7)

         end if
         if(magnitude(ng,filter_index).eq.0.0d0) then
            print *, 'add modelled galaxy 0 magnitude !',
     &           ng,  ra(ng), dec(ng),filter_index,
     &           magnitude(ng,filter_index)
            stop
         end if
c
c         if(xg.le.0.d0 .or. xg.gt.2048.d0 .or.
c     *        yg.le.0.d0 .or. yg.gt.2048.d0) go to 200
c     
c     radial profile unit = pixel
c     Find largest extension 
c
         rmax        = re(ng,1) 
         if(ncomponents(ng).gt.1) then 
            do i = 2, ncomponents(ng)
               if(re(ng, i).gt. rmax)  rmax = re(ng, i)
            end do
         end if
c     
c     Estimate the total magnitude using a large radius.
c     maximum radius: SDSS truncate at 4 scale lengths. Try at 10
c     
         rmax   =   rmax * 100.D0 
         if(rmax .eq. 0.0d0) go to 200
         if(debug.ge.2) 
     *        print 90, ncomponents(ng), rmax,
     *        xg, yg
 90      format('add_modelled_galaxy  #components, rmax, xg, yg',
     &        i3,2x,f9.4,2(2x,f9.2))
c
c    add photons corresponding to each component
c
         if(debug.ge.2) print 100
 100     format('  nc nsersic      re    ellipticity  magnitude ',
     *        '  photons     expected')
c         print *,'add_modelled_galaxy ', ng, filter_index
c     
c     create profiles for each component and co-add
c
         do nc = 1, ncomponents(ng)
            mag = magnitude(ng,filter_index) 
     *           -2.5d0*dlog10(flux_ratio(ng,nc))
            if(debug.ge.2) then
               print 110, filter_index, ng, nc,
     &              magnitude(ng,filter_index),flux_ratio(ng,nc)
 110           format('add_modelled_galaxy filter_index, ng, nc, mag',
     &              3(2x,i6), 2(2x,f20.12))
            end if
            if(debug.gt.1)
     &           print *,'add_modelled_galaxy:nsersic(ng,nc),re(ng,nc)',
     &           nsersic(ng,nc),re(ng,nc)
            
            if((nsersic(ng,nc).ge.20.d0 .or. nsersic(ng,nc).le.0.01d0)
     &           .and. re(ng,nc).le.0.1d0) then
               call add_star(xg, yg, mag, abmag, integration_time,
     *              noiseless, psf_add, ipc_add, distortion,
     *              psf_scale, over_sampling_rate, 
     *              naxis1, naxis2, sca_id-480, 
     *              precise, 
     &              sci_to_ideal_x, sci_to_ideal_y, sci_to_ideal_degree,
     &              ideal_to_sci_x, ideal_to_sci_y, ideal_to_sci_degree,
     &              x_det_ref, y_det_ref, x_sci_ref, y_sci_ref,
     &              det_sci_yangle, det_sci_parity,
     &              v3_idl_yang, v_idl_parity, v2_ref, v3_ref,
     &              debug)
            else
               call add_galaxy_component(xg, yg, mag, id(ng),
     *              ellipticity(ng, nc), re(ng,nc), rmax, 
     *              theta(ng, nc), nsersic(ng, nc), zp, scale,
     *              pa_degrees,
     *              wavelength, bandwidth,system_transmission, 
     *              mirror_area, abmag, integration_time,seed,
     *              noiseless, psf_add, ipc_add, 
     *              sca_id-480, distortion,precise,
     &              sci_to_ideal_x, sci_to_ideal_y, sci_to_ideal_degree,
     &              ideal_to_sci_x, ideal_to_sci_y, ideal_to_sci_degree,
     &              x_det_ref, y_det_ref, x_sci_ref, y_sci_ref,
     &              det_sci_yangle, det_sci_parity,
     &              v3_idl_yang, v_idl_parity, v2_ref, v3_ref,
     *              psf_scale, over_sampling_rate, 
     *              naxis1, naxis2, debug)
            end if
         end do
         in_field = in_field +1
 200     continue
      end do
      return
      end
