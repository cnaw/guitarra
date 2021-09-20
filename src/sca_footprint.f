c
c     read calibration files and initialise the image footprint
c
c     version 2018-06-08
c
      subroutine sca_footprint(sca_id, noiseless, naxis1, naxis2,
     &     include_bias, include_ktc, include_latents,
     &     include_non_linear, brain_dead_test, include_1_over_f,
     &     latent_file, idither, verbose)
      implicit none
c
      double precision gain,
     *     decay_rate, time_since_previous, read_noise, 
     *     dark_mean, dark_sigma, ktc, voltage_offset,
     *     voltage_sigma
      double precision bias_value,zbqlnor
      double precision linearity_gain,  lincut, well_fact
c
c     images are either real*4 or integer
c
      real  image,  accum, latent_image, base_image, bias, well_depth,
     *     gain_image, linearity, variate, scratch, flat_image
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
      integer include_bias, include_ktc, include_latents,
     &      include_non_linear, brain_dead_test, include_1_over_f

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
     *     bias(nnn,nnn), gain_image(nnn,nnn), scratch(nnn,nnn),
     *     flat_image(nnn,nnn,2)
c
      dimension gain(10), dark_mean(10), dark_sigma(10), 
     &     read_noise(10), ktc(10), voltage_offset(10),
     &     voltage_sigma(10)
c
c     images
c
      common /base/ base_image
      common /flat_/ flat_image
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
     *     dark_mean, dark_sigma, ktc, voltage_offset,
     *     voltage_sigma
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
c     This is now read in the main code (guitarra.f)
c      call read_sca_calib(sca_id, verbose)
c     
c     if latents are being considered read the previous image
c     which will be attenuated as time progresses.
c
      if(include_latents .eq.1 .and.idither .gt.1) then
         if(verbose.gt.1) then
            print *,'sca_footprint reading latent file:'
            print 120, latent_file
 120        format(a180)
         end if
         call  read_fits(latent_file,latent_image, nlx, nly)
         if(nlx .ne. n_image_x .or. nly .ne. n_image_y) then
            print *,' size of latent image does not match:',
     *           nlx, nly, 'image ', n_image_x, n_image_y
            include_latents = 0
            print *,' latents will be ignored'
         end if
      end if
cccccccccccccccccccc
c
c     Brain-dead test
c
      if(brain_dead_test.eq.1) then
         print *,' ktc = 1000 '
         do j = 1, nnn
            do i = 1, nnn
               base_image(i,j) = 1000.0
            end do
         end do
         go to 1000
      end if
c
cccccccccccccccccc
c
c     
c     create baseline image (bias + kTC)
c     both ktc and voltage_offset have been
c     converted into e- in guitarra.f
c     
c     
c     Add kTC for random SCA (i.e., not a NIRCam one)
c
      if(sca_id.eq.0) then 
         do j = 1, nnn
            do i = 1, nnn
               base_image(i,j) = 0.0
            end do
         end do
         go to 1000
      end if
c      
      if(noiseless .eqv. .TRUE.) then
         do j = 1, nnn
            do i = 1, nnn
               bias(i,j)       = 0.0
               base_image(i,j) = 0.0
            end do
         end do
         go to 1000
      end if
c
c      print *,'sca_footprint: include_ktc,noiseless ', include_ktc,
c     &     noiseless
      if(noiseless .eqv. .FALSE.) then
c
c     no ktc, no bias
c
         if(include_ktc.eq.0 .and. include_bias.eq.0) then
c            bias_value = ktc(indx) + voltage_offset(indx)
            bias_value = 0.0d0
            do j = 1, nnn
               do i = 1, nnn
                  base_image(i,j) = bias_value
               end do
            end do
            go to 1000
         end if
c
c     bias only
c
         if(include_ktc.eq.0 .and. include_bias.eq.1) then
c
c     fix NaNs or negative values
c     that may be present in the calibration files
c     The added 110 is for consistency with PyNRC
c 
            do j = 1, nnn
               do i = 1, nnn
                  if(bias(i,j).ne.bias(i,j).or.bias(i,j).le. 0.0) then
                     base_image(i,j) = 110.0 +
     &                    zbqlnor(voltage_offset(indx),
     &                    voltage_sigma(indx))
                  else
                     base_image(i,j) =  bias(i,j) + 110.0 +
     &                    zbqlnor(voltage_offset(indx),
     &                    voltage_sigma(indx)) 
                  end if
               end do
            end do
            go to 1000
         end if
c
c     ktc only
c
         if(include_ktc.eq.1 .and. include_bias.eq.0) then
            do j = 1, nnn
               do i = 1,nnn
                  base_image(i,j) = real(zbqlpoi(ktc(indx)))
               end do
            end do
            go to 1000
         end if
c
c     ktc, Voltage offset and bias
c
         if(include_ktc.eq.1 .and. include_bias.eq.1) then
            do j = 1, nnn
               do i = 1,nnn
c     
c     fix NaNs or negative values
c     that may be present in the calibration files
c     The added 110 is for consistency with PyNRC
c     
                  if(bias(i,j).ne.bias(i,j).or.bias(i,j).le. 0.0) then
                     base_image(i,j) = zbqlnor(voltage_offset(indx),
     &                    voltage_sigma(indx)) + 110.0
     &                    + real(zbqlpoi(ktc(indx)))
                  else
                     base_image(i,j) =  bias(i,j) +
     &                    zbqlnor(voltage_offset(indx),
     &                    voltage_sigma(indx)) + 110.0
     &                    + real(zbqlpoi(ktc(indx)))
                  end if
               end do
            end do
         end if
      end if
c
 1000 return
      end
