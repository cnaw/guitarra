c      implicit none
c      integer sca, verbose
cccccccccccccccccccccccccccccccccccccccccccccccccccccc
c      integer ideal_to_sci_degree, v_idl_parity,
c     &     sci_to_ideal_degree, det_sci_parity
c      double precision 
c     &     x_det_ref, y_det_ref,
c     &     x_sci_ref, y_sci_ref,
c     &     sci_to_ideal_x, sci_to_ideal_y,
c     &     ideal_to_sci_x, ideal_to_sci_y,
c     &     v3_sci_x_angle,v3_sci_y_angle,
c     &     v3_idl_yang,
c     &     det_sci_yangle
cc
c      double precision attitude_dir, attitude_inv,
c     &     aa, bb, ap, bp
c      integer a_order, b_order, ap_order, bp_order
cc
c      double precision
c     &     ra_ref, dec_ref, pa_v3, v2_ref, v3_ref,
c     &     ra_sca, dec_sca
cc     
c      double precision crpix1, crpix2, crval1, crval2,
c     &     cd1_1, cd1_2, cd2_1, cd2_2
c      character ctype1*15, ctype2*15
c      character cunit1*40,cunit2*40
cc 
c      dimension 
c     &     sci_to_ideal_x(6,6), sci_to_ideal_y(6,6), 
c     &     ideal_to_sci_x(6,6), ideal_to_sci_y(6,6)
c      dimension attitude_dir(3,3),attitude_inv(3,3),
c     &     aa(9,9), bb(9,9), ap(9,9), bp(9,9)
ccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c      sca  = 10
c      verbose = 1
c
c      call  read_siaf_parameters(sca, 
c     &     sci_to_ideal_x, sci_to_ideal_y, sci_to_ideal_degree,
c     &     ideal_to_sci_x, ideal_to_sci_y, ideal_to_sci_degree,
c     &     x_det_ref, y_det_ref, x_sci_ref, y_sci_ref,
c     &     det_sci_yangle, det_sci_parity,
c     &     v3_idl_yang, v_idl_parity, v2_ref, v3_ref,
c     &     verbose)
cc     
c      call prep_wcs(
c     &     sci_to_ideal_x, sci_to_ideal_y, sci_to_ideal_degree,
c     &     ideal_to_sci_x, ideal_to_sci_y, ideal_to_sci_degree,
c     &     x_det_ref, y_det_ref, x_sci_ref, y_sci_ref,
c     &     det_sci_yangle, det_sci_parity,
c     &     v3_idl_yang, v_idl_parity, v2_ref, v3_ref,
c     &     crpix1, crpix2,
c     &     crval1, crval2,
c     &     ctype1, ctype2,
c     &     cunit1, cunit2,
c     &     cd1_1, cd1_2, cd2_1, cd2_2,
c     &     ra_ref, dec_ref, pa_v3,
c     &     a_order, aa, b_order, bb,
c     &     ap_order, ap, bp_order, bp, 
c     &     attitude_dir, attitude_inv,
c     &     ra_sca, dec_sca,
c     &     verbose)
cc
c      stop
c      end
c======================================================================
c----------------------------------------------------------------------
c
c     Make sure to have the latest  SIAF/pysiaf PRDOPSSOC-XXX version.
c     This can usually be obtained by updating pysiaf and then searching 
c     for the xlsx file in the anaconda tree:
c/home/cnaw/anaconda3/lib/python3.7/site-packages/pysiaf/prd_data/JWST/PRDOPSSOC-029/SIAFXML/Excel/NIRCam_SIAF.xlsx
c     which is translated into CSV (using libreoffice) and the output 
c     processed by siaf_PRDOPSSOC-029/read_siaf_csv.pl, which creates
c     reference files for each SCA.
c
c     The reference values in the ideal-> science transformation 
c     for the "science" reference frame are not exactly 1024.5.
c     This code sets them all to 1024.5 since they should be
c     using a geometrical centre.
c     The files read in by this code will need to be updated 
c     as the SIAF parameters get updated.
c     There are two methods to get these data
c     (a) translate the SIAF excel sheet into a csv file and then
c         into ascii
c     (b) dump asdf files into ascii
c
      subroutine read_siaf_parameters(sca,
     &     sci_to_ideal_x, sci_to_ideal_y, sci_to_ideal_degree,
     &     ideal_to_sci_x, ideal_to_sci_y, ideal_to_sci_degree,
     &     x_sci_scale, y_sci_scale,
     &     x_det_ref, y_det_ref, x_sci_ref, y_sci_ref,
     &     det_sci_yangle, det_sci_parity,
     &     v3_idl_yang, v_idl_parity, v2_ref, v3_ref,
     &     nrcall_v3idlyangle, nrcall_v2, nrcall_v3,     
     &     verbose)

      implicit none
      integer sca, verbose
      integer ideal_to_sci_degree, v_idl_parity,
     &     sci_to_ideal_degree, det_sci_parity
      double precision 
     &     x_det_ref, y_det_ref,
     &     x_sci_ref, y_sci_ref,
     &     sci_to_ideal_x, sci_to_ideal_y,
     &     ideal_to_sci_x, ideal_to_sci_y,
     &     v3_sci_x_angle,v3_sci_y_angle,
     &     v3_idl_yang,
     &     det_sci_yangle,
     &     v2_ref, v3_ref,
     &     nrcall_v3idlyangle, nrcall_v2, nrcall_v3

      double precision x_sci_scale, y_sci_scale
      double precision var
c     &     v2, v3, var, xx, yy
      integer ii, jj, kk, ll, nterms, nx, ix, iy
