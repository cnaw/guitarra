      subroutine read_sca_calib(sca_id, verbose)
c
c     read calibration files for SCAs. These are the bias,
c     linearity, dark current and well-depth.
c     
c     Updated to use ISIM CV3 values for calibrations and noise
c     cnaw@as.arizona.edu
c     2016-05-04
c     Using new style of everything
c     2017-05-03
      implicit none
      double precision gain, 
     *     decay_rate, time_since_previous, read_noise, 
     *     dark_mean, dark_sigma, ktc, bias_level, voltage_offset
      double precision ave, gain_pix, linearity_gain, lincut,
     *     well_fact, well_max, gain_max, ave_well,sum2
c
      real accum, gain_image,base_image, dark_image,
     *     well_depth, bias, linearity, temp
c
      integer nnn, nz, sca_id, i, j, l, ii, jj, nwell,
     *     ngx, ngy, nbx, nby, nwx, nwy, max_order, order, good,
     &     m, n, verbose
      character filename*180, partname*5, guitarra_aux*120

      character darkfile*180, flatfile*180, biasfile*180, file*180,
     *     gainfile*180, sigmafile*180, WellDepthFile*180,
     *     linearityfile*180, badpixelmask*180
      character darkfile_r*180, biasfile_r*180, sigmafile_r*180,
     *     gainfile_r*180, linearityfile_r*180, badpixelmask_r*180,
     *     WellDepthFile_r*180
c
      parameter (nnn=2048,nz=30,max_order=7)
c
      dimension  accum(nnn,nnn), gain_image(nnn,nnn),
     *     base_image(nnn,nnn), dark_image(nnn,nnn,2),
     *     well_depth(nnn,nnn), linearity(nnn,nnn,max_order),
     *     bias(nnn,nnn)
c
      dimension dark_mean(10), dark_sigma(10), gain(10),
     *     read_noise(10), ktc(10), voltage_offset(10)
c 
      common /base/ base_image
      common /dark_/ dark_image
      common /gain_/ gain_image
      common /well_d/ well_depth, bias, linearity,
     *     linearity_gain,  lincut, well_fact, order
      common /parameters/ gain, 
     *     decay_rate, time_since_previous, read_noise, 
     *     dark_mean, dark_sigma, ktc, voltage_offset
      
      if(sca_id .le.0) then
         if(verbose.gt.0) print 10, sca_id
 10      format('read_sca_calib : ', i4)
         do j = 1, nnn
            do i = 1, nnn
               gain_image(i,j)   = gain(1)
               dark_image(i,j,1) = dark_mean(1)
               dark_image(i,j,2) = dark_sigma(1)
               well_depth(i,j)   = 65534.0
               gain_image(i,j)   = 1.0
               accum(i,j)        = 0.0
               base_image(i,j)   = 0.0
            end do
         end do
         return
      else
         call get_sca_id(sca_id, partname)
          if(verbose.gt.0) print 20, sca_id, partname
 20      format('read_sca_calib : ', i4,' = ', a5,2x,a180)
c     
c     calibration images
c     
         write(file,25) sca_id
 25      format(i3,'_calib.list')
c     
         call getenv('GUITARRA_AUX',guitarra_aux)
         file = guitarra_aux(1:len_trim(guitarra_aux))//file
         open (1,file=file)
c         read(1,30)  flatfile
         read(1,30)  biasfile_r
         read(1,30)  badpixelmask_r
         read(1, 30) darkfile_r
         read(1,30)  sigmafile_r
         read(1,30)  gainfile_r
         read(1,30)  linearityfile_r
         read(1,30)  WellDepthFile_r
         biasfile = guitarra_aux(1:len_trim(guitarra_aux))//biasfile_r
         badpixelmask = guitarra_aux(1:len_trim(guitarra_aux))
     +                    //badpixelmask_r
         darkfile = guitarra_aux(1:len_trim(guitarra_aux))//darkfile_r
         sigmafile = guitarra_aux(1:len_trim(guitarra_aux))
     +                    //sigmafile_r
         gainfile = guitarra_aux(1:len_trim(guitarra_aux))//gainfile_r
         linearityfile = guitarra_aux(1:len_trim(guitarra_aux))
     +                   //linearityfile_r
         WellDepthFile = guitarra_aux(1:len_trim(guitarra_aux))
     +                   //WellDepthFile_r
         if(verbose.gt.0) print 30, linearityfile
 30      format(a180)
         close(1)
