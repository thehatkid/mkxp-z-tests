#!/usr/bin/env ruby

HOST = `clang -dumpmachine`.strip
ARCH = HOST[/x86_64|arm64/]

def run_build(arch)
    printf("\n================================================================================\n")
    printf("  *  Building dependencies. This will take a while...\n")
    printf("================================================================================\n")

    # Build libraries for Apple Silicon if we have atleast Xcode 12.0
    if `xcodebuild -version`.scan(/Xcode (\d+)/)[0][0].to_i >= 12
        printf("\n  *  Building libraries for Apple Silicon (arm64)...\n\n")
        success = system("make -f./arm64.make")
        if !success
            printf("\n\e[31m  *  Something went wrong while building for Apple Silicon...\e[0m\n\n")
            return success
        end
    end

    # Build libraries for Intel x86_64
    printf("\n  *  Building libraries for Intel (x86_64)...\n\n")
    success = system("make -f./x86_64.make")
    if !success
        printf("\n\e[31m  *  Something went wrong while building for Intel...\e[0m\n\n")
        return success
    end

    printf("\n================================================================================\n")
    printf("  *  Performing Post-Setup...\n")
    printf("================================================================================\n")

    # Try to create universal libraries with both x86_64 and arm64 arch if possible
    printf("\n  *  Creating universal libraries...\n")
    ENV['_FROM_SETUP_SH'] = "1"
    success = system("ruby ./make_universal.sh")
    printf("\n\e[31m  *  Something went wrong while creating universal libraries...\e[0m\n\n") if !success
    return success
end

def fix_steam(libpath)
    # Don't need to do anything if it's already set to runpath
    return 0 if (`otool -L #{libpath}`[/@rpath/])

    printf("\n  *  Patching Steamworks SDK library...\n\n")

    # Remove 32-bit code from the binary
    if `lipo -info #{libpath}`[/i386/]
        return 1 if !system("lipo -remove i386 #{libpath} -o #{libpath}")
    end

    # Set the install name to runpath
    return 1 if !system("install_name_tool -id @rpath/libsteam_api.dylib #{libpath}")

    # Resign
    return system("codesign -fs - #{libpath}")
end

# Build all dependencies
exitcode = run_build(ARCH) ? 0 : 1
exit(exitcode) if exitcode != 0

# Fix Steamworks SDK library
STEAM_LIB = "Frameworks/Steamworks/sdk/redistributable_bin/osx/libsteam_api.dylib"
if File.exist?(STEAM_LIB)
    exitcode = fix_steam(STEAM_LIB)
    exit(exitcode) if exitcode != 0
end

printf("\n\e[32m  *  All done!\e[0m\n\n")

exit(0)
