# MAKE                 = /usr/bin/make
SUBDIRS =  slatec distortion proselytism src play_pen

.PHONY :  subdirs $(SUBDIRS)

subdirs : $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@

src  :  src
play_pen    : distortion
proselytism :  distortion
distortion  : slatec

.PHONY : cleanobj

cleanobj:
	-rm ./distortion/*.o ./distortion/*.a ./slatec/*.o ./slatec/*.a
