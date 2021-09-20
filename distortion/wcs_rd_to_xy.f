      subroutine wcs_rd_to_xy(xpix, ypix, ra, dec, 
     &     crpix1, crpix2, crval1, crval2,
     &     cd1_1, cd1_2, cd2_1, cd2_2)
      implicit none
      double precision xpix, ypix, ra, dec, 
     &     crpix1, crpix2, crval1, crval2,
     &     cd1_1, cd1_2, cd2_1, cd2_2
      double precision dx, dy, dra, ddec, detcd,
     &     inv1_1, inv1_2, inv2_1, inv2_2, 
     &     q, cosdec
      q = dacos(-1.0d0)/180.d0
      cosdec = dcos(dec*q)
c
      detcd = (cd1_1*cd2_2) - (cd1_2*cd2_1)
      inv1_1 =  cd2_2/detcd
      inv1_2 = -cd1_2/detcd
      inv2_1 = -cd2_1/detcd
      inv2_2 =  cd1_1/detcd
c
      dra  = (ra  - crval1) * cosdec
      ddec =  dec - crval2
      dx   = inv1_1 * dra + inv1_2 * ddec
      dy   = inv2_1 * dra + inv2_2 * ddec
c
      xpix  = crpix1 + dx
      ypix  = crpix2 + dy
      return
      end

