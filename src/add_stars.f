      subroutine add_stars(ra_dithered, dec_dithered, pa_degrees,
     *     xc, yc, osim_scale, sca_id, filter_index,
     *     seed, subarray, colcornr, rowcornr, naxis1, naxis2,
     *     wavelength, bandwidth,system_transmission,
     *     mirror_area, integration_time, in_field, 
     *     noiseless, psf_add, ipc_add, distortion,
     *     psf_scale, over_sampling_rate, 
     &     attitude_inv,
     &     sci_to_ideal_x, sci_to_ideal_y, sci_to_ideal_degree,
     &     ideal_to_sci_x, ideal_to_sci_y, ideal_to_sci_degree,
     &     x_det_ref, y_det_ref, x_sci_ref, y_sci_ref,
     &     det_sci_yangle, det_sci_parity,
     &     v3_idl_yang, v_idl_parity, v2_ref, v3_ref,
     *     precise, verbose)
c
c     Add "stars" to an image. The NIRCam footprint is centered at
c     ra_dithered, dec_dithered 
c     
      implicit none
      double precision ra_dithered, dec_dithered, xc, yc, pa_degrees,
     *     osim_scale
      double precision ra_stars, dec_stars, mag_stars
      double precision rra, ddec, rra_pix, ddec_pix
      double precision intensity, total_per_cycle, stellar_photons,
     *     x_sca, y_sca, xx, yy, xhit, yhit, x_osim, y_osim
      double precision ab_mag_to_photon_flux, zbqlnor
      double precision mirror_area, wavelength, bandwidth,
     *     system_transmission, integration_time
      double precision psf_scale, attitude_inv
      double precision xg, yg, v2_arcsec, v3_arcsec, ra_rad, dec_rad,
     *     v2_rad, v3_rad, q
c
      real gain_image
c
      integer distortion, over_sampling_rate, precise
c     
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
      double precision v2, v3, x
      dimension 
     &     sci_to_ideal_x(6,6), sci_to_ideal_y(6,6), 
     &     ideal_to_sci_x(6,6), ideal_to_sci_y(6,6)
c
      integer expected, zbqlpoi
      integer colcornr, rowcornr, naxis1, naxis2, filter_index
      integer verbose, sca_id, nnn, max_stars, nfilters, ix, iy,
     *     i, j, nstars, ixmin, ixmax, iymin, iymax, seed, invert,
     *     in_field
c
      character subarray*8
      logical noiseless, psf_add, ipc_add
c
      parameter (max_stars=10000,nnn=2048,nfilters=54)
c
      dimension gain_image(nnn,nnn)
      dimension ra_stars(max_stars), dec_stars(max_stars), 
     *     mag_stars(max_stars,nfilters)
      dimension attitude_inv(3,3)

      common / gain_/ gain_image
      common /stars/ ra_stars, dec_stars, mag_stars, nstars
c
      if (verbose .eq.1) then
         print *,'enter add_stars'
      end if
      q  = dacos(-1.0d0)/180.d0
c
      if(subarray(1:4) .eq.'FULL') then
         ixmin = 5
         ixmax = naxis1- 4
         iymin = 5
         iymax = naxis2 - 4
      else
         ixmin = colcornr
         ixmax = ixmin + naxis1
         iymin = rowcornr
         iymax = iymin + naxis2
      end if
c
      xhit     = 0.0d0
      xhit     = 0.0d0
      in_field = 0
      do  i = 1, nstars
cc     
cc     verify that star is contained within field
cc     (could be done later for objects at the edges)
cc
c         if(x_sca.lt.ixmin .or. x_sca.gt.ixmax) go to 100
c         if(y_sca.lt.iymin .or. y_sca.gt.iymax) go to 100
c
c     calculate the number of photo-electrons per second
c     (system_transmission contains the quantum efficiency term)
c
         stellar_photons = 
     *        ab_mag_to_photon_flux(mag_stars(i,filter_index),
     *        mirror_area,  wavelength, bandwidth, system_transmission)
