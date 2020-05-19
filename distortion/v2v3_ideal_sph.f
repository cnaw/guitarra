c
c----------------------------------------------------------------------
c     JWST-STScI-001550, SM-12, section 4.3, higher precision
c     2020-04-14
      subroutine v2v3_ideal_sph(v2sphsec,v3sphsec, v2ref, v3ref, 
     &     v2, v3)

      implicit none
      double precision t,u, v2ref, v3ref, v2sphsec, v3sphsec, v2, v3
      double precision qsec,q, dv2, dv3, cosrho,
     &     v2refrad, v3refrad, v2sphrad, v3sphrad
c
      q = dacos(-1.0d0)/180.d0
      qsec = q/3600.d0
c
      v2sphrad = v2sphsec * qsec
      v3sphrad = v3sphsec * qsec
      v2refrad = v2ref * qsec
      v3refrad = v3ref * qsec
c
      cosrho = dcos(v2sphrad-v2refrad) * dcos(v3sphrad)*dcos(v3refrad)
     &     + dsin(v3sphrad) * dsin(v3refrad)
c
      dv2      = dsin(v2sphrad-v2refrad) * dcos(v3sphrad)/cosrho
      dv3      = (dsin(v3sphrad)/cosrho) - dsin(v3refrad) 
      dv3      = dv3/dcos(v3refrad)

      v2       = dv2/qsec
      v3       = dv3/qsec
      return
      end
