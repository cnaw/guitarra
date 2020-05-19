c
c----------------------------------------------------------------------
c
c     Convert Ideal to V2V3. The coefficients are cos/sin of angles
c     used in expressions of JWST-STScI-001550, SM-12, section 4.3
c     2020-04-14
c
      subroutine idl_to_v2v3(x_ideal, y_ideal, v2, v3,
     &     v2_offset, v3_offset,v_idl_parity, v3_idl_yang, 
     &     precise, verbose)
      implicit none
      integer v_idl_parity, precise, verbose
      double precision x_ideal, y_ideal, v2, v3,
     &     v2_offset, v3_offset,v3_idl_yang
      double precision q, angle, cosa, sina, dv2, dv3, t1, t2,
     &      v2sphsec, v3sphsec
      q   = dacos(-1.0d0)/180.d0
      cosa = dcos(v3_idl_yang*q)
      sina = dsin(v3_idl_yang*q)
c
      dv2 =  v_idl_parity * x_ideal * cosa + y_ideal * sina
      dv3 = -v_idl_parity * x_ideal * sina + y_ideal * cosa

      if(precise .eq. 1) then
         call ideal_v2v3_sph(dv2, dv3, v2_offset, 
     &        v3_offset, v2sphsec, v3sphsec)
         dv2 = v2sphsec
         dv3 = v3sphsec
      end if
      v2 = dv2 + v2_offset
      v3 = dv3 + v3_offset
      if(verbose.gt.1) then
         print *,'idl_to_v2v3', dv2, dv3, v2, v3
      end if
      return
      end
