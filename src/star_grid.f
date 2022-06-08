      implicit none
      double precision ra, dec, ra0, dec0, step, mag, cosdec, pi, qq,
     &     fov, amag
      double precision zz, semi_a, semi_b, theta, n_sersic
      integer nstep, nstar, nnn, nmag, jj, ii, ll, mm
c
      parameter(nnn=30000,nmag=12)
      dimension  mag(nmag)
c
      qq  = dacos(-1.0d0)/180.0
      fov = 10.d0/60.d0         ! NIRCam FOV in degrees (approx)
c
      amag  = 27.5d0
      zz    = 0.0d0
      semi_a = 0.03d0
      semi_b = semi_a
      theta  = 200.d0
      n_sersic = 0.2d0
c
      do ii = 1, nmag
         mag(ii) = amag
      end do
c
      nstep = 15                ! number of grid points per side
      step  = (2000.d0/nstep)  ! separation in pixels
      print *, step, nstep
      step  = step * 0.0624d0 ! separation in arc seconds
      print *, step,' arc sec'
      step  = step/3600.d0 
      print *, step
c
      nstar = nstep*fov/step
      print *, nstar, fov
c
c     centre of 01180021001_MEDS0003_params.dat
c
      ra0  =  53.14704167
      dec0 = -27.83304167
      ll = 0
      open(1,file = '../data/star_grid.cat')
      write(1,200)
 200  format('# id', 8x,'RA', 13x,'DEC', 12x, 'amag', 15x,'z', 
     &    10x,'semi_a', 10x, 'semi_b',9x,'theta', 9x,'n_sersic', 
     &     11x,'F070W', 11x, 'F090W',11x, 'F115W',11x, 'F150W',
     &     11x,'F200W', 11x, 'F277W',11x, 'F335M',11x, 'F356W',
     &     11x,'F410M', 11x, 'F444WW')
      do jj = 1, nstar 
         dec = dec0 -fov/2.d0 + jj*step
         do ii = 1, nstar
            ll = ll + 1
            ra = ra0 -fov/2.d0 + ii*step
            write(1, 400) ll, ra, dec, amag, zz, semi_a, semi_b, theta, 
     &           n_sersic, (mag(mm),mm=1, nmag)
 400        format(i8,22(1x,f15.6))
         end do
      end do
      close(1)
      print *,' ll ', ll
      stop
      end
