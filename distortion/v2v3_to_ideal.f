c
c----------------------------------------------------------------------
c
c     Convert V2V3 to Ideal. The coefficients are cos/sin of angles
c     used in expressions of JWST-STScI-001550, SM-12, section 4.3
c     2020-04-14
c     2020-05-08
c
      subroutine v2v3_to_ideal(x_ideal, y_ideal, v2, v3,
     &     v2_ref, v3_ref,v_idl_parity, v3_idl_yang, 
     &     precise, verbose)
      implicit none
      integer v_idl_parity, precise, verbose
      double precision xx, yy, x_ideal, y_ideal, v2, v3,
     &     v2_ref, v3_ref, v3_idl_yang
      double precision q, angle, cosa, sina, t1, t2, dv2, dv3
      q    = dacos(-1.0d0)/180.d0
      if(verbose.gt.3) then
         print *,'v2v3_to_ideal v2,v3', v2, v3,
     &        v2_ref, v3_ref,v_idl_parity, v3_idl_yang
      end if
c
      cosa = dcos(v3_idl_yang*q)
      sina = dsin(v3_idl_yang*q)
c
c     standard
c
      dv2 = v2 - v2_ref
      dv3 = v3 - v3_ref
c     more precise using spherical astronomy expressions
c
      if(precise .eq.1) then
         call v2v3_ideal_sph(v2,v3,v2_ref,v3_ref, 
     &        dv2, dv3)
      end if
c     this is what Cox and Lallo have
c      x_ideal =  v_idl_parity * dv2 * cosa - dv3*sina
c     this seems correct to me; it produces better results (see below)
      x_ideal =  v_idl_parity * (dv2 * cosa - dv3*sina)
      y_ideal =  dv2*sina + dv3 * cosa
      if(verbose.gt.2) then
         print *,'v2v3_to_ideal', dv2, dv3, v2, v3, x_ideal, y_ideal
      end if
      return
      end
c
c     2021-07-02: comparing the transform adopted here and 
c     Cox and Lallo for (dv2,dv3) -> (xidl, yidl)
c     direct:
c     "truth": (x, y) -> (ra, dec) 
c     x_det, y_det           2024.5000000000000        2024.5000000000000     
c     v2_arcsec, v3_arcsec  -153.39760278884503       -554.63389986182096     
c     ra_siaf , dec_siaf      53.112080802607238       -27.811696671822453     
c     siaf_xy_to_rd           53.112080802607238       -27.811696671822453     
c     ra_siaf, dec_siaf        03:32:26.8994  -27:48:42.108
c     c
c     inverse: SIAF  (ra, dec) -> (x, y) using my version
c     "truth"
c     ra_obj, dec_obj           53.112080802607238       -27.811696671822453     
c     ra_rad, dec_rad          0.92698068259076882      -0.48540567748925068     
c     v2_arcsec, v3_arcsec     -153.39760278879979       -554.63389986183574     
c     x_det, y_det (recov)      2024.4852576773549        2024.4868315334372     
c     x_det_org, y_det_org      2024.5000000000000        2024.5000000000000     
c     diff_x, diff_y (pixel)    1.4742322645133754E-002   1.3168466562774483E-002
c
c     siaf_rd_to_xy
c     siaf_rd_to_xy             2024.4852576773549        2024.4868315334372     
c     diff_x, diff_y (pixel)    1.4742322645133754E-002   1.3168466562774483E-002

c     inverse: SIAF  (ra, dec) -> (x, y)  using Cox & Lallo
c     "truth"
c     ra_obj, dec_obj           53.112080802607238       -27.811696671822453     
c     ra_rad, dec_rad          0.92698068259076882      -0.48540567748925068     
c     v2_arcsec, v3_arcsec     -153.39760278879979       -554.63389986183574     
c     x_det, y_det (recov)      2024.7636420155793        2024.4900021960561     
c     x_det_org, y_det_org      2024.5000000000000        2024.5000000000000     
c     diff_x, diff_y (pixel)  -0.26364201557930755        9.9978039438610722E-003
c
c     siaf_rd_to_xy
c     siaf_rd_to_xy             2024.7636420155793        2024.4900021960561     
c     diff_x, diff_y (pixel)  -0.26364201557930755        9.9978039438610722E-003
