# MAKE                 = /usr/bin/make
SUBDIRS =  slatec distortion proselytism src

.PHONY :  subdirs $(SUBDIRS)

subdirs : $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@

src  :  src
play_pen    : distortion
proselytism :  distortion
distortion  : slatec

.PHONY : clean

clean:
	-rm ./distortion/*.o ./distortion/*.a ./slatec/*.o ./slatec/*.a ./src/*.o  ./proselytism/*.o

