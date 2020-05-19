c
c     Create data cube for an SCA at a given dither position.
c     Start by reading the bias and gain images for this SCA.
c     If this is the first dither, ignore reading the latent 
c     image.
c     as sca_image:
c     cnaw 2015-01-27
c     Steward Observatory, University of Arizona
c
c     as add_up_the_ramp
c     modified to make it compatible with STScI data model and ncdhas
c     cnaw 2017-05-01
c     Steward Observatory, University of Arizona
c     more changes 
c     cnaw 2018-02-26
c     cnaw 2018-06-08
c     cnaw 2020-03-17
c
      subroutine new_ramp(idither, ra_dithered, dec_dithered, 
     *     pa_degrees,
     *     filename, noise_name,
     *     sca_id, module, brain_dead_test, 
     *     xc, yc, pa_v3, osim_scale,scale,
     *     include_ipc,
     *     include_ktc, include_dark, include_dark_ramp,
     *     include_readnoise, 
     *     include_reference, include_flat,
     *     include_1_over_f, include_latents, include_non_linear,
     *     include_cr, cr_mode, include_bg,
     *     include_stars, include_galaxies, nstars, ngal,
     *     bitpix, ngroups, nframe, nskip, tframe, tgroup, object,
     *     nints,
     *     subarray, colcornr, rowcornr, naxis1, naxis2,
     *     filter_id, wavelength, bandwidth, system_transmission,
     *     mirror_area, photplam, photflam, stmag, abmag,
     *     background, icat_f,filter_index,npsf, psf_file, 
     *     dark_file,
     *     over_sampling_rate, noiseless, psf_add, 
     *     distortion, precise, attitude_inv,
     &     sci_to_ideal_x, sci_to_ideal_y, sci_to_ideal_degree,
     &     ideal_to_sci_x, ideal_to_sci_y, ideal_to_sci_degree,
     &     x_det_ref, y_det_ref, x_sci_ref, y_sci_ref,
     &     det_sci_yangle, det_sci_parity,
     &     v3_idl_yang, v_idl_parity, v2_ref, v3_ref,
     *     verbose)
      
      implicit none
c
      double precision mirror_area, integration_time, gain,
     *     decay_rate, time_since_previous, read_noise, 
     *     dark_mean, dark_sigma, ktc, voltage_offset,
     *     voltage_sigma
      double precision wavelength, bandwidth, system_transmission, 
     *     background, scale, bias_value
      double precision  even_odd, mean, sigma, deviate, zbqlnor
      double precision x_sca, y_sca, ra_sca, dec_sca
      double precision xc, yc, pa_v3, q, posang, ra_dithered,
     *     dec_dithered, osim_scale, x_osim, y_osim,
     *     pa_degrees, psf_scale
      double precision linearity_gain,  lincut, well_fact
      double precision zero_point, tol, eps
c
      double precision attitude_inv
c
c     images are either real*4 or integer
c
      integer image_4d, zero_frames, max_nint
      real  image,  accum, latent_image, base_image, bias, well_depth,
     *     gain_image, linearity, variate, scratch
      real noise, flat_image
      double precision photplam, photflam, stmag, abmag
c
      integer max_order, order,over_sampling_rate, nints
      integer zbqlpoi
      integer filter_index, icat_f
      integer nint_level, read_number
      integer pixel_index
c     
c     parameters
c
      double precision tframe, tgroup
c 
c      double precision
c     *     equinox, crpix1, crpix2, crval1, crval2, cdelt1,cdelt2,
c     *     cd1_1, cd1_2, cd2_1, cd2_2, cd3_2

      double precision equinox, crpix1, crpix2, crpix3,
     &     crval1, crval2, crval3, cdelt1, cdelt2,cdelt3,
     &     pc1_1, pc1_2, pc2_1, pc2_2, pc3_1, pc3_2, cd3_3,
     *     cd1_1, cd1_2, cd2_1, cd2_2, cd3_2
c
      integer colcornr, rowcornr, naxis1, naxis2
c
      integer frame,  bitpix, groupgap, sca_id, ibitpix,iunit
      integer time_step, verbose, naxes, n_image_x, n_image_y,idither,
     *     nskip, naxis, ngroups, nframe, job, indx
