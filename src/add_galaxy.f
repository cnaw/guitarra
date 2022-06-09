c
c-----------------------------------------------------------------------
c
      subroutine add_galaxy(
     &     include_cloned_galaxies, include_galaxies,
     *     galaxy, max_objects,
     &     level, filter_id,
     *     sca_id, naxis1, naxis2,
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
     &     verbose)

      implicit none
!
      type guitarra_source
      character :: path*180, id*25
      integer :: number, ncomponents
      real (kind=8)  :: ra, dec, mag, zz, 
     &     re, ellipticity, flux_ratio, theta, nsersic
      end type guitarra_source
c
      double precision photon_flux_from_uresp
      double precision ra_dithered, dec_dithered, pa_degrees,
     *     xc, yc, osim_scale
      double precision xg, yg, ra, dec, v2, v3,
     *     magnitude, ellipticity, theta, re, nsersic,flux_ratio,
     *     z, scale, 
     *     wavelength, bandwidth, system_transmission, 
     *     mirror_area, abmag,integration_time
      double precision rmax, photons, mag, zp, mzp
      double precision xgal, xhit, ygal, yhit,
     *     x_sca, y_sca, xx, yy, x_osim, y_osim
      
      double precision ab_mag_to_photon_flux
      double precision ra_rad, dec_rad, v2_rad, v3_rad, v2_arcsec,
     &     v3_arcsec, psf_scale, attitude_inv, qq
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
      integer ix, iy, seed, verbose, ngal, ng,in_field, naxis1, naxis2,
     *     ncomponents,id, i, j, nc, sca_id, filter_index, junk
      logical noiseless, psf_add, ipc_add
      integer colcornr, rowcornr
      character subarray*(*)
c
      character clone_template*180, filter_id*6
      integer zbqlpoi
      double precision zbqlu01
      double precision one_d, flux_scale
      double precision hst_mags
      integer level, expected,  nx, ny, nz, nxny, npts, kk,
     &     include_cloned_galaxies, include_galaxies, clone_or_model
      integer ixmin, ixmax, iymin, iymax
      double precision cosdec, dra, ddec, cospa, sinpa, flux_total,
     &     intensity
      double precision scale_0, scale_z, redshift, wl_source_filter,
     &     zp_filter
      character source_filter*6
c
c      parameter(max_objects = 60000)
      parameter ( nnn = 2048, nfilters=54,nsub=4)
      parameter (nxny = 2048*2048)
 !
      integer nclone
c      type(clone_source) :: clone(max_objects)
      type(guitarra_source) :: galaxy(max_objects)

!
      dimension source_filter(nfilters), wl_source_filter(nfilters),
     &     zp_filter(nfilters)
c      dimension ra(max_objects), dec(max_objects), z(max_objects),
c     *     magnitude(max_objects), ncomponents(max_objects), 
c     *     id(max_objects),
c     *     nsersic(max_objects,nsub),ellipticity(max_objects,nsub), 
c     *     re(max_objects, nsub), theta(max_objects,nsub),
c     *     flux_ratio(max_objects, nsub)
c
      dimension attitude_inv(3,3)
      dimension one_d(nxny), hst_mags(nfilters)
c
c      common /galaxy/ra, dec, z, magnitude, nsersic, ellipticity, re,
c     *     theta, flux_ratio, ncomponents,id
c
      common /wcs/ equinox, 
     *     crpix1, crpix2,      ! crpix3,
     *     crval1, crval2,      !crval3,
     *     cdelt1, cdelt2,      !cdelt3,
     *     cd1_1, cd1_2, cd2_1, cd2_2,! cd3_3,
     *     pc1_1, pc1_2, pc2_1, pc2_2 !, pc3_1, pc3_2
c
      qq  = dacos(-1.0d0)/180.d0
c     

      in_field = 0
      zp   = 0.0d0
c
c     Loop over catalogue
c
      if(sca_id.lt.481) then
         junk = 1
      else
         junk = sca_id
      end if
      intensity  = 1.d0
