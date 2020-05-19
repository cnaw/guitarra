c     
c-----------------------------------------------------------------------
c      
c     Converts vector expressed in Euler angles to unit vector components.
c     JWST-STScI-001550 page 23
c     angles in radians
c     cnaw@as.arizona.edu
c     2017-03-20
c     2020-04-18
c
      subroutine unit_vector(rar, decr, u)
      implicit none
      double precision rar, decr, u
      dimension  u(3)
      u(1) = dcos(rar) * dcos(decr)
      u(2) = dsin(rar) * dcos(decr)
      u(3) = dsin(decr)
      return
      end
