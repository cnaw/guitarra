c
c     cnaw 2015-01-27
c     modified 2020-02-17 changing
c     image = image + noise 
c     to
c     accum  = image + noise
c     and commented last term in
c     deviate = deviate * integration_time ! * gain_image(k,l) 
c      
c     Steward Observatory, University of Arizona
c 
      subroutine add_dark(brain_dead_test,
     *     subarray, colcornr, rowcornr, naxis1, naxis2,
     *     dark_mean, dark_sigma, integration_time)

      implicit none
c
      double precision dark_mean, dark_sigma, integration_time
      double precision xmean, xsig, deviate, zbqlnor
c
      real  image, accum, dark_image, gain_image, noise
c
      integer istart, iend, jstart, jend, i, j, k, l, nnn, nx, ny
      integer brain_dead_test
      integer colcornr, rowcornr, naxis1, naxis2, n_image_x, n_image_y
c
      character subarray*(*)
c
      parameter (nnn=2048)
c
      dimension dark_image(nnn,nnn,2),
     *     gain_image(nnn,nnn), noise(nnn, nnn)
c
      common /gain_/ gain_image
      common /dark_/ dark_image
      common /noise_/ noise
c                    
c     According to Fowler et al. [1998, Proceedings of SPIE vol. 3301, 
c     pp. 178-185, (San Jose, CA)], dark current is described as a 
c     Poisson process, not Gaussian as here.
c
      if(subarray .eq. 'FULL') then
         istart = 5
         iend   = naxis1 - 4
         jstart = 5
         jend   = naxis2 - 4
      else
         istart = 1
         iend   = naxis1
         jstart = 1
         jend   = naxis2
      end if
      if(brain_dead_test.eq.1) then
         do j = jstart, jend
            if(subarray .eq. 'FULL') then
               l = j 
            else
               l = j + rowcornr-5
            end if
            do i = istart, iend
               if(subarray .eq. 'FULL') then
                  k = i 
               else
                  k = i + colcornr-5
               end if
               xmean   = 1.d0
               noise(i,j) = noise(i,j) + xmean
            end do
         end do
         return
      end if

      do j = jstart, jend
         if(subarray .eq. 'FULL') then
            l = j
         else
            l = j + rowcornr-5
         end if
         do i = istart, iend
            if(subarray .eq. 'FULL') then
               k = i
            else
               k = i + colcornr-5
            end if
            xmean   = dark_image(k,l,1)
            xsig    = dark_image(k,l,2)
            deviate = zbqlnor(xmean, xsig)
c
c     This may need to be changed from linearity_gain to gain(k,l)
c     
            deviate = deviate * integration_time ! * gain_image(k,l)
c     if(deviate .lt.0.d0) deviate = 0.d0
c            accum(i,j) = image(i,j) +  real(deviate)
            noise(i,j) = noise(i,j) +  real(deviate)
         end do
      end do
      return
      end
