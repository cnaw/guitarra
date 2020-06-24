c
c-----------------------------------------------------------------------
c
c     Convert V2, V3 coordinates from radians into arc sec
c     cnaw@as.arizona.edu
c     2020-04-18
c
      subroutine coords_to_v2v3(xx, yy, v2, v3)
      implicit none
      double precision xx, yy, v2, v3, q
      q = dacos(-1.0d0)/(180.0d0*3600.d0)
      v2 = xx/q
      v3 = yy/q
      return
      end
