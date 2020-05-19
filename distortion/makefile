FC  = gfortran

# FFLAGS = -O3 -g -pedantic -C -mcmodel=medium

AR  = ar
RM  = -rm -v
SRC     := $(wildcard *.f)
OBJECTS := $(SRC:.f=.o)

distortion.a: $(OBJECTS)
	$(FC) -c -g -pedantic -O3 $(SRC)
	$(AR) -rv distortion.a $(OBJECTS)
#
.PHONY: clean
clean:
	$(RM) $(OBJECTS) distortion.a
