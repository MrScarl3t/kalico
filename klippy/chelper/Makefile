# Cross-compile c_helper.so for targets without a compiler (K1 series).
#
# Usage: make CROSS_PREFIX=<toolchain-triplet>-
#
# There is deliberately no default prefix. The K1 Max host is 32-bit
# little-endian MIPS32r2 (o32, NAN2008, glibc 2.29, Python 3.8); a
# big-endian "mips-linux-gnu-" toolchain produces a library the printer
# cannot load. build-k1-host.sh checks the resulting ELF header.
#
# Keep OBJECTS in sync with SOURCE_FILES in __init__.py.
ifeq ($(CROSS_PREFIX),)
$(error CROSS_PREFIX is not set; refusing to guess a cross toolchain)
endif

CC = $(CROSS_PREFIX)gcc
CFLAGS := -Wall -g -O2 -fPIC -flto -fwhole-program -fno-use-linker-plugin

OBJECTS = pyhelper.o serialqueue.o stepcompress.o steppersync.o itersolve.o \
	  trapq.o pollreactor.o msgblock.o trdispatch.o \
	  kin_cartesian.o kin_corexy.o kin_corexz.o kin_delta.o \
	  kin_deltesian.o kin_polar.o kin_rotary_delta.o kin_winch.o \
	  kin_extruder.o kin_shaper.o kin_idex.o

DIST_LIB = c_helper.so

all: $(DIST_LIB)

clean:
	@echo "Cleaning up directory."
	rm -f *.a *.o $(DIST_LIB) *~

$(DIST_LIB): $(OBJECTS)
	$(CC) -shared -fPIC -o $@ $(OBJECTS)

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<
