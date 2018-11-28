c
c     Simple Latent count estimate (in ADU) from Jarron Leisenring
c     2015-09-09. Inputs are time since reset, the flux in a
c     given pixel from the previous exposure and the time the
c     pixel was at saturation. All time estimates are in seconds.
c
c     2015-09-09
c     cnaw@as.arizona.edu
c
      double precision function jl_latent(sca, time_since_reset, flux,
     *     time_saturated)
      implicit none
      integer sca
      double precision time_since_reset, flux, time_saturated
      double precision coeff, t
      dimension coeff(5)
c
      t = time_since_reset
c
c     First coefficient has two possible values depending whether
c     there is  saturation or not
c
      if(flux.le.0.0d0) then
         jl_latent = 0.d0
         return
      end if
c
      if(time_saturated.le.0.0d0) then
         coeff(1) = -1.811d-08 * flux**2.424d0
      else
         coeff(1) =  -104.066  * time_saturated**0.1233d0
      end if
c
      coeff(2)  = -2.60d-03 * coeff(1) - 1.d0
c
      coeff(3)  =  1.0d-05
c     
      coeff(4)  =  1.d0
c
      coeff(5) = 0.1778d0 * 10.d0**(-coeff(1)/200.d0)
c
      jl_latent = coeff(1) * t**coeff(2) + coeff(3)*t**coeff(4)
      jl_latent = jl_latent + coeff(4)
c      print *, sca, time_since_reset, flux,
c     *     time_saturated
c      print *, 'jl_latent', coeff, t, jl_latent
      return
      end
