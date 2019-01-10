c
c-----------------------------------------------------------------------
c
      subroutine int_sersic(nr, radius, profile, int_profile, nnn,
     *     magnitude, re, rmax, n, zp, ellipticity, debug)
      implicit none
      double precision n, re, magnitude, rmax, mue, mu0, itot,m2, 
     *     intensity, area_e, zp, axial_ratio, ellipticity
      double precision radius, profile, int_profile
      double precision bn, ie, dr, flux, area, pi, sum, eps, amag
      double precision sersic_bn, ie_sersic, sersic_profile, flux_to_r,
     *     sb_sersic, find_ie, mag_to_r, total_mag
      integer nr, nnn, i, debug
      character guitarra_aux*120,file*120
c
      dimension radius(nnn), profile(nnn), int_profile(nnn)
c
c      print *,'int_sersic'
      pi = dacos(-1.0d0)
      eps = 1.d-3
c
      do i = 1, nnn
         radius(i)      = 0.0d0
         profile(i)     = 0.0d0
         int_profile(i) = 0.0d0
      end do
c
c     given the magnitude, re and n, derive other Sersic parameters
c     (ie, bn)
c
c
      axial_ratio = 1.d0-ellipticity
      bn          = sersic_bn(n)
c     intensity at the effective radius
      ie          = ie_sersic(magnitude, re, n, bn, axial_ratio)
c     effective area
      area_e = pi *re * re
c     surface brightness at effective radius
      mue = -2.5d0*dlog10(ie/area_e)
c     central surface brightness
      mu0 = mue-2.5d0*bn/dlog(10.0d0)
c     total magnitude
      itot = total_mag(n, bn, ie, re)
      if(debug.gt.1) then
         print 10,  magnitude, re, n, bn
 10      format('int_sersic: mtot,      re,      n,        bn ',/,
     *        8x, f9.4,2x,f8.4,2x,f6.2,2x,f9.5)
         print *, 'Ie Jy/pixel**2           ', ie
         print *, 'int_sersic: mue, mu0, dmu', mue, mu0, mue-mu0
         print *, 'Ae, log10(Ae)', area_e, 2.5*log10(area_e)
      end if
