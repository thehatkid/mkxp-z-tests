embedded_assets = [
    'icon.png',
    'gamecontrollerdb.txt'
]

if get_option('cjk_fallback_font') == true
    embedded_assets += 'wqymicrohei.ttf'
else
    embedded_assets += 'liberation.ttf'
endif

embedded_assets_f = files(embedded_assets)

count = 0
foreach file : embedded_assets_f
    global_sources += custom_target(embedded_assets[count],
        input: file,
        output: '@0@.xxd'.format(embedded_assets[count]),
        command: [xxd, '-i', '@INPUT@'],
        capture: true,
        depend_files: embedded_assets_f[count]
    )
    count += 1
endforeach
