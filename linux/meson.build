if sizeof['long'] == 8
    archbits = '64'
else
    archbits = '32'
endif

if get_option('appimage') == true
    appimagetool = get_option('appimagekit_path')
    if steamworks == true
        meson.add_install_script('make_appimg.sh', appimagetool, archbits, steam_libpath)
    else
        meson.add_install_script('make_appimg.sh', appimagetool, archbits)
    endif
else
    if steamworks == true
        meson.add_install_script('install.sh', archbits, steam_libpath)
    else
        meson.add_install_script('install.sh', archbits)
    endif
endif
