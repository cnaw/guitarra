      implicit none
      integer seed
      integer i, j, k, loop, ngroups, nframe, nskip, nexp,len
      real accum,group, image, flat, dark, noise, avexp, last
      double precision zbqlnor, readnoise
      double precision timestep, value, slope, sigmaa, texp, tframe,
     &     offset, sigmab, r, chi2, scratch, non_linear, counts, per_sec
     &     , gain, crval3, cdelt3
      dimension group(2,2), image(2,2), flat(2,2), dark(2,2), accum(2,2)
     &     , noise(2,2), timestep(108), value(108)
c     
      seed      = 0
      call zbqlini(seed)
      gain      = 1.85d0
      readnoise = 10.5d0
      per_sec   = 0.0d0
c     
      flat(1,1) = 1.00
      flat(1,2) = 1.00
      flat(2,1) = 1.00
      flat(2,2) = 1.00
c
      dark(1,1) =  0.02
      dark(1,2) =  0.02
      dark(2,1) =  0.02
      dark(2,2) =  0.02
c
      noise(1,1) = 0.0d0
      noise(1,2) = 0.0d0
      noise(2,1) = 0.0d0
      noise(2,2) = 0.0d0
c
      accum(1,1) = 0.0
      accum(1,2) = 0.0
      accum(2,1) = 0.0
      accum(2,2) = 0.0
c
      dark(1,1) =  0.00
      dark(1,2) =  0.00
      dark(2,1) =  0.00
      dark(2,2) =  0.00     
c
      ngroups =  7
      nframe  =  8
      nskip   = 12
c
      texp       = 0.0d0
      tframe     = 10.73677d0
      crval3     =  -tframe *(nskip+(nframe/2.0))
      cdelt3     =  (nframe+nskip)*tframe
      counts     =  per_sec * tframe ! counts per frame
      counts     =  idint(counts) ! counts per frame
c
      do j = 1, 2
         do i = 1, 2
            group(i,j) = 0.0
         end do 
      end do
c
c     image will contain the "real" counts - i.e., all photon events
c     accumulated by the detector
c
      do j = 1, 2
         do i = 1, 2
            image(i,j) = 0.0
         end do
      end do
c     
      nexp       = 0
      last       = 0.0
      avexp      = 0.0
c
c     accumulate charge for a group
c
      do k = 1, ngroups
c
c     noise will hold noise counts due to detector (i.e., dark current,
c     readout noise, 1/f noise), which are not flatfielded
c
c     accum will hold the counts due to object + background + cosmic rays 
c     (i.e., sources external to the detector, which are flatfielded)
c     Must be initialised at the beginning of each group
         do j = 1, 2
            do i = 1, 2
               accum(i,j) = 0.0
            end do
         end do
c     
         avexp = 0.0
c
c     Accumulate charge for each group; loop over the number of 
c     detector cycles that are read out (nframe) and skipped 
c
         print 20
 20      format(12x,'frame N',4x,'t_ramp',6x,'image',
     &        6x,'accum',6x,'noise')
         do loop = 1, nframe+ nskip
c
c     add dark current (+ 1/f noise etc)
c
            do j = 1, 2
               do i = 1, 2
                  noise(i,j) = noise(i,j) + dark(i,j)
               end do
            end do
c
c     add charge due to sources
c
            do j = 1, 2
               do i = 1, 2
                  image(i,j) = image(i,j) + counts
               end do
            end do
c
c     keep track of the number of exposures and exposure time since
c     beginning of ramp
c
            nexp = nexp + 1
            texp = texp + tframe
c
c     the time step correspondong to each group will be the average of
c     times corresponding to each frame that is readout
            avexp = avexp + texp
c
c     These are only added to frames that are read out
c
            if(loop.le.nframe) then
               do j = 1, 2
                  do i = 1, 2
                     noise(i,j) = noise(i,j) + zbqlnor(0.0d0,readnoise)
c     total counts up to now assuming all is linear
                     scratch    =  image(i,j)*flat(i,j) + noise(i,j)
c
c     non-linearity distortion should come here,affecting image + noise
c     before accumulation
c
c                     if(scratch.gt.32000.d0) then
c                        non_linear = 32000.d0
c                     else
                        non_linear = scratch
c                     end if
                     accum(i,j) = accum(i,j) + non_linear
                  end do
               end do
               print 140, loop, nexp, texp,
     &              image(2,2),accum(2,2), noise(2,2)
 140           format('loop, cycle',2i4,10(1x,f10.3))
