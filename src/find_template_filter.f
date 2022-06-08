c     Given a galaxy with redshift z_obs and observed with a filter
c     centred at lambda_obs, find the  lambda_sim for the best
c     matching filter when the galaxy is simulated at redshift z_sim.
c     Following  Papovich+ 2003 ApJ, 598,287, mathematically
c     the best matching filter is that which minimises
c     abs[lambda_sim/(1+zsim) -  lambda_obs/(1+zobs)]
c     
c-----------------------------------------------------------------------
c
      subroutine find_template_filter(z_obs, z_sim, wl_nrc, nrc_name,
     &     template_wl, template_filter, nf, psf_conv, closest,
     &     verbose)
      implicit none
      double precision z_obs, z_sim, wl_nrc, wl_z
      double precision template_wl, lambda_emitted
      integer nf, verbose
      character template_filter*6, nrc_name*6
c
      integer ii, jj, closest
      double precision zplus1, dlambda, dmin
      character psf_conv*(*)
c
      dimension template_wl(nf), template_filter(nf)
c
      wl_z   = wl_nrc / (1.d0+z_sim)
      zplus1 = z_obs + 1.0d0
c
      dmin = 100.d0
      do ii = 1, nf
         dlambda  = dabs(wl_z - template_wl(ii)/zplus1)
         if(verbose.gt.1) then
            print *,'find_template_filter ', 
     &           wl_nrc, wl_z, template_wl(ii)* zplus1, dlambda,
     &           template_filter(ii)
         end if
c         if(dlambda.lt.0.d0.and. dabs(dlambda).gt.dmin*1.50) go to 90
         if(dlambda .le. dmin) then
            dmin = dlambda
            closest = ii
         end if
      end do
 90   continue
      if(verbose.gt.0)
     &     print *,'find_template_filter: closest ',
     &     template_filter(closest), ' ',trim(nrc_name)
c      write(psf_conv,100) trim(template_filter(closest)), trim(nrc_name)
c 100  format('corr_',A,'_',A,'.fits')
c      if(verbose.gt.1) then
c         print 120, wl_nrc, template_wl(closest), 
c     &        template_wl(closest)*zplus1, dmin, trim(psf_conv)
c 120     format('find_template_filter: best match is ',4(1x,f9.4),2x,A)
c      end if
      return
      end
