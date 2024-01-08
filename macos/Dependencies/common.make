# Makefile options:

# Specifies number of jobs at once for the build targets.
# "make NPROC=2" to build targets with only 2 processing units (threads).
# (default: max count of available processing units on current host)
NPROC := $(shell sysctl -n hw.ncpu)

# Enables Link-Time Optimization for Ruby to improve performance,
# but increases compile time. "make LTO=1" to build Ruby with LTO.
# (default: 0 (false))
LTO := 0

# Whether build SDL_image with JPEG XL (JXL) decoding support.
# This also means additional downloading libjxl and their dependencies.
# "make SDL_IMAGE_JXL=1" to build SDL2_image with JXL support.
# (default: 1 (true))
SDL_IMAGE_JXL := 1


# ==============================================================================


DEPLOYMENT_TARGET_FLAGS := -mmacosx-version-min=$(MINIMUM_REQUIRED)
DEPLOYMENT_TARGET_ENV   := MACOSX_DEPLOYMENT_TARGET="$(MINIMUM_REQUIRED)"

# Need to specify "--build" argument for Ruby build
ifeq ($(strip $(shell uname -m)), "arm64")
	RUBY_BUILD := aarch64-apple-darwin
else
	RUBY_BUILD := $(ARCH)-apple-darwin
endif

# Declare directories
PREFIX := $(PWD)/build-$(ARCH)
DLDIR  := $(PWD)/downloads/$(HOST)
BINDIR := $(PREFIX)/bin
LIBDIR := $(PREFIX)/lib
INCDIR := $(PREFIX)/include
PKGDIR := $(PREFIX)/lib/pkgconfig

# Variables for compiling
CC      := clang -arch $(ARCH)
CFLAGS  := -I$(INCDIR) $(DEPLOYMENT_TARGET_FLAGS) -O3
LDFLAGS := -L$(LIBDIR)

GIT := git clone -q -c advice.detachedHead=false --single-branch --no-tags --depth 1

CONFIGURE_ENV  := $(DEPLOYMENT_TARGET_ENV) PKG_CONFIG_LIBDIR="$(PKGDIR)" CC="$(CC)" CFLAGS="$(CFLAGS)" LDFLAGS="$(LDFLAGS)"
CONFIGURE_ARGS := --prefix="$(PREFIX)" --libdir="$(PREFIX)/lib" --host="$(HOST)"

CMAKE_ARGS := \
	-DCMAKE_INSTALL_PREFIX="$(PREFIX)" \
	-DCMAKE_PREFIX_PATH="$(PREFIX)" \
	-DCMAKE_OSX_ARCHITECTURES="$(ARCH)" \
	-DCMAKE_OSX_DEPLOYMENT_TARGET="$(MINIMUM_REQUIRED)" \
	-DCMAKE_C_FLAGS="$(CFLAGS)" \
	-DCMAKE_BUILD_TYPE=Release

RUBY_CONFIGURE_ARGS := \
	--build="$(RUBY_BUILD)" \
	--enable-shared \
	--enable-install-static-library \
	--disable-install-doc \
	--disable-install-rdoc \
	--disable-install-capi \
	--disable-rubygems \
	--enable-mkmf-verbose \
	--without-gmp \
	--with-zlib-dir="$(PREFIX)" \
	--with-libyaml-dir="$(PREFIX)" \
	--with-libffi-dir="$(PREFIX)" \
	--with-openssl-dir="$(PREFIX)" \
	--with-static-linked-ext \
	--with-out-ext=readline,pty,syslog,win32,win32ole

CONFIGURE := $(CONFIGURE_ENV) ./configure $(CONFIGURE_ARGS)
AUTOGEN   := $(CONFIGURE_ENV) ./autogen.sh $(CONFIGURE_ARGS)
CMAKE     := $(CONFIGURE_ENV) cmake -S . -B build $(CMAKE_ARGS)


# ==============================================================================


all: download build


