# Dependencies
sdl2 = dependency('SDL2', static: build_static)
sdl2_image = dependency('SDL2_image', method: 'cmake', modules: ['SDL2_image::SDL2_image-static', 'SDL2_image::brotlicommon-static', 'SDL2_image::brotlidec-static', 'SDL2_image::hwy', 'SDL2_image::external_libjxl'], static: build_static)
sdl2_ttf = dependency('SDL2_ttf', method: 'cmake', modules: ['SDL2_ttf::SDL2_ttf-static'], static: build_static)
sdl2_sound = dependency('SDL2_sound', static: build_static)
physfs = dependency('physfs', version: '>=2.1', static: build_static)
openal = dependency('openal', method: 'pkg-config', static: build_static)
freetype = dependency('freetype2', static: build_static)
harfbuzz = dependency('harfbuzz', static: build_static)
pixman = dependency('pixman-1', static: build_static)
ogg = dependency('ogg', static: build_static)
vorbis = dependency('vorbis', static: build_static)
vorbisfile = dependency('vorbisfile', static: build_static)
theora = dependency('theora', static: build_static)
zlib = dependency('zlib', static: build_static)
uchardet = dependency('uchardet', static: build_static)

if host_system == 'windows'
    iconv = compilers['cpp'].find_library('iconv', static: build_static)
else
    # FIXME: Specifically asking for static doesn't work if iconv isn't
    # installed in the system prefix somewhere
    iconv = compilers['cpp'].find_library('iconv')
    global_dependencies += compilers['cpp'].find_library('charset')
endif

if get_option('enable-https') == true
    openssl = dependency('openssl', required: false, static: build_static)
    if openssl.found() == true
        global_dependencies += openssl
        global_args += '-DMKXPZ_SSL'
        if host_system == 'windows'
            global_link_args += '-lcrypt32'
        endif
    else
        warning('Could not locate OpenSSL. HTTPS will be disabled.')
    endif
endif

if build_static == true
    if host_system == 'windows'
        # '-static-libgcc', '-static-libstdc++' are here to avoid needing to ship a separate libgcc_s_seh-1.dll on Windows.
        # It still works without those flags if you have the DLLs.
        global_link_args += ['-static-libgcc', '-static-libstdc++', '-Wl,-Bstatic', '-lgcc', '-lstdc++', '-lpthread', '-Wl,-Bdynamic']
    else
        global_link_args += ['-static-libgcc', '-static-libstdc++']
    endif
    global_args += '-DAL_LIBTYPE_STATIC'
endif

explicit_libs = ''
if host_system == 'windows'
    # Newer versions of Ruby will refuse to link without these
    explicit_libs += 'libmsvcrt;libgcc;libmingwex;libgmp;'
endif

foreach l : explicit_libs.split(';')
    if l != ''
        global_link_args += '-l:' + l + '.a'
    endif
endforeach

alcdev_struct = 'ALCdevice_struct'
if openal.type_name() == 'pkgconfig'
    if openal.version().version_compare('>=1.20.1')
        alcdev_struct = 'ALCdevice'
    endif
endif
global_args += '-DMKXPZ_ALCDEVICE=' + alcdev_struct

# Add dependencies
global_dependencies += [sdl2, sdl2_image, sdl2_ttf, sdl2_sound, physfs, openal, freetype, harfbuzz, pixman, ogg, vorbis, vorbisfile, theora, zlib, iconv, uchardet]

if host_system == 'windows'
    global_dependencies += compilers['cpp'].find_library('wsock32')
endif

if get_option('shared_fluid') == true
    fluidsynth = dependency('fluidsynth', static: build_static)
    add_project_arguments('-DSHARED_FLUID', language: 'cpp')
    global_dependencies += fluidsynth
    if host_system == 'windows'
        global_dependencies += compilers['cpp'].find_library('dsound')
    endif
endif

# Add mkxp-z include directories
global_include_dirs += include_directories(
    '.',
    'audio',
    'crypto',
    'display',
    'display/gl',
    'display/libnsgif',
    'display/libnsgif/utils',
    'etc',
    'filesystem',
    'filesystem/ghc',
    'input',
    'net',
    'system',
    'util',
    'util/sigslot',
    'util/sigslot/adapter'
)

# Add mkxp-z source files
global_sources += files(
    'main.cpp',
    'config.cpp',
    'eventthread.cpp',
    'settingsmenu.cpp',
    'sharedstate.cpp',

    'audio/alstream.cpp',
    'audio/audio.cpp',
    'audio/audiostream.cpp',
    'audio/fluid-fun.cpp',
    'audio/midisource.cpp',
    'audio/sdlsoundsource.cpp',
    'audio/soundemitter.cpp',
    'audio/vorbissource.cpp',
    'theoraplay/theoraplay.c',

    'crypto/rgssad.cpp',

    'display/autotiles.cpp',
    'display/autotilesvx.cpp',
    'display/bitmap.cpp',
    'display/font.cpp',
    'display/graphics.cpp',
    'display/plane.cpp',
    'display/sprite.cpp',
    'display/tilemap.cpp',
    'display/tilemapvx.cpp',
    'display/viewport.cpp',
    'display/window.cpp',
    'display/windowvx.cpp',

    'display/libnsgif/libnsgif.c',
    'display/libnsgif/lzw.c',

    'display/gl/gl-debug.cpp',
    'display/gl/gl-fun.cpp',
    'display/gl/gl-meta.cpp',
    'display/gl/glstate.cpp',
    'display/gl/scene.cpp',
    'display/gl/shader.cpp',
    'display/gl/texpool.cpp',
    'display/gl/tileatlas.cpp',
    'display/gl/tileatlasvx.cpp',
    'display/gl/tilequad.cpp',
    'display/gl/vertex.cpp',

    'util/iniconfig.cpp',
    'util/win-consoleutils.cpp',

    'etc/etc.cpp',
    'etc/table.cpp',

    'filesystem/filesystem.cpp',
    'filesystem/filesystemImpl.cpp',

    'input/input.cpp',
    'input/keybindings.cpp',

    'net/LUrlParser.cpp',
    'net/net.cpp',

    'system/systemImpl.cpp'
)
