      subroutine ra_dec_xy_osim(ra0, dec0, ra, dec, pa_degrees,
     *     xc, yc, osim_scale, x_osim, y_osim)
c
c     Transform RA, DEC in degrees into OSIM coordinates in
c     OSIM units (each OSIM unit corresponds to about 1.6 arc sec) 
c
c     ra0,dec0   - coordinates of field centre in degrees
c     ra, dec    - INPUT coordinates of object
c     pa_degrees - position angle relative to N, positive to E
c     xc, yc     - OSIM coordinates of field centre (nominally 0, -315.0)
c     osim_scale - size of OSIM unit (nominally 1.59879d0 arc sec)
c     x_osim, y_osim - OUTPUT coordinates in OSIM units
c
c     requires 
c     projec.f        
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
      implicit none
      double precision ra, dec, ra0, dec0, pa_degrees, xc, yc,
     *     osim_scale, x_osim, y_osim, osim_to_rad, x, y, q
c      data xc, yc /0.0d0, -315.6d0/
c      data osim_scale/1.59879d0/ ! arc sec average for X and Y
      q = dacos(-1.0d0)/180.d0
c     
c     osim scale is in arc sec per osim unit
c
      osim_to_rad  = (osim_scale/3600.d0) * q
c
c     first project RA, DEC onto the tangent plane using the
c     gnomonic projection. In the PROJEC subroutine all input
c     and output parameters are in radians
c
c      call projec(ra*q, dec*q,ra0*q,dec0*q, x, y)
      call spherical_to_plane(ra0, dec0, x, y, ra, dec)
c
c
c     convert into OSIM units and rotate
c
c      print *, 'ra_dec_xy_osim',ra, dec, x, y, 
c    * x/osim_to_rad, y/osim_to_rad
      x = xc + x/osim_to_rad
      y = yc + y/osim_to_rad
c
      call rotate_coords(xc, yc, x, y, pa_degrees, x_osim, y_osim)
c
      return
      end