c
      integer distortion, precise
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
      logical ipc_add, psf_add, noiseless
      integer npsf
      integer cr_mode, seed
      integer include_ipc, include_ktc, include_bg, 
     &     include_cr, include_dark,include_dark_ramp,
     *     include_latents, include_flat,
     &     include_readnoise, include_non_linear,
     *     include_stars, include_galaxies, include_cloned_galaxies,
     &     brain_dead_test, include_1_over_f, include_reference
      integer i, j, k, loop, nlx, nly, level
      integer nnn, nstars, ngal, in_field
      character filename*(*), latent_file*180, psf_file*(*),
     &     noise_name*(*), dark_file*(*),test_image*80
      character object*20, partname*5, module*1, filter_id*5
      character guitarra_aux*100, v2v3_ref*180
c     
      character subarray*(*)
c
      parameter (nnn=2048, max_nint=1, max_order=7)
c
      dimension dark_mean(10), dark_sigma(10), gain(10),
     *     read_noise(10), even_odd(8), ktc(10), voltage_offset(10),
     *     voltage_sigma(10)
c     distortion-related
      dimension attitude_inv(3,3)
c     
c     images
c
      dimension image_4d(nnn,nnn,20,max_nint), naxes(4),
     &     zero_frames(nnn, nnn, max_nint)
      dimension base_image(nnn,nnn)
      dimension accum(nnn,nnn),image(nnn,nnn),latent_image(nnn,nnn),
     *     well_depth(nnn,nnn), linearity(nnn,nnn,max_order),
     *     bias(nnn,nnn), gain_image(nnn,nnn), scratch(nnn,nnn)
      dimension noise(nnn,nnn), flat_image(nnn,nnn,2)
      dimension psf_file(npsf)
c
c     images
c
      common /four_d/   image_4d, zero_frames
      common /accum_/   accum
      common /base/     base_image
      common /flat_/    flat_image
      common /gain_/    gain_image
      common /image_/   image
      common /latent/   latent_image
      common /noise_/   noise
      common /scratch_/ scratch
      common /well_d/ well_depth, bias, linearity,
     *     linearity_gain,  lincut, well_fact, order
c
      common /wcs/ equinox, 
     *     crpix1, crpix2,      ! crpix3,
     *     crval1, crval2,      !crval3,
     *     cdelt1, cdelt2,      !cdelt3,
     *     cd1_1, cd1_2, cd2_1, cd2_2,! cd3_3,
     *     pc1_1, pc1_2, pc2_1, pc2_2 !, pc3_1, pc3_2
c
c     Parameters
c
      common /parameters/ gain,
     *     decay_rate, time_since_previous, read_noise, 
     *     dark_mean, dark_sigma, ktc, voltage_offset,
     *     voltage_sigma
c     
      q   = dacos(-1.0d0)/180.d0
      tol = 1.d-10
      eps = 1.d-16
      integration_time = tframe
      partname='anoni'
      n_image_x = naxis1
      n_image_y = naxis2
c
c      even_odd(1) = 1.d0
c      even_odd(2) = 1.d0
c      even_odd(3) = 1.00682d0
c      even_odd(4) = 1.00682d0
c      even_odd(5) = 0.983038d0
c      even_odd(6) = 0.983038d0
c      even_odd(7) = 1.01164d0
c      even_odd(8) = 1.01164d0
      
c
      if(verbose.gt.0) then
         print 10,sca_id, filter_index, filter_id, idither
 10      format('add_up_the_ramp:  sca ', i4,' filter ', i4, 2x, a5,
     *        ' dither ',i4)
      end if
      indx = sca_id - 480
c
      if(distortion.eq.1) then
         do j = 1, 3
            print *,'new_ramp:attitude',(attitude_inv(i,j),i=1,3)
         end do
      end if
c
      write(latent_file, 1120) filter_id, iabs(sca_id)
 1120 format('latent_',a5,'_',i3.3,'.fits')
c
      if(include_ipc .eq.1) then
         ipc_add = .true.
      else
         ipc_add = .false.
      end if
c
c     Read PSF
c
      if(verbose.gt.1) then
         PRINT *,'SCA_IMAGE:', sca_id, ra_dithered, dec_dithered
c     *        x_sca, y_sca, ra_sca, dec_sca
         print 1130, psf_file(1)
      end if
      print 1130, psf_file(1)
 1130 format('new_ramp - going to read psf:',/, a180)
      call read_psf(psf_file(1), psf_scale, verbose)
      if(verbose.gt.0) print *,'psf has been read'
