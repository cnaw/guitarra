c     Add charge to reference pixels
c     According to B. Rauscher the noise is 0.80 times lower than 
c     for normal pixels. The noise is moduled by the relative
c     bias between amplifiers, assumed identical for
c     all SCAs.
c     cnaw 2018-06-05
c     added a reference pixel baseline cnaw 2019-11-18
c     Steward Observatory, University of Arizona
c     
      subroutine add_reference_pixels (read_noise,even_odd,
     *     subarray, colcornr, rowcornr, naxis1, naxis2)
      implicit none
      double precision mirror_area, integration_time, ktc, zbqlnor,
     *     deviate, read_noise, even_odd,noise, ref_baseline
      real accum, image
      integer colcornr, rowcornr, naxis1, naxis2 
      integer istart, iend, jstart, jend, indx,l
      integer i, j, n_image_x, n_image_y, nnn
c      logical subarray
      character subarray*8
c
      parameter (nnn=2048)
c
      dimension accum(nnn,nnn), image(nnn,nnn), even_odd(8)
c
      common /images/ accum, image, n_image_x, n_image_y
      even_odd(1) = 1.d0
      even_odd(2) = 1.d0
      even_odd(3) = 1.00682d0
      even_odd(4) = 1.00682d0
      even_odd(5) = 0.983038d0
      even_odd(6) = 0.983038d0
      even_odd(7) = 1.01164d0
      even_odd(8) = 1.01164d0
      
c
c     Read noise is assumed as being described by a Gaussian with
c     mean = 0 and sigma = read_noise
c     e.g. Fowler et al. 1998, Proceedings of SPIE vol. 3301, pp.178-185,
c     (San Jose, CA)
c     
      if(subarray .ne. 'FULL') then
         istart = 1
         iend   = naxis1
         jstart = 1
         jend   = naxis2
      else
         istart = 1
         iend   = n_image_x
         jstart = 1
         jend   = n_image_y
      end if
c
c     Bottom rows
c
      do j = 1, 4
         do i = istart, iend
            indx = 1
            if(i.gt.1536) indx = 7
            if(i.gt.1024 .and. i.le.1536) indx = 5
            if(i.gt. 512 .and. i.le.1024) indx = 3
            if(mod(i,2).eq.0) indx = indx + 1
            noise = read_noise * 0.8d0 * even_odd(indx)
c            noise = read_noise * 0.8d0
c
c     According to Karl Misselt these should be non-negative
c     modified 2019-11-18
c
            deviate =  zbqlnor(0.0d0, noise)
c            deviate =  dabs(zbqlnor(0.0d0, noise))
            image(i,j) = image(i,j) +  real(deviate)
c            accum(i,j) = accum(i,j) +  real(deviate)
         end do
      end do
c
c     Top rows
c
      do j = 2045, 2048
         do i = istart, iend
            indx = 1
            if(i.gt.1536) indx = 7
            if(i.gt.1024 .and. i.le.1536) indx = 5
            if(i.gt. 512 .and. i.le.1024) indx = 3
            if(mod(i,2).eq.0) indx = indx + 1
            noise = read_noise * 0.8d0 * even_odd(indx)
            deviate =  zbqlnor(0.0d0, noise)
c            deviate =  dabs(zbqlnor(0.0d0, noise))
            image(i,j) = image(i,j) +  real(deviate)
c            accum(i,j) = accum(i,j) +  real(deviate)
         end do
      end do
c
      do j = 5, 2044
c
c     left side
c
         do i = 1, 4
            indx = 1
            if(mod(i,2).eq.0) indx = indx + 1
            noise = read_noise * 0.8d0 * even_odd(indx)
            deviate =  zbqlnor(0.0d0, noise)
c            deviate =  dabs(zbqlnor(0.0d0, noise))
            image(i,j) = image(i,j) +  real(deviate)
         end do
c
c     right side
c
         do i = 2045,2048
            indx = 7
            if(mod(i,2).eq.0) indx = indx + 1
            noise = read_noise * 0.8d0 * even_odd(indx)
            deviate =  zbqlnor(0.0d0, noise)
c            deviate =  dabs(zbqlnor(0.0d0, noise))
            image(i,j) = image(i,j) +  real(deviate)
         end do
      end do
c
c     now to the light-sensitive pixels
c
c      do j = jstart, jend
c         do i = istart, iend 
c            indx = 1
c            if(i.gt.1536) indx = 7
c            if(i.gt.1024 .and. i.le.1536) indx = 5
c            if(i.gt. 512 .and. i.le.1024) indx = 3
c            if(mod(i,2).eq.0) indx = indx + 1
c            noise = read_noise * even_odd(indx)
cc            noise = read_noise * 0.8d0
c            deviate =  zbqlnor(0.0d0, noise)
c            image(i,j) = image(i,j) +  real(deviate)
cc            accum(i,j) = accum(i,j) +  real(deviate)
c         end do
c      end do
c
      return
      end

