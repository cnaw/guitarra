c
c     read calibration files and initialise the image footprint
c
c     version 2018-06-08
c
      subroutine sca_footprint(sca_id, noiseless, naxis1, naxis2,
     &     include_ktc, include_latents,
     &     include_non_linear, brain_dead_test, include_1_over_f,
     &     latent_file, idither, verbose)
      implicit none
c
      double precision gain,
     *     decay_rate, time_since_previous, read_noise, 
     *     dark_mean, dark_sigma, ktc, voltage_offset
      double precision bias_value
      double precision linearity_gain,  lincut, well_fact
c
c     images are either real*4 or integer
c
      real  image,  accum, latent_image, base_image, bias, well_depth,
     *     gain_image, linearity, variate, scratch
c
      integer max_order, order, naxis1, naxis2
      integer zbqlpoi
c
c     parameters
c
      integer sca_id, idither, iunit
      integer verbose, n_image_x, n_image_y
c
      logical noiseless
      integer include_ktc, include_latents, include_non_linear,
     &     brain_dead_test, include_1_over_f

      integer nnn, i, j, k,  nlx, nly, level, indx
      character latent_file*(*)
      character object*20, partname*5, module*20, filter_id*5
      character noise_name*180
c     
      parameter (nnn=2048, max_order=7)
c
c     images
c
      dimension base_image(nnn,nnn)
      dimension accum(nnn,nnn),image(nnn,nnn),latent_image(nnn,nnn),
     *     well_depth(nnn,nnn), linearity(nnn,nnn,max_order),
     *     bias(nnn,nnn), gain_image(nnn,nnn), scratch(nnn,nnn)
c
      dimension gain(10), dark_mean(10), dark_sigma(10), 
     &     read_noise(10), ktc(10), voltage_offset(10)
c
c     images
c
      common /base/ base_image
      common /latent/ latent_image
      common /images/ accum, image, n_image_x, n_image_y
      common /scratch_/ scratch
      common /well_d/ well_depth, bias, linearity,
     *     linearity_gain,  lincut, well_fact, order
c
c     Parameters
c
      common /parameters/ gain,
     *     decay_rate, time_since_previous, read_noise, 
     *     dark_mean, dark_sigma, ktc, voltage_offset 
c
      n_image_x = naxis1
      n_image_y = naxis2
c
c     How to tag this to a previous image ?
c
c      write(latent_file, 1120) filter_id, iabs(sca_id)
c 1120 format('latent_',a5,'_',i3.3,'.fits')
c
c     read gain, bias and well-depth images; set the average and sigma values
c     for the darks.
c
      indx = sca_id - 480
      call read_sca_calib(sca_id, verbose)
c     
c     if latents are being considered read the previous image
c     which will be attenuated as time progresses.
c
      if(include_latents .eq.1 .and.idither .gt.1) then
         call  read_fits(latent_file,latent_image, nlx, nly)
         if(nlx .ne. n_image_x .or. nly .ne. n_image_y) then
            print *,' size of latent image does not match:',
     *           nlx, nly, 'image ', n_image_x, n_image_y
            include_latents = 0
            print *,' latents will be ignored'
         end if
      end if
cccccccccccccccccc
c
c     
c     create baseline image (bias + kTC)
c     
      if(include_ktc.eq.0.and.noiseless .eqv. .false.) then
         bias_value = ktc(indx) + voltage_offset(indx)
      end if
c
      if(include_ktc.eq.1) then
         variate = real(zbqlpoi(dble(ktc(indx) + voltage_offset(indx))))
         bias_value = variate/gain(indx)
c         do j = 1, n_image_y
c            do i = 1, n_image_x
c               image(i,j)      = 0.0
c               base_image(i,j) = 0.0
c            end do
c         end do
      end if
cccccccccccccccccccc
c
c     Brain-dead test
c
      if(brain_dead_test.eq.1) then
         print *,' ktc = 1000 '
         do j = 1, n_image_y
            do i = 1, n_image_x
               image(i,j)      =    0.0
               base_image(i,j) = 1000.0
            end do
         end do
      end if
c
c     Add kTC for random SCA (i.e., not a NIRCam one)
c
      if(noiseless .eqv. .true.) then
         do j = 1, n_image_y
            do i = 1, n_image_x
               image(i,j)      = 0.0
               base_image(i,j) = 0.0
c               base_image(i,j) = bias(i,j)
            end do
         end do
      else
         if(include_ktc.eq.-1 .or.sca_id.eq.0) then 
            do j = 1, n_image_y
               do i = 1, n_image_x
                  image(i,j)      = 0.0
                  base_image(i,j) = 0.0
               end do
            end do
         else
c
c     otherwise use the bias calibration images
c
            do j = 1, n_image_y
               do i = 1, n_image_x
                  image(i,j)     = 0.0
c
c     fix NaNs or negative values
c     that may be present in the calibration files
c
                  if(bias(i,j).ne.bias(i,j).or.bias(i,j).le. 0.0) then
                     variate = 0.0 
                  else
                     variate = real(zbqlpoi(dble(bias(i,j))))
                  end if
                  base_image(i,j) = variate ! units [ADU] 
c                  variate = real(zbqlpoi(voltage_offset(indx)))
                  base_image(i,j) = 
     &                 base_image(i,j) + voltage_offset(indx)
               end do
            end do
         end if
      end if
c
      print *, 'image has been initialised'
      return
      end
