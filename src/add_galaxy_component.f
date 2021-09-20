c
c-----------------------------------------------------------------------
c
      subroutine add_galaxy_component(v2_arcsec, v3_arcsec,
     &     xg, yg,
     &     subarray,colcornr, rowcornr,
     *     magnitude, id, ellipticity,re, rmax, 
     *     theta, nsersic, zp, scale, 
     *     pa_degrees,
     *     wavelength, bandwidth, system_transmission, 
     *     mirror_area, abmag, integration_time,seed, 
     *     noiseless, psf_add, ipc_add, 
     *     sca, distortion,precise,
     &     sci_to_ideal_x, sci_to_ideal_y, sci_to_ideal_degree,
     &     ideal_to_sci_x, ideal_to_sci_y, ideal_to_sci_degree,
     &     x_det_ref, y_det_ref, x_sci_ref, y_sci_ref,
     &     det_sci_yangle, det_sci_parity,
     &     v3_idl_yang, v_idl_parity, v2_ref, v3_ref,
     *     psf_scale, over_sampling_rate, 
     *     naxis1, naxis2, debug)
c
c     Code to add photons for a single Sersic component
c
      implicit none
      double precision xg, yg, magnitude, ellipticity, re, rmax, theta,
     *     nsersic, zp, scale, mirror_area, wavelength,
     *     bandwidth, system_transmission, abmag, integration_time
      double precision a11, a12, a21, a22
      double precision v2, v3, v2_arcsec, v3_arcsec, xdet, ydet,
     &     psf_scale

      integer seed, debug, id, cube, overlap, last, indx
      integer sca, distortion, precise, over_sampling_rate
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
      integer naxis1, naxis2
      integer  colcornr, rowcornr
      integer ixmin, ixmax, iymin, iymax
      character subarray*(*)
c
      real image, gain_image
c
      double precision radius, profile, int_profile
      double precision photons, cospa, sinpa, axial_ratio, ymax, ran,
     *     rr, angle, sina, cosa, chi, a_prime, b_prime,
     *     xgal, ygal, xhit, yhit, flux_total, pi, q, two_pi,
     *     intensity, pa_degrees
      integer nr, nnn,i, j, expected, ix, iy
c
      double precision ab_mag_to_photon_flux,zbqlu01,
     *     photon_flux_from_uresp
      integer zbqlpoi
      logical noiseless, psf_add, ipc_add
c
      parameter(nnn=2048, overlap=30)
c
      dimension cube(nnn,nnn,overlap)
      dimension image(nnn,nnn), gain_image(nnn,nnn)
      dimension radius(nnn), profile(nnn), int_profile(nnn)
c
      common /history/ cube
      common /image_/ image
      common /gain_/ gain_image
c
      pi = dacos(-1.0d0)
      q  = pi/180.d0
      two_pi = pi * 2.d0
c
c     create profile
c     
      if(debug.gt.2)
     &    print *,'add_galaxy_component : magnitude ',magnitude
      call int_sersic(nr, radius, profile, int_profile, nnn,
     *     magnitude, re, rmax, nsersic, zp, ellipticity, debug)
      if(debug.ge.1) then
         print *,'add_galaxy_component: nr ',nr
         do j = 1, nr,100
            print 40,j, radius(j), profile(j), int_profile(j),
     *           -2.5d0*dlog10(int_profile(j)), magnitude
 40         format(i5,1x,f10.3,2(1x,e16.8),3(1x,f8.3),2x,
     &           'add_galaxy_component')
         end do
      end if
c     
c     calculate total number of expected photons within profile
c
      photons = photon_flux_from_uresp(magnitude, abmag)
      if(debug.ge.2) print *,'add_galaxy_component ',
     &     photons, magnitude, abmag
      if(noiseless .eqv. .true.) then
         expected  = photons * integration_time
      else
         expected  = zbqlpoi(photons * integration_time)
      end if
      
      if(debug.gt.2) then
         print *,'add_galaxy_component:'
         print *, 'magnitude, mirror_area, wavelength, bandwidth,', 
     *        'system_transmission, integration_time'
         print *, magnitude, mirror_area, wavelength, bandwidth, 
     *        system_transmission, integration_time
c         expected  = photons * integration_time
         print *,' add_galaxy_component not random:',expected,
     *        photons*integration_time
      end if
c     
c     add individual photons to image
c     For each photon, find a radius weighted by the surface-brightness 
c     profile and a random angle. The position of this photon on the 
c     image will be modulated by ellipticity and position angle.
c     In the case of disks, the ellipticity is a function of cos(inclination)
c     
c      cospa  = dcos(theta*q)
c      sinpa  = dsin(theta*q)
c     This gives correct PAs when the PA in the original catalogue
c     has N= 0, E =90
c
c      cospa  = dcos((90.d0-theta)*q)
c      sinpa  = dsin((90.d0-theta)*q)
c     As angles are normally measured relative to the X axis and
c     we are dealing with position angles, which are measured relative
c     to North, add offset
c
      angle  =  theta + 90.d0 - pa_degrees
      cospa  = dcos(angle*q)
      sinpa  = dsin(angle*q)
      axial_ratio = 1.d0 - ellipticity
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
      ymax = int_profile(nr)
c     
      flux_total = 0.0d0