c
ccccccccccccccccccccccccc
c
c     set image domain
c
      ixmin = 5
      ixmax = 2044
      iymin = 5
      iymax = 2044
c
      if(subarray(1:4) .eq.'FULL') then
         ixmin = 5
         ixmax = naxis1- 4
         iymin = 5
         iymax = naxis2 - 4
      else
         ixmin = colcornr
         ixmax = ixmin + naxis1 - 1
         iymin = rowcornr
         iymax = iymin + naxis2 - 1
      end if
c     
ccccccccccccccccccccccccc
c
      do ng = 1, ngal
         flux_total = 0.0d0

         cospa = dcos((pa_degrees)*qq)
         sinpa = dsin((pa_degrees)*qq)
c     find SCA coordinates for this object 
c         if(distortion.eq.0) then
c            call ra_dec_to_sca(junk, 
c     *           ra_dithered, dec_dithered, 
c     *           galaxy(ng)%ra, galaxy(ng)%dec, pa_degrees, 
c     *           xc, yc,  osim_scale, xg, yg)
c         endif
c     calculate the (V2, V3) coordinates of object centre from RA, DEC
         if(distortion.eq.1) then
c           ra_rad  = ra(ng) * qq
c           dec_rad = dec(ng) * qq
            ra_rad  = galaxy(ng)%ra  * qq 
            dec_rad = galaxy(ng)%dec * qq
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
     &           precise,verbose)
c            print *, ng, 
c     &           x_det_ref, y_det_ref,
c     &           x_sci_ref, y_sci_ref,
c     &           sci_to_ideal_x,sci_to_ideal_y,sci_to_ideal_degree,
c     &           ideal_to_sci_x,ideal_to_sci_y,ideal_to_sci_degree,
c     &           v3_sci_x_angle,v3_sci_y_angle,
c     &           v3_idl_yang, v_idl_parity,
c     &           det_sci_yangle, det_sci_parity,
c     &           v2_ref, v3_ref,
c     &           v2_arcsec, v3_arcsec,  xg, yg
         end if
c     
c     no distortion using SIAF WCS
c     
         if(distortion.eq.2) then
            call wcs_rd_to_xy(xg,yg,galaxy(ng)%ra,galaxy(ng)%dec,
     &           crpix1, crpix2, crval1, crval2,
     &           cd1_1, cd1_2, cd2_1, cd2_2)
         end if
c         print *,'add_galaxy ', ng, ra_dithered, dec_dithered,
c     &        ' path ', galaxy(ng)%path
c         print 40, galaxy(ng)%path
 40      format(A180)
c     
c     these are the possible cases for making a simulation regarding
c     whether to include cloned and/or modelled galaxies. The
c     underlying assumption is that all galaxies have a Sersic
c     profile assigned to them, which may prove false.
c     
         clone_or_model = 1
c
         if( include_cloned_galaxies .eq. 0 .and.
     &        include_galaxies .eq. 1)  clone_or_model = 1
c
         if( include_cloned_galaxies .eq. 0 .and.
     &        include_galaxies .eq. 0) clone_or_model = 3
c
         if( include_cloned_galaxies .eq. 1 .and.
     &        include_galaxies .eq. 1 .and.
     &        trim(galaxy(ng)%path) .eq. 'none') clone_or_model = 1
c
         if( include_cloned_galaxies .eq. 1 .and.
     &        include_galaxies .eq. 1 .and.
     &        trim(galaxy(ng)%path) .ne. 'none') clone_or_model = 2
c
         if( include_cloned_galaxies .eq. 1 .and.
     &        include_galaxies .eq. 0 .and.
     &        trim(galaxy(ng)%path) .ne. 'none') clone_or_model = 2
c
         if( include_cloned_galaxies .eq. 1 .and.
     &        include_galaxies .eq. 0 .and.
     &        trim(galaxy(ng)%path) .eq. 'none')  clone_or_model = 3
