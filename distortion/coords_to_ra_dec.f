c
c-----------------------------------------------------------------------
c     
c     Convert RA, DEC in radians to degrees
c     cnaw@as.arizona.edu
c     2020-04-18
c
      subroutine coords_to_ra_dec(xx, yy, ra, dec)
      implicit none
      double precision xx, yy, ra, dec,q
      q = dacos(-1.0d0)/180.0d0
      ra  = xx/q
      dec  = yy/q
      if(ra.lt.0.d0)    ra = ra + 360.d0
      if(ra.gt.360.0d0) ra = ra - 360.d0      
      return
      end
