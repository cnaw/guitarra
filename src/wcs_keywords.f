      subroutine wcs_keywords(sca_id, x_sca, y_sca, xc, yc, osim_scale,
     *     ra_dithered, dec_dithered, pa_degrees, verbose)
c     
c     (C) Copyright 2015 Christopher N. A. Willmer
c     Steward Observatory, University of Arizona
c     cnaw@as.arizona.edu 
c     2015-02-10
c     Corrected the rotation matrix
c     2016-10-12
c     
c------------------------------------------------------------------------------
c     This routine is free software; you can redistribute it and/or modify it
c     under the terms of the GNU General Public License as published by the Free
c     Software Foundation; either version 3 of the License, or (at your option)
c     any later version.
c     This program is distributed in the hope that it will be useful,
c     but WITHOUT ANY WARRANTY; without even the implied warranty of
c     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
c     GNU General Public License for more details.
c-----------------------------------------------------------------------------
c
      implicit none
      double precision osim_scale, xc, yc, q, sw_scale, lw_scale,
     *     cospa, sinpa, cosx, sinx, cosy, siny, scale, ra_sca, dec_sca,
     *     x_sca, y_sca, ra_dithered, dec_dithered, pa_degrees,
     *     xshift, yshift, xmag, ymag, xrot, yrot,
     *     oxshift, oyshift, oxmag, oymag, oxrot, oyrot,
     *     cosdec
c
      double precision a11, a12, a21, a22
      double precision
     *     cd1_1, cd1_2, cd2_1, cd2_2, crval1, crval2, crpix1, crpix2,
     *     cdelt1, cdelt2, equinox,
     *     pc1_1, pc1_2, pc2_1, pc2_2
c      real cd1_1, cd1_2, cd2_1, cd2_2, crval1, crval2, crpix1, crpix2,
c     *     cdelt1, cdelt2, equinox
      integer sca_id, i, verbose
c     
      dimension xshift(10), yshift(10), xmag(10), ymag(10), xrot(10),
     *     yrot(10)
      dimension oxshift(10), oyshift(10), oxmag(10), oymag(10),
     *     oxrot(10), oyrot(10)
c     
      common /wcs/ equinox, crpix1, crpix2, crval1, crval2,
     *     cdelt1,cdelt2, cd1_1, cd1_2, cd2_1, cd2_2,
     *     pc1_1, pc1_2, pc2_1, pc2_2
      common /transform/ xshift, yshift, xmag, ymag, xrot, yrot
      common /otransform/ oxshift, oyshift, oxmag, oymag, oxrot, oyrot
c     
c     data xc, yc /0.0d0, -315.6d0/
c     data osim_scale/1.59879d0/ 
c     
      q  = dacos(-1.d0)/180.0d0
c     
      sw_scale = 0.0317d0
      lw_scale = 0.0648d0
c     
c-----------------------------------------------------------------------
c     
      cospa = dcos((pa_degrees)*q)
      sinpa = dsin((pa_degrees)*q)
c     
      if(sca_id .eq. 485 .or. sca_id .eq. 490) then
         scale = lw_scale
      else
         scale = sw_scale
      end if
c     
c     For each SCA use the centre as reference
c     
      x_sca = 1024.5d0
      y_sca = 1024.5d0
c     
c     Find corresponding RA, DEC
c     
      call sca_to_ra_dec(sca_id, 
     *     ra_dithered, dec_dithered,
     *     ra_sca, dec_sca, pa_degrees, 
     *     xc, yc, osim_scale, x_sca, y_sca)
c     
c     set the WCS keywords assuming no curvature, until RA---TAN-SIP is
c     included
c     
      i = sca_id - 480
      if(i.lt.0) i = 1
c
      cosdec = dcos(dec_dithered*q)
c     
      cosx  = dcos(xrot(i)*q)
      sinx  = dsin(xrot(i)*q)
c     
      cosy  = dcos(yrot(i)*q)
      siny  = dsin(yrot(i)*q)
c
c     These transformations give very small residuals when
c     matching fields at different rotations. They
c     are systematic and of the order of 0.2" in RA and Dec.,
c     but infinitely better than the previous rotation matrix.
c
      a11 =  xmag(i) * cosx * cospa - xmag(i) * sinx * sinpa
      a12 =  ymag(i) * siny * cospa + ymag(i) * cosy * sinpa
      a21 = -xmag(i) * cosx * sinpa - xmag(i) * sinx * cospa
      a22 = -ymag(i) * siny * sinpa + ymag(i) * cosy * cospa
c
      cd1_1  = a11 * (osim_scale/3600.d0)
      cd1_2  = a12 * (osim_scale/3600.d0)
      cd2_1  = a21 * (osim_scale/3600.d0)
      cd2_2  = a22 * (osim_scale/3600.d0)
c
      if(verbose.gt.1) then
         print *,'wcs_keywords ', ra_sca, dec_sca, x_sca, y_sca
         print *,'wcs_keywords ', xmag(i), ymag(i), xrot(i), yrot(i)
      end if
c     
      equinox   = 2000.00000000
c      crval1    = ra_dithered   ! CRVALn  refer to the centre of NIRCam
c      crval2    = dec_dithered  ! at ra_dithered, dec_dithered
      crval1    = ra_sca        ! CRVALn  refer to the centre of SCA
      crval2    = dec_sca       ! at ra_dithered, dec_dithered
      cdelt1    = scale/3600.d0 ! scale in degrees per pixel
      cdelt2    = scale/3600.d0 
      crpix1    = x_sca         ! CRPIXn are the SCA coordinates for
      crpix2    = y_sca         ! XC, YC
c     
      return
      end
c
