c
c-----------------------------------------------------------------------
c
      subroutine add_modelled_galaxy(sca_id, naxis1, naxis2,
     *     subarray,colcornr, rowcornr,
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
     &     aa, a_order, bb, b_order,
     &     ap, ap_order, bp, bp_order, det_sign,
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
     &     v2_ref, v3_ref,
     &     aa, bb, ap, bp, det_sign
c
      double precision equinox, 
     *     crpix1, crpix2,      ! crpix3,
     *     crval1, crval2,      !crval3,
     *     cdelt1, cdelt2,      !cdelt3,
     *     cd1_1, cd1_2, cd2_1, cd2_2, ! cd3_3,
     *     pc1_1, pc1_2, pc2_1, pc2_2 !, pc3_1, pc3_2
      integer a_order, ap_order, b_order, bp_order
      dimension 
     &     sci_to_ideal_x(6,6), sci_to_ideal_y(6,6), 
     &     ideal_to_sci_x(6,6), ideal_to_sci_y(6,6),
     &     aa(9,9), bb(9,9), ap(9,9), bp(9,9)
c
      integer max_objects, nnn, nsub, nfilters
      integer ix, iy, seed, debug, ngal, ng,in_field, naxis1, naxis2,
     *     ncomponents,id, i, j, nc, sca_id, filter_index, junk
      logical noiseless, psf_add, ipc_add
      integer colcornr, rowcornr
      character subarray*(*)
c
      parameter (max_objects=60000, nnn = 2048, nfilters=54,nsub=4)
      dimension ra(max_objects), dec(max_objects), z(max_objects),
     *     magnitude(max_objects), ncomponents(max_objects), 
     *     id(max_objects),
     *     nsersic(max_objects,nsub),ellipticity(max_objects,nsub), 
     *     re(max_objects, nsub), theta(max_objects,nsub),
     *     flux_ratio(max_objects, nsub)
c
      dimension attitude_inv(3,3)
c
      common /galaxy/ra, dec, z, magnitude, nsersic, ellipticity, re,
     *     theta, flux_ratio, ncomponents,id
c
      common /wcs/ equinox, 
     *     crpix1, crpix2,      ! crpix3,
     *     crval1, crval2,      !crval3,
     *     cdelt1, cdelt2,      !cdelt3,
     *     cd1_1, cd1_2, cd2_1, cd2_2,! cd3_3,
     *     pc1_1, pc1_2, pc2_1, pc2_2 !, pc3_1, pc3_2
c
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
c         if(distortion.eq.0) then
c            call ra_dec_to_sca(junk, 
c     *           ra_dithered, dec_dithered, 
c     *           ra(ng), dec(ng), pa_degrees, 
c     *           xc, yc,  osim_scale, xg, yg)
cc
c         endif
c
c     calculate the (V2, V3) coordinates of object centre from RA, DEC
c
         if(distortion.eq.1) then
            ra_rad  = ra(ng)  * q 
            dec_rad = dec(ng) * q
            call rot_coords(attitude_inv, ra_rad, dec_rad, v2_rad,
     &           v3_rad)
            call coords_to_v2v3(v2_rad, v3_rad, v2_arcsec, v3_arcsec)
            call v2v3_to_det(
     &           x_det_ref, y_det_ref,
     &           x_sci_ref, y_sci_ref,
     &           sci_to_ideal_x,sci_to_ideal_y,sci_to_ideal_degree,
     &           ideal_to_sci_x,ideal_to_sci_y,ideal_to_sci_degree,
     &           v3_sci_x_angle,v3_sci_y_angle,
     &           v3_idl_yang, v_idl_parity,
     &           det_sci_yangle, det_sci_parity,
     &           v2_ref, v3_ref,
     &           v2_arcsec, v3_arcsec,  xg, yg,
     &           precise,debug)
c            print *,' add_modelled_galaxy: ',ng,ra(ng),dec(ng),xg,yg, 
c     &           subarray, colcornr, rowcornr
         end if
c
         if(distortion.eq.2) then
c     
c     no distortion using SIAF WCS
c     
               call wcs_rd_to_xy(xg,yg,ra(ng),dec(ng),
     &              crpix1, crpix2, crval1, crval2,
     &              cd1_1, cd1_2, cd2_1, cd2_2)
         end if
c         
c         if(debug.gt.0) then 
            print 50,
     &           ra(ng), dec(ng), xg, yg,
     &           magnitude(ng), filter_index 
 50         format('add_modelled_galaxy 50 ',5(1x,f12.5),
     &           i7)
c         end if
         if(magnitude(ng).eq.0.0d0) then
            print *, 'add modelled galaxy 0 magnitude !',
     &           ng,  ra(ng), dec(ng),filter_index,
     &           magnitude(ng)
            print *,'quitting'
            stop
         end if
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
         if(debug.ge.1) 
     *        print 90, ncomponents(ng), rmax,
     *        xg, yg
 90      format('add_modelled_galaxy  #components, rmax, xg, yg',
     &        i3,2x,f9.4,2(2x,f9.2))
c
c    add photons corresponding to each component
c
         if(debug.ge.1) print 100
 100     format('  nc nsersic      re    ellipticity  magnitude ',
     *        '  photons     expected')
c         print *,'add_modelled_galaxy ', ng, filter_index
c     
c     create profiles for each component and co-add
c
         do nc = 1, ncomponents(ng)
            mag = magnitude(ng) 
     *           -2.5d0*dlog10(flux_ratio(ng,nc))
            if(debug.ge.1) then
               print 110, filter_index, ng, nc,
     &              magnitude(ng),flux_ratio(ng,nc)
 110           format('add_modelled_galaxy filter_index, ng, nc, mag',
     &              3(2x,i6), 2(2x,f20.12))
                print *,'add_modelled_galaxy:nsersic(ng,nc),re(ng,nc)',
     &           nsersic(ng,nc),re(ng,nc)
            end if
c            if(debug.gt.1)
            
            if((nsersic(ng,nc).ge.20.d0 .or. nsersic(ng,nc).le.0.01d0)
     &           .and. re(ng,nc).le.0.1d0) then
c               print *,'add_modelled_galaxy: xg, yg',xg, yg
               call add_star(
     &              v2_arcsec, v3_arcsec, xg,  yg,
     &              subarray,colcornr, rowcornr,
     &              mag, abmag, integration_time,
     *              noiseless, psf_add, ipc_add,
     *              psf_scale, over_sampling_rate, 
     *              naxis1, naxis2, sca_id-480, 
     *              distortion, precise, 
     &              sci_to_ideal_x, sci_to_ideal_y, sci_to_ideal_degree,
     &              ideal_to_sci_x, ideal_to_sci_y, ideal_to_sci_degree,
     &              x_det_ref, y_det_ref, x_sci_ref, y_sci_ref,
     &              det_sci_yangle, det_sci_parity,
     &              v3_idl_yang, v_idl_parity, v2_ref, v3_ref,
     &              debug)
            else
               call add_galaxy_component(
     *              v2_arcsec, v3_arcsec, xg, yg,
     &              subarray,colcornr, rowcornr,
     *              mag, id(ng),
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
