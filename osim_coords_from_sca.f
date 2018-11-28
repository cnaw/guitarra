c     
c-----------------------------------------------------------------------
c
c     Find OSIM coordinates given an SCA and pixel coordinates
c
      subroutine osim_coords_from_sca(sca, xpix, ypix, x_osim, y_osim)
      implicit double precision (a-h,o-z)
      integer sca
      dimension xshift(10), yshift(10), xmag(10), ymag(10), xrot(10),
     *     yrot(10)
      common /transform/ xshift, yshift, xmag, ymag, xrot, yrot
      q = dacos(-1.0d0)/180.d0
c
      index = sca - 480
c      if(index .eq.2) then
c         x_osim = 200.d0
c         y_osim =   0.0d0
c      else
      x_osim = xshift(index) + xmag(index) * dcos(xrot(index)*q) * xpix
     *        + ymag(index) * dsin(yrot(index)*q) * ypix
      y_osim = yshift(index) - xmag(index) * dsin(xrot(index)*q) * xpix
     *        + ymag(index) * dcos(yrot(index)*q) * ypix
c      end if
      return
      end
