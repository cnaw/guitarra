c
c-----------------------------------------------------------------------
c     
      subroutine hmsdms(ra,rastring,dec,decstring )
      implicit double precision (a-h,o-z)
      character sign*1, rastring*(*), decstring*(*)
      if(ra .lt.0.d0)     ra = ra + 24.d0
      if(ra .gt. 24.d0)   ra = ra - 24.d0
      ir=idint(ra)
      ramin=(ra-dble(ir))*60.d000
      im=idint(ramin)
      rasec=(ramin-dble(im))*60.d000
      write(rastring,10) ir, im, rasec
 10   format(i2.2,':',i2.2,':',f7.4)
      if(rastring(7:12) .eq. '60.000') then
         im = im + 1
         if(im.eq.60) then
            im = 0
            ir = ir + 1
            if(ir.eq.24) ir = 0
         end if
         rasec = 0.0d0
         write(rastring,10) ir, im, rasec
      end if
      if(rastring(7:7) .eq.' ') rastring(7:7)='0'
c
c     Dec
c
      sign = '+'
      if(dec.lt.0.0d0) sign = '-'
      dec2=dabs(dec)
      idg=idint(dec2)
      decmin=(dec2-dble(idg))*60.d000
      im=idint(decmin)
      decsec=(decmin-dble(im))*60.d000
      write(decstring,20) sign,idg, im, decsec
 20   format(a1,i2.2,':',i2.2,':',f6.3)
      if(decstring(8:12) .eq. '60.000') then
         im = im + 1
         if(im.eq.60) then
            im = 0
            idg = idg + 1
         end if
         decsec = 0.0d0
         write(decstring,10) sign,idg, im, decsec
      end if
      if(decstring(8:8) .eq.' ') decstring(8:8)='0'
      return
      end             
c----------------------------------------------------------------------------
      double precision function getra(rt)
      double precision rs
      character rt*(*)
      read(rt,10) irh, irm, rs
 10   format(i2,':',i2,':',f6.3)
      getra = dble(irh) + dble(irm)/60.0d0 + rs/3600.d0
      return
      end
c----------------------------------------------------------------------------
      double precision function getdec(dt)
      double precision ds
      character dt*(*)
      read(dt,10) idg, idm, ds
 10   format(i2,':',i2,':',f5.2)
      getdec = dble(idg) + dble(idm)/60.0d0 + ds/3600.d0
      return
      end
