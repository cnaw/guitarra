c
c=======================================================================
c
      subroutine rotate_coords2(xr, yr, xx, yy, x0, y0, angle) 
c     *     xoff, yoff)
      implicit none
      double precision xr, yr, xx, yy, x0, y0, angle, xoff, yoff,
     *     xi, yi
      double precision q, phi
      q = dacos(-1.d0)/180.d0
      xoff =  0.0d0
      yoff = -7.8d0
      xi   = xx - xoff
      yi   = yy - yoff
      phi =  angle * q
      xr = x0 + xi * dcos(phi) + yi *dsin(phi)
      yr = y0 - xi * dsin(phi) + yi *dcos(phi)
      return
      end