c
      groupgap =   nskip
      naxis    =   3
c     
c     Read the cosmic ray distribution if set;
c     The sca id is required to set the wavelength for the
c     M. Robberto cosmic ray models
c     
      if(include_cr .eq. 1) then
         call cr_distribution(cr_mode, sca_id)
      end if
c     
c======================================================================
c     
      nint_level  = 1
      read_number = 0
c     
c     Loop through the number of groups
c     
c     These will store counts for each ramp, due to the detector 
c     coming from external sources (in "image") and internal sources (noise)
c     
      do j = 1, nnn
         do i = 1, nnn
            image(i,j) = 0.0
            noise(i,j) = 0.0
         end do
      end do
c
c     loop through groups of a ramp
c      
      do k = 1, ngroups
         if(verbose.ge.1) then
            print 1140,idither, nint_level,k, ngroups,nframe,nskip
 1140       format('dither, nint, group, ngroups,nframe, nskip ', 
     &           7I6)
         end if
         frame = 0 
c     
c     clear the "accum" matrix which stores counts for each group
c     
         call clear_accum(accum, n_image_x, n_image_y)
c
c     add charge for all cycles (read out and skipped)
c     
         do loop = 1, nframe+nskip
            read_number = read_number + 1
            if(verbose .ge. 2) then
               if(loop.le.nframe) then
                  print *,'dither',idither,' group ', k , 
     *                 ' of ',ngroups,', read ',loop,
     *                 ' of  nframe+nskip =',nframe+nskip,
     *                 ' nskip ',nskip
               else
                  print *,'dither',idither,' group ', k , 
     *                 ' of ',ngroups,', skip ',loop-nframe,
     *                 ' of  nframe+nskip =',nframe+nskip,
     *                 ' nskip ',nskip
               end if
            end if
c     
c     Accumulate signal whether the frame is read out or not
c     (in the "image" matrix).
c
c     add stars
c     [e-]
            if(include_stars.eq.1 .and. nstars.gt.0) then
               if(verbose.ge.2) print *, 'sca_image: add_stars '
               call add_stars(ra_dithered, dec_dithered,pa_degrees,
     *              xc, yc, osim_scale, sca_id, filter_index, seed,
     *              subarray, colcornr, rowcornr, naxis1, naxis2,
     *              wavelength, bandwidth,system_transmission,
     *              mirror_area,tframe, in_field, 
     *              noiseless, psf_add, ipc_add,
     *              distortion, psf_scale, over_sampling_rate,
     *              attitude_inv,
     &              sci_to_ideal_x, sci_to_ideal_y, sci_to_ideal_degree,
     &              ideal_to_sci_x, ideal_to_sci_y, ideal_to_sci_degree,
     &              x_det_ref, y_det_ref, x_sci_ref, y_sci_ref,
     &              det_sci_yangle, det_sci_parity,
     &              v3_idl_yang, v_idl_parity, v2_ref, v3_ref,
     *              verbose)
               if(verbose.ge.2) then
                  print *, 'added ',in_field, ' stars of ', nstars
               end if
            end if
c     
c     add galaxies
c     [e-]
            if(include_galaxies .eq. 1 .and. ngal .gt. 0) then
               if(verbose.ge.2)then 
                  print *, 'add_up_the_ramp: add_galaxies: ',
     &                 'background, filter_index, abmag'
                  print *, background, filter_index, abmag
               end if
               call add_modelled_galaxy(sca_id,naxis1, naxis2,
     *              ra_dithered, dec_dithered, pa_degrees,
     *              xc, yc, osim_scale, filter_index,
     *              ngal, scale,
     *              wavelength, bandwidth, system_transmission, 
     *              mirror_area, abmag, tframe, seed, in_field,
     &              noiseless, psf_add, ipc_add,
     &              distortion, precise, psf_scale, over_sampling_rate,
     &              attitude_inv,
     &              sci_to_ideal_x, sci_to_ideal_y, sci_to_ideal_degree,
     &              ideal_to_sci_x, ideal_to_sci_y, ideal_to_sci_degree,
     &              x_det_ref, y_det_ref, x_sci_ref, y_sci_ref,
     &              det_sci_yangle, det_sci_parity,
     &              v3_idl_yang, v_idl_parity, v2_ref, v3_ref,
     &              verbose)
               if(verbose.ge.2) then
                  print *, 'sca_image: added', in_field,
     &                 ' galaxies of ',ngal
               end if
            end if
