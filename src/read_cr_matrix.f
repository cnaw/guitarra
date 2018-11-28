c      character channel*2
c      parameter(ncr = 21)
c      dimension cr_matrix(ncr,ncr,10000),tarray(2)
cc      
c      common /cr_list/ cr_matrix, cr_flux
cc
c      call cpu_time(cpu_start)
c      channel = 'LW'
c      mode    =   3
c      call read_cr_matrix(channel, mode)
cc     do i = 1, 10000, 100
cc        print *, i, cr_matrix(11,11,i)
cc     end do
c      call etime(tarray,time)
c      call cpu_time(cpu_finish)
c      print *,' execution time', time,'  user time ', tarray(1),
c     *     '  system time ',tarray(2)
c      print *, 'cpu time ', cpu_finish - cpu_start
c      stop
c      end
c
c----------------------------------------------------------------------
c
      subroutine read_cr_matrix(mode, sca_id)
c
c     Read simulated rates of CR hits calculated by Massimo Robberto
c     for HgCdTe detectors. The intensity is measured in electrons.
c     The description of these simulations can be found in the 
c     Technical Report: Robberto, M.  2009, JWST-STScI-001928, SM-12
c
c     cr_flux   - is the number of Cosmic Ray hits per second for
c                 different models (solar min, solar max, flare)
c     cr_matrix - is the image of CRs in units of hits/sec/cm**2
c
c     cnaw 2015-01-26
c     Steward Observatory, University of Arizona
c
      implicit none
      double precision wl
      real cr_matrix, cr_flux, cr_accum, rate, fnull, temp
c
      integer mode, sca_id, naxes, fpixels, lpixels, incs, i, j, level,
     *     l, m, status, group, hdutype, nhdu, naxis, ncr, indx, iunit,
     *     n_cr_levels
c
      character activity*6, channel*2,filename*80, comment*30
c
      logical anyf
c
      parameter(ncr = 21)
      dimension temp(ncr,ncr),naxes(3), fpixels(3), lpixels(3), incs(3)
      dimension cr_matrix(ncr,ncr,10000),cr_flux(10000),cr_accum(10000)
c      
      common /cr_list/ cr_matrix, cr_flux,cr_accum, n_cr_levels
c
      fnull = 0.00
      wl = 2.50d0
      wl = 1.70d0
      if(sca_id .eq.485 .or.sca_id.eq.490) wl  = 5.5d0
c     
      if(mode.eq.1) then
         activity = 'SUNMIN'
         rate     = 4.8983   ! events per second
      end if
      if(mode.eq.2) then
         activity = 'SUNMAX'
         rate  = 1.7783
      end if      
      if(mode.eq.3) then
         activity = 'FLARES'
         rate  = 3046.83
      end if
c     
      status  = 0
      iunit   = 90
      group   = 0
      fpixels(1) = 1
      fpixels(2) = 1
      lpixels(1) = ncr
      lpixels(2) = ncr
      incs(1)    = 1
      incs(2)    = 1
      incs(3)    = 1
      nhdu       = 2
c
      n_cr_levels = 10000
c
      indx = 0
      do i = 1, 10
         j = i-1
         write(filename,10) wl,activity,j
 10      format('./cr_robberto/CRs_MCD',f3.1,'_',a6,'_',i2.2,'.fits')
         print 20, filename
 20      format(a50)
         call ftgiou(iunit, status)
         call ftiopn(iunit, filename,0,status)
         call ftgkyj(iunit,"NAXIS",naxis,comment, status)
         call ftgkyj(iunit,"NAXIS1",naxes(1),comment, status)
         call ftgkyj(iunit,"NAXIS2",naxes(2),comment, status)
         call ftgkyj(iunit,"NAXIS3",naxes(3),comment, status)
c 
         do level = 1, naxes(3)
            status  = 0
            fpixels(3) = level
            lpixels(3) = level
            call ftgsve(iunit, group, naxis, naxes, fpixels, lpixels, 
     *           incs, fnull, temp, anyf, status)
            if (status .gt. 0) then 
               call printerror(status)
            endif
c            indx = (j-1) * 1000 + level
            indx = indx + 1
            do m = 1, ncr
               do l = 1, ncr
                  cr_matrix(l,m,indx) = temp(l,m)
               end do
               cr_flux(indx) = rate
            end do
         end do
         call closefits(iunit)
c         print *,i, level, indx
      end do
c      print *,i, level, indx
      return
      end
