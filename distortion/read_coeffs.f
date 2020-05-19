c
c----------------------------------------------------------------------
c     read parameters
c
      subroutine read_coeffs(file, 
     &     sci_to_ideal_x, sci_to_ideal_y, sci_to_ideal_degree,
     &     det_sci_yangle, det_sci_parity,
     &     ideal_to_sci_x, ideal_to_sci_y, ideal_to_sci_degree,
     &     v3_idl_yang, v_idl_parity, v2_ref, v3_ref, verbose)
      implicit none
      double precision x_det_ref, y_det_ref
      double precision x_sci_ref, y_sci_ref 
      double precision x_ideal, y_ideal
      integer ideal_to_sci_degree, v_idl_parity,
     &     sci_to_ideal_degree, det_sci_parity

      double precision 
     &     sci_to_ideal_x,sci_to_ideal_y,
     &     ideal_to_sci_x, ideal_to_sci_y,
     &     x_sci_scale, y_sci_scale,
     &     v3_sci_x_angle,v3_sci_y_angle,
     &     v3_idl_yang,
     &     det_sci_yangle
      double precision v2_ref, v3_ref
      double precision
     &     v2, v3, var, xx, yy
      integer sca, verbose, init, ii, jj, kk, ll, nterms, nx, ny,
     &     ix, iy, precise
c
      character file*(*)

      dimension 
     &     sci_to_ideal_x(6,6), sci_to_ideal_y(6,6), 
     &     ideal_to_sci_x(6,6), ideal_to_sci_y(6,6)
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
      open(87,file=file)
c     PRINT 10, sca, files(sca)
 10   format(i3,2x,a80)
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
      
      x_det_ref = 1024.5d0
      y_det_ref = 1024.5d0
      x_sci_ref = 1024.5d0
      y_sci_ref = 1024.5d0
c     
c     Sci -> Ideal_x
c     
      read(87,*) nx
      sci_to_ideal_degree = nx
c     (sci_to_ideal_degree(i)+1)*(sci_to_ideal_degree(i)+2)/2
      nterms =  nx*(nx+1)/2
c     print *,'nterms ', nterms
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
            print 110 , ix, iy, sci_to_ideal_x(ix,iy),
     &           sci_to_ideal_y(ix,iy)
 110        format(2(1x,i2),2(2x, e17.9)) 
         end if
      end do
c
c     Ideal -> Science X
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
c     Ideal -> Science Y
c     
      read(87, *) nx
      nterms =  nx*(nx+1)/2
      do  ll = 1, nterms
         read(87, *) ii, jj, var
         ix = ii + 1
         iy = jj + 1
         ideal_to_sci_y(ix,iy) = var
         if(verbose.gt.0) then
            print 110 , ix, iy, ideal_to_sci_x(ix,iy),
     &           ideal_to_sci_y(ix,iy)
         end if
      end do
      close(87)
      return
      end