c     
c     add cosmic rays [e-]
c     
            if(include_cr .eq. 1) then 
               call add_modelled_cosmic_rays(n_image_x, n_image_y,
     *              cr_mode, subarray, naxis1, naxis2, 
     *              integration_time, ipc_add, read_number, verbose)
c     *              subarray, colcornr, rowcornr, naxis1, naxis2)
            end if
c     
c     add sky background [e-]
c     
            if(include_bg .eq. 1) then 
               if(verbose.ge.2) print *, 
     &              'add sky background',background,
     &              ' e-/sec/pixel', loop, nframe+nskip
               call add_sky_background(background,
     *              subarray, colcornr, rowcornr, naxis1, naxis2,
     *              integration_time, noiseless,verbose)
            end if
c     
c     Add latent charge [e-] (is persistence an internal or external source?)
c     
            if(include_latents .eq. 1) then 
               time_step = (k-1) * (nframe+nskip) +loop
               call add_latents(sca_id, time_step, integration_time,
     *              decay_rate, time_since_previous)
            end if
c     
c     add dark current  [e-] to noise matrix
c     
            if(include_dark_ramp .eq. 1) then
               call add_dark_ramp(sca_id, noise, gain(indx),
     &              subarray, colcornr, rowcornr,naxis1, naxis2,
     &              read_number,dark_file, verbose)
               if(verbose.ge.2) then
                  print *, 'new_ramp @ add_dark_ramp: ',read_number,
     &                 ' group ', k,' loop', loop, noise(1020,1020)
               end if
            end if

            if(include_dark .eq. 1) then
               if(verbose.ge.2) print *, 'add dark'
               call add_dark(brain_dead_test,
     *              subarray, colcornr, rowcornr, naxis1, naxis2,
     *              dark_mean, dark_sigma, integration_time)
            end if
c     
c     effects that are added only when frames are read out
c     
            if(loop.le.nframe) then
c     
               if(noiseless .eqv. .FALSE.) then
                  if(verbose.ge.2) then
                     level = (k-1)*(nskip+nframe) + loop
                     print *, 'sca_image: add read noise ',
     &                    '(loop, k, level)',loop, k, level
                  end if
c     
c     Add charge to reference pixels  [e-] in "noise"
c     
                  if(include_reference .eq. 1) then
                     call add_reference_pixels(read_noise(indx),
     &                    even_odd,
     &                    subarray,colcornr, rowcornr, naxis1, naxis2)
                  end if
c
c     add 1/f noise [e-] in "noise"
c     
                  if(include_1_over_f.eq.1) then
                     level = (k-1)*(nskip+nframe) + loop
                     call add_one_over_f_noise(noise_name, level,
     *                    subarray, colcornr, rowcornr, naxis1, naxis2)
                  end if
c     
c     apply flatfield only to electrons due to external sources
c     2020.02.17 
c
                  if(include_flat .eq. 1) then 
                     do j = 1, naxis2
                        do i = 1, naxis1
                           mean    = flat_image(i,j,1)
                           sigma   = flat_image(i,j,2)
                           deviate =  zbqlnor(mean, sigma)
                           scratch(i,j) = image(i,j)   * deviate
c     now add noise (which is not flatfielded)
                           scratch(i,j) = scratch(i,j) + noise(i,j)
c     add readnoise; however, readnoise should not be accumulated
c     as it is a measurement error, not an additive error that is
c     aggregated to the signal. It is added to the  "scratch" matrix,
c     as this will correspond to a "measured" quantity. 
c     The same holds true for 1/F noise
c     read_noise units [e-]
c     
                           if(include_readnoise .eq.1) then
                              deviate = zbqlnor(0.0d0, read_noise(indx))
                              scratch(i,j) = scratch(i,j) + deviate
                           end if
                        end do
                     end do
                  else
c     
c     no flatfielding
c     
                     do j = 1, naxis2
                        do i = 1, naxis1
                           scratch(i,j) = image(i,j)
                           scratch(i,j) = scratch(i,j) + noise(i,j) 
                           if(include_readnoise .eq.1) then
                              deviate = zbqlnor(0.0d0, read_noise(indx))
                              scratch(i,j) = scratch(i,j) + deviate
                           end if
                        end do
                     end do
                  end if
