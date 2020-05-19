      subroutine pick_dark_ramp(sca, dark_file,verbose)
      integer sca, verbose
      character dark_file*(*)
      double precision zbqluab
      integer nd, ii, pick
      character guitarra_aux*100, dark_list*180, darks*180,list*180
c
      dimension darks(50)
      
c
c     read list of dark ramps for this SCA
c
        write(dark_list, 110) sca
 110    format(i3,'_dark.list')
        print 120, dark_list
        call getenv('GUITARRA_AUX',guitarra_aux)
        print 120, dark_list
        print 120, guitarra_aux
        list = guitarra_aux(1:len_trim(guitarra_aux))//dark_list
        print 120, list(1:len_trim(list))
        open(66,file=list)
        nd = 0
        do ii = 1, 50
           read(66,120,end=150) darks(ii)
 120       format(a180)
           nd = nd + 1
           if(verbose.gt.2) print 130, ii, darks(ii)
 130       format('pick_dark_ramp ii:',i3,2x,a180)
        end do
        nd = nd -1
 150    close(66)
c     
c     Pick one randomly
c
        pick = idnint(zbqluab(1.0d0,dble(nd)))
        dark_file = 
     &       guitarra_aux(1:len_trim(guitarra_aux))//darks(pick)
        print 160, pick, dark_file
 160    format('pick_dark_ramp: ',i3,2x,a180)
c     
        return
        end