c         print *,stellar_photons, integration_time, filter_index,
c     *        mag_stars(i,filter_index), mirror_area
c     
c      Find expected number of photo-electrons
c     
         total_per_cycle = stellar_photons * integration_time
c     
c     for noiseless
c     
        if(noiseless .eqv. .true.) then
           expected = total_per_cycle !+ zbqlnor(0.0d0,0.5d0)
        else
           expected = zbqlpoi(total_per_cycle)
        end if
c     write(17, 10) ra_stars(i), dec_stars(i), x_sca,  y_sca,
c     *           mag_stars(i,filter_index), stellar_photons,
c     *           total_per_cycle, expected
        if(verbose.gt.1) then
            print 10, ra_stars(i), dec_stars(i), x_sca,  y_sca,
     *          mag_stars(i,filter_index), stellar_photons,
     *          total_per_cycle, expected
 10         format('add_stars ', 4(1x,f12.6), f8.3, 
     *           2(2x,f12.2),2x,i10)
         end if

         if(expected .gt.0 ) then
            if(distortion.eq.0) then
c     
c     find SCA coordinates for this object 
c
               x_sca = ra_stars(i)
               y_sca = dec_stars(i)
               do j = 1, expected
                  if(psf_add .eqv. .true.) 
     &                 call psf_convolve(seed, xhit, yhit)
c     
                  ix = idnint(x_sca - xhit/over_sampling_rate)
                  iy = idnint(y_sca - yhit/over_sampling_rate)
c
c     add this photo-electron
c     
                  if(ix.gt.ixmin .and.ix.lt.ixmax .and. 
     *                 iy.gt.iymin .and. iy .lt.ixmax) then
                     intensity = 1.d0
                     if(subarray(1:4) .ne.'FULL') then
                        ix = ix - colcornr
                        iy = iy - rowcornr
                     end if
                     call add_ipc(ix, iy, intensity,naxis1, naxis2, 
     &                    ipc_add)
c     PRINT *, 'ADD IPC ', IX, IY
                  end if
               end do
            else
c
c     calculate the (V2, V3) coordinates of object centre from RA, DEC
c     
            ra_rad  = ra_stars(i)  * q 
            dec_rad = dec_stars(i) * q
            if(verbose.gt.1) 
     &           print *,'add_stars : nstars, ra, dec',
     &           nstars, ra_stars(i), dec_stars(i)
            call rot_coords(attitude_inv, ra_rad, dec_rad, v2_rad,
     &           v3_rad)
            call coords_to_v2v3(v2_rad, v3_rad, v2_arcsec, v3_arcsec)
            xg = v2_arcsec
            yg = v3_arcsec
c
c     with FOV distortion
c
               do j = 1, expected
                  call psf_convolve(seed, xhit, yhit)
c     detector coordinates for this photon (arc sec)
                  v2 = xg + xhit * psf_scale
                  v3 = yg + yhit * psf_scale
c     print *,'add_stars: xg, yg,v2, v3, xhit, yhit, psf_scale ',
c     &              xg, yg, v2, v3, xhit, yhit, psf_scale
                  call v2v3_to_det(
     &                 x_det_ref, y_det_ref,
     &                 x_sci_ref, y_sci_ref,
     &            sci_to_ideal_x,sci_to_ideal_y, sci_to_ideal_degree,
     &            ideal_to_sci_x,ideal_to_sci_y,ideal_to_sci_degree,
     &                 v3_sci_x_angle,v3_sci_y_angle,
     &                 v3_idl_yang, v_idl_parity,
     &                 det_sci_yangle,
     &                 v2_ref, v3_ref,
     &                 v2, v3, x_sca, y_sca,
     &                 precise,verbose)
                  ix = idnint(x_sca)
                  iy = idnint(y_sca)
                  if(ix.gt.ixmin .and.ix.lt.ixmax .and. 
     *                 iy.gt.iymin .and. iy .lt.ixmax) then
                     intensity = 1.d0
                     call add_ipc(ix, iy, intensity,naxis1, naxis2, 
     &                    ipc_add)
                  endif
               end do
            end if
         end if
         in_field = in_field + 1
 100     continue
      end do
      return
      end
