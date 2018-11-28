c
c     cnaw 2015-01-27
c
c     Steward Observatory, University of Arizona
c     XHIT, YHIT -  position within pixel
c     
      subroutine psf_convolve(seed, xhit, yhit)
c
      implicit none
c     
      double precision integrated_psf, xhit, yhit, x, y, fz, slope,
     *     zest, zbqlu01, dummy
      integer nxy, nxny
      integer over_sampling_rate, seed, n_psf_x, n_psf_y, ix, iy, 
     *     index, nx, ny, npsf
      parameter (nxny = 2048*2048)
      dimension integrated_psf(nxny)
      common /psf/ integrated_psf,n_psf_x, n_psf_y, 
     *     nxy,over_sampling_rate
      nx = n_psf_x
      ny = n_psf_y
      npsf = nx * ny
c     
c     find random variate
c
      dummy = dble(seed)
      fz = zbqlu01(dummy)  * integrated_psf(nxy)
c
c     find nearest position in the accumulated psf
c
      call find_index(npsf, integrated_psf, fz, index)
      if(index.lt.1) index = 1
      if(index.gt.nxy-1) index = nxy - 1
c
c Interpolate linearly to recover the "x" position
c
      slope = 1.d0/(integrated_psf(index+1)-integrated_psf(index))
      zest  = float(index) + (fz - integrated_psf(index)) * slope
c     
c     Find the corresponding "y" position
c
      iy    = int(float(index)/float(nx))
      x     = zest - iy*nx
c
c     within this pixel place the Y-position randomly. Not correct 
c     since one would like to use the PSF value to have a unique
c     x, y pair.
c
      y     = iy +  zbqlu01(dummy)  
c
c Find offsets relative to optical axis, taking into account the
c sampling rate.
c
      xhit  = x - (nx/2)
      yhit  = y - (ny/2)
c      print *, index, zest, x, mod(index,nx), iy,y,xhit,yhit
c      print *,' ** ', xhit, yhit, zest, iy, index,nxy, fz
c      print *, nx, ny, x, y, over_sampling_rate, integrated_psf(nxy)
c      pause
c
      return
      end
