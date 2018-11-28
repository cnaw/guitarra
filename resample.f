      subroutine resample(n_org_x, n_org_y, original, 
     *     over_sampling_rate, nx, ny, resampled, nnn)
      implicit none
      double precision resampled, total, sum
      real original
      integer n_org_x, n_org_y, nx, ny, nnn,over_sampling_rate
      integer i, i1, i2, j, j1, j2, l, m, sample
c
      dimension original(nnn, nnn), resampled(nnn,nnn)
c
c
c     now rebin to normal scale, conserving flux. The resampled
c     image will be placed at pixels starting at (1,1).
c
      sample = over_sampling_rate
      nx     = n_org_x/over_sampling_rate
      ny     = nx
c
      total = 0.0d0
      do m = 1, ny
         j1 = (m-1) * sample + 1
         j2 = j1  + sample -1
         do l = 1, nx
            i1 = (l-1) * sample + 1
            i2 = i1  + sample -1
            sum = 0.d0
            do j = j1, j2
               do i = i1, i2
                  sum = sum + original(i,j)
               end do
            end do
            resampled(l,m) = sum
            total = total + sum
         end do
      end do
      return
      end
