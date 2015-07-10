MAIN_MAKEFILE=1
include config.mak

vpath %.c    $(SRC_PATH)
vpath %.cpp  $(SRC_PATH)
vpath %.h    $(SRC_PATH)
vpath %.m    $(SRC_PATH)
vpath %.S    $(SRC_PATH)
vpath %.asm  $(SRC_PATH)
vpath %.rc   $(SRC_PATH)
vpath %.v    $(SRC_PATH)
vpath %.texi $(SRC_PATH)
vpath %/fate_config.sh.template $(SRC_PATH)

#AVPROGS-$(CONFIG_FFMPEG)   += ffmpeg
#AVPROGS-$(CONFIG_FFMPEG)   += sapphireCloud
#AVPROGS-$(CONFIG_FFPLAY)   += ffplay
#AVPROGS-$(CONFIG_FFPROBE)  += ffprobe
#AVPROGS-$(CONFIG_FFSERVER) += ffserver

AVPROGS    := $(AVPROGS-yes:%=%$(PROGSSUF)$(EXESUF))
INSTPROGS   = $(AVPROGS-yes:%=%$(PROGSSUF)$(EXESUF))
PROGS      += $(AVPROGS)

AVBASENAMES  = sapphireCloud ffmpeg ffplay ffprobe ffserver
ALLAVPROGS   = $(AVBASENAMES:%=%$(PROGSSUF)$(EXESUF))
ALLAVPROGS_G = $(AVBASENAMES:%=%$(PROGSSUF)_g$(EXESUF))

$(foreach prog,$(AVBASENAMES),$(eval OBJS-$(prog) += cmdutils.o))
$(foreach prog,$(AVBASENAMES),$(eval OBJS-$(prog)-$(CONFIG_OPENCL) += cmdutils_opencl.o))

OBJS-sapphireCloud            += ffmpeg.o ffmpeg_opt.o ffmpeg_filter.o
OBJS-sapphireCloud-$(HAVE_VDPAU_X11) += ffmpeg_vdpau.o
OBJS-sapphireCloud-$(HAVE_DXVA2_LIB) += ffmpeg_dxva2.o
OBJS-sapphireCloud-$(CONFIG_VDA)     += ffmpeg_vda.o
OBJS-ffserver                 += ffserver_config.o

TESTTOOLS   = audiogen videogen rotozoom tiny_psnr tiny_ssim base64
HOSTPROGS  := $(TESTTOOLS:%=tests/%) doc/print_options
TOOLS       = qt-faststart trasher uncoded_frame
TOOLS-$(CONFIG_ZLIB) += cws2fws

# $(FFLIBS-yes) needs to be in linking order
FFLIBS-$(CONFIG_AVDEVICE)   += avdevice
FFLIBS-$(CONFIG_AVFILTER)   += avfilter
FFLIBS-$(CONFIG_AVFORMAT)   += avformat
FFLIBS-$(CONFIG_AVCODEC)    += avcodec
FFLIBS-$(CONFIG_AVRESAMPLE) += avresample
FFLIBS-$(CONFIG_POSTPROC)   += postproc
FFLIBS-$(CONFIG_SWRESAMPLE) += swresample
FFLIBS-$(CONFIG_SWSCALE)    += swscale

FFLIBS := avutil

