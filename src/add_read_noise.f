c     cnaw 2015-01-27
c     modified so signal is added to the noise matrix
c     cnaw 2020-04-03
c     Steward Observatory, University of Arizona
c     
      subroutine add_read_noise (brain_dead_test, read_noise,
     *     subarray, colcornr, rowcornr, naxis1, naxis2)
      implicit none
      double precision mirror_area, integration_time, ktc, zbqlnor,
     *     deviate, read_noise, old
      real noise
      integer colcornr, rowcornr, naxis1, naxis2 
      integer istart, iend, jstart, jend
      integer i, j, nnn, brain_dead_test
c      logical subarray
      character subarray*8
c
      parameter (nnn=2048)
c
      dimension noise(nnn,nnn)
c     
c      common /noise_/ noise
      common /ziriguidum_/ noise

      save old

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
         istart = 5
         iend   = naxis1 - 4
         jstart = 5
         jend   = naxis2 - 4
      end if
c
      if(brain_dead_test.eq.1) then
         do j = jstart, jend
            do i = istart, iend 
               noise(i,j) = noise(i,j) + 0.0000
c               noise(i,j) = noise(i,j) + 10.0000
            end do
         end do
         return
      end if
c
c     add read-noise to non-reference pixels
c
c      print *,'add_read_noise ', read_noise,' e- ', subarray
c      print *, istart, iend, jstart, jend
c
      do j = jstart,jend
         do i = istart, iend
            deviate = zbqlnor(0.0d0, read_noise)
            old     = noise(i,j)
            noise(i,j) = noise(i,j) +  real(deviate)
            if(i.eq.1029 .and. j.eq.1041)  then
                print *,'add_read_noise ',noise(i,j), deviate, old
             end if
         end do
      end do
      return
      end
