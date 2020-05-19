c
c-----------------------------------------------------------------------
c
c     rotate coordinates from one frame to another
c     cnaw@as.arizona.edu
c     2017-03-20
c
      subroutine rot_coords(attitude_matrix, xx, yy, xp, yp)
      implicit none
      double precision attitude_matrix, xx, yy, xp, yp
      double precision v, w, matrix1, matrix2
      integer nx, ny, nnn, i, j, nx2, ny2
      dimension v(3), w(3), attitude_matrix(3,3) 
      dimension matrix1(3,1), matrix2(3,1)
      data matrix1, matrix2 /3*0.0d0, 3*0.0d0/
      data v/3*0.0d0/
c
      nnn = 3
      call unit_vector(xx, yy, v)
      nx = 3
      ny = 1
      nx2 = 3
      ny2 = 1
      do i = 1, 3
         matrix1(i,1) = v(i)
      end do
c
      call dot_matrix(attitude_matrix,nnn,nnn, matrix1, nx, ny, 
     *     matrix2, nx2, ny2, nnn)
      do i = 1,nx
         w(i) = matrix2(i,1)
      end do
      call coords_from_unit_vector(w, xp, yp)
      return
      end