# Download target recipes
download: \
	$(DLDIR) \
	$(DLDIR)/libogg/CMakeLists.txt \
	$(DLDIR)/libvorbis/CMakeLists.txt \
	$(DLDIR)/libtheora/autogen.sh \
	$(DLDIR)/zlib/configure \
	$(DLDIR)/physfs/CMakeLists.txt \
	$(DLDIR)/uchardet/CMakeLists.txt \
	$(DLDIR)/libpng/CMakeLists.txt \
	$(DLDIR)/libjpeg/CMakeLists.txt \
	$(DLDIR)/pixman/autogen.sh \
	$(DLDIR)/harfbuzz/CMakeLists.txt \
	$(DLDIR)/freetype/CMakeLists.txt \
	$(DLDIR)/sdl2/CMakeLists.txt \
	$(DLDIR)/sdl2_image/CMakeLists.txt \
	$(DLDIR)/sdl2_ttf/CMakeLists.txt \
	$(DLDIR)/sdl2_sound/CMakeLists.txt \
	$(DLDIR)/openal/CMakeLists.txt \
	$(DLDIR)/libyaml/CMakeLists.txt \
	$(DLDIR)/libffi/configure.ac \
	$(DLDIR)/openssl/Configure \
	$(DLDIR)/ruby/configure.ac

# Build target recipes
build: \
	libogg \
	libvorbis \
	libtheora \
	zlib \
	physfs \
	uchardet \
	libpng \
	libjpeg \
	pixman \
	harfbuzz \
	freetype \
	harfbuzz-ft \
	sdl2 \
	sdl2_image \
	sdl2_ttf \
	sdl2_sound \
	openal \
	openssl \
	ruby


init: $(DLDIR) $(BINDIR) $(LIBDIR) $(INCDIR)

$(DLDIR):
	@mkdir -p $(DLDIR)

$(BINDIR):
	@mkdir -p $(BINDIR)

$(LIBDIR):
	@mkdir -p $(LIBDIR)

$(INCDIR):
	@mkdir -p $(INCDIR)


clean: clean-download clean-prefix

clean-download:
	@printf "\e[91m=>\e[0m \e[35mCleaning download folder...\e[0m\n"
	@rm -rf $(DLDIR)

clean-prefix:
	@printf "\e[91m=>\e[0m \e[35mCleaning prefix folder...\e[0m\n"
	@rm -rf $(PREFIX)


.PHONY: \
	all download build init clean clean-download clean-prefix \
	libogg libvorbis libtheora zlib physfs uchardet libpng libjpeg \
	pixman harfbuzz freetype harfbuzz-ft sdl2 sdl2_image sdl2_ttf sdl2_sound \
	openal libyaml libffi openssl ruby


# ================================= Xiph codecs ================================

# ------------------------------------- Ogg ------------------------------------
libogg: init $(LIBDIR)/libogg.a

$(LIBDIR)/libogg.a: $(DLDIR)/libogg/build/Makefile
	@printf "\e[94m=>\e[0m \e[36mBuilding libogg...\e[0m\n"
	@cd $(DLDIR)/libogg/build; make -j$(NPROC); make install

$(DLDIR)/libogg/build/Makefile: $(DLDIR)/libogg/CMakeLists.txt
	@printf "\e[94m=>\e[0m \e[36mConfiguring libogg...\e[0m\n"
	cd $(DLDIR)/libogg; $(CMAKE) -DBUILD_SHARED_LIBS=NO -DINSTALL_DOCS=NO -DBUILD_TESTING=NO

$(DLDIR)/libogg/CMakeLists.txt:
	@printf "\e[94m=>\e[0m \e[36mDownloading libogg 1.3.5...\e[0m\n"
	@$(GIT) -b v1.3.5 https://github.com/xiph/ogg $(DLDIR)/libogg

# ----------------------------------- Vorbis -----------------------------------
libvorbis: init libogg $(LIBDIR)/libvorbis.a

