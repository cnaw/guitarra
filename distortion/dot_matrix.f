c
c-----------------------------------------------------------------------
c
c     Call SLATEC DGEMM routine to perform matrix operations
c
c     cnaw@as.arizona.edu
c     2017-03-20
c     
      subroutine dot_matrix(mat1, n1x, n1y, mat2, n2x, n2y, 
     &     mat3, n3x, n3y, nnn)
      implicit none
      double precision mat1, mat2, mat3, sum
      integer n1x, n1y,  n2x, n2y,  n3x, n3y
      integer i, j, k, nnn
c
      character transa*1, transb*1
      double precision alpha, beta
      integer lda, ldb, ldc
c
      dimension mat1(nnn,nnn), mat2(nnn,nnn), mat3(nnn,nnn)
c
c      print *, n1x, n1y, n2x, n2y
      if(n1y.ne.n2x) then
         print *,'dot_matrix dimension mis-match'
         print *,' n1 x, y', n1x, n1y
         print *,' n2 x, y', n2x, n2y
        stop
      end if
c
      n3x = n1x
      n3y = n2y
c
      transa = 'N'
      transb = 'N'
      lda   = max(1, n1x)       ! number of rows in op(mat1)
      ldb   = max(1, n2x)       ! number of columns in op(mat2)
      ldc   = max(1, n1x)       ! number of columns in matrix op(mat1)
      alpha = 1.d0
      beta  = 0.0d0
c      print *, 'lda, ldb, ldc', lda, ldb, ldc
      call dgemm(transa, transb, n1x, n2y, n1y, alpha, mat1, lda,
     &     mat2, ldb, beta, mat3, ldc)

      return
      end
