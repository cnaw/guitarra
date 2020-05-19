c
c---------------------------------------------------------------------
c
      subroutine coords_from_unit_vector(u, xrot, yrot)
c     Convert unit vector to ra, dec (radians)
c     probably pirated from python code by Bryan Hilbert (STScI)
c     
      implicit none
      double precision u, norm, xrot, yrot
      dimension  u(3)
c
      norm = dsqrt(u(1)*u(1) + u(2)*u(2)  + u(3) * u(3))
      yrot = dasin(u(3)/norm)
      xrot = datan2(u(2), u(1))
      end