$(LIBDIR)/libvorbis.a: $(DLDIR)/libvorbis/build/Makefile
	@printf "\e[94m=>\e[0m \e[36mBuilding libvorbis...\e[0m\n"
	@cd $(DLDIR)/libvorbis/build; make -j$(NPROC); make install

$(DLDIR)/libvorbis/build/Makefile: $(DLDIR)/libvorbis/CMakeLists.txt
	@printf "\e[94m=>\e[0m \e[36mConfiguring libvorbis...\e[0m\n"
	cd $(DLDIR)/libvorbis; $(CMAKE) -DBUILD_SHARED_LIBS=NO

$(DLDIR)/libvorbis/CMakeLists.txt:
	@printf "\e[94m=>\e[0m \e[36mDownloading libvorbis 1.3.7...\e[0m\n"
	@$(GIT) -b v1.3.7 https://github.com/xiph/vorbis $(DLDIR)/libvorbis

# ----------------------------------- Theora -----------------------------------
libtheora: init libogg libvorbis $(LIBDIR)/libtheora.a

$(LIBDIR)/libtheora.a: $(DLDIR)/libtheora/Makefile
	@printf "\e[94m=>\e[0m \e[36mBuilding libtheora...\e[0m\n"
	@cd $(DLDIR)/libtheora; make -j$(NPROC); make install

$(DLDIR)/libtheora/Makefile: $(DLDIR)/libtheora/configure
	@printf "\e[94m=>\e[0m \e[36mConfiguring libtheora...\e[0m\n"
	cd $(DLDIR)/libtheora; \
	$(CONFIGURE) --enable-static=true --enable-shared=false \
	--disable-doc --disable-spec --disable-examples --disable-encode

$(DLDIR)/libtheora/configure: $(DLDIR)/libtheora/autogen.sh
	cd $(DLDIR)/libtheora; ./autogen.sh

$(DLDIR)/libtheora/autogen.sh:
	@printf "\e[94m=>\e[0m \e[36mDownloading libtheora 1.2.0alpha1+git...\e[0m\n"
	@$(GIT) -b master https://github.com/xiph/theora $(DLDIR)/libtheora


# =============================== Misc libraries ===============================

# ------------------------------------ Zlib ------------------------------------
zlib: init $(LIBDIR)/libz.a

$(LIBDIR)/libz.a: $(DLDIR)/zlib/configure
	@printf "\e[94m=>\e[0m \e[36mBuilding Zlib...\e[0m\n"
	cd $(DLDIR)/zlib; export $(CONFIGURE_ENV); export CFLAGS="$$CFLAGS -fPIC"; \
	./configure --prefix="$(PREFIX)" --static; make -j$(NPROC); make install

$(DLDIR)/zlib/configure:
	@printf "\e[94m=>\e[0m \e[36mDownloading Zlib 1.3...\e[0m\n"
	@$(GIT) -b v1.3 https://github.com/madler/zlib $(DLDIR)/zlib

# ----------------------------------- PhysFS -----------------------------------
physfs: init $(LIBDIR)/libphysfs.a

$(LIBDIR)/libphysfs.a: $(DLDIR)/physfs/build/Makefile
	@printf "\e[94m=>\e[0m \e[36mBuilding PhysFS...\e[0m\n"
	@cd $(DLDIR)/physfs/build; make -j$(NPROC); make install

$(DLDIR)/physfs/build/Makefile: $(DLDIR)/physfs/CMakeLists.txt
	@printf "\e[94m=>\e[0m \e[36mConfiguring PhysFS...\e[0m\n"
	cd $(DLDIR)/physfs; $(CMAKE) \
	-DPHYSFS_BUILD_STATIC=YES -DPHYSFS_BUILD_SHARED=NO -DPHYSFS_BUILD_DOCS=NO

$(DLDIR)/physfs/CMakeLists.txt:
	@printf "\e[94m=>\e[0m \e[36mDownloading PhysFS 3.2.0...\e[0m\n"
	@$(GIT) -b release-3.2.0 https://github.com/icculus/physfs $(DLDIR)/physfs

