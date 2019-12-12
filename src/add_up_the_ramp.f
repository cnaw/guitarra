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
c
      subroutine add_up_the_ramp(idither, ra_dithered, dec_dithered, 
     *     pa_degrees,
     *     filename, noise_name,
     *     sca_id,              ! x_sca, y_sca,
     *     module, brain_dead_test, 
     *     xc, yc, pa_v3, osim_scale,scale,
     *     include_ipc,
     *     include_ktc, include_dark, include_readnoise, 
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
     *     over_sampling_rate, noiseless, psf_add,
     *     verbose)
      
      implicit none
c
      double precision mirror_area, integration_time, gain,
     *     decay_rate, time_since_previous, read_noise, 
     *     dark_mean, dark_sigma, ktc, voltage_offset
      double precision wavelength, bandwidth, system_transmission, 
     *     background, scale, bias_value
      double precision  even_odd
      double precision x_sca, y_sca, ra_sca, dec_sca
      double precision xc, yc, pa_v3, q, posang, ra_dithered,
     *     dec_dithered, osim_scale, x_osim, y_osim,
     *     pa_degrees
      double precision linearity_gain,  lincut, well_fact
      double precision zero_point, tol, eps
c
c     images are either real*4 or integer
c
      integer image_4d, zero_frames, max_nint
      real  image,  accum, latent_image, base_image, bias, well_depth,
     *     gain_image, linearity, variate, scratch
      double precision photplam, photflam, stmag, abmag
c
      integer max_order, order,over_sampling_rate, nints
      integer zbqlpoi
      integer filter_index, icat_f
      integer nint_level, read_number
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
      logical ipc_add, psf_add, noiseless
      integer npsf
      integer cr_mode, seed
      integer include_ipc, include_ktc, include_bg, 
     &     include_cr, include_dark,
     *     include_latents, include_flat,
     &     include_readnoise, include_non_linear,
     *     include_stars, include_galaxies, include_cloned_galaxies,
     &     brain_dead_test, include_1_over_f, include_reference

      integer i, j, k, loop, nlx, nly, level
      integer nnn, nstars, ngal, in_field
      character filename*(*), latent_file*180, psf_file*(*),
     &     noise_name*(*)
      character object*20, partname*5, module*1, filter_id*5
c     
      character subarray*(*)
c
      parameter (nnn=2048, max_nint=1, max_order=7)
c
      dimension dark_mean(10), dark_sigma(10), gain(10),
     *     read_noise(10), even_odd(8), ktc(10), voltage_offset(10)
c
c     images
c
      dimension image_4d(nnn,nnn,20,max_nint), naxes(4),
     &     zero_frames(nnn, nnn, max_nint)
      dimension base_image(nnn,nnn)
      dimension accum(nnn,nnn),image(nnn,nnn),latent_image(nnn,nnn),
     *     well_depth(nnn,nnn), linearity(nnn,nnn,max_order),
     *     bias(nnn,nnn), gain_image(nnn,nnn), scratch(nnn,nnn)
      dimension psf_file(54)
c
c     images
c
      common /four_d/ image_4d, zero_frames
      common /gain_/ gain_image
      common /base/ base_image
      common /latent/ latent_image
      common /images/ accum, image, n_image_x, n_image_y
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
     *     dark_mean, dark_sigma, ktc, voltage_offset 
c     
      q   = dacos(-1.0d0)/180.d0
      tol = 1.d-10
      eps = 1.d-16
      integration_time = tframe
      partname='anoni'
      n_image_x = naxis1
      n_image_y = naxis2
