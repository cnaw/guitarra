c      parameter(ncr = 21)
c      dimension tarray(8)
c      dimension cr_matrix(ncr,ncr,10000),cr_flux(10000),cr_accum(10000),
c     &     ion(10000), mev(10000)
cc      
c      common /cr_list/ cr_matrix, cr_flux,cr_accum, n_cr_levels,
c     &     ion, mev
cc
cc
c      call cpu_time(cpu_start)
c      mode    =   1
c      call read_cr_matrix(mode, 485, 1)
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
      subroutine read_cr_matrix(mode, sca_id, verbose)
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
c     cnaw 2019-10-29 added ion and energy level arrays, set arrays to
c                     5.5 microns depth
c     cnaw 2021-07-14 add verbose keyword
c     Steward Observatory, University of Arizona
c
      implicit none
      double precision wl
      real cr_matrix, cr_flux, cr_accum, rate, fnull, temp, rate_el,
     &     mev, energy
c
      integer mode, sca_id, naxes, fpixels, lpixels, incs, i, j, level,
     *     l, m, status, group, hdutype, nhdu, naxis, ncr, indx, iunit,
     *     n_cr_levels, ion,  iii, null, verbose
c
      character activity*6, channel*2,filename*80, comment*30
c
      logical anyf
c
      parameter(ncr = 21)
      dimension temp(ncr,ncr),naxes(3), fpixels(3), lpixels(3), incs(3),
     &     rate_el(6), iii(1000), energy(1000)
      dimension cr_matrix(ncr,ncr,10000),cr_flux(10000),cr_accum(10000),
     &     ion(10000), mev(10000)
c      
      common /cr_list/ cr_matrix, cr_flux,cr_accum, n_cr_levels,
     &      ion, mev
c
      fnull = 0.00
      null  = -9999
      wl = 2.50d0
c     all NIRCam detectors have 5.5 depths
      wl = 5.50d0
c      if(sca_id .eq.485 .or.sca_id.eq.490) wl  = 5.5d0
c     
      if(mode.eq.1) then
         activity = 'SUNMIN'
         rate       = 4.8983    ! events per second for all ions
         rate_el(1) = 4.4626    ! H
         rate_el(2) = 0.4106    ! He
         rate_el(3) = 0.0108    ! C
         rate_el(4) = 0.0029    ! N
         rate_el(5) = 0.0103    ! O
         rate_el(6) = 0.0011    ! Fe
      end if
      if(mode.eq.2) then
         activity = 'SUNMAX'
         rate  = 1.7783
         rate_el(1) = 1.5782    ! H
         rate_el(2) = 0.1882    ! He
         rate_el(3) = 0.0051    ! C
         rate_el(4) = 0.0014    ! N
         rate_el(5) = 0.0048    ! O
         rate_el(6) = 0.0006    ! Fe
      end if      
      if(mode.eq.3) then
         activity = 'FLARES'
         rate  = 3046.83
         rate_el(1) = 3033.4    ! H
         rate_el(2) = 13.300    ! He
         rate_el(3) = 0.0322    ! C
         rate_el(4) = 0.0093    ! N
         rate_el(5) = 0.0664    ! O
         rate_el(6) = 0.0112    ! Fe
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
c     Read the 10 files associated to each Cosmic Ray level
c     units are electrons
c
      indx = 0
      do i = 1, 10
         j = i-1
         write(filename,10) wl,activity,j
 10      format('./data/cr_robberto/CRs_MCD',
     &        f3.1,'_',a6,'_',i2.2,'.fits')
         if(verbose.gt.0) print 20, filename
 20      format('read_cr_matrix :', a50)
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
c
c     read second extension which contains the Ion ID
c
         call ftmrhd(iunit,1, hdutype, status)
c         if(verbose .gt.1) print *, 'read_cr_matrix:hdutype 1', hdutype
         call ftgpvj(iunit, group, 1, naxes(3), null, iii, anyf, status)
         do level = 1, naxes(3)
            indx = j*1000+ level
            ion(indx) = iii(level)
         end do
c
c     read third extension which contains the CR energy in Mev
c
         call ftmrhd(iunit,1, hdutype, status)
c         if(verbose .gt.1) print *, 'read_cr_matrix:hdutype 2', hdutype
         call ftgpve(iunit, group, 1, naxes(3), null, energy, 
     &        anyf, status)
         do level = 1, naxes(3)
            indx = j*1000+ level
            mev(indx) = energy(level)
         end do
c
         call closefits(iunit)
c         print *,i, level, indx
      end do
c      print *,i, level, indx
      return
      end