c     
c     apply the inverse of the linearity correction using values in
c     the "scratch" matrix
c     
                  call linearity_incorrect(include_non_linear,
     *                 subarray,colcornr, rowcornr,
     *                 naxis1, naxis2, verbose)
c
c     add the distorted counts to the accum matrix
c
                  do j = 1, naxis2
                     do i = 1, naxis1
                        accum(i,j) = accum(i,j) + scratch(i,j)
                     end do
                  end do
               else
c     for noiseless images                  
                  do j = 1, naxis2
                     do i = 1, naxis1
                        scratch(i,j) = image(i,j)
                        accum(i,j)   = accum(i,j) + scratch(i,j)
                     end do
                  end do
               end if           ! closes "if noiseless .eqv. .false."
c     
c     if this is the last frame read in a group, calculate the average 
c     and convert into ADU:
c     scratch(i,j) = accum(i,j)/avtime/gain 
c     
               if(loop .eq. nframe) then
                  call divide_image(nframe, gain(indx), 
     &                 n_image_x, n_image_y)
c     
c     add baseline noise [ADU] if 1/f noise is not used
c     
                  if(include_1_over_f.ne.1 .and.
     &                 noiseless .eqv. .FALSE.) then
                     call add_baseline(
     &                    subarray,colcornr, rowcornr, naxis1, naxis2)
                  end if
c     
c     write to data cube
c     
                  do j = 1, naxis2
                     do i = 1, naxis1
                        if(scratch(i,j)+0.d0 .ne. scratch(i,j)) then
                           image_4d(i,j,k,nint_level) = 0
                        else
                           image_4d(i,j,k,nint_level) = scratch(i,j)
                        end if
                     end do
                  end do
               end if           ! closes loop on if(loop.eq.nframe)
c     
c     if this is the first frame of a ramp, save it in zero_frames
c     
               if(loop.eq.1) then
                  do j = 1, naxis2
                     do i = 1, naxis1
                        zero_frames(i,j,nint_level) = scratch(i,j)
                     end do 
                  end do
               end if
            end if
c     
c     if this is the last read of a group, there are no more frames to skip
c     exit all integrations
c     
            if(loop .eq. nframe .and. k .eq. ngroups) go to 1000
         end do                 ! close loop on nframe+ nskip
      end do                    ! close loop on ngroups
c     
 1000 continue
c     
      if(verbose .ge. 2) print *,'dither: exit main loop'
c     
c      call closefits(iunit)
c     
c     write image with accumulated counts but without the read noise
c
c      write(test_image,1100) filter_id,iabs(sca_id),idither
 1100 format('sim_',a5,'_',i3.3,'_',i3.3,'.fits')
c      ibitpix   = -32
c      call write_float_2d_image(filename, image,
cc     &     n_image_x, n_image_y,
c     &     naxis1, naxis2,
c     *     ibitpix, nframe, tframe, nskip, tgroup, ngroups, object, 
c     *     partname, sca_id, module, filter_id,
c     *     subarray, colcornr, rowcornr, naxis1, naxis2, job)
c
c     store/update image for latents
c
      if(include_latents .eq. 1) then
         do i = 1, n_image_x
            do j = 1, n_image_y
               latent_image(i,j) = image(i,j)
            end do
         end do
         ibitpix = -32
         call write_float_2d_image(latent_file, latent_image,
     *        naxis1, naxis2,
c     *        ibitpix, nframe, tframe, nskip, tgroup, ngroups, object, 
c     *        partname, sca_id,module, filter_id,
     *        subarray, colcornr, rowcornr)
c      print *,'crval1, crval2, crval3',crval1, crval2, crval3
      endif
c      end do ! Loop over NINTS
      if(verbose.ge.1) then
         print * ,'end of dither', sca_id, idither, n_image_x, 
     *        n_image_y, ngroups
      end if
      return
      end
c     if(i.eq.1161 .and.j.eq.1051) 
c     &         print *, image(i,j), noise(i,j),scratch(i,j)
c     accum(i,j) = accum(i,j) + image(i,j)
c     accum(i,j) = accum(i,j) + noise(i,j)
c     
c     pixel_index = 1
c     if(i.gt.1536) pixel_index = 7
c     if(i.gt.1024 .and. i.le.1536) pixel_index = 5
c     if(i.gt. 512 .and. i.le.1024) pixel_index = 3
c     if(mod(i,2).eq.0) pixel_index = pixel_index + 1
