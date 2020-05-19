FC         = gfortran
# add the correct path for the CFITSIO library
# e.g.:
#libcfitsio = /Users/sandrotacchella/ASTRO/Programms/cfitsio/lib/libcfitsio.a
#libcfitsio=/home/cnaw/cfitsio/libcfitsio.a
libcfitsio = /usr/lib64/libcfitsio.so
LIBS       =  $(libcfitsio) ../distortion/distortion.a ../slatec/libslatec.a


FFLAGS = -O3 -g -pedantic -C -mcmodel=medium 

AR  = ar
RM  = rm -v
MV  = mv -v

# OBJECTS := $(patsubst %.f,%.o,$(wildcard *.f))
SRC     := $(wildcard *.f)
OBJECTS := $(SRC:.f=.o)

all : libguitarra.a guitarra

libguitarra.a: $(OBJECTS)
	$(FC) -c -g -pedantic -O3 $(SRC)
	$(AR) -rv libguitarra.a $(OBJECTS)
	$(AR) -d libguitarra.a guitarra.o

guitarra: guitarra.o
	$(FC) $(FFLAGS) -o guitarra guitarra.o \
	libguitarra.a $(LIBS)
	$(MV) guitarra $(GUITARRA_HOME)/bin/
#
.PHONY: clean
clean:
	$(RM) $(OBJECTS)

