      double precision function ab_mag_to_photon_flux (mag, mirror_area,
     *     wavelength, bandwidth, system_transmission)
c     
c     input
c     mag         : AB magnitude of source
c     wavelength  : effective wavelength of filter in microns
c     mirror_area : mirror area in square centimeters
c     
c     output 
c     photon_flux in number of photo-electrons per second per micron
c     (this is because the filter transmission already contains the
c     quantum efficiency
c     
c     convert magnitudes into F_nu in Jy
c     f_nu  = 10.d0**(0.40d0*(8.90d0 - mag))
c
c     f_nu --> f_lambda (f_nu * dnu = f_lambda * dlambda)
c     f_lam = f_nu * c /wavelength^2
c     
c     energy_of_a_photon  = h * c/wavelength
c     thus the number of photons for a given flux density is
c     photon_flux = f_lambda * dlambda / energy_of_a_photon
c     photon_flux = dlambda* (f_nu *c / wavelength^2)/( h * c / wavelength)
c     photon_flux = (f_nu / h) * (dlambda/wavelength)
c
c     Units:
c     photon_flux = (f_nu [erg/s/cm^2/hz] / h [erg s]) * dlambda/wavelength 
c     photon_flux [cm^-2 s^-1 ] = 1.5091905D3 * f_nu [Jy]  
c     photon_flux [ m^2  s^-1 ] = 1.5091905D7 * f_nu [Jy] 
c
c     cnaw 2015-01-27
c     Steward Observatory, University of Arizona
c     
      implicit none
      double precision bandwidth, wavelength, system_transmission,
     *     dlam_over_lam, f_nu, sim_nicmos, hplanck, photon_flux,
     *     photon_flux_per_unit_area, sim_flux
      double precision mag, mirror_area, integration_time
c
      hplanck   = 6.62606957d-27     ! erg s 
c
      f_nu  = 10.d0**(0.40d0*(8.90d0 - mag)) ! units are Jy
c
c     photon flux (photons/sec/cm^2) for f_nu in Jy and wavelength in microns:
c
      dlam_over_lam = bandwidth/wavelength
      photon_flux_per_unit_area =  dlam_over_lam * f_nu/(hplanck*1.d23)
c
c     total number of photons per second
c
      photon_flux = photon_flux_per_unit_area  * mirror_area 
c
c     Number of photo-electrons per second
c
      photon_flux = photon_flux *  system_transmission
      ab_mag_to_photon_flux = photon_flux
c
c      print 10,  wavelength, mag, f_nu, photon_flux
 10   format('ab_mag_to_photon_flux: wl, mag,f_nu, photons/s',
     *     1x, f9.3, 1x, f8.3,1x,1pe11.5,1x,1pe11.5)
c
c     units for NICMOS simulator is photons/cm2/s/A but note that
c     AB = -2.5 * log [Flux(frequency)] - 48.57 instead of
c     AB = -2.5 * log [Flux(frequency)] - 48.60
c
c      sim_nicmos = 1.5091905d3 * f_nu *1.0d-4 /wavelength
c      sim_flux   = sim_nicmos * mirror_area
c      sim_flux   = sim_flux  * bandwidth * system_transmission * 1.d04
c      print *, 'ab_mag_to_photon_flux:', mag, f_nu, wavelength,
c     *     bandwidth, photon_flux_per_unit_area,
c     *     system_transmission, sim_nicmos,ab_mag_to_photon_flux,
c     *     sim_flux
c      stop
      return
      end