DATA_FILES := $(wildcard $(SRC_PATH)/presets/*.ffpreset) $(SRC_PATH)/doc/ffprobe.xsd
EXAMPLES_FILES := $(wildcard $(SRC_PATH)/doc/examples/*.c) $(SRC_PATH)/doc/examples/Makefile $(SRC_PATH)/doc/examples/README

SKIPHEADERS = cmdutils_common_opts.h compat/w32pthreads.h


.PHONY : sapphire-Cloud
sapphire-Cloud : cmdutils.o ffmpeg.o ffmpeg_opt.o ffmpeg_filter.o sapphireCloud.o
	@printf "LD\tsapphireCloud\n"; g++ -Llibavcodec -Llibavdevice -Llibavfilter -Llibavformat -Llibavresample -Llibavutil -Llibpostproc -Llibswscale -Llibswresample -L/home/ubuntu/ffmpeg_build/lib  -Wl,--as-needed -Wl,-z,noexecstack -Wl,--warn-common -Wl,-rpath-link=libpostproc:libswresample:libswscale:libavfilter:libavdevice:libavformat:libavcodec:libavutil:libavresample   -o sapphireCloud cmdutils.o ffmpeg.o ffmpeg_opt.o ffmpeg_filter.o sapphireCloud.o   -lavdevice -lavfilter -lavformat -lavcodec -lpostproc -lswresample -lswscale -lavutil -lva -lva-x11 -lva -lxcb -lXau -lXdmcp -lxcb-shm -lxcb -lXau -lXdmcp -lxcb-xfixes -lxcb-render -lxcb-shape -lxcb -lXau -lXdmcp -lxcb-shape -lxcb -lXau -lXdmcp -lX11 -ljack -lasound -lSDL -lasound -lm -ldl -lpulse-simple -lpulse -lX11 -lXext -lcaca -lpthread -lx264 -lpthread -lm -ldl -lvpx -lvpx -lvpx -lvpx -lvorbisenc -lvorbis -logg -ltheoraenc -ltheoradec -logg -lopus -lm -lmp3lame -lfreetype -lz -lpng12 -lfdk-aac -lass -lfontconfig -lenca -lm -lfribidi -lexpat -lfreetype -lz -lpng12 -lcrystalhd -lm -llzma -lz -pthread
	@printf "strip\tsapphireCloud\n"; strip sapphireCloud

sapphireCloud.o : sapphireCloud.cc
	@printf "g++\tsapphireCloud.o\n"; g++ -I. -I./ -std=c++11 -D_ISOC99_SOURCE -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -D_POSIX_C_SOURCE=200112 -D_XOPEN_SOURCE=600 -DZLIB_CONST -I/home/ubuntu/ffmpeg_build/include -fomit-frame-pointer -pthread -I/usr/include/freetype2 -I/usr/include/fribidi -I/usr/include/freetype2 -I/usr/include/opus  -D_GNU_SOURCE=1 -D_REENTRANT -I/usr/include/SDL  -g -Wall -Wdisabled-optimization -Wpointer-arith -Wredundant-decls -Wwrite-strings -Wtype-limits -Wundef -Wempty-body -Wno-parentheses -Wno-switch -Wno-format-zero-length -O3 -fno-math-errno -fno-signed-zeros -fno-tree-vectorize -Werror=format-security -Werror=implicit-function-declaration -Werror=missing-prototypes -Werror=return-type -Werror=vla -Wformat -Wno-maybe-uninitialized   -MMD -MF sapphireCloud.d -MT sapphireCloud.o -c -o sapphireCloud.o sapphireCloud.cc
#	$(CXX) -c $(CXXFLAGS) -o sapphireCloud.o sapphireCloud.cc


include $(SRC_PATH)/common.mak

FF_EXTRALIBS := $(FFEXTRALIBS)
FF_DEP_LIBS  := $(DEP_LIBS)


#$(warning AVPROGS : $(AVPROGS))
#$(warning LD : $(LD))
#$(warning TOOLS : $(TOOLS))
#$(warning LDFLAGS : $(LDFLAGS))
#$(warning LD_O : $(LD_O))


all: $(AVPROGS)

$(TOOLS): %$(EXESUF): %.o $(EXEOBJS)
	$(LD) $(LDFLAGS) $(LDEXEFLAGS) $(LD_O) $^ $(ELIBS)

tools/cws2fws$(EXESUF): ELIBS = $(ZLIB)
tools/uncoded_frame$(EXESUF): $(FF_DEP_LIBS)
tools/uncoded_frame$(EXESUF): ELIBS = $(FF_EXTRALIBS)

config.h: .config
.config: $(wildcard $(FFLIBS:%=$(SRC_PATH)/lib%/all*.c))
	@-tput bold 2>/dev/null
	@-printf '\nWARNING: $(?F) newer than config.h, rerun configure\n\n'
	@-tput sgr0 2>/dev/null

SUBDIR_VARS := CLEANFILES EXAMPLES FFLIBS HOSTPROGS TESTPROGS TOOLS      \
               HEADERS ARCH_HEADERS BUILT_HEADERS SKIPHEADERS            \
               ARMV5TE-OBJS ARMV6-OBJS ARMV8-OBJS VFP-OBJS NEON-OBJS     \
               ALTIVEC-OBJS MMX-OBJS YASM-OBJS                           \
               MIPSFPU-OBJS MIPSDSPR2-OBJS MIPSDSPR1-OBJS MSA-OBJS       \
               LOONGSON3-OBJS OBJS SLIBOBJS HOSTOBJS TESTOBJS

define RESET
$(1) :=
$(1)-yes :=
endef

define DOSUBDIR
$(foreach V,$(SUBDIR_VARS),$(eval $(call RESET,$(V))))
SUBDIR := $(1)/
include $(SRC_PATH)/$(1)/Makefile
-include $(SRC_PATH)/$(1)/$(ARCH)/Makefile
-include $(SRC_PATH)/$(1)/$(INTRINSICS)/Makefile
include $(SRC_PATH)/library.mak
endef

$(foreach D,$(FFLIBS),$(eval $(call DOSUBDIR,lib$(D))))

include $(SRC_PATH)/doc/Makefile

define DOPROG
OBJS-$(1) += $(1).o $(EXEOBJS) $(OBJS-$(1)-yes)
$(1)$(PROGSSUF)_g$(EXESUF): $$(OBJS-$(1))
$$(OBJS-$(1)): CFLAGS  += $(CFLAGS-$(1))
$(1)$(PROGSSUF)_g$(EXESUF): LDFLAGS += $(LDFLAGS-$(1))
$(1)$(PROGSSUF)_g$(EXESUF): FF_EXTRALIBS += $(LIBS-$(1))
-include $$(OBJS-$(1):.o=.d)
endef

$(foreach P,$(PROGS),$(eval $(call DOPROG,$(P:$(PROGSSUF)$(EXESUF)=))))

ffprobe.o cmdutils.o libavcodec/utils.o libavformat/utils.o libavdevice/avdevice.o libavfilter/avfilter.o libavutil/utils.o libpostproc/postprocess.o libswresample/swresample.o libswscale/utils.o : libavutil/ffversion.h


#$(warning PROGS : $(PROGS))
#$(warning PROGSSUF : $(PROGSSUF))
#$(warning CP : $(CP))


$(PROGS): %$(PROGSSUF)$(EXESUF): %$(PROGSSUF)_g$(EXESUF)
	$(CP) $< $@
	$(STRIP) $@

%$(PROGSSUF)_g$(EXESUF): %.o $(FF_DEP_LIBS)
	$(LD) $(LDFLAGS) $(LDEXEFLAGS) $(LD_O) $(OBJS-$*) $(FF_EXTRALIBS)

OBJDIRS += tools

-include $(wildcard tools/*.d)

VERSION_SH  = $(SRC_PATH)/version.sh
GIT_LOG     = $(SRC_PATH)/.git/logs/HEAD

.version: $(wildcard $(GIT_LOG)) $(VERSION_SH) config.mak
.version: M=@

libavutil/ffversion.h .version:
	$(M)$(VERSION_SH) $(SRC_PATH) libavutil/ffversion.h $(EXTRA_VERSION)
	$(Q)touch .version

# force version.sh to run whenever version might have changed
-include .version

ifdef AVPROGS
install: install-progs install-data
endif

install: install-libs install-headers

install-libs: install-libs-yes

install-progs-yes:
install-progs-$(CONFIG_SHARED): install-libs

install-progs: install-progs-yes $(AVPROGS)
	$(Q)mkdir -p "$(BINDIR)"
	$(INSTALL) -c -m 755 $(INSTPROGS) "$(BINDIR)"

install-data: $(DATA_FILES) $(EXAMPLES_FILES)
	$(Q)mkdir -p "$(DATADIR)/examples"
	$(INSTALL) -m 644 $(DATA_FILES) "$(DATADIR)"
	$(INSTALL) -m 644 $(EXAMPLES_FILES) "$(DATADIR)/examples"

uninstall: uninstall-libs uninstall-headers uninstall-progs uninstall-data

uninstall-progs:
	$(RM) $(addprefix "$(BINDIR)/", $(ALLAVPROGS))

uninstall-data:
	$(RM) -r "$(DATADIR)"

clean::
	$(RM) $(ALLAVPROGS) $(ALLAVPROGS_G)
	$(RM) $(CLEANSUFFIXES)
	$(RM) $(CLEANSUFFIXES:%=tools/%)
	$(RM) -r coverage-html
	$(RM) -rf coverage.info lcov

distclean::
	$(RM) $(DISTCLEANSUFFIXES)
	$(RM) config.* .config libavutil/avconfig.h .version version.h libavutil/ffversion.h libavcodec/codec_names.h

config:
	$(SRC_PATH)/configure $(value FFMPEG_CONFIGURATION)

check: all alltools examples testprogs fate

include $(SRC_PATH)/tests/Makefile

$(sort $(OBJDIRS)):
	$(Q)mkdir -p $@

# Dummy rule to stop make trying to rebuild removed or renamed headers
%.h:
	@:

# Disable suffix rules.  Most of the builtin rules are suffix rules,
# so this saves some time on slow systems.
.SUFFIXES:

.PHONY: all all-yes alltools check *clean config install*
.PHONY: testprogs uninstall*
