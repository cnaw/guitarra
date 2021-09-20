c      character filename*80
c      integer cat_filter, filters_in_cat, nf_used, ngal
c      dimension cat_filter(54)
c      filters_in_cat = 8
c      filename = 'fake_mag_cat.cat'
c      filename = 'candels_with_fake_mag.cat'
c      call read_fake_mag_cat(filename,cat_filter,filters_in_cat,
c     *     nf_used, ngal)
c      stop
c      end
cc
c     Read catalogue derived from CANDELs with fake magnitudes, derived
c     using random sampling of BC2003 spectra
c
      subroutine read_fake_mag_cat(filename, cat_filter,filters_in_cat,
     *     nf_used, ngal)
      implicit none
      double precision ra, dec, z, magnitude, nsersic,
     *     ellipticity, re, theta, flux_ratio
      double precision tra, tdec, tz, tmagnitude, tnsersic,
     *     ttheta, tlambda, semi_major, semi_minor,
     *     tra1, tdec1, tra2,tdec2, q, cosdec, angle, dra, ddec,
     *     abmag
c
      integer max_objects, nfilters, nsub, nf_used, cat_filter,indx
      integer ngal, ncomponents,i, j, nc, l, filters_in_cat, id
c
      character filename*180,line*100, header*200
c     
      parameter (max_objects=65000, nfilters=54, nsub=4)
c     
      dimension ra(max_objects), dec(max_objects), z(max_objects),
     *     magnitude(max_objects,nfilters), ncomponents(max_objects), 
     *     nsersic(max_objects,nsub),ellipticity(max_objects,nsub), 
     *     re(max_objects, nsub), theta(max_objects,nsub),
     *     flux_ratio(max_objects, nsub), abmag(nfilters),
     *     id(max_objects)
      dimension cat_filter(nfilters)
c     
      common /galaxy/ra, dec, z, magnitude, nsersic, ellipticity, re,
     *     theta, flux_ratio, ncomponents
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
     *        tz, semi_major, semi_minor, ttheta, tnsersic,
     *        (abmag(j), j = 1, filters_in_cat)
         go to 50
 30      continue
         print *,'skipping '
         print 40, l, tra, tdec, tmagnitude,
     *        tz, semi_major, semi_minor, ttheta, tnsersic,
     *        (abmag(j), j = 1, filters_in_cat)
 40      format(i8,20(1x,f15.6))
         go to 90
 50      continue
c
         cosdec = dcos(tdec*q)
         angle  = ttheta
         dra    = 0.5d0*semi_major * dcos(ttheta*q)/cosdec
         dra    = dra/3600.d0
         ddec   = 0.5d0*semi_major * dsin(ttheta*q)
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

c         do j = 1, nf_used
c            indx  = cat_filter(j)
c            magnitude(ngal,j)   = abmag(indx) !
c         end do
         ncomponents(ngal)   = 1
         ellipticity(ngal,1) = 1.d0 - semi_minor/semi_major 
         nsersic(ngal,1)     = tnsersic
         re(ngal,1)          = dsqrt(semi_major*semi_minor)
         flux_ratio(ngal,1)  = 1.d0
         theta(ngal,1)       = ttheta
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
