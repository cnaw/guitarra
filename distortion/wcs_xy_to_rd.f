      subroutine wcs_xy_to_rd(xpix, ypix, ra, dec, 
     &     crpix1, crpix2, crval1, crval2,
     &     cd1_1, cd1_2, cd2_1, cd2_2)
      implicit none
      double precision xpix, ypix, ra, dec, 
     &     crpix1, crpix2, crval1, crval2,
     &     cd1_1, cd1_2, cd2_1, cd2_2
      double precision dx, dy, dra, ddec, q,cosdec, det_sign
      q = dacos(-1.0d0)/180.d0
c
      dx = xpix-crpix1
      dy = ypix-crpix2
      dra  = cd1_1 * dx + cd1_2 * dy
      ddec = cd2_1 * dx + cd2_2 * dy
      dec  = crval2 + ddec
      cosdec = dcos(dec*q)
      ra   = crval1 + dra/cosdec
      return
      end

