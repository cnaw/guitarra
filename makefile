ifeq ($(HOSTNAME), surtr.as.arizona.edu)
FC         = gfortran
# PGPLOT =  /usr/lib64/libpgplot.so.5.2.2 /usr/lib64/libpng16.so.16 -lX11 /usr/lib64/libgfortran.so
libcfitsio = /usr/lib64/libcfitsio.so
LIBS       =  $(libcfitsio)
# libslatec  = /home/cnaw/bin/libslatec.a
endif

FFLAGS = -O3 -g -pedantic -C -mcmodel=medium 

AR  = ar
RM  = rm -v

# SOURCES = *.f

# OBJECTS = ${SOURCES:.f=.o}

OBJECTS := $(patsubst %.f,%.o,$(wildcard *.f))

guitarra: $(OBJECTS) 
	$(FC) $(FFLAGS) -o guitarra \
	$(OBJECTS) $(LIBS)
#
.PHONY: clean
clean:
	$(RM) $(OBJECTS)

