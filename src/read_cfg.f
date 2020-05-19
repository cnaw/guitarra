c      implicit none
c      double precision gain, readnoise
c      integer sca_num, sca_id, ii, jj
c      character cfg_files*180, files*180, guitarra_aux*100,
c     &     line*180, junk*20, filename*180
c      character gainfile*180, ipckernelfile*180,
c     &     welldepthfile*180, linearityfile*180,
c     &     biasfile*180, badpixelmask*180
c      dimension cfg_files(10)
cc
c      do sca_id = 481, 490
c         call read_cfg(sca_id, biasfile, welldepthfile, gainfile, 
c     &        linearityfile, badpixelmask,ipckernelfile)
c         print 60, badpixelmask
c         print 60, biasfile
c         print 60, linearityfile
c         print 60, welldepthfile
c         print 60, ipckernelfile
c         print 60, gainfile
c 60      format(A100)
c      end do
c      stop
c      end
c=======================================================================
      subroutine read_cfg(sca_id, biasfile, welldepthfile, gainfile, 
     &     linearityfile, badpixelmask,ipckernelfile)
      implicit none
      double precision gain, readnoise
      integer sca_num, sca_id, ii, jj
      character cfg_files*180, files*180, guitarra_aux*100,
     &     line*180, junk*20, filename*180
      character biasfile*(*), welldepthfile*180, gainfile*(*),
     &     linearityfile*(*), badpixelmask*(*), ipckernelfile*(*)
      dimension cfg_files(10)
c
      data cfg_files/
     &     'NRCA1_17004_SW_ISIMCV3.cfg',
     &     'NRCA2_17006_SW_ISIMCV3.cfg',
     &     'NRCA3_17012_SW_ISIMCV3.cfg',
     &     'NRCA4_17048_SW_ISIMCV3.cfg',
     &     'NRCA5_17158_LW_ISIMCV3.cfg',
     &     'NRCB1_16991_SW_ISIMCV3.cfg',
     &     'NRCB2_17005_SW_ISIMCV3.cfg',
     &     'NRCB3_17011_SW_ISIMCV3.cfg',
     &     'NRCB4_17047_SW_ISIMCV3.cfg',
     &     'NRCB5_17161_LW_ISIMCV3.cfg'/
      sca_num = sca_id - 480
      filename = '/home/cnaw/guitarra/SCAConfig/'//cfg_files(sca_num)
      print *,' '
      print 60, filename
      open(33,file=filename)
      do ii = 1, 30
         read(33,60,end=200) line
 60      format(A100)
         read(line, 70) junk
 70      format(a20)
c         print 70, junk(1:9)
         if(junk(1:1) .eq.'#') go to 190
         if(junk(1:1) .eq.'[') go to 190
         if(junk(1:1) .eq.' ') go to 190
         if(junk(1:5) .eq. 'Gain=') then
            read(line, 80) gain
 80         format(5x,f4.2)
         end if
         if(junk(1:10) .eq. 'Read Noise') then
            if(junk(1:13) .eq. 'Read Noise=RN') go to 190
            read(line, 90) readnoise
 90         format(11x,f4.1)
         end if
         if(junk(1:8) .eq. 'BPM Mask') then
            read(line, 100) badpixelmask
 100        format(9x,a100)
         end if
         if(junk(1:10) .eq. 'Bias Image') then
            read(line, 110) biasfile
 110         format(11x,a100)
         end if
         if(junk(1:15) .eq. 'Linearity Image') then
            read(line, 120) linearityfile
 120         format(16x,a100)
         end if
c     Well Depth Image
c     1234567890123456
         if(junk(1:16) .eq. 'Well Depth Image') then
            read(line, 130) welldepthfile
 130         format(17x,a100)
         end if
         if(junk(1:10) .eq. 'IPC Kernel') then
            read(line, 110) ipckernelfile
         end if
         if(junk(1:8) .eq. 'Gain Map') then
            read(line, 140) gainfile
 140        format(9x, a100)
         end if
 190     continue
      end do
 200  close(33)
c      print  *, 'gain, readnoise', gain, readnoise
      return
      end
