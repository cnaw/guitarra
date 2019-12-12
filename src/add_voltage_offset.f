c
c     Add voltage baseline in ADU, following suggestion by Karl Misselt
c     The voltages come from measurements by Jarron Leisenring.
c
c     cnaw@as.arizona.edu 
c     2019-11-18
c     Steward Observatory, University of Arizona
c     
      subroutine add_voltage_offset (voltage_offset,even_odd,
     *     subarray, colcornr, rowcornr, naxis1, naxis2)
      implicit none
      double precision mirror_area, integration_time, ktc, zbqlnor,
     *     deviate, read_noise, even_odd,noise, voltage_offset
      double precision zbqlpoi
      real base_image, image, accum, scratch
      integer colcornr, rowcornr, naxis1, naxis2 
      integer istart, iend, jstart, jend, indx,l
      integer i, j, n_image_x, n_image_y, nnn
c      logical subarray
      character subarray*8
c
      parameter (nnn=2048)
c
      dimension base_image(nnn,nnn),accum(nnn,nnn),image(nnn,nnn),
     &     scratch(nnn,nnn)
      common /base/ base_image
      common /scratch_/ scratch 
      common /images/ accum, image, n_image_x, n_image_y

c      even_odd(1) = 1.d0
c      even_odd(2) = 1.d0
c      even_odd(3) = 1.00682d0
c      even_odd(4) = 1.00682d0
c      even_odd(5) = 0.983038d0
c      even_odd(6) = 0.983038d0
c      even_odd(7) = 1.01164d0
c      even_odd(8) = 1.01164d0
      
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
      do j = jstart, jend
         do i = istart, iend 
            indx = 1
            if(i.gt.1536) indx = 7
            if(i.gt.1024 .and. i.le.1536) indx = 5
            if(i.gt. 512 .and. i.le.1024) indx = 3
            if(mod(i,2).eq.0) indx = indx + 1
c            noise = read_noise * 0.8d0 * even_odd
c            noise = read_noise * 0.8d0
c            deviate =  real(zbqlpoi(voltage_offset))
c            scratch(i,j) = scratch(i,j) + deviate * even_odd
            scratch(i,j) = scratch(i,j) + voltage_offset
c            accum(i,j) = accum(i,j) +  real(deviate)
         end do
      end do
      return
      end