c
      character files*17, guitarra_aux*100, filename*180,temp*17
      dimension files(11)

      dimension 
     &     sci_to_ideal_x(6,6), sci_to_ideal_y(6,6), 
     &     ideal_to_sci_x(6,6), ideal_to_sci_y(6,6)
c
c     Initialise variables
c
      files(1)   = 'NRCA1_FULL.ascii'
      files(2)   = 'NRCA2_FULL.ascii'
      files(3)   = 'NRCA3_FULL.ascii'
      files(4)   = 'NRCA4_FULL.ascii'
      files(5)   = 'NRCA5_FULL.ascii'
c
      files(6)   = 'NRCB1_FULL.ascii'
      files(7)   = 'NRCB2_FULL.ascii'
      files(8)   = 'NRCB3_FULL.ascii'
      files(9)   = 'NRCB4_FULL.ascii'
      files(10)  = 'NRCB5_FULL.ascii'
c
      files(11)  = 'NRCALL_FULL.ascii'
c
      do jj = 1, 6
         do ii = 1, 6
            sci_to_ideal_x(ii,jj) = 0.0d0
            sci_to_ideal_y(ii,jj) = 0.0d0
            ideal_to_sci_x(ii,jj) = 0.0d0
            ideal_to_sci_y(ii,jj) = 0.0d0
         end do
      end do
c
c----------------------------------------------------------------------
c
c     read V2,V3 coordinates of NIRCam
c
      temp = files(11)
      temp = temp(1:len_trim(temp))
      call getenv('GUITARRA_AUX',guitarra_aux)
      filename=guitarra_aux(1:len_trim(guitarra_aux))//temp
      print 100, filename
      if(verbose.gt.0) print 100, filename
 100  format(a100)
      open(87,file=filename)
      read(87,*) ! x_det_ref
      read(87,*) ! y_det_ref
      read(87,*) ! det_sci_yangle
      read(87,*) ! det_sci_parity
      read(87,*) ! x_sci_ref
      read(87,*) ! y_sci_ref
      read(87,*) ! x_sci_scale
      read(87,*) ! y_sci_scale
      read(87,*) ! v3_sci_x_angle
      read(87,*) ! v3_sci_y_angle
      read(87,*) nrcall_v3idlyangle
      read(87,*) ! v_idl_parity
      read(87,*) nrcall_v2
      read(87,*) nrcall_v3
      close(87)
c
c----------------------------------------------------------------------
c
c     Open file
c
      temp = files(sca)
      temp = temp(1:len_trim(temp))
      call getenv('GUITARRA_AUX',guitarra_aux)
      filename=guitarra_aux(1:len_trim(guitarra_aux))//temp
      print 100, filename
      if(verbose.gt.0) print 100, filename
c
c     read parameters
c
      open(87,file=filename)
      read(87,*) x_det_ref
      read(87,*) y_det_ref
      read(87,*) det_sci_yangle
      read(87,*) det_sci_parity
      read(87,*) x_sci_ref
      read(87,*) y_sci_ref
      read(87,*) x_sci_scale
      read(87,*) y_sci_scale
      read(87,*) v3_sci_x_angle
      read(87,*) v3_sci_y_angle
      read(87,*) v3_idl_yang
      read(87,*) v_idl_parity
      read(87,*) v2_ref
      read(87,*) v3_ref
c
c     set these to a fixed value
c
      x_det_ref = 1024.5d0
      y_det_ref = 1024.5d0
      x_sci_ref = 1024.5d0
      y_sci_ref = 1024.5d0
c     
c     Sci_ -> Ideal_x coefficients
c     
      if(verbose .gt.0) print *,'science -> ideal'
      read(87,*) nx
      sci_to_ideal_degree = nx
      nterms =  nx*(nx+1)/2
      do  ll = 1, nterms
         read(87, *) ii, jj, var
         ix = ii + 1
         iy = jj + 1
         sci_to_ideal_x(ix,iy) = var
      end do 
c     
c     Sci -> Ideal_y
c     
      read(87,*) nx
      nterms =  nx*(nx+1)/2
      do  ll = 1, nterms
         read(87, *) ii, jj, var
         ix = ii + 1
         iy = jj + 1
         sci_to_ideal_y(ix,iy) = var
         if(verbose.gt.0) then
            print 110 , ii, jj, ix, iy, sci_to_ideal_x(ix,iy),
     &           sci_to_ideal_y(ix,iy)
 110        format(4(1x,i2),2(2x, e17.9)) 
         end if
      end do
c
c     Ideal -> Sci_x
c
      if(verbose .gt.0) print *,'ideal -> science'
      read(87, *) nx
      ideal_to_sci_degree = nx
      nterms =  nx*(nx+1)/2
      do  ll = 1, nterms
         read(87, *) ii, jj, var
         ix = ii + 1
         iy = jj + 1
         ideal_to_sci_x(ix,iy) = var
      end do
c
c     Ideal -> Sci_y
c     
      read(87, *) nx
      nterms =  nx*(nx+1)/2
      do  ll = 1, nterms
         read(87, *) ii, jj, var
         ix = ii + 1
         iy = jj + 1
         ideal_to_sci_y(ix,iy) = var
         if(verbose.gt.0) then
            print 110 , ii, jj, ix, iy, ideal_to_sci_x(ix,iy),
     &           ideal_to_sci_y(ix,iy)
         end if
      end do
      close(87)
c
c     make the values consistent with polynomial
c
      x_sci_scale  = sci_to_ideal_x(2,1)
      y_sci_scale  = sci_to_ideal_y(2,2)
      return
      end
      