# ---------------------------------- uchardet ----------------------------------
uchardet: init $(LIBDIR)/libuchardet.a

$(LIBDIR)/libuchardet.a: $(DLDIR)/uchardet/build/Makefile
	@printf "\e[94m=>\e[0m \e[36mBuilding uchardet...\e[0m\n"
	@cd $(DLDIR)/uchardet/build; make -j$(NPROC); make install

$(DLDIR)/uchardet/build/Makefile: $(DLDIR)/uchardet/CMakeLists.txt
	@printf "\e[94m=>\e[0m \e[36mConfiguring uchardet...\e[0m\n"
	cd $(DLDIR)/uchardet; $(CMAKE) \
	-DBUILD_STATIC=YES -DBUILD_SHARED_LIBS=NO -DBUILD_BINARY=NO

$(DLDIR)/uchardet/CMakeLists.txt:
	@printf "\e[94m=>\e[0m \e[36mDownloading uchardet 0.0.8...\e[0m\n"
	@$(GIT) -b v0.0.8 https://gitlab.freedesktop.org/uchardet/uchardet.git $(DLDIR)/uchardet


# =============================== Image libraries ==============================

# ----------------------------------- libpng -----------------------------------
libpng: init zlib $(LIBDIR)/libpng.a

$(LIBDIR)/libpng.a: $(DLDIR)/libpng/build/Makefile
	@printf "\e[94m=>\e[0m \e[36mBuilding libpng...\e[0m\n"
	@cd $(DLDIR)/libpng/build; make -j$(NPROC); make install

$(DLDIR)/libpng/build/Makefile: $(DLDIR)/libpng/CMakeLists.txt
	@printf "\e[94m=>\e[0m \e[36mConfiguring libpng...\e[0m\n"
	cd $(DLDIR)/libpng; $(CMAKE) \
	-DPNG_STATIC=YES -DPNG_SHARED=NO -DPNG_EXECUTABLES=NO -DPNG_TESTS=NO

$(DLDIR)/libpng/CMakeLists.txt:
	@printf "\e[94m=>\e[0m \e[36mDownloading libpng 1.6.40...\e[0m\n"
	@$(GIT) -b v1.6.40 https://github.com/glennrp/libpng $(DLDIR)/libpng

# ----------------------------------- libjpeg ----------------------------------
libjpeg: init $(LIBDIR)/libjpeg.a

$(LIBDIR)/libjpeg.a: $(DLDIR)/libjpeg/build/Makefile
	@printf "\e[94m=>\e[0m \e[36mBuilding libjpeg-turbo...\e[0m\n"
	@cd $(DLDIR)/libjpeg/build; make -j$(NPROC); make install

$(DLDIR)/libjpeg/build/Makefile: $(DLDIR)/libjpeg/CMakeLists.txt
	@printf "\e[94m=>\e[0m \e[36mConfiguring libjpeg-turbo...\e[0m\n"
	cd $(DLDIR)/libjpeg; $(CMAKE) -DENABLE_STATIC=YES -DENABLE_SHARED=NO \
	-DWITH_SIMD=NO

$(DLDIR)/libjpeg/CMakeLists.txt:
	@printf "\e[94m=>\e[0m \e[36mDownloading libjpeg-turbo 3.0.1...\e[0m\n"
	@$(GIT) -b 3.0.1 https://github.com/libjpeg-turbo/libjpeg-turbo $(DLDIR)/libjpeg

# ----------------------------------- Pixman -----------------------------------
pixman: init libpng $(LIBDIR)/libpixman-1.a

$(LIBDIR)/libpixman-1.a: $(DLDIR)/pixman/Makefile
	@printf "\e[94m=>\e[0m \e[36mBuilding Pixman...\e[0m\n"
	@cd $(DLDIR)/pixman; make -j$(NPROC); make install

$(DLDIR)/pixman/Makefile: $(DLDIR)/pixman/autogen.sh
	@printf "\e[94m=>\e[0m \e[36mConfiguring Pixman...\e[0m\n"
	cd $(DLDIR)/pixman; $(AUTOGEN) --enable-static=yes --enable-shared=no \
	--disable-gtk --disable-libpng --disable-arm-neon --disable-arm-a64-neon

