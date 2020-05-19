c      implicit none
c      double precision ra, dec, z, magnitude, nsersic,
c     *     ellipticity, re, theta, flux_ratio, abmag 
cc
c      integer max_objects, nfilters, nsub, nf_used, cat_filter,indx
c      integer ngal, ncomponents,i, j, nc, l, filters_in_cat, id
cc
c      character filename*180,line*100, header*200
cc     
c      parameter (max_objects=50000, nfilters=54, nsub=4)
cc     
c      dimension ra(max_objects), dec(max_objects), z(max_objects),
c     *     magnitude(max_objects,nfilters), ncomponents(max_objects), 
c     *     nsersic(max_objects,nsub),ellipticity(max_objects,nsub), 
c     *     re(max_objects, nsub), theta(max_objects,nsub),
c     *     flux_ratio(max_objects, nsub), abmag(nfilters),
c     *     id(max_objects)
c      dimension cat_filter(nfilters)
cc     
c      common /galaxy/ra, dec, z, magnitude, nsersic, ellipticity, re,
c     *     theta, flux_ratio, ncomponents, id
cc
c      filename = 'test.cat'
c      filters_in_cat = 2
c      call read_multicomponent(filename, 
c     &     cat_filter, filters_in_cat,
c     &     nf_used, ngal)
c      stop
c      end
c@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
      subroutine read_multicomponent(filename, 
     &     cat_filter, filters_in_cat,
     &     nf_used, ngal)
      implicit none
      double precision ra, dec, z, magnitude, nsersic,
     *     ellipticity, re, theta, flux_ratio, abmag
      double precision tra, tdec, tz, tmagnitude, tlambda,
     *     semi_major, semi_minor, ttheta, tnsersic, fr,
     *     tra1, tdec1, tra2,tdec2, q, cosdec, dra, ddec
c
      integer max_objects, nfilters, nsub, nf_used, cat_filter,indx
      integer ngal, ncomponents,i, j, nc, l, filters_in_cat, id
c
      character filename*180,line*100, header*200
c     
      parameter (max_objects=50000, nfilters=54, nsub=4)
c     
      dimension ra(max_objects), dec(max_objects), z(max_objects),
     *     magnitude(max_objects,nfilters), ncomponents(max_objects), 
     *     nsersic(max_objects,nsub),ellipticity(max_objects,nsub), 
     *     re(max_objects, nsub), theta(max_objects,nsub),
     *     flux_ratio(max_objects, nsub), abmag(nfilters),
     *     id(max_objects)
      dimension cat_filter(nfilters),
     *     semi_major(4), semi_minor(4), ttheta(4), tnsersic(4), fr(4)
c     
      common /galaxy/ra, dec, z, magnitude, nsersic, ellipticity, re,
     *     theta, flux_ratio, ncomponents, id
c
      q = dacos(-1.0d0)/180.d0
      nf_used = filters_in_cat
c
      print *, filters_in_cat
      print *, filename
      open(1,file=filename)
      read(1,190) header
 190  format(a200)
      ngal = 0
      open(2,file='cat.reg')
      do i = 1, max_objects
         read(1, *, err= 30, end=110) l, tra, tdec, tmagnitude,
     *        tz, nc, 
     *        (semi_major(j), semi_minor(j), ttheta(j), 
     *        tnsersic(j),fr(j),j=1, nc),
     *        (abmag(j), j = 1, filters_in_cat)
         go to 50
 30      continue
         print *,'skipping '
         print 40,  l, tra, tdec, tmagnitude, tz, nc,
     *        (semi_major(j), semi_minor(j), ttheta(j), 
     *        tnsersic(j),fr(j),j=1, nc),
     *        (abmag(j), j = 1, filters_in_cat)
40      format(i8,4(1x,f15.6), i8,40(1x,f15.6))
         go to 90
 50      continue
c
         cosdec = dcos(tdec*q)
         dra    = 0.5d0*semi_major(nc) * dcos(ttheta(nc)*q)/cosdec
         dra    = dra/3600.d0
         ddec   = 0.5d0*semi_major(nc) * dsin(ttheta(nc)*q)
         ddec   = ddec/3600.d0
         tra1 = tra - dra
         tra2 = tra + dra

         tdec1 = tdec - ddec
         tdec2 = tdec + ddec
         
c         if(tmagnitude.gt.25.d0) go to 90
c     
         ngal = ngal + 1
         id(ngal)           = l
         ra(ngal)           = tra
         dec(ngal)          = tdec
         z(ngal)            = tz
c     axial_ratio = 1.d0-ellipticity
c     
c     As the source catalogue may use a different set of filters,
c     this allows using the correct column for the filter
c
         do j = 1, filters_in_cat
            magnitude(ngal,j)   = abmag(j) !
         end do
c
         ncomponents(ngal)   = nc
         do j = 1, nc
            ellipticity(ngal,j) = 1.d0 - semi_minor(j)/semi_major(j)
            nsersic(ngal,j)     = tnsersic(j)
            re(ngal,j)          = dsqrt(semi_major(j)*semi_minor(j))
            flux_ratio(ngal,j)  = fr(j)
            theta(ngal,j)       = ttheta(j) !+ 90.d0
         end do
c     
c         print *,  ncomponents(ngal),ellipticity(ngal,1), 
c     *        nsersic(ngal,1), re(ngal,1) 
c         if(l.eq.1) then
c            print 40,  l, tra, tdec, tmagnitude,
c     *           tz, semi_major, semi_minor, ttheta, tnsersic,
c     *           (magnitude(ngal, j), j = 1, nf_used)
c         end if
         write(line,60) tra1, tdec1, tra2, tdec2
     *        ,magnitude(ngal,nf_used)
 60      format('fk5;line(',f12.6,',',f12.6,',',f12.6,',',f12.6,
     *        ' # line = 0 0 color=black text={',f5.2,'}')
         write(2,70) line
 70      format(a100)
 90      continue
c         print *,'read_fake_mag_cat: nf_used, pause',nf_used
c         read(*,'(A)')
      end do
 110  close(1)
      print 120, ngal, filename
 120  format('read ',i6,' objects from',/,a80)
      close(2)
      return
      end

      