c
      if(verbose.gt.0) then
         print 10,sca_id, filter_index, filter_id, idither
 10      format('add_up_the_ramp:  sca ', i4,' filter ', i4, 2x, a5,
     *        ' dither ',i4)
      end if
      indx = sca_id - 480
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
c     WCS keywords; these are kept to maintain compatibility
c     with older code while not using the ZEMAX distortion
c     models.
c
c      print *, crpix1, crpix2, crpix3
c      print *, crval1, crval2, crval3
c      print *, cdelt1, cdelt2, cdelt3
c      x_sca = 1024.5d0
c      y_sca = 1024.5d0
cc      call sca_to_ra_dec(sca_id, 
cc     *     ra_dithered, dec_dithered,
cc     *     ra_sca, dec_sca, pa_degrees, 
cc     *     xc, yc, osim_scale, x_sca, y_sca)
cc      print *, crpix1, crpix2, crpix3
cc      print *, crval1, crval2, crval3
cc      print *, cdelt1, cdelt2, cdelt3
c      print *,'add_up_the_ramp '
c      call wcs_keywords(
c     *     sca_id, x_sca, y_sca, xc, yc, osim_scale,
c     *     ra_dithered, dec_dithered,  pa_degrees,verbose)
c      call osim_coords_from_sca(sca_id, x_sca, y_sca, x_osim, y_osim)
c      call sca_to_ra_dec(sca_id, 
c     *     ra_dithered, dec_dithered,
c     *     ra_sca, dec_sca, pa_degrees, 
c     *     xc, yc, osim_scale, x_sca, y_sca)
c      print 1130, psf_file
c      print *,'crval1, crval2', crval1, crval2
c      print *,'crpix1, crpix2', crpix1, crpix2
c      print *,'ra_dithered, dec_dithered',ra_dithered, dec_dithered
c      print *,'ra_sca, dec_sca',ra_sca, dec_sca
c      print *,'pa_degrees, osim_scale',pa_degrees, osim_scale
c      print *,'xc, yc', xc, yc
c      print *,'add_up_the_ramp crval1, crval2, crval3',
c     *     crval1, crval2, crval3
c
c     Read PSF
c
c      print 1130, psf_file(1)
      if(verbose.gt.1) then
         PRINT *,'SCA_IMAGE:', sca_id, ra_dithered, dec_dithered
c     *        x_sca, y_sca, ra_sca, dec_sca
         print 1130, psf_file(1)
      end if
      print 1130, psf_file(1)
 1130 format('read psf ', a180)
      call read_psf(psf_file(1), verbose)
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
c
c     Loop through the number of groups
c
         do k = 1, ngroups
            if(verbose.ge.1) then
               print 1140,idither, nint_level,k, ngroups,nframe,nskip
 1140          format('dither, nint, group, ngroups,nframe, nskip ', 
     &              7I6)
            end if
c     
c     loop through the cycles
c     
            frame = 0 
c
c     clear matrix where all charge is accumulated
c
            call clear_accum
c
c     start adding charge
c
            do loop = 1, nframe+nskip
               read_number = read_number + 1
               if(verbose .ge. 2) then
                  if(loop.le.nframe) then
                     print *,'dither',idither,' group ', k , 
     *                    ' of ',ngroups,', read ',loop,
     *                    ' of  nframe+nskip =',nframe+nskip,
     *                    ' nskip ',nskip
                  else
                     print *,'dither',idither,' group ', k , 
     *                    ' of ',ngroups,', skip ',loop-nframe,
     *                    ' of  nframe+nskip =',nframe+nskip,
     *                    ' nskip ',nskip
                  end if
               end if
c     
c     Keep on accumulating signal whether the frame is read out or not
c     (in the "image" matrix). The "accum" matrix will contain the
c     scene to which readout noise is added.
c     
c     add stars
c     [e-]
               if(include_stars.eq.1 .and. nstars.gt.0) then
                  if(verbose.ge.2) print *, 'sca_image: add_stars '
                  call add_stars(ra_dithered, dec_dithered,pa_degrees,
     *                 xc, yc, osim_scale, sca_id, filter_index, seed,
     *                 subarray, colcornr, rowcornr, naxis1, naxis2,
     *                 wavelength, bandwidth,system_transmission,
     *                 mirror_area,tframe, in_field, 
     *                 noiseless, psf_add, ipc_add, verbose)
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
     &                    'background, filter_index, abmag'
                     print *, background, filter_index, abmag
                  end if
                  call add_modelled_galaxy(sca_id,
     *                 ra_dithered, dec_dithered, pa_degrees,
     *                 xc, yc, osim_scale, filter_index,
     *                 ngal, scale,
     *                 wavelength, bandwidth, system_transmission, 
     *                 mirror_area, abmag, tframe, seed, in_field,
     &                 noiseless, psf_add, ipc_add,verbose)
                  if(verbose.ge.2) then
                     print *, 'sca_image: added', in_field,
     &                    ' galaxies of ',ngal
                  end if
               end if