$(DLDIR)/pixman/autogen.sh:
	@printf "\e[94m=>\e[0m \e[36mDownloading Pixman 0.42.2...\e[0m\n"
	@$(GIT) -b pixman-0.42.2 https://gitlab.freedesktop.org/pixman/pixman.git $(DLDIR)/pixman


# ================================ Text shaping ================================

# ---------------------------------- HarfBuzz ----------------------------------
harfbuzz: init $(LIBDIR)/libharfbuzz.a

$(LIBDIR)/libharfbuzz.a: $(DLDIR)/harfbuzz/build/Makefile
	@printf "\e[94m=>\e[0m \e[36mBuilding HarfBuzz...\e[0m\n"
	@cd $(DLDIR)/harfbuzz/build; make -j$(NPROC); make install
	@touch $(LIBDIR)/libharfbuzz.a

$(DLDIR)/harfbuzz/build/Makefile: $(DLDIR)/harfbuzz/CMakeLists.txt
	@printf "\e[94m=>\e[0m \e[36mConfiguring HarfBuzz...\e[0m\n"
	cd $(DLDIR)/harfbuzz; $(CMAKE) -DHB_BUILD_SUBSET=NO

$(DLDIR)/harfbuzz/CMakeLists.txt:
	@printf "\e[94m=>\e[0m \e[36mDownloading HarfBuzz 8.3.0...\e[0m\n"
	@$(GIT) -b 8.3.0 https://github.com/harfbuzz/harfbuzz $(DLDIR)/harfbuzz

# ---------------------------------- FreeType ----------------------------------
freetype: init zlib libpng harfbuzz $(LIBDIR)/libfreetype.a

$(LIBDIR)/libfreetype.a: $(DLDIR)/freetype/build/Makefile
	@printf "\e[94m=>\e[0m \e[36mBuilding FreeType...\e[0m\n"
	@cd $(DLDIR)/freetype/build; make -j$(NPROC); make install

$(DLDIR)/freetype/build/Makefile: $(DLDIR)/freetype/CMakeLists.txt
	@printf "\e[94m=>\e[0m \e[36mConfiguring FreeType...\e[0m\n"
	cd $(DLDIR)/freetype; $(CMAKE) \
	-DFT_REQUIRE_HARFBUZZ=YES -DFT_DISABLE_BZIP2=YES -DFT_DISABLE_BROTLI=YES

$(DLDIR)/freetype/CMakeLists.txt:
	@printf "\e[94m=>\e[0m \e[36mDownloading FreeType 2.13.2...\e[0m\n"
	@$(GIT) -b VER-2-13-2 https://gitlab.freedesktop.org/freetype/freetype.git $(DLDIR)/freetype

# ------------------------- HarfBuzz + FreeType interop ------------------------

harfbuzz-ft: init harfbuzz freetype $(DLDIR)/harfbuzz/build/.ft-interop

$(DLDIR)/harfbuzz/build/.ft-interop:
	cd $(DLDIR)/harfbuzz; $(CMAKE) -DHB_HAVE_FREETYPE=YES
	cd $(DLDIR)/harfbuzz/build; make -j$(NPROC); make install
	touch $(DLDIR)/harfbuzz/build/.ft-interop
	touch $(LIBDIR)/libharfbuzz.a


# ============================== SDL2 and modules ==============================

# ------------------------------------ SDL2 ------------------------------------
sdl2: init $(LIBDIR)/libSDL2.a

$(LIBDIR)/libSDL2.a: $(DLDIR)/sdl2/build/Makefile
	@printf "\e[94m=>\e[0m \e[36mBuilding SDL2...\e[0m\n"
	@cd $(DLDIR)/sdl2/build; make -j$(NPROC); make install

