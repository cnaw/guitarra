      subroutine xy_osim_ra_dec(ra0, dec0, ra, dec, pa_degrees,
     *     xc, yc, osim_scale, x_osim, y_osim)
c
c     convert from (x, y) in osim coordinates into RA, DEC, given
c     a known position angle in degrees
c
c     ra0,dec0   - coordinates of field centre in degrees
c     ra, dec    - OUTPUT coordinates of object
c     pa_degrees - position angle relative to N, positive to E
c     xc, yc     - OSIM coordinates of field centre (nominally 0, -315.0)
c     osim_scale - size of OSIM unit (nominally 1.59879d0 arc sec)
c     x_osim, y_osim - INPUT coordinates in OSIM units
c
c     requires 
c     plane_to_spherical.f  
c     rotate_coords.f 
c
c     (C) Copyright 2015 Christopher N. A. Willmer
c     Steward Observatory, University of Arizona
c     cnaw@as.arizona.edu 
c     2015-02-02
c
c------------------------------------------------------------------------------
c This routine is free software; you can redistribute it and/or modify it
c under the terms of the GNU General Public License as published by the Free
c Software Foundation; either version 3 of the License, or (at your option) any
c later version.
c This program is distributed in the hope that it will be useful,
c but WITHOUT ANY WARRANTY; without even the implied warranty of
c MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
c GNU General Public License for more details.
c-----------------------------------------------------------------------------
c
c
      implicit none
      double precision ra, dec, ra0, dec0,  pa_degrees,  xc, yc,
     *     osim_scale, x_osim, y_osim, osim_to_rad, xx, yy, q

c      data osim_scale/1.59879d0/ ! arc sec average for X and Y
      q = dacos(-1.0d0)/180.d0
c
c     convert OSIM coordinates into radians
c
      osim_to_rad  = (osim_scale/3600.d0)*q
c     
c     Remove rotation from the OSIM coordinate plane
c
      call rotate_coords(xc, yc, x_osim, y_osim, -pa_degrees, xx, yy)
c
      xx = (xx-xc) * osim_to_rad
      yy = (yy-yc) * osim_to_rad
c      print 10, x_osim, y_osim, xx, yy
 10   format('xy_osim_ra_dec ',4(1x,f20.15))
      call plane_to_spherical(ra0, dec0, xx, yy, ra, dec)
c     
      return
      end