c
c     Sample randomly in polar coordinates
c
      intensity = 1.d0
      do  j = 1,   expected
         ran = int_profile(1) + 
     *        zbqlu01(seed) * (ymax-int_profile(1))
         call linear_interpolation(nr, int_profile, radius, ran, 
     *        rr)
c
c     angular random variate
c     
         angle   = zbqlu01(seed) * two_pi
         a_prime =  rr / dsqrt(axial_ratio)
         b_prime =  a_prime * (axial_ratio)
c     
c     Position angles are relative to X, Y axis
c     
         chi   = angle
         xgal  = a_prime * dcos(chi) *cospa + b_prime*dsin(chi)*sinpa
         ygal  =-a_prime * dcos(chi) *sinpa + b_prime*dsin(chi)*cospa
c     photon intensity 
         xhit = 0.d0
         yhit = 0.d0
c
         if(distortion.eq.0 .or. distortion.eq.2) then
            if(distortion.eq.0) then
               xgal  = xg + xgal/scale ! arc sec -> pixel
               ygal  = yg + ygal/scale
            else
               xgal  = xg + xgal/sci_to_ideal_x(2,1)
               ygal  = yg + ygal/sci_to_ideal_y(2,2)
            end if
c     no noise - no PSF convolution
            if(noiseless.eqv. .True.) then
               ix    = idnint(xgal) !- colcornr
               iy    = idnint(ygal) !- rowcornr
               if(ix.ge.ixmin .and. ix. le.ixmax .and. 
     *              iy.ge.iymin .and.iy.le.iymax) then
                  image(ix, iy) = image(ix,iy) + 1.0
                  flux_total    = flux_total + 1.0d0
               end if
            else
c     
c     convolve with PSF if psf_add is true
c     
               if(psf_add .eqv. .true.) 
     &              call psf_convolve(seed, xhit, yhit)
c
               ix = idnint(xgal - xhit/over_sampling_rate)
               iy = idnint(ygal - yhit/over_sampling_rate)
c     commented 2021-03-19
c               ix = ix - colcornr
c               iy = iy - rowcornr
c     
c     add this photo-electron
c     
               if(ix.ge.ixmin .and. ix. le.ixmax .and. 
     *              iy.ge.iymin .and.iy.le.iymax) then
                  call add_ipc(ix, iy, intensity, naxis1, naxis2,
     &                 ipc_add)
c     
                  flux_total = flux_total + 1.d0
c     keep track of how many objects overlap at this pixel
                  do i = 1, overlap
                     if(cube(ix, iy,i).eq.0) then
                        last = i -1
                        go to 700
                     else
                        if(cube(ix,iy,i).eq.id) go to 710
                     end if
                  end do
                  go to 710
 700              indx = last + 1
                  cube(ix,iy,indx) = id
c                  print *,'add_galaxy_component ', ix, iy, indx, id
 710              continue    
               end if ! close "if(ix.gt.4 .and.ix.lt.2045" 
            end if ! close "if(noiseless.eqv. .True.)"
         end if
c
c     adding focal plane distortion
c
         if(distortion.eq.1) then
            call psf_convolve(seed, xhit, yhit)
c, integrated_psf,
c     &           n_psf_x,n_psf_y, nxy, over_sampling_rate, verbose)
c     calculate v2, v3 
c     detector coordinates for this photon (arc sec)
            v2 = v2_arcsec + xgal - xhit * psf_scale
            v3 = v3_arcsec + ygal - yhit * psf_scale
            call v2v3_to_det(
     &           x_det_ref, y_det_ref,
     &           x_sci_ref, y_sci_ref,
     &           sci_to_ideal_x,sci_to_ideal_y,sci_to_ideal_degree,
     &           ideal_to_sci_x, ideal_to_sci_y,ideal_to_sci_degree,
     &           v3_sci_x_angle,v3_sci_y_angle,
     &           v3_idl_yang, v_idl_parity,
     &           det_sci_yangle, det_sci_parity,
     &           v2_ref, v3_ref,
     &           v2, v3, xdet, ydet,
     &           precise,debug)
c
c     commented 2021-03-19. colcornr and rowcornr should be
c     equivalent to either x_det_ref or x_sci_ref - x_sci_size/2
c
            ix = idnint(xdet) !- colcornr
            iy = idnint(ydet) !- rowcornr
            if(debug.gt.2 .and. j.eq.5) then ! print a random photon position
               print 600,xg, yg, v2, v3, xhit,yhit,ix,iy,psf_scale
 600           format('add_galaxy_component:',6(2x,f12.5),2i8,2x,f12.5)
            end if
            if(ix.ge. ixmin .and.ix.le.ixmax .and. 
     *           iy.gt.iymin .and. iy .lt.iymax) then
               call add_ipc(ix, iy, intensity, naxis1, naxis2, ipc_add)
c               print *, 'add_galaxy_component ix, iy ', ix, iy
            end if
         end if                 ! close  "if(distortion)"
      end do
c
      if(debug.gt.0) then
         print 800, id, nsersic, re,  ellipticity,
     *        magnitude, photons*integration_time, expected,flux_total
 800     format('add_galaxy_component:', 1x, i8,2x,f7.3,3(2x,f9.4),
     &        2x, f11.1, 2x, i10,2x,f12.1)
      end if
      return
      end