c
      nr = nnn
      dr = dlog10(rmax/eps)/dble(nr-1)
      if(debug.gt.1) print *,'int_sersic: rmax, dr in re units ',
     &     rmax, dr
      sum = 0.d0
      call getenv('GUITARRA_AUX',guitarra_aux)
      if(debug.eq.1) then
         open(1,
     &  file=guitarra_aux(1:len_trim(guitarra_aux))//'int_sersic.dat')
      end if
      do i = 1, nr
         radius(i)  = eps*10.d0**(dble(i-1)*dr)
c
c     integrated flux to r
c
         if(radius(i) .eq.0.0d0) then
            flux       = flux_to_r(n, bn, ie, re, eps)
         else
            flux      = flux_to_r(n, bn, ie, re, radius(i))
         end if
c
c     if we have zero flux, exit and reset nr to previous radius
c
         if(flux.eq. 0.0d0) then
            go to 200
         end if
         int_profile(i) = flux
c     surface brightness in mag/arcsec**2
         profile(i) = sb_sersic(n, bn, mue, re, radius(i))
c     surface brightness in flux/arcsec**2
         intensity  = sersic_profile(n, bn, ie, re, radius(i))
c     note that the above are related through:
c     profile = -2.5*dlog10(intensity/area_e)
c
c     "curve of growth"; requires subtracting - 2.5d0*dlog10(area_e)
c     to be equivalent to flux_to_r if mue is used;
c     amag = -2.5d0*dlog10(flux)+2.5d0*dlog10(area_e)
c
         amag      = mag_to_r(n, bn, mue, re, radius(i))
c         if(mod(i,100).eq.1) print 100,  radius(i)/re, amag
c     brute force integration of flux density * solid angle
         sum = sum + intensity * 2.d0*pi*(i-1)*dr*dr
c
         if(debug.gt.1) then 
            write(1,100) radius(i)/re, flux, amag,
     *         -2.5d0*dlog10(sum),-2.5d0*dlog10(flux), 
     *           amag - 2.5d0*dlog10(area_e),
     *           profile(i), -2.5d0*dlog10(intensity/area_e),
     *           intensity, radius(i)*intensity/re
 100        format(f10.6, 1x,e15.6, 6(1x,f12.4),2(1x,e15.6))
         end if
      end do
      if(debug.gt.1) close(1)
      return
 200  nr = i -1
      if(debug.eq.1) close(1)
      return
      end
c
c-----------------------------------------------------------------------
c
      double precision function sersic_bn(n)
c
c     find the value of bn for a Sersic profile, parameterised by
c     a slope n; for n >= 10, use the approximation by 
c     Ciotti & Bertin 1999, A&A, 249, 99, following
c     Graham & Driver 2005, PASA, 22, 118
c     requires gammain_bhattacharjee.f ~/slatec/zeroin.f alngam.f
c
      implicit none
      double precision gdif, zeroin
      double precision tol, eps
      double precision n, two_n, bn, x0, xf
      common /gdif_par/ two_n
c
      external gdif
c
      eps = 1.d-16
      tol = 1.d-16
c
      two_n = 2.d0 * n
      x0 = 0.1d0
      xf = two_n
      if(n.le.10.d0) then
         sersic_bn = zeroin(x0, xf, gdif, tol, eps)
      else
         sersic_bn =  2*n-(1.d0/3.d0)
      end if
      return
      end

      double precision function gdif(bn)
      implicit none
      double precision alngam, gammain, bn, two_n, cgammain, gamma_c
      integer chabu
      common /gdif_par/ two_n
c
      gamma_c  = dexp(alngam(two_n,chabu)) 
      cgammain = gammain(bn, two_n, chabu) * gamma_c
      gdif     = 2.d0*cgammain - gamma_c

      return
      end
c
c-----------------------------------------------------------------------
c
c     Profile in intensity
c     Graham & Driver 2005, PASA, 22, 118,  eq. (1)
c
      double precision function sersic_profile(n, bn, ie, re, r)
      implicit none
      double precision n, bn, ie, re, r
      double precision rr
c
      rr             = (r/re)**(1.d0/n) - 1.d0
      sersic_profile = ie * dexp(-bn*rr)
      return
      end
c
c-----------------------------------------------------------------------
c
c     Profile in surface brightness
c     Graham & Driver 2005, PASA, 22, 118,  eq. (6)
c     mue = -2.5*log10(ie/(pi*re*re))
c     1/ln(10) = dlog10(dexp(1.0d0))
      double precision function sb_sersic(n, bn, mue, re, r)
      implicit none
      double precision n, bn, mue, re, r, rr
c     
      rr        = (r/re)**(1.d0/n) - 1.d0
      sb_sersic = mue + 2.5d0*bn*rr/dlog(10.0d0)
      return
      end
c
c-----------------------------------------------------------------------
c
      double precision function flux_to_r(n, bn, ie, re, r)
c
c     Graham & Driver 2005, PASA, 22, 118,  eq. (2)
c     Calculate the total flux within radius r. 
c     gammain(x, p) = [1/gamma(p)] * int_0^x exp(-t) * t**(p-1)*dt
c     therefore to calculate small_gamma of eq (3) :
c     small_gamma(x, p) = gamma(p) * gammain(x,p).
c     Expression may need to be corrected for the non-circular cases.
c
      implicit none
      double precision n, bn, ie, re, r, x
      double precision rr, gammain, alngam, two_n
      integer chabu1, chabu2
c
      x         = bn * (r/re)**(1.d0/n)
      two_n     = 2.d0 * n
      flux_to_r = dexp(alngam(two_n,chabu1))*gammain(x,two_n,chabu2)
      flux_to_r = flux_to_r * 2.d0*dacos(-1.0d0) * n
      flux_to_r = flux_to_r * dexp(bn)/(bn**two_n)
      flux_to_r = ie * re * re * flux_to_r 
      return
      end
c
c-----------------------------------------------------------------------
c
      double precision function mag_to_r(n, bn, mue, re, r)
c
c     Graham & Driver 2005, PASA, 22, 118,  eq. (5)
c     Calculate the total magnitude within radius r. 
c     gammain(x, p) = [1/gamma(p)] int_0^x exp(-t) * t**(p-1)*dt
c     therefore to calculate small_gamma of eq (3): 
c     small_gamma(x, 2n) = gamma(2n) * gammain(x,2n)
c
c     Note that because mue = -2.5 log(ie/area_e) then
c     -2.5*dlog10(flux[<=R]) = mag(<=R) - 2.5d0*dlog10(area_e) 
c
      implicit none
      double precision n, bn, mue, re, r, x
      double precision gammain, alngam, two_n, eps, pi
      integer chabu1, chabu2
      pi = dacos(-1.0d0)
c
      eps = 1.d-16
c
      if(r.eq.0.d0) then
         x        = bn * (eps/re)**(1.d0/n)
      else
         x        = bn * (r/re)**(1.d0/n)
      end if
c
      two_n    = 2.d0 * n
c
      mag_to_r = dexp(alngam(two_n,chabu1)) * gammain(x,two_n,chabu2)
c      mag_to_r = gammain(x,two_n,chabu2)
      mag_to_r = mag_to_r * 2.d0 * dacos(-1.0d0) * n 
      mag_to_r = mag_to_r * dexp(bn)/(bn**two_n)
      mag_to_r = 2.5d0*dlog10(mag_to_r)
      mag_to_r = mue - 5.d0*dlog10(re) - mag_to_r
c     so this is equivalent to -2.5 * dlog10(L<r) need to add
c     -2.5d0 dlog10(pi) 
c     IF the mean effective surface brightness is used
      mag_to_r = mag_to_r - 2.5d0*dlog10(pi)
      return
      end
c
c-----------------------------------------------------------------------
c
      double precision function total_mag(n, bn, ie, re)
c
c     Calculate the total magnitude following eq (5) of
c     Graham & Driver 2005, PASA, 22, 118,
c     replacing small_gamma(x, 2n) = gamma(2n) * gammain(x,2n)
c     with gamma(2n)
c
      implicit none
      double precision n, bn, ie, re
      double precision alngam, two_n
      integer chabu1
      two_n    = 2.d0 * n
      total_mag = dexp(alngam(two_n,chabu1))
      total_mag = total_mag * 2.d0 * dacos(-1.0d0) * n 
      total_mag = total_mag * dexp(bn)/(bn**two_n)
      total_mag = ie * re * re * total_mag
      total_mag = -2.5d0*dlog10(total_mag)
      return
      end
c
c-----------------------------------------------------------------------
c
      double precision function ie_sersic(magnitude, re, n, bn, 
     *     axial_ratio)
c
c     Find value of the intensity at the effective radius given 
c     a Sersic profile (N) and total magnitude. Both Ie and Ie are 
c     defined at half-light   radius so that
c     (Ltot/2)  = Ie * Re**2 * 2*pi*n*exp(bn) * gammainc(x,2*n)/(bn**(2*n))
c     (Graham & Driver 2005, PASA, 22, 118, eq. 2)
c     where  x= bn * (r/Re)**(1/n). As r== Re, then x  = bn  and
c     (Ltot/2)  = Ie * Re**2 * 2*pi*n*exp(bn) * gammainc(bn,2*n)/(bn**(2*n))
c
c     ie_sersic will have units of Jy arcsec**-2 or Jy kpc**-2
c
      implicit none
      double precision magnitude, re, n, axial_ratio
      double precision pi, bn, two_n, term, x
      double precision alngam, gammain
      integer chabu
      pi    = dacos(-1.0d0)
      two_n = 2.d0 * n
      term  = dexp(alngam(two_n,chabu))
      term  = term * gammain(bn,two_n,chabu)
      term  = term * 2.d0*pi*n*re*re
      term  = term * dexp(bn)/(bn**two_n)   
      ie_sersic = 0.5d0*(10.d0**(-0.4*magnitude))/term
      ie_sersic = ie_sersic * axial_ratio
      return
      end
