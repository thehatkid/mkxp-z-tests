windows = import('windows')

# mkxp-z Windows resources
windows_resources = windows.compile_resources(
    windows_resource_directory + '/resource-mkxpz.rc',
    depend_files: files(
        windows_resource_directory + '/resource.h',
        windows_resource_directory + '/icon.ico',
        windows_resource_directory + '/mkxpz.manifest'
    )
)

# Steamshim Windows resources
if steamworks == true
    windows_resources_steamshim = windows.compile_resources(
        windows_resource_directory + '/resource-steamshim.rc',
        depend_files: files(
            windows_resource_directory + '/resource.h',
            windows_resource_directory + '/icon.ico',
            windows_resource_directory + '/mkxpz.manifest'
        )
    )
endif
