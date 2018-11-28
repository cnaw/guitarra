c
      double precision function photon_flux_from_uresp(mag, m0_nu)
c
c     input
c     mag         : AB magnitude of source
c     m0_nu       : AB magnitude of a source  1 photon/sec count date
c     
c     output 
c     photon_flux in number of photo-electrons per second per micron
c
c     cnaw 2018-06-12
c     Steward Observatory, University of Arizona
c     
      implicit none
      double precision mag, m0_nu
      photon_flux_from_uresp = 10.d0**(0.4d0*(m0_nu-mag))

c      print 10,  mag,m0_nu,photon_flux_from_uresp
 10   format('photon_flux_from_uresp: mag, m0_nu, photons/s',
     *     2(1x, f8.3),1x, 1pe11.5)
      return
      end

