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
      subroutine new_read_fake_mag_cat(filename, clone_cat,
     &     use_filter, cat_filter,filters_in_cat, nf_used,
     &     galaxy, ngal, max_objects, include_cloned_galaxies)
      implicit none
c
      type guitarra_source
      character :: path*180, id*25
      integer :: number, ncomponents
      real (kind=8)  :: ra, dec, mag, zz, 
     &     re, ellipticity, flux_ratio, theta, nsersic
      end type guitarra_source
!

      character clone_file*180, temp*25
      integer (kind=4) :: nmags, ii, jj, include_cloned_galaxies
      real (kind=8) :: apa, amag, abmag, smags
c      double precision ra, dec, z, magnitude, nsersic,
c     *     ellipticity, re, theta, flux_ratio
      double precision tra, tdec, tz, tmagnitude, tnsersic,
     *     ttheta, tlambda, semi_major, semi_minor,
     *     tra1, tdec1, tra2,tdec2, q, cosdec, angle, dra, ddec
c
      integer max_objects, nfilters, nsub, nf_used, cat_filter,indx
      integer ngal, ncomponents,i, j, nc, l, filters_in_cat, id,
     &     use_filter
c
      character filename*180,line*100, header*200, clone_cat*180
c
      type(guitarra_source) :: galaxy(max_objects)
c
c      parameter (max_objects = 60000)
      parameter (nfilters=54, nsub=4)
c
      dimension  abmag(nfilters), smags(nfilters)
c      dimension ra(max_objects), dec(max_objects),
c     &     z(max_objects),id(max_objects),
c     *     magnitude(max_objects), ncomponents(max_objects), 
c     *     nsersic(max_objects,nsub),ellipticity(max_objects,nsub), 
c     *     re(max_objects, nsub), theta(max_objects,nsub),
c     *     flux_ratio(max_objects, nsub)
      dimension cat_filter(nfilters)
c     
c      common /galaxy/ra, dec, z, magnitude, nsersic, ellipticity, re,
c     *     theta, flux_ratio, ncomponents,id
c
      q = dacos(-1.0d0)/180.d0
      nf_used = filters_in_cat
      nmags   = 10
c
      print *, filters_in_cat
      print *, 'new_read_fake_mag_cat ',filename
      open(1,file=filename)
      read(1,190) header
 190  format(a200)
      ngal = 0
      open(2,file='cat.reg')
      read(1,*,end=110)
      do i = 1, max_objects
         read(1,20, err= 30, end=110) temp, tra, tdec, tmagnitude,
     *        tz, semi_major, semi_minor, ttheta, tnsersic,
     *        (abmag(j), j = 1, filters_in_cat)
 20       format(a25,2(1x,f14.8),100(1x,f12.6))
         go to 50
 30      continue
         print *,'skipping '
         print 20, temp, tra, tdec, tmagnitude,
     *        tz, semi_major, semi_minor, ttheta, tnsersic,
     *        (abmag(j), j = 1, filters_in_cat)
         print 40, temp, tra, tdec, tmagnitude,
     *        tz, semi_major, semi_minor, ttheta, tnsersic,
     *        (abmag(j), j = 1, filters_in_cat)
 40      format(a6,20(1x,f15.6))
         stop
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
         galaxy(ngal)%id  = temp
         galaxy(ngal)%ra  = tra
         galaxy(ngal)%dec = tdec
         galaxy(ngal)%zz  = tz
         galaxy(ngal)%mag = abmag(use_filter)
         galaxy(ngal)%path   = 'none'
         galaxy(ngal)%ellipticity = 1.d0 - semi_minor/semi_major
         galaxy(ngal)%theta  = ttheta
         galaxy(ngal)%nsersic = tnsersic
         galaxy(ngal)%re = dsqrt(semi_major*semi_minor)
         galaxy(ngal)%flux_ratio = 1.d0
         galaxy(ngal)%ncomponents = 1
c         id(ngal)           = l
c         ra(ngal)           = tra
c         dec(ngal)          = tdec
c         z(ngal)            = tz
cc         print *,'read_fake_mag_cat ', ngal, id(ngal), ra(ngal)
cc     axial_ratio = 1.d0-ellipticity
cc
cc     As the source catalogue may use a different set of filters,
cc     this allows using the correct column for the filter
cc
c         magnitude(ngal)   = abmag(use_filter) !
cc
cc         do j = 1, nf_used
cc            indx  = cat_filter(j)
cc            magnitude(ngal,j)   = abmag(indx) !
cc         end do
c         ncomponents(ngal)   = 1
c         ellipticity(ngal,1) = 1.d0 - semi_minor/semi_major 
c         nsersic(ngal,1)     = tnsersic
c         re(ngal,1)          = dsqrt(semi_major*semi_minor)
c         flux_ratio(ngal,1)  = 1.d0
c         theta(ngal,1)       = ttheta
c         print *,  ncomponents(ngal),ellipticity(ngal,1), 
c     *        nsersic(ngal,1), re(ngal,1) 
         
c         if(l.eq.1) then
c            print 40,  l, tra, tdec, tmagnitude,
c     *           tz, semi_major, semi_minor, ttheta, tnsersic,
c     *           (magnitude(ngal, j), j = 1, nf_used)
c         end if
         write(line,60) tra1, tdec1, tra2, tdec2
     *        ,galaxy(ngal)%mag
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
 120  format('read ',i6,' objects from',/,a180)
      close(2)
c
      if(include_cloned_galaxies.ne.1) return
      print *,'new_read_fake_mag_cat clone_cat ',clone_cat
      open(11, file= clone_cat)
      read(11,*)
      nc = 0
      do ii = 1, max_objects
         read(11, 130, err = 140, end=1000) temp, tra, tdec,
     &        tmagnitude,apa,  tz,
     &        (abmag(jj), jj = 1, 10),
     &        (smags(jj), jj=1,18), clone_file
 130     format(a25,2(2x, f14.9), 2(2x,f10.2), 2x, f9.5,
     &        28(2x,f8.4),2x, A180)
         go to 150
 140      print 130, temp, tra, tdec, tmagnitude, apa, tz,
     &        (abmag(jj),jj=1, 10), (smags(jj), jj=1,18),clone_file
          print *,'error at new_read_fake_mag_cat, ii ', ii
          stop
 150     continue
         ngal = ngal + 1
         nc   = nc + 1
         galaxy(ngal)%id   = temp
         galaxy(ngal)%ra   = tra
         galaxy(ngal)%dec  = tdec
         galaxy(ngal)%zz   = tz
         galaxy(ngal)%mag  = smags(use_filter)
         galaxy(ngal)%path = clone_file
         galaxy(ngal)%ellipticity = 0.0d0
         galaxy(ngal)%theta = apa
         galaxy(ngal)%nsersic = 1.0
         galaxy(ngal)%re = 1.0
         galaxy(ngal)%flux_ratio = 1.d0
         galaxy(ngal)%ncomponents = 1
c         if(verbose.gt.0) print 155, galaxy(ngal)%path
 155     format('new_read_fake_mag_cat ',1x,A)
 160     continue
      end do
 1000 close(11)
      print *,'new_read_fake_mag_cat: clones added ', nc
      print *,'new_read_fake_mag_cat: total        ', ngal
      return
      end
