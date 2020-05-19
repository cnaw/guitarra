FC         = gfortran
AR  = ar
RM  = rm -v
MV  = mv -v

SRC     := $(wildcard *.f)
OBJECTS := $(SRC:.f=.o)

libslatec.a: $(OBJECTS)
	$(FC) -c -g -pedantic $(SRC)
	$(AR) -rv libslatec.a $(OBJECTS)
#

.PHONY: clean
clean:
	$(RM) $(OBJECTS) libslatec.a
