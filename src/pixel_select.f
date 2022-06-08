c----------------------------------------------------------------------
c
c     derived from psf_convolve. 
c     Given a 2-D image integrated into 1-D, find a random 
c     x and y position
c 
      subroutine pixel_select(one_d_image, npts, nx, ny, seed, 
     *     xhit, yhit)
      implicit none
c     
      integer (kind=8) nxy
      integer npts, nx, ny, over_sampling_rate, seed
      double precision one_d_image, xhit, yhit
c     
      integer indx, ix, iy
      double precision fz, slope, x, y, zest
c
      double precision zbqlu01
c     
      dimension one_d_image(npts)
      nxy = npts
      over_sampling_rate = 1
c     
c     find random variate
c     
c      print *,'pixel_select ', npts
      fz = zbqlu01(dble(seed)) * one_d_image(npts)
c
c     find nearest position in the accumulated image
c
      call find_index(npts, one_d_image, fz, indx)
      if(indx.lt.1) indx = 1
      if(indx.gt.npts-1) indx = npts - 1
c
c     Interpolate linearly to recover the "x" position
c
      slope = 1.d0/(one_d_image(indx+1)-one_d_image(indx))
      zest  = dble(indx) + (fz - one_d_image(indx)) * slope
c     
c     Find the corresponding "y" position
c
      iy    = int(float(indx)/float(nx))
      x     = zest - iy*nx
c     
c     within this pixel place the Y-position randomly. 
c
      y     = iy +  zbqlu01(dble(seed))
c
      xhit = x + 1.d0 
      yhit = y + 1.d0 
      xhit  = x - (nx/2)! + 1    !/over_sampling_rate
      yhit  = y - (ny/2)! + 1    !/over_sampling_rate
c      print 10, zest, indx, iy, xhit, yhit,fz, npts,nx, ny
 10   format(1x,f9.2,2(1x,i6),2x,2(f9.2), e11.4,3(1x,i6))
c      print *, nx, ny, x, y, over_sampling_rate, one_d_image(nxy)
c      pause
c
      return
      end
