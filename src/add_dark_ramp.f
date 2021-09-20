c      implicit none
c      double precision gain
c      real noise
c      integer sca,  colcornr, rowcornr, naxis1, naxis2, verbose, 
c     &     read_number
c      integer ii, jj, kk, seed
c      dimension noise(2048, 2048)
c      character dark_file*180, subarray*20
c      dark_file = '/home/cnaw/guitarra/NRCNRCBLONG-DARK-60270226121_1_49
c     &0_SE_2016-01-27T02h51m47.fits'
c      naxis1 = 2048
c      naxis2 = 2048
c      gain   = 1.85d0
c      do jj = 1, naxis2
c         do ii = 1, naxis1
c            noise(ii,jj) = 0.0
c         end do
c      end do
c      seed = 0
c      call zbqlini(seed)
c      sca     = 490
c      verbose = 3
c      open(11,file='/home/cnaw/guitarra/dark_counts.dat')
c      do kk = 1, 128
c         read_number = kk
c         call add_dark_ramp(sca, noise, gain,
c     &        subarray, colcornr, rowcornr, naxis1, naxis2,
c     &        read_number,dark_file, verbose)
c         print *,'kk',read_number,  noise(2,2), noise(1020, 1020)
c         write(11, *) read_number,  noise(2,2), noise(1020, 1020)
c      end do
c      close(11)
c      read_number = -1
c      call add_dark_ramp(sca, noise, gain,
c     &     subarray, colcornr, rowcornr, naxis1, naxis2,
c     &     read_number,dark_file, verbose)
c      stop
c      end
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c     Add data from ISIM CV3 dark ramps
c     cnaw@as.arizona.edu
c     2020-05-11
c
      subroutine add_dark_ramp(sca, noise, gain,
     &     subarray, colcornr, rowcornr, naxis1, naxis2,
     &     read_number,dark_file, verbose)
      implicit none
      double precision zbqluab, gain
      real noise
      integer dark
      integer sca,  colcornr, rowcornr, naxis1, naxis2, verbose, 
     &     read_number
      integer iunit, naxes, naxis, nnn, ii, jj, fpixels, lpixels, incs,
     &     bitpix, status, group, block, nfound, null, nd, pick, i, j
      character dark_file*(*), comment*40, guitarra_aux*100,list*180,
     &     dark_list*20, darks*180
      character subarray*(*)
      logical chabu
c
      parameter(nnn=2048)
c
      dimension noise(nnn,nnn), dark(nnn,nnn), fpixels(3),
     *     lpixels(3), incs(3), naxes(3), darks(50) 

      save iunit, naxis, naxes

      if(read_number .eq. -1) then
         call closefits(iunit)
         return
      end if
c
      status = 0
      if(read_number.eq.1) then
c
c     read list of dark ramps for this SCA
c
c        write(dark_list, 110) sca
c 110    format(i3,'_dark.list')
c        print 120, dark_list
c        call getenv('GUITARRA_AUX',guitarra_aux)
c        print 120, dark_list
c        print 120, guitarra_aux
c        list = guitarra_aux(1:len_trim(guitarra_aux))//dark_list
c        print 120, list(1:len_trim(list))
c        open(66,file=list)
c        nd = 0
c        do ii = 1, 50
c           read(66,120,end=150) darks(ii)
c 120       format(a180)
c           nd = nd + 1
cc           print 120, darks(ii)
c        end do
c        nd = nd -1
c 150    close(66)
cc     
cc     Pick one randomly
cc
c        pick = idnint(zbqluab(1.0d0,dble(nd)))
c        dark_file = 
c     &       guitarra_aux(1:len_trim(guitarra_aux))//darks(pick)
c        print 160, pick, dark_file
c 160    format(i3,2x,a180)
c     
c     read dark ramp
c     
        call ftgiou(iunit, status)
         if (status .gt. 0) then
            print *,'add_dark_ramp: ftgiou'
            call printerror(status)
            stop
         end if
         call ftopen(iunit, dark_file, 0, block, status)
         if (status .gt. 0) then
            print *,'dark_file ', dark_file
            print *,'add_dark_ramp: ftopen',status
            call printerror(status)
            stop
         end if
         call ftgkyj(iunit,'BITPIX',bitpix,comment, status)
         if (status .gt. 0) then
            print *,'add_dark_ramp: ftgkyj: bitpix',bitpix
            call printerror(status)
            stop
         end if

         call ftgkyj(iunit,'NAXIS',naxis,comment, status)
         if (status .gt. 0) then
            print *,'add_dark_ramp: ftgkyj: naxis',naxis
            call printerror(status)
            stop
         end if
         call ftgknj(iunit,'NAXIS',1,3,naxes,nfound,status)
          if(status .ne.0) then
            print *,'add_dark_ramp: ftgknj:NAXIS',status,nfound
            call printerror(status)
            print *, naxis, naxes
            stop
         end if
         if(verbose.ge.2) print *,'add_dark_ramp: iunit, bitpix',
     &        iunit, bitpix, naxis, naxes
      end if
c
      group=1
      incs(1)    = 1
      incs(2)    = 1
      incs(3)    = 1
c
      fpixels(1) = 1
      lpixels(1) = naxes(1)
      fpixels(2) = 1
      lpixels(2) = naxes(2)

      if(read_number.gt.naxes(3)) then
c         print *,'add_dark_ramp:read_number > naxes(3) exiting',
c     &        read_number, naxes(3)
c     get a random read 
         pick = idnint(zbqluab(dble(naxes(3)-30),dble(naxes(3))))
         fpixels(3) = pick
         lpixels(3) = pick
      else
         fpixels(3) = read_number
         lpixels(3) = read_number
      end if

      call ftgsvj(iunit, group, naxis, naxes, fpixels, lpixels, 
     *     incs, null, dark, chabu, status)
      if (status .gt. 0) then
         print *,'add_dark_ramp ', naxes(1), naxes(2), naxes(3)
         print *,'fpixels, lpixels', fpixels, lpixels
         print *,'at ftgsvj '
         call printerror(status)
         stop
      end if
      do j = 1, naxis2
         jj = j + rowcornr-1
         do i = 1, naxis1
            ii = i + colcornr -1
c            noise(ii,jj) = noise(ii,jj) + dark(ii,jj)
            noise(i,j) = dark(ii,jj)*gain
         end do
c         if(mod(j,16).eq.1) print *,'dark_ramp ', j,j,noise(j,j)
      end do
      return
      end

