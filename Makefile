include pcmcia/config.mk
TOPDIR  := $(shell if [ "$$PWD" != "" ]; then echo $$PWD; else pwd; fi)

CC = gcc -V2.7.2.3
YACC = bison -y
LEX = flex -8
CFLAGS = -O2 -fomit-frame-pointer -c -I$(TOPDIR)/libc/include -I$(TOPDIR) $(EXTRA_FLAGS)
LDFLAGS = -static -s -u__force_mini_libc_symbols -Wl,-Map=linuxrc.map
WARN = -Wstrict-prototypes -Wall

ARCH = $(shell uname -m)
ifeq "$(ARCH)" "alpha"
    CFLAGS += -DLINUXRC_AXP
endif

.EXPORT_ALL_VARIABLES:

SRC=display.c keyboard.c window.c text.c global.c dialog.c util.c \
    linuxrc.c module.c rootimage.c info.c net.c modparms.c        \
    pcmcia.c install.c settings.c bootpc.c file.c ftp.c smp.c
OBJ=$(SRC:.c=.o)
INC=global.h keyboard.h display.h window.h text.h dialog.h util.h \
    module.h rootimage.h info.h net.h modparms.h pcmcia.h install.h \
    settings.h linuxrc.h file.h ftp.h smp.o

LIBS=insmod/insmod.a loadkeys/loadkeys.a pcmcia/pcmcia.a portmap/portmap.a libc/mini-libc.a

SUBDIRS=insmod loadkeys pcmcia portmap libc

.PHONY:	Libs

all: Libs linuxrc

linuxrc: $(SRC) $(OBJ) Makefile $(LIBS)
	$(CC) $(OBJ) $(LIBS) $(LDFLAGS) -o linuxrc
	strip linuxrc
	strip -R .note -R .comment linuxrc
	ls -l linuxrc

dep::	$(SRC) $(INC)
	$(CC) -M $(CFLAGS) $(SRC) -DSTATIC=static > .depend

clean::
	-rm *.o linuxrc

%.o:	%.c
	$(CC) $(CFLAGS) $(WARN) -o $@ $<

Libs:
	@for d in $(SUBDIRS); do $(MAKE) -C $$d; done

dep clean ::
	$(foreach dir, $(SUBDIRS), $(MAKE) -C $(dir) $@ &&) echo;