$(DLDIR)/sdl2/build/Makefile: $(DLDIR)/sdl2/CMakeLists.txt
	@printf "\e[94m=>\e[0m \e[36mConfiguring SDL2...\e[0m\n"
	cd $(DLDIR)/sdl2; $(CMAKE) -DSDL_STATIC=YES -DSDL_SHARED=NO

$(DLDIR)/sdl2/CMakeLists.txt:
	@printf "\e[94m=>\e[0m \e[36mDownloading SDL2 2.28.5...\e[0m\n"
	@$(GIT) -b release-2.28.5 https://github.com/libsdl-org/SDL $(DLDIR)/sdl2

# --------------------------------- SDL2_image ---------------------------------
sdl2_image: init sdl2 libpng libjpeg $(LIBDIR)/libSDL2_image.a

$(LIBDIR)/libSDL2_image.a: $(DLDIR)/sdl2_image/build/Makefile
	@printf "\e[94m=>\e[0m \e[36mBuilding SDL2_image...\e[0m\n"
	@cd $(DLDIR)/sdl2_image/build; make -j$(NPROC); make install

$(DLDIR)/sdl2_image/build/Makefile: $(DLDIR)/sdl2_image/CMakeLists.txt
	@printf "\e[94m=>\e[0m \e[36mConfiguring SDL2_image...\e[0m\n"
	cd $(DLDIR)/sdl2_image; $(CMAKE) -DBUILD_SHARED_LIBS=NO \
	-DSDL2IMAGE_DEPS_SHARED=NO -DSDL2IMAGE_VENDORED=NO -DSDL2IMAGE_SAMPLES=NO
ifeq ($(SDL_IMAGE_JXL),1)
	cd $(DLDIR)/sdl2_image/build; \
	cmake .. -DSDL2IMAGE_VENDORED=YES -DSDL2IMAGE_JXL=YES -DJPEGXL_ENABLE_OPENEXR=NO
endif

$(DLDIR)/sdl2_image/CMakeLists.txt:
	@printf "\e[94m=>\e[0m \e[36mDownloading SDL2_image 2.8.1...\e[0m\n"
	@$(GIT) -b release-2.8.1 https://github.com/libsdl-org/SDL_image $(DLDIR)/sdl2_image
ifeq ($(SDL_IMAGE_JXL),1)
	@printf "\e[94m=>\e[0m \e[36mDownloading libjxl for SDL2_image...\e[0m\n"
	@cd $(DLDIR)/sdl2_image; git submodule update -q --init --recursive external/libjxl
endif

# ---------------------------------- SDL2_ttf ----------------------------------
sdl2_ttf: init sdl2 freetype harfbuzz $(LIBDIR)/libSDL2_ttf.a

$(LIBDIR)/libSDL2_ttf.a: $(DLDIR)/sdl2_ttf/build/Makefile
	@printf "\e[94m=>\e[0m \e[36mBuilding SDL2_ttf...\e[0m\n"
	@cd $(DLDIR)/sdl2_ttf/build; make -j$(NPROC); make install

$(DLDIR)/sdl2_ttf/build/Makefile: $(DLDIR)/sdl2_ttf/CMakeLists.txt
	@printf "\e[94m=>\e[0m \e[36mConfiguring SDL2_ttf...\e[0m\n"
	cd $(DLDIR)/sdl2_ttf; $(CMAKE) \
	-DBUILD_SHARED_LIBS=NO -DSDL2TTF_SAMPLES=NO -DSDL2TTF_HARFBUZZ=YES

$(DLDIR)/sdl2_ttf/CMakeLists.txt:
	@printf "\e[94m=>\e[0m \e[36mDownloading SDL2_ttf 2.20.2...\e[0m\n"
	@$(GIT) -b release-2.20.2 https://github.com/libsdl-org/SDL_ttf $(DLDIR)/sdl2_ttf

# --------------------------------- SDL2_sound ---------------------------------
sdl2_sound: init sdl2 libogg libvorbis $(LIBDIR)/libSDL2_sound.a

