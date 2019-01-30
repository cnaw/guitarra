FC         = gfortran

FFLAGS = -O3 -g -pedantic -C -mcmodel=medium 

AR  = ar
RM  = rm -v
MV  = mv -v

# SOURCES = *.f

# OBJECTS = ${SOURCES:.f=.o}

OBJECTS := $(patsubst %.f,%.o,$(wildcard *.f))

proselytism: $(OBJECTS) 
	$(FC) $(FFLAGS) -o proselytism \
	$(OBJECTS) $(LIBS)
	$(MV) proselytism $(GUITARRA_HOME)/bin
#
.PHONY: clean
clean:
	$(RM) $(OBJECTS)