c
!
!     no model nor clone (for completeness)
!
         select case(clone_or_model)
         case (3)
            go to 200
!     model
         case(1)
            if(verbose.gt.0) then 
               print 50,
     &              galaxy(ng)%ra, galaxy(ng)%dec, xg, yg,
     &              galaxy(ng)%mag, filter_index 
 50            format('add_galaxy :ra, dec, xg, yg, mag, filter_index',
     &              4(1x,f12.5), 1x, f9.3, i7)
            end if
            if(galaxy(ng)%mag .eq.0.0d0) then
               print *, 'add modelled galaxy 0 magnitude !',
     &              ng,  galaxy(ng)%ra, galaxy(ng)%dec,filter_index,
     &              galaxy(ng)%mag
               print *,'quitting'
               stop
            end if
c     
c     radial profile unit = pixel
c     Find largest extension 
c     
            rmax        = galaxy(ng)%re
c            if(galaxy(ng)%ncomponents.gt.1) then 
c               do i = 2, galaxy(ng)%ncomponents
c                  if(galaxy(ng)%re.gt. rmax)
c     &                 rmax = galaxy(ng)%re(i)
c               end do
c            end if
c     
c     Estimate the total magnitude using a large radius.
c     maximum radius: SDSS truncates at 4 scale lengths. Try at 10
c     
            rmax   =   rmax * 100.D0 
            if(rmax .eq. 0.0d0) go to 200
            if(verbose.ge.1) 
     *           print 90, galaxy(ng)%ncomponents, rmax,
     *           xg, yg
 90         format('add_modelled_galaxy  #components, rmax, xg, yg',
     &           i3,2x,f9.4,2(2x,f9.2))
c     
c     add photons corresponding to each component
c     
            if(verbose.ge.1) then
               print 100
 100           format('  nc nsersic      re    ellipticity  magnitude ',
     *           '  photons     expected')
            end if
c     
c     create profiles for each component and co-add
c
c            print *,'add_galaxy  galaxy(ng)%ncomponents',
c     &            galaxy(ng)%ncomponents,galaxy(ng)%mag
            do nc = 1, galaxy(ng)%ncomponents
               mag = galaxy(ng)%mag
     *              -2.5d0*dlog10(galaxy(ng)%flux_ratio)
               if(verbose.ge.1) then
                  print 110, filter_index, ng, nc,
     &                 galaxy(ng)%mag,galaxy(ng)%flux_ratio
 110              format(
     &                 'add_modelled_galaxy filter_index, ng, nc, mag',
     &                 3(2x,i6), 2(2x,f20.12))
                  print *,
     &                 'add_modelled_galaxy:nsersic(ng,nc),re(ng,nc)',
     &                 galaxy(ng)%nsersic,galaxy(ng)%re
               end if
c     if(verbose.gt.1)
               
               if((galaxy(ng)%nsersic.ge.20.d0.or.
     &              galaxy(ng)%nsersic.le.0.01d0)
     &              .and. galaxy(ng)%re.le.0.1d0) then