c     
c     add sky background [e-]
c     
               if(include_bg .eq. 1) then 
                  if(verbose.ge.2) print *, 
     &              'add sky background',background,
     &                 ' e-/sec/pixel', loop, nframe+nskip
                  call add_sky_background(background,
     *                 subarray, colcornr, rowcornr, naxis1, naxis2,
     *                 integration_time, noiseless,verbose)
               end if
c
c     add cosmic rays [e-]
c     
               if(include_cr .eq. 1) then 
                  call add_modelled_cosmic_rays(n_image_x, n_image_y,
     *                 cr_mode, subarray, naxis1, naxis2, 
     *                 integration_time, ipc_add, read_number, verbose)
c     *              subarray, colcornr, rowcornr, naxis1, naxis2)
               end if
c     
c     add dark current  [e-]
c     
            if(include_dark .eq. 1) then
               if(verbose.ge.2) print *, 'add dark'
               call add_dark(brain_dead_test,
     *              subarray, colcornr, rowcornr, naxis1, naxis2,
     *              dark_mean, dark_sigma, integration_time)
            end if
c     
c     Add latent charge [e-]
c     
            if(include_latents .eq. 1) then 
               time_step = (k-1) * (nframe+nskip) +loop
               call add_latents(sca_id, time_step, integration_time,
     *              decay_rate, time_since_previous)
            end if
c     
c     Add charge to reference pixels  [e-]
c     
c            if(include_reference.eq.1) then
c               if(verbose.gt.2) print *,'add reference pixels'
cc               call add_reference_pixels(read_noise, even_odd,
cc     &              subarray,colcornr, rowcornr, naxis1, naxis2)
c            end if
c     
            if(loop.le.nframe) then
c     
c     add readnoise; however, readnoise should not be accumulated
c     as it is a measurement error, not an additive error that is
c     aggregated to the signal. This is added to the accumulated image,
c     as this will correspond to a "measured" quantity. The
c     same holds true for 1/F noise
c     read_noise units [e-];    1/f noise  units [e-]
c     
               if (include_readnoise .eq. 1) then 
                  level = (k-1)*(nskip+nframe) + loop
                  if(verbose.ge.2) then
                     print *, 'sca_image: add read noise ',
     &                    '(loop, k, level)',loop, k, level,
     &                    read_noise(indx)
                  end if
                  call add_read_noise(brain_dead_test,read_noise, 
     *                 subarray,colcornr, rowcornr, naxis1, naxis2)
c     
c     Add charge to reference pixels  [e-]
c     
                  call add_reference_pixels(read_noise, even_odd,
     &                 subarray,colcornr, rowcornr, naxis1, naxis2)
               end if
c     [e-]
               if(include_1_over_f.eq.1) then
                  level = (k-1)*(nskip+nframe) + loop
c     write(noise_name,900) sca_id
c     900              format('ng_hxrg_noise_',i3,'.fits')
                  call add_one_over_f_noise(noise_name, level,
     *                 subarray,colcornr, rowcornr, naxis1, naxis2)
               end if
c
c     accum(i,j) = accum(i,j) + image(i,j) * flat_image(i,j):
c
               call coadd(include_flat)
            end if
c     
c     if this is the last frame read in a group, calculate the average 
c     
            if(loop .eq. nframe) then
               call divide_image(nframe)
c     
c     undo the linearity correction and convert into ADU
c     copying the results into the "scratch" array
c
               if(verbose.ge.2) then
                  print *,'add_up_the_ramp: gain(indx)',indx, gain(indx)
               end if
               if(indx.gt.0) then
                  call linearity_incorrect(include_non_linear,
     *                 gain(indx), subarray,colcornr, rowcornr,
     *                 naxis1, naxis2, verbose)
               else
                  do j = 1, naxis2
                     do i = 1, naxis1
                        scratch(i,j) = image(i,j)
                     end do
                  end do
               end if
c     
c     add baseline noise [ADU] if 1/f noise is not used
c     
               if(include_1_over_f.ne.1) then
                  call add_baseline(
     &                 subarray,colcornr, rowcornr, naxis1, naxis2)
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
c     
c     write to FITS data cube
c     
c     if(verbose.ge.2) print *,'sca_image : write image plane'
c     call write_frame(filename, iunit, bitpix, k, 
c     *              naxis, naxes)
            endif
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
c      write(filename,1100) filter_id,iabs(sca_id),idither
c 1100 format('sim_',a5,'_',i3.3,'_',i3.3,'.fits')
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