$(LIBDIR)/libSDL2_sound.a: $(DLDIR)/sdl2_sound/build/Makefile
	@printf "\e[94m=>\e[0m \e[36mBuilding SDL2_sound...\e[0m\n"
	@cd $(DLDIR)/sdl2_sound/build; make -j$(NPROC); make install

$(DLDIR)/sdl2_sound/build/Makefile: $(DLDIR)/sdl2_sound/CMakeLists.txt
	@printf "\e[94m=>\e[0m \e[36mConfiguring SDL2_sound...\e[0m\n"
	cd $(DLDIR)/sdl2_sound; $(CMAKE) -DSDLSOUND_BUILD_STATIC=YES \
	-DSDLSOUND_BUILD_SHARED=NO -DSDLSOUND_BUILD_TEST=NO

$(DLDIR)/sdl2_sound/CMakeLists.txt:
	@printf "\e[94m=>\e[0m \e[36mDownloading SDL2_sound 2.0.2...\e[0m\n"
	@$(GIT) -b v2.0.2 https://github.com/icculus/SDL_sound $(DLDIR)/sdl2_sound


# =============================== Audio backends ===============================

# ----------------------------------- OpenAL -----------------------------------
openal: init libogg $(LIBDIR)/libopenal.a

$(LIBDIR)/libopenal.a: $(DLDIR)/openal/build/Makefile
	@printf "\e[94m=>\e[0m \e[36mBuilding OpenAL...\e[0m\n"
	@cd $(DLDIR)/openal/build; make -j$(NPROC); make install

$(DLDIR)/openal/build/Makefile: $(DLDIR)/openal/CMakeLists.txt
	@printf "\e[94m=>\e[0m \e[36mConfiguring OpenAL...\e[0m\n"
	cd $(DLDIR)/openal; $(CMAKE) -DLIBTYPE=STATIC -DALSOFT_UTILS=NO \
	-DALSOFT_EXAMPLES=NO -DALSOFT_EMBED_HRTF_DATA=YES

$(DLDIR)/openal/CMakeLists.txt:
	@printf "\e[94m=>\e[0m \e[36mDownloading OpenAL 1.23.1...\e[0m\n"
	@$(GIT) -b 1.23.1 https://github.com/kcat/openal-soft $(DLDIR)/openal


# ============================== Ruby 3.1 and etc. =============================

# ----------------------------- libyaml (for Ruby) -----------------------------

libyaml: init $(LIBDIR)/libyaml.a

$(LIBDIR)/libyaml.a: $(DLDIR)/libyaml/build/Makefile
	@printf "\e[94m=>\e[0m \e[36mBuilding libyaml...\e[0m\n"
	@cd $(DLDIR)/libyaml/build; make -j$(NPROC); make install

$(DLDIR)/libyaml/build/Makefile: $(DLDIR)/libyaml/CMakeLists.txt
	@printf "\e[94m=>\e[0m \e[36mConfiguring libyaml...\e[0m\n"
	cd $(DLDIR)/libyaml; $(CMAKE) -DBUILD_SHARED_LIBS=NO -DBUILD_TESTING=NO \
	-DCMAKE_POSITION_INDEPENDENT_CODE=YES -DINSTALL_CMAKE_DIR="lib/cmake/yaml"

$(DLDIR)/libyaml/CMakeLists.txt:
	@printf "\e[94m=>\e[0m \e[36mDownloading libyaml 0.2.5...\e[0m\n"
	@$(GIT) -b 0.2.5 https://github.com/yaml/libyaml $(DLDIR)/libyaml

# --------------------------- libffi (for Fiddle ext) --------------------------
libffi: init $(LIBDIR)/libffi.a

$(LIBDIR)/libffi.a: $(DLDIR)/libffi/Makefile
	@printf "\e[94m=>\e[0m \e[36mBuilding libffi...\e[0m\n"
	@cd $(DLDIR)/libffi; make -j$(NPROC); make install

