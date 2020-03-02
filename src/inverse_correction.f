c     
c=======================================================================
c
c     Rather than make the linearity correction, do the inverse -
c     bias the counts !
c     Uses the linearity correction coefficients to create a look-up
c     table that is used to estimate what the observed counts would be.
c     If counts are above the level where the linearity correction is
c     valid, the observed counts get assigned the full well depth value
c
c     i, j    = pixel being used for the correction
c     eflux   = electron flux
c     inverse_correction = output convolved by the inverse linearity,
c                           converted into ADU
c     cnaw 2015-04-07
c     cnaw 2016-05-02
c     Steward Observatory, University of Arizona
c     removed conversion of e- -> ADU 2020-02-24
c     
      double precision function inverse_correction(i, j, eflux)
      implicit none
      double precision xx, yy, debiased,eflux, observed,
     *     measured_electrons
      double precision linearity_gain, lincut, well_fact
      real  bias, well_depth, linearity, gain
      integer nnn, nlin, l, i, j, order, ninterv, max_order
      parameter(nnn=2048, nlin=30, max_order=7)
      dimension xx(nnn), yy(nnn)
      dimension well_depth(nnn,nnn), linearity(nnn,nnn,max_order), 
     *     bias(nnn,nnn), gain(nnn, nnn)
c     
      common /gain_/ gain
      common /well_d/ well_depth, bias, linearity, linearity_gain,
     *     lincut, well_fact, order
c
c     if there are no coefficients, set to 0 (i.e., bad pixels)
c
      if(linearity(i,j,1)+0.0d0 .ne.linearity(i,j,1)) then
         inverse_correction = 0.d0
         return
      endif
c
c     The flux unit of co-added stacked pixels is in electrons.
c
      if(eflux.le.0.0d0) then
         if(gain(i,j).ne.0) then
            inverse_correction = eflux
         else
            inverse_correction = 0.0d0
         end if
         return
      end if
c
      if(eflux.lt.lincut) then
         inverse_correction = eflux
         return
      end if
c
c     otherwise create the linearity look-up table for this pixel
c
      call linearity_table(i, j, xx, yy, ninterv)
c
c     multiply the accumulated charge by the correction factor
c     to find the "real" number of electrons
c
      do l = 1, ninterv
         yy(l) = yy(l) * xx(l)
      end do
c
c     find corresponding output value by inverting the table search:
c
      call linear_interpolation(ninterv, yy, xx, eflux, 
     &     measured_electrons)
      inverse_correction = measured_electrons
c     &     print 10,i,j, eflux, altered, gain(i,j),inverse_correction,
c     &     well_depth(i,j)*gain(i,j), well_depth(i,j)
 10   format('inverse correction ',2(i5),7(1x,f15.4))
c
      return
      end