c     
c     once last frame in a group is read out, calculate the average
c     charge in the detector and the corresponding time step
c     (which is also an average)
c
               if(loop.eq.nframe) then
                  avexp = nframe * tframe
                  avexp = avexp/(nframe)
                  avexp = crval3 + k*cdelt3
                  print *,' '
                  print 145
 145              format(14x,'group',4x,'avexp',3x,'accum(i,j)',
     &                 1x,'scratch   ','nframe')
                  do j = 1, 2
                     do i = 1, 2
                        scratch    = accum(i,j)
                        accum(i,j) = scratch/nframe
                     end do
                     print 150, k, avexp, (accum(i,j), i =2,2),scratch
     &                    , nframe
 150                 format('accum',10x,i4,3(1x,f10.3),i8)
                  end do
                  timestep(k) = avexp
                  value(k)    = accum(2,2)! /gain
                  len         = k
c
c     if this is the last frame read out in a ramp, exit loop
c     (skipped frames are ignored in the last ramp)
c
                  if(k.eq.ngroups) go to 100
               end if
            end if
         end do   
c
c     calculate the total accumulated in group up to this point
c
 100     print *,' '
         do j = 1, 2
            do i = 1, 2
               group(i,j) =  accum(i,j)/gain
            end do
c            print 160, k,  (group(i,j), i =1,2)
 160        format('group',9x,i4,10(1x,f10.3))
         end do
         print *,' '
      end do
c
c     once the loop over groups is completed, we have finished with this
c     ramp. As a sanity check, calculate the average rate for this ramp
c
      print *, 'nexp,avexp ', nexp, avexp, crval3, cdelt3
      print *,' '
      do j = 1, 2
         print *,'rate ', (group(i,j)/avexp, i =1,2),(image(1,j)/nexp)
      end do
      print *,'ramp: k     time     e-        ADU'

      do k = 1, len
         print 180, k, timestep(k), value(k),value(k)/gain
 180     format(i8,5(2x,f10.4))
      end do
      call linfit(timestep, value, len, offset, sigmaa, slope, sigmab,
     &     r, chi2)
      print *,'fit  e_ : slope +/- offset +/-  r  Chi**2 '
      print 190, slope, sigmaa, offset, sigmab, r, chi2
      print *,'fit ADU : slope +/- offset +/-  r  Chi**2 '
      print 190, slope/gain, sigmaa/gain, offset/gain, 
     &     sigmab/gain, r, chi2
 190  format(6(2x,f8.3))
      stop
      end

      SUBROUTINE LINFIT(X,Y,LEN,A,SIGMAA,B,SIGMAB,R,CHI2)
      implicit double precision (A-H, O-Z)
      DOUBLE PRECISION SUM,SUMX,SUMY,SUMX2,SUMY2,SUMXY,VAR,C,XI,YI,DELTA
      DIMENSION X(LEN),Y(LEN)
C     OPEN (10,FILE='AJUSTE.DA')
      SUM=dble(LEN)
      SUMX2=0.0d0
      SUMXY =0.0d0
      SUMX =0.00d0
      SUMY =0.00d0
      SUMY2 =0.0d0
      DO  J=1,LEN
         XI=X(J)
         YI=Y(J)
         SUMX =SUMX +XI
         SUMY =SUMY +YI
         SUMY2 =SUMY2+YI*YI
         SUMX2 =SUMX2 +XI*XI
         SUMXY =SUMXY+XI*YI
      END DO
C
C     CALCULO DOS COEFICIENTES DE AJUSTE
C     
      IF(SUM .LT.3.00) GO TO 60
      DELTA=SUM*SUMX2-SUMX*SUMX 
      A=(SUMX2*SUMY-SUMX*SUMXY)/DELTA
      B=(SUMXY*SUM-SUMX*SUMY)/DELTA
      C=SUM -2.00d0
      VAR=(SUMY2+A*A*SUM+B*B*SUMX2-2.0d0*(A*SUMY+B*SUMXY-A*B*SUMX))/C
      SIGMAA=DSQRT(VAR*SUMX2/DELTA)
      SIGMAB=DSQRT(VAR*SUM/DELTA)
      R=(SUM*SUMXY-SUMX*SUMY)/DSQRT(DELTA*(SUM*SUMY2-SUMY*SUMY))
C     
C     CALCULO DA DISPERSAO DO AJUSTE
C     
        SUM=0.00
        C=FLOAT(LEN)-2.0d0
        DO 40 J=1,LEN
           XI=X(J)
           XI=Y(J)-(A+B*XI)
           YI=XI*XI
        SUM=SUM+YI
 40   CONTINUE
      CHI2=DSQRT(SUM/C)
c      WRITE(*,50) LEN,A,SIGMAA,B,SIGMAB,R,CHI2
 50   FORMAT(I5,4(1X,1pe11.4),2(1X,0pf11.4))
 60   RETURN
c     CLOSE (10)
      END 
