FC         = gfortran
LIBS   = ../distortion/distortion.a ../slatec/libslatec.a
FFLAGS = -O3 -g -pedantic -C -mcmodel=medium 

PROGRAM = proselytism

AR  = ar
RM  = -rm -v
MV  = mv -v

OBJECTS := $(patsubst %.f,%.o,$(wildcard *.f))

all: ${PROGRAM} 

$(PROGRAM) : $(OBJECTS) 
	$(FC) $(FFLAGS) $(OBJECTS) $(LIBS) -o $(@)
	$(MV) ${PROGRAM} $(GUITARRA_HOME)/bin
#
clean:
	$(RM) $(OBJECTS)