c     print *,'add_modelled_galaxy: xg, yg',xg, yg
                  call add_star(
     &                 v2_arcsec, v3_arcsec, xg,  yg,
     &                 subarray,colcornr, rowcornr,
     &                 mag, abmag, integration_time,
     *                 noiseless, psf_add, ipc_add,
     *                 psf_scale, over_sampling_rate, 
     *                 naxis1, naxis2, sca_id-480, 
     *                 distortion, precise, 
     &                 sci_to_ideal_x, sci_to_ideal_y,
     &                 sci_to_ideal_degree,
     &                 ideal_to_sci_x, ideal_to_sci_y,
     &                 ideal_to_sci_degree,
     &                 x_det_ref, y_det_ref, x_sci_ref, y_sci_ref,
     &                 det_sci_yangle, det_sci_parity,
     &                 v3_idl_yang, v_idl_parity, v2_ref, v3_ref,
     &                 verbose)
               else
                  call add_galaxy_component(
     *                 v2_arcsec, v3_arcsec, xg, yg,
     &                 subarray,colcornr, rowcornr,
     *                 mag, galaxy(ng)%id,
     *                 galaxy(ng)%ellipticity, galaxy(ng)%re, rmax, 
     *                 galaxy(ng)%theta, galaxy(ng)%nsersic, zp, scale,
     *                 pa_degrees,
     *                 wavelength, bandwidth,system_transmission, 
     *                 mirror_area, abmag, integration_time,seed,
     *                 noiseless, psf_add, ipc_add, 
     *                 sca_id-480, distortion,precise,
     &                 sci_to_ideal_x, sci_to_ideal_y,
     &                 sci_to_ideal_degree,
     &                 ideal_to_sci_x, ideal_to_sci_y,
     &                 ideal_to_sci_degree,
     &                 x_det_ref, y_det_ref, x_sci_ref, y_sci_ref,
     &                 det_sci_yangle, det_sci_parity,
     &                 v3_idl_yang, v_idl_parity, v2_ref, v3_ref,
     *                 psf_scale, over_sampling_rate, 
     *                 naxis1, naxis2, verbose)
               end if
            end do
            go to 200
c     
c--------------------------------------------------------------
c--------------------------------------------------------------
c     cloning
         case(2)
!
!     level refers to the HST filter's level in the data cube
!
!            mag = clone(ng)%mag(level)
!     this should satisfy Marcia's suggestion
            mag = galaxy(ng)%mag
            clone_template = galaxy(ng)%path

            call read_one_d_image(clone_template, 
     &           filter_id, one_d, nxny, npts,
     &           ra, dec, redshift, magnitude, zp_filter,
     &           scale_0, scale_z, nx, ny,
     &           source_filter, wl_source_filter,verbose)
c            
c            call prepare_clone_s(clone_template, 
c     &           filter_index, level, nx, ny,
c     &           x_scale, y_scale,  sca_scale, one_d, nxny, npts,
c     &           hst_mags, nfilters, verbose)
            flux_scale = photon_flux_from_uresp(mag, abmag)
            if(one_d(npts).le.0.d0) then
               print *,'add_galaxy :one_d ',one_d(npts),
     &             clone_template 
               go to 660
            end if
            flux_scale = flux_scale/one_d(npts)
            do j = 1, npts
               one_d(j) = one_d(j) * flux_scale
            end do
            photons  = one_d(npts)
c            print *,'add_galaxy ', photons, trim(clone_template)
c     print *,'add_galaxy ng: ',  ng, 'ngal ', ngal,
c     *           'template ',  trim(clone_template(ng)),
c     *           ' kk', kk, ' level', level,' nxny ', nxny
c            print *,'add_galaxy: photons from magnitude, oned',
c     &           photon_flux_from_uresp(mag, abmag),
c     &           photon_flux_from_uresp(clone_mags(level), abmag),
c     &           photons,
c     &           mag,clone_mags(level), abmag
c            print *,'add_galaxy ng, id(ng),mag',
c     &           ng, id(ng),one_d(npts), mag
c            stop
            if(noiseless .eqv. .TRUE.) then
               expected  = photons * integration_time
            else
               expected  = zbqlpoi(photons * integration_time)
            end if
c            print *, 'add_galaxy clone npts: ',
c     &           npts, one_d(npts), expected
c     
            if(distortion.eq.1) then
               do  j = 1,   expected
c     find location of pixel
                  call  pixel_select(one_d, npts, nx, ny,
     *                 seed,  xgal, ygal)
c     
c     rotate to detector orientation
c     
c                  dra    =  xgal * cospa + ygal * sinpa
c                  ddec   = -xgal * sinpa + ygal * cospa
                  dra    = xgal
                  ddec   = ygal