c     
c======================================================================
c     
c     Read average dark and sigma (ADU)
c     
         do j = 1, nnn
            do i = 1, nnn
               dark_image(i,j,1) = 0.0
               dark_image(i,j,2) = 0.0
               base_image(i,j)   = 0.0
               accum(i,j)        = 0.0
               well_depth(i,j)   = 0.0
               gain_image(i,j)   = 0.0
               do l = 1, max_order
                  linearity(i,j,l) = 0.0
               end do
            end do
         end do
         if(verbose.gt.0) print 20, sca_id, partname, darkfile
c
c     Use ISIM CV3 values
c
         if(darkfile .eq. 'none') then
            do j = 1, 2048
               do i = 1, 2048
                  dark_image(i,j,1) = dark_mean(sca_id-480)
                  dark_image(i,j,2) = dark_sigma(sca_id-480)
               end do
            end do
         else
            call  read_fits(darkfile,base_image, nbx, nby, verbose)
             if(verbose.gt.0) print 20, sca_id, partname, sigmafile
            call  read_fits(sigmafile,accum, nbx, nby, verbose)
            do j = 1, nby
               do i = 1, nbx
                  temp              = base_image(i,j)
                  good              = 1
                  if(temp +0.0 .ne.temp) good =0
                  if(temp+1.0 .eq. temp) good = 0
                  if(temp .lt. 0.0) good = 0
                  if(good.eq.1) then
                     dark_image(i,j,1) = base_image(i,j)
                     dark_image(i,j,2) = accum (i,j)
                  else
                     ave = 0.0d0
                     sum2 = 0.d0
                     n   = 0
                     do jj = j-2,j+2
                        do ii = i-2, i+2
                           good = 1 ! Test each pixel for NaNs
                           temp = base_image(ii,jj)
                           if(temp.      ne.temp) good = 0
                           if(temp+1.0 .eq. temp) good = 0
                           if(temp .lt. 0.0) good = 0
                           if(good.eq.1) then
                              ave = ave + dble(base_image(ii,jj))
                              sum2 = sum2 + dble(base_image(ii,jj))**2
                              n = n + 1
                           end if
                        end do
                     end do
                     ave               = ave/n
                     dark_image(i,j,1) = real(ave)
                     dark_image(i,j,2) = dsqrt((sum2/n) - ave**2)
                  end if
               end do
            end do
         end if
c     
c     read bias file (ADU)
c     
         if(verbose.gt.0) print 20, sca_id, partname, biasfile
         call  read_funky_fits(biasfile,bias, nbx, nby,2,
     *        verbose)
c
c     read well depth (ADU)
c     
         if(verbose.gt.0) print 20, sca_id, partname,WellDepthFile
         call read_funky_fits(WellDepthFile, well_depth, nwx, nwy,2,
     *        verbose)
c
c     read gain (e-/ADU)
c     
         if(verbose.gt.0) print 20, sca_id, partname,gainfile
         call read_funky_fits(gainfile, gain_image, ngx, ngy,2, verbose)
         do j = 1, ngy
            do i = 1, ngx
               good = 1
               temp = gain_image(i,j)
cc     remove NaNs
c               if(temp.ne.temp) gain_image(i,j) = 0.0
cc     remove infinity
c               if(temp+1.0 .eq. temp) gain_image(i,j) = 0.0
cc     remove negative gains
c               if(temp .lt. 0.0) gain_image(i,j) = 0.0
c     remove NaNs
               if(temp.ne.temp) good = 0
c     remove infinity
               if(temp+1.0 .eq. temp) good = 0
c     remove negative gains
               if(temp .lt. 0.0) good = 0
c
               if(good.eq.0) then
                  ave = 0.0d0
                  n   = 0
                  do jj = j-2,j+2
                     do ii = i-2, i+2
                        good = 1 ! Test each pixel for NaNs
                        temp = gain_image(ii,jj)
                        if(temp.      ne.temp) good = 0
                        if(temp+1.0 .eq. temp) good = 0
                        if(temp .lt. 0.0) good = 0
                        if(good.eq.1) then
                           ave = ave + dble(gain_image(ii,jj))
                           n = n + 1
                        end if
                     end do
                  end do
                  gain_image(i,j) = real(ave/n)
               end if
            end do
         end do
c     
c     read linearity coefficients (ramp in e-)
c     
          if(verbose.gt.0) print 20, sca_id, partname, linearityfile
          call read_linearity(linearityfile, linearity, nnn, nnn,
     *         max_order, linearity_gain, order, lincut, well_fact,
     *         verbose)
      end if
      return
      end