$(DLDIR)/libffi/Makefile: $(DLDIR)/libffi/configure
	@printf "\e[94m=>\e[0m \e[36mConfiguring libffi...\e[0m\n"
	cd $(DLDIR)/libffi; \
	export $(CONFIGURE_ENV); export CFLAGS="-fPIC $$CFLAGS"; \
	./configure $(CONFIGURE_ARGS) --disable-shared --enable-static --disable-docs

$(DLDIR)/libffi/configure: $(DLDIR)/libffi/configure.ac
	cd $(DLDIR)/libffi; autoreconf -i

$(DLDIR)/libffi/configure.ac:
	@printf "\e[94m=>\e[0m \e[36mDownloading libffi 3.4.4...\e[0m\n"
	@$(GIT) -b v3.4.4 https://github.com/libffi/libffi $(DLDIR)/libffi

# --------------------------------- OpenSSL 3.0 --------------------------------
openssl: init $(LIBDIR)/libssl.a

$(LIBDIR)/libssl.a: $(DLDIR)/openssl/Makefile
	@printf "\e[94m=>\e[0m \e[36mBuilding OpenSSL...\e[0m\n"
	@cd $(DLDIR)/openssl; make -j$(NPROC); make install_sw

$(DLDIR)/openssl/Makefile: $(DLDIR)/openssl/Configure
	@printf "\e[94m=>\e[0m \e[36mConfiguring OpenSSL...\e[0m\n"
	cd $(DLDIR)/openssl; \
	$(DEPLOYMENT_TARGET_ENV) CFLAGS="$(DEPLOYMENT_TARGET_FLAGS)" \
	./Configure $(OPENSSL_TARGET) no-shared no-makedepend no-tests \
	--prefix="$(PREFIX)" --libdir="lib" --openssldir="$(PREFIX)/ssl"

$(DLDIR)/openssl/Configure:
	@printf "\e[94m=>\e[0m \e[36mDownloading OpenSSL 3.0.12...\e[0m\n"
	@$(GIT) -b openssl-3.0.12 https://github.com/openssl/openssl $(DLDIR)/openssl

# ---------------------------------- Ruby 3.1 ----------------------------------
ruby: init zlib libyaml libffi openssl $(LIBDIR)/libruby.3.1.dylib

$(LIBDIR)/libruby.3.1.dylib: $(DLDIR)/ruby/Makefile
	@printf "\e[94m=>\e[0m \e[36mBuilding Ruby...\e[0m\n"
	cd $(DLDIR)/ruby; \
	$(CONFIGURE_ENV) make -j$(NPROC); $(CONFIGURE_ENV) make install; \
	install_name_tool -id @rpath/libruby.3.1.dylib $(LIBDIR)/libruby.3.1.dylib

$(DLDIR)/ruby/Makefile: $(DLDIR)/ruby/configure
	@printf "\e[94m=>\e[0m \e[36mConfiguring Ruby...\e[0m\n"
ifeq ($(LTO),1)
	cd $(DLDIR)/ruby; \
	export $(CONFIGURE_ENV); \
	export CFLAGS="$$CFLAGS -DRUBY_FUNCTION_NAME_STRING=__func__ -flto=full"; \
	export LDFLAGS="$$LDFLAGS -flto=full"; \
	./configure $(CONFIGURE_ARGS) $(RUBY_CONFIGURE_ARGS)
else
	cd $(DLDIR)/ruby; \
	export $(CONFIGURE_ENV); \
	export CFLAGS="$$CFLAGS -DRUBY_FUNCTION_NAME_STRING=__func__"; \
	./configure $(CONFIGURE_ARGS) $(RUBY_CONFIGURE_ARGS)
endif

$(DLDIR)/ruby/configure: $(DLDIR)/ruby/configure.ac
	cd $(DLDIR)/ruby; autoreconf -i

$(DLDIR)/ruby/configure.ac:
	@printf "\e[94m=>\e[0m \e[36mDownloading Ruby 3.1.4...\e[0m\n"
	@$(GIT) -b v3_1_4 https://github.com/ruby/ruby $(DLDIR)/ruby
