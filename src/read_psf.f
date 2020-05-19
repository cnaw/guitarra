c
c     read the point spread function and create a 1-D array that will
c     be used in the MC simulations
c     over_sampling_rate should be a parameter of the PSF file
c
      subroutine read_psf(file, scale, verbose)
      implicit none
c
      double precision integrated_psf, dpsf, scale, dx
      real psf
      integer ix, nxy, nxny
      integer over_sampling_rate, nx, ny, n_psf_x, n_psf_y, i, j, nnn,
     &     det_samp, verbose
      character file*(*)
      parameter(nnn=3100, nxny=3100*3100)
c      parameter(nnn=6144, nxny=6144*6144)
      dimension psf(nnn,nnn), dpsf(nnn,nnn),dx(nnn,nnn), ix(nnn,nnn)
      dimension integrated_psf(nxny)
c
      common /psf/ integrated_psf,n_psf_x, n_psf_y, 
     *     nxy, over_sampling_rate
c
c     read PSF as a fits file
c
      call read_psf_fits(file, psf, dx, ix, nx, ny,det_samp,scale,
     &     nnn,verbose)
      if(det_samp.ne.0) over_sampling_rate = det_samp
      print *,'read_psf: over_sampling_rate, nx, ny',
     &     over_sampling_rate, nx, ny
      print *,'read_psf: verbose',verbose
c
c     commented 2020-04-24 
c     resampling should be done when adding photons to the image
c
c      if(verbose.gt.0) print *,'read_psf: enter resample'
c      call resample(nx, ny, psf, over_sampling_rate,
c     *     n_psf_x, n_psf_y, dpsf, nnn)
c      if(verbose.gt.0) print *,'read_psf: exit  resample'
c
      n_psf_x = nx
      n_psf_y = ny
      do j = 1, ny
         do i = 1, nx
            dpsf(i,j) = dble(psf(i,j))
         enddo
      enddo
      nxy    = n_psf_x * n_psf_y
      print *,'read_psf: over_sampling_rate,nxy,nx,ny,n_psf_x,n_psf_y',
     *     over_sampling_rate, nxy, nx, ny, n_psf_x, n_psf_y
c
c     create the cummulative distribution in a 1-D array
c
      if(verbose.gt.0) print *,'read_psf: enter integration'
      call integration(dpsf,nnn, n_psf_x, n_psf_y, integrated_psf, nxny, 
     &     nxy, verbose)
      if(verbose.gt.0) print *,'read_psf: exit  integration'
      print *,'read_psf: n_psf_x, n_psf_y',n_psf_x, n_psf_y, nxny, nxy,
     &     n_psf_x * n_psf_y
c
      return
      end
