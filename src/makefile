FC         = gfortran
# add the correct path for the CFITSIO library
libcfitsio = /Users/sandrotacchella/ASTRO/Programms/cfitsio/lib/libcfitsio.a
LIBS       =  $(libcfitsio)


FFLAGS = -O3 -g -pedantic -C -mcmodel=medium 

AR  = ar
RM  = rm -v
MV  = mv -vu
# SOURCES = *.f

# OBJECTS = ${SOURCES:.f=.o}

OBJECTS := $(patsubst %.f,%.o,$(wildcard *.f))

guitarra: $(OBJECTS) 
	$(FC) $(FFLAGS) -o guitarra \
	$(OBJECTS) $(LIBS)
	$(MV) guitarra ~/bin/
#
.PHONY: clean
clean:
	$(RM) $(OBJECTS)

