c
c----------------------------------------------------------------------
c     JWST-STScI-001550, SM-12, section 4.3, higher precision
c     2020-04-14
      subroutine ideal_v2v3_sph(v2, v3, v2ref, v3ref, 
     &     v2sphsec, v3sphsec)

      implicit none
      double precision t,u, v2ref, v3ref, v2sphsec, v3sphsec, v2, v3
      double precision qsec, q, rho, s, cosrho, tanrho,
     &     v2refrad, v3refrad, v2sphrad, v3sphrad
c
      q = dacos(-1.0d0)/180.d0
      qsec = q/3600.d0
c
      v2refrad = v2ref * qsec
      v3refrad = v3ref * qsec
      t = (v2 - v2ref) * qsec
      u = (v3 - v3ref) * qsec
c      
      tanrho = dsqrt(t*t+u*u)
      rho    = datan(tanrho)
      cosrho = dcos(rho)
c
      v2sphrad = v2refrad + dasin(t*cosrho/dcos(v3refrad))
      v3sphrad = dasin(cosrho*(u*dcos(v3refrad)+dsin(v3refrad)))
c
      v2sphsec = v2sphrad/qsec
      v3sphsec = v3sphrad/qsec
      return
      end
