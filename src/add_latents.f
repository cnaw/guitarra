c
c     Add latents, by integrating over the time interval since previous
c     frame.  Still needs to be adapted for subarrays
c
c     cnaw 2015-01-27
c     Steward Observatory, University of Arizona
c
c     According to Jarron Leisenring, the latent count is not a 
c     Poisson process and it is better described by the measured
c     value.
c     cnaw 2015-09-09
c 
      subroutine add_latents (sca, time_step, integration_time, 
     *     decay_rate, time_since_previous, n_image_x, n_image_y)
      implicit none
      double precision integration_time,mirror_area, ktc,
     *     decay_rate, time_since_previous, t2, t1, term2, term1,
     *     factor, counts, expected
      double precision jl_latent
      real image, latent_image
      integer n_image_x, n_image_y, nnn, i, j, sca
      integer time_step, zbqlpoi
c
      parameter (nnn=2048)
c
      dimension image(nnn,nnn), latent_image(nnn,nnn)
c
      common /image_/ image
      common /latent/ latent_image
c
c
c  decay-rate       - is assumed exponential
c  time_since_previous - time elapsed between end of previous integration
c                     and beginning of the current one
c  time_step        - read number
c  integration_time - time between readouts (10.6 seconds)
c
c  "factor" will contain the total number of events between t
c
c      t2     = time_since_previous + (1+ time_step)*integration_time
      t1     = time_since_previous +     time_step*integration_time
      t2     = 0.0d0
c      term2  = dexp(-decay_rate * t2) 
c      term1  = dexp(-decay_rate * t1)
c      factor = (term1-term2)/decay_rate
c      print * ,'add_latents : at time_step decay factor is', 
c     *     time_step, factor
      do j = 1, n_image_y
         do i = 1, n_image_x
c            counts = factor * dble(latent_image(i,j))
c
c            if(counts .ge. 0) then
c               expected = zbqlpoi(counts)
c            else
c               expected = 0.d0
c            end if
c            image(i,j) =  image(i,j) + expected
            counts = jl_latent(sca, t1, dble(latent_image(i,j)),t2)
c            print *,' add_latents ', i, j, counts, image(i,j)
            image(i,j) =  image(i,j) + counts
         end do
      end do
      return
      end

