c
c-----------------------------------------------------------------------
c
      subroutine add_galaxy_component(xg, yg, magnitude, id,
     *     ellipticity,re, rmax, 
     *     theta, nsersic, zp, scale, 
     *     pa_degrees,
     *     wavelength, bandwidth, system_transmission, 
     *     mirror_area, abmag, integration_time,seed, 
     *     noiseless, psf_add, ipc_add, debug)
c
c     Code to add photons for a single Sersic component
c
      implicit none
      double precision xg, yg, magnitude, ellipticity, re, rmax, theta,
     *     nsersic, zp, scale, mirror_area, wavelength,
     *     bandwidth, system_transmission, abmag, integration_time
      double precision a11, a12, a21, a22
      integer seed, debug, id, cube, overlap, last, indx
c
      real accum, image, gain_image
c
      double precision radius, profile, int_profile
      double precision photons, cospa, sinpa, axial_ratio, ymax, ran,
     *     rr, angle, sina, cosa, chi, a_prime, b_prime,
     *     xgal, ygal, xhit, yhit, flux_total, pi, q, two_pi,
     *     intensity, pa_degrees
      integer nr, nnn,i, j, expected, ix, iy,n_image_x, n_image_y
c
      double precision ab_mag_to_photon_flux,zbqlu01,
     *     photon_flux_from_uresp
      integer zbqlpoi
      logical noiseless, psf_add, ipc_add
c
      parameter(nnn=2048, overlap=30)
c
      dimension cube(nnn,nnn,overlap)
      dimension accum(nnn,nnn),image(nnn,nnn), gain_image(nnn,nnn)
      dimension radius(nnn), profile(nnn), int_profile(nnn)
c
      common /history/ cube
      common /images/ accum, image, n_image_x, n_image_y
      common /gain_/ gain_image
c
      pi = dacos(-1.0d0)
      q  = pi/180.d0
      two_pi = pi * 2.d0
c
c     create profile
c     
      call int_sersic(nr, radius, profile, int_profile, nnn,
     *     magnitude, re, rmax, nsersic, zp, ellipticity, debug)
      if(debug.gt.2) then
c      print *,'add_galaxy_component: nr ',nr
         do j = 1, nr,100
            print 40,j, radius(j), profile(j), int_profile(j),
     *           -2.5d0*dlog10(int_profile(j))
 40         format(i5,1x,f10.3,2(1x,e16.8),2(1x,f8.3),2x,
     &           'add_galaxy_component')
         end do
      end if
c     
c     calculate total number of expected photons within profile
c
c      photons =  
c     *     ab_mag_to_photon_flux(magnitude, mirror_area,
c     *     wavelength, bandwidth, system_transmission)
c      print *,'photons 1',photons
      photons = photon_flux_from_uresp(magnitude, abmag)
c     print *,'photons 2',photons, magnitude, abmag
      if(noiseless .eqv. .true.) then
         expected  = photons * integration_time
      else
         expected  = zbqlpoi(photons * integration_time)
      end if
      
      if(debug.gt.1) then
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
c      cospa  = dcos((-theta)*q)
c      sinpa  = dsin((-theta)*q)
      cospa  = dcos(angle*q)
      sinpa  = dsin(angle*q)
      axial_ratio = 1.d0 - ellipticity
c     
      ymax = int_profile(nr)
c     
      flux_total = 0.0d0
c
c     Sample randomly in polar coordinates
c
      do  j = 1,   expected
         ran = int_profile(1) + 
     *        zbqlu01(seed) * (ymax-int_profile(1))
         call linear_interpolation(nr, int_profile, radius, ran, 
     *        rr)
c
c     angular random variate
c
         angle   = zbqlu01(seed) * two_pi
c         sina    = dsin(angle)
c         cosa    = dcos(angle) 
         a_prime =  rr / dsqrt(axial_ratio)/scale
         b_prime =  a_prime * (axial_ratio)
c     
c     Position angles are relative to X, Y axis
c     
         chi   = angle + theta * q
         chi   = angle
         xgal  = a_prime * dcos(chi) *cospa + b_prime*dsin(chi)*sinpa
         ygal  =-a_prime * dcos(chi) *sinpa + b_prime*dsin(chi)*cospa
         xgal  = xg + xgal
         ygal  = yg + ygal
c     
c     convolve with PSF
c     
c         if(debug.gt.1) then
         if(noiseless.eqv. .True.) then
            ix    = idnint(xgal)
            iy    = idnint(ygal)
            if(ix.gt.4 .and. ix. lt.2045 .and. 
     *           iy.gt.4 .and.iy.lt.2045) then
               image(ix, iy) = image(ix,iy) + 1.0
               flux_total    = flux_total + 1.0d0
            end if
         else
            xhit = 0.d0
            yhit = 0.d0
            if(psf_add .eqv. .true.) call psf_convolve(seed, xhit, yhit)
c            print *,' xhit, yhit',xhit, yhit
            ix = idnint(xgal - xhit)
            iy = idnint(ygal - yhit)
c     
c     add this photo-electron
c     
            if(ix.gt.4 .and.ix.lt.2045 .and. 
     *           iy.gt.4 .and. iy .lt.2045) then
               intensity = 1.d0
               call add_ipc(ix, iy, intensity, ipc_add)
c
               flux_total = flux_total + 1.d0
               do i = 1, overlap
                  if(cube(ix, iy,i).eq.0) then
                     last = i -1
                     go to 700
                  else
                     if(cube(ix,iy,i).eq.id) go to 710
                  end if
               end do
               go to 710
 700           indx = last + 1
               cube(ix,iy,indx) = id
c               print *,'add_galaxy_component ', ix, iy, indx, id
 710        continue    
        end if
         end if
      end do
c
      if(debug.gt.0) then
         print 800, id, nsersic, re,  ellipticity,
     *        magnitude, photons*integration_time, expected,flux_total
 800     format(i8,2x,f7.3,3(2x,f9.4),2x, f11.1, 2x, i10,2x,f12.1,
     &        ' add_galaxy_component')
      end if
      return
      end