c     
c     (ra, dec) coordinates
c     
                  dec_rad = (galaxy(ng)%dec + ddec*scale_0) * qq
                  cosdec  = cos(dec_rad)
                  ra_rad  = (galaxy(ng)%ra -  dra*scale_0*cosdec) * qq
                  call rot_coords(attitude_inv, ra_rad, dec_rad, 
     &                 v2_rad, v3_rad)
                  call coords_to_v2v3(v2_rad, v3_rad,
     &                 v2_arcsec, v3_arcsec)
c     
                  xhit = 0.0d0
                  yhit = 0.0d0
                  call psf_convolve(seed, xhit, yhit)
                  v2 = v2_arcsec - (xhit * psf_scale)
                  v3 = v3_arcsec - (yhit * psf_scale)
                  call v2v3_to_det(
     &                 x_det_ref, y_det_ref,
     &                 x_sci_ref, y_sci_ref,
     &                 sci_to_ideal_x,sci_to_ideal_y,
     &                 sci_to_ideal_degree,
     &                 ideal_to_sci_x, ideal_to_sci_y,
     &                 ideal_to_sci_degree,
     &                 v3_sci_x_angle,v3_sci_y_angle,
     &                 v3_idl_yang, v_idl_parity,
     &                 det_sci_yangle, det_sci_parity,
     &                 v2_ref, v3_ref,
     &                 v2, v3,  xg, yg,
     &                 precise,verbose)
c     
                  ix = idnint(xg)
                  iy = idnint(yg)
c                  print *,'add_galaxy clone 1', xgal, ygal, xg,yg,ix,iy
                  if(verbose.gt.0 .and.j.eq.1 ) then
                     print *,' '
                     print *,'add_galaxy 1',
     &                ng, galaxy(ng)%ra, galaxy(ng)%dec
                     print 600,xg, yg, v2, v3, xhit,yhit,ix,iy,
     &                    psf_scale
 600                 format(' add_galaxy 2:',6(2x,f12.5),2i8,2x,f12.5)
                  end if
                  if(ix.ge. ixmin .and.ix.le.ixmax .and. 
     *                 iy.gt.iymin .and. iy .lt.iymax) then
                     call add_ipc(ix, iy, intensity,
     *                    naxis1, naxis2, ipc_add)
                     flux_total = flux_total + intensity
                  end if
c                  print *,'add_galaxy clone 1', ix, iy, ixmin, ixmax,
c     &                 iymin, iymax,flux_total
               end do           ! close do j = 1, expected
            else                ! close distortion.eq.1
               do  j = 1,   expected
c     find location of pixel
                  call  pixel_select(one_d, npts, nx, ny,
     *                 seed,  xhit, yhit)
                  dra    =  xhit * cospa + yhit * sinpa
                  ddec   = -xhit * sinpa + yhit * cospa
c                  ix = idnint(xg + dra)
c                  iy = idnint(yg - ddec)
                  ix = idnint(xg - dra)
                  iy = idnint(yg + ddec)
c     print *, xg, xhit, ix
c     print *, yg, yhit, iy
c     
c     add this photo-electron
c     
                  if(ix.gt.ixmin .and.ix.lt.ixmax .and. 
     *                 iy.gt.iymin .and. iy .lt.ixmax) then
                     if(subarray(1:4) .ne.'FULL') then
                        ix = ix - colcornr 
                        iy = iy - rowcornr
                     end if
                     call add_ipc(ix, iy, intensity,naxis1, naxis2, 
     &                    ipc_add)
                     flux_total = flux_total + intensity
                  end if        ! ixmin, ixmax, iymin, iymax
c                  print *,'add_galaxy clone 2', ix, iy, ixmin, ixmax,
c     &                 iymin, iymax,flux_total
               end do           !j = 1, expected
            endif               ! closes distortion == 2
 660        continue
            if(verbose.ge.1) 
     &          print *,
     &        'add_galaxy ng, id,mag, one_d(npts),flux_total,expected',
     &         ng, galaxy(ng)%id,mag, abmag, one_d(npts),
     &           flux_total,expected
c     
         case default
            go to 200
         end select
         in_field = in_field +1
 200     continue
      end do                    ! close loop over ng = 1, ngal
      return
      end
