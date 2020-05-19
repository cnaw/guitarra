c     Add charge to reference pixels
c     According to B. Rauscher the noise is 0.80 times lower than 
c     for normal pixels.
c     The noise is modulated by the relative
c     bias between amplifiers, assumed identical for
c     all SCAs. PyNRC does not make this assumption:
c
c     ch_off_arr   =
c     [1700, 530, -375, -2370]
c     [-150, 570, -500,   350]
c     [-530, 315,  460,  -200]
c     [ 480, 775, 1040, -2280]
c     [ 560, 100, -440,  -330]
c
c     [ 105,  -29, 550,  -735]
c     [ 315,  425,-110,  -590]
c     [ 918, -270, 400, -1240]
c     [-100,  500, 300,  -950]
c     [ -35, -160, 125,  -175]
c     
c     cnaw 2018-06-05
c     added a reference pixel baseline cnaw 2019-11-18
c     Steward Observatory, University of Arizona
c     
      subroutine add_reference_pixels (read_noise,even_odd,
     *     subarray, colcornr, rowcornr, naxis1, naxis2)
      implicit none
      double precision zbqlnor, read_noise, even_odd, bzzz,
     *     ref_rat
      real noise
      integer colcornr, rowcornr, naxis1, naxis2 
      integer istart, iend, jstart, jend, indx,l
      integer i, j, nnn
c      logical subarray
      character subarray*8
c
      parameter (nnn=2048)
c
      dimension even_odd(8), noise(nnn,nnn)
c
      common /noise_/ noise
      even_odd(1) = 1.d0
      even_odd(2) = 1.d0
      even_odd(3) = 1.00682d0
      even_odd(4) = 1.00682d0
      even_odd(5) = 0.983038d0
      even_odd(6) = 0.983038d0
      even_odd(7) = 1.01164d0
      even_odd(8) = 1.01164d0
c
c     According to B. Rauscher the noise is 0.80 times the readnoise of
c     normal pixels.  PyNRC  uses 0.90
c     (ref_rat is the name PyNRC adopts, so let us use it)
      ref_rat      = 0.9d0
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
         iend   = naxis1
         jstart = 1
         jend   = naxis2
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

            bzzz    = read_noise * ref_rat
            noise(i,j) = zbqlnor(0.0d0, bzzz) * even_odd(indx)
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
            bzzz = read_noise * ref_rat
            noise(i,j) =  zbqlnor(0.0d0, bzzz) * even_odd(indx)
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
            bzzz = read_noise * ref_rat
            noise(i,j) =  zbqlnor(0.0d0, bzzz) * even_odd(indx)
         end do
c
c     right side
c
         do i = 2045,2048
            indx = 7
            if(mod(i,2).eq.0) indx = indx + 1
            bzzz = read_noise * ref_rat
            noise(i,j) =  zbqlnor(0.0d0, bzzz) * even_odd(indx)
         end do
      end do
c
      return
      end

