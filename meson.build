project(
    'mkxp-z',
    ['cpp', 'c'],
    version: '2.4.2',
    license: 'GPLv2',
    meson_version: '>=0.56.0',
    default_options: [
        'cpp_std=c++14',
        'buildtype=release',
        'bindir=.'
    ]
)

host_system = host_machine.system()

if host_system == 'darwin'
    error('\n\nThis Meson project no longer supports macOS. Please use the Xcode project instead.')
endif

compilers = {
    'cpp': meson.get_compiler('cpp')
}

sizeof = {
    'void*': compilers['cpp'].sizeof('void*'),
    'long': compilers['cpp'].sizeof('long')
}

win64 = (sizeof['void*'] != sizeof['long'])

fs = import('fs')

# Get xxd program for embedding assets/shaders into executable
xxd = find_program('xxd', native: true)

# Define global variables of project
global_sources = []
global_dependencies = []
global_include_dirs = []
global_args = []
global_link_args = []
windres_flags = []

# Get latest git commit hash
git_hash = '0000000'
if fs.is_dir('.git')
    git = find_program('git', required: false)
    if git.found()
        git_hash = run_command('git', 'rev-parse', '--short', 'HEAD', capture: true, check: true).stdout().strip()
    else
        warning('Unable to get Git; fallback MKXPZ_GIT_HASH to 0000000')
    endif
else
    warning('".git" directory was not found; fallback MKXPZ_GIT_HASH to 0000000')
endif

if get_option('buildtype') == 'debug'
    global_args += '-DDEBUG'
    windres_flags += '-DDEBUG'
endif

global_args += '-DMKXPZ_BUILD_MESON'
global_args += '-DMKXPZ_VERSION="@0@"'.format(meson.project_version())
global_args += '-DMKXPZ_GIT_HASH="@0@"'.format(git_hash)
global_args += '-DHAVE_NANOSLEEP'

# OpenGL backend
gfx_backend = get_option('gfx_backend')
if gfx_backend == 'gles'
    # Needs to be manually set up for now
    global_args += '-DGLES2_HEADER'
elif gfx_backend == 'gl'
    global_dependencies += dependency('gl')
endif

# Steamworks SDK
steamworks = false
steamworks_path = get_option('steamworks_path')
if steamworks_path != ''
    libname = 'steam_api'

    # Determine directory and library names for 32-bit and 64-bit
    if host_system == 'linux'
        if sizeof['void*'] == 4
            bindir = 'linux32'
        else
            bindir = 'linux64'
        endif
    else
        if win64 == true
            bindir = 'win64'
            libname += '64'
        else
            bindir = ''
        endif
    endif

    steam_libpath = steamworks_path + '/redistributable_bin/' + bindir
    steamlib = compilers['cpp'].find_library(libname, required: false, dirs: [steam_libpath])

    if steamlib.found() == true
        global_include_dirs += include_directories('steamshim')
        global_args += '-DMKXPZ_STEAM'
        global_sources += 'steamshim/steamshim_child.c'
        steamworks = true
    else
        warning('Could not locate Steamworks SDK in ' + steam_libpath)
    endif
endif

# Suppress warnings
global_args += ['-Wno-non-virtual-dtor', '-Wno-reorder', '-Wno-uninitialized', '-Wno-unknown-pragmas', '-Wno-stringop-truncation']
if compilers['cpp'].get_id() == 'clang'
    global_args += ['-Wno-undefined-var-template', '-Wno-delete-non-abstract-non-virtual-dtor']
endif
if host_system == 'windows'
    if compilers['cpp'].get_id() != 'clang'
        global_args += '-masm=intel'
    endif
endif

# Decide whether or not to use MiniFFI
miniffi = get_option('use_miniffi')
if miniffi == true
    miniffi = true
    global_args += '-DMKXPZ_MINIFFI'
endif

# Defines
if get_option('workdir_current')
    global_args += '-DWORKDIR_CURRENT'
endif

if get_option('cxx11_experimental') == true
    global_args += '-DMKXPZ_EXP_FS'
endif

if get_option('force32') == true
    global_args += '-m32'
endif

build_static = false
if get_option('static_executable') == true
    build_static = true
endif

if get_option('cjk_fallback_font') == true
    add_project_arguments('-DMKXPZ_CJK_FONT', language: 'cpp')
endif

global_args += '-DMKXPZ_INIT_GL_LATER'

subdir('src')
subdir('binding')
subdir('shader')
subdir('assets')

global_include_dirs += include_directories('src', 'binding')

rpath = ''
if host_system == 'windows'
    windows_resource_directory = '../' + get_option('windows_resource_directory')
    subdir('windows')
    global_sources += windows_resources
    global_include_dirs += include_directories('windows')
else
    subdir('linux')
    rpath = '$ORIGIN/lib'
    if get_option('appimage') != true
        if sizeof['long'] == 8 and get_option('force32') != true
            rpath += '64'
        else
            rpath += '32'
        endif
    endif
endif

exe_name = meson.project_name().to_lower()

# Steamshim executable target
if steamworks == true
    shim_sources = files('steamshim/steamshim_parent.cpp')

    # Append Windows resources
    if host_system == 'windows'
        shim_sources += windows_resources_steamshim
    endif

    la = ''
    if build_static == true
        if host_system == 'windows'
            la = '-static'
        else
            la = '-static-libgcc -static-libstdc++'
        endif
    endif

    shim_args = [
        '-DGAME_LAUNCH_NAME="' + exe_name + '"',
        '-I' + steamworks_path + '/public'
    ]

    if get_option('steam_appid') != ''
        shim_args += '-DSTEAM_APPID=' + get_option('steam_appid')
    endif

    if get_option('steamshim_debug') == true
        shim_args += '-DSTEAMSHIM_DEBUG'
        shim_ws = 'console,6.0'
    else
        shim_ws = 'windows,6.0'
    endif

    executable(
        'steamshim',
        sources: shim_sources,
        dependencies: steamlib,
        cpp_args: shim_args,
        link_args: la.split(),
        win_subsystem: shim_ws,
        install: true
    )
endif

# mkxp-z executable target
executable(
    exe_name,
    sources: global_sources,
    dependencies: global_dependencies,
    include_directories: global_include_dirs,
    install_rpath: rpath,
    link_args: global_link_args,
    cpp_args: global_args,
    objc_args: global_args,
    objcpp_args: global_args,
    win_subsystem: 'windows,6.0',
    install: true
)
