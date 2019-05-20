FC         = gfortran
# add the correct path for the CFITSIO library
# e.g.:
#libcfitsio = /Users/sandrotacchella/ASTRO/Programms/cfitsio/lib/libcfitsio.a
libcfitsio=/n/sw/fasrcsw/apps/Comp/gcc/7.1.0-fasrc01/cfitsio/3390-fasrc01/lib/libcfitsio.a
#libcfitsio=/home/cnaw/cfitsio/libcfitsio.a
LIBS       =  $(libcfitsio)


FFLAGS = -O3 -g -pedantic -C -mcmodel=medium 

AR  = ar
RM  = rm -v
MV  = mv -v
# SOURCES = *.f

# OBJECTS = ${SOURCES:.f=.o}

OBJECTS := $(patsubst %.f,%.o,$(wildcard *.f))

guitarra: $(OBJECTS) 
	$(FC) $(FFLAGS) -o guitarra \
	$(OBJECTS) $(LIBS)
	$(MV) guitarra $(GUITARRA_HOME)/bin/
#
.PHONY: clean
clean:
	$(RM) $(OBJECTS)

