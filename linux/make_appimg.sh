#!/bin/bash

if [[ -z "$MESON_SOURCE_ROOT" ]] || [[ -z "$MESON_INSTALL_PREFIX" ]]; then
  echo "This script can be only used in Meson builds." >&2
  exit 1
fi

APPIMAGETOOL=$1
BITS=$2
STEAM_PATH=$3

source "$MESON_SOURCE_ROOT/linux/vars.sh"

# Prepare AppDir structure
mkdir -p "$MESON_INSTALL_PREFIX/usr/lib"
mkdir -p "$MESON_INSTALL_PREFIX/usr/share/applications"
mkdir -p "$MESON_INSTALL_PREFIX/usr/share/icons/hicolor/256x256/apps"

# Copy AppImage files
echo "Installing AppRun..."
cp -pu "$MESON_SOURCE_ROOT/linux/AppRun" "$MESON_INSTALL_PREFIX/"
chmod +x "$MESON_INSTALL_PREFIX/AppRun"

echo "Installing mkxp-z.desktop..."
cp -pu "$MESON_SOURCE_ROOT/linux/mkxp-z.desktop" "$MESON_INSTALL_PREFIX/"
chmod +x "$MESON_INSTALL_PREFIX/mkxp-z.desktop"
ln -sf "$MESON_INSTALL_PREFIX/mkxp-z.desktop" "$MESON_INSTALL_PREFIX/usr/share/applications/mkxp-z.desktop"

echo "Installing mkxp-z.png..."
cp -pu "$MESON_SOURCE_ROOT/linux/mkxp-z.png" "$MESON_INSTALL_PREFIX/"
ln -sf "$MESON_INSTALL_PREFIX/mkxp-z.png" "$MESON_INSTALL_PREFIX/usr/share/icons/hicolor/256x256/apps/mkxp-z.png"

# Patch RPATH in executables
echo "Patching mkxp-z RPATH..."
patchelf "$MESON_INSTALL_PREFIX/usr/bin/mkxp-z" --set-rpath "\$ORIGIN/../lib"

if [[ -n "$STEAM_PATH" ]]; then
  echo "Patching steamshim RPATH..."
  patchelf "$MESON_INSTALL_PREFIX/usr/bin/steamshim" --set-rpath "\$ORIGIN/../lib"
fi

# Copy Ruby SO library
echo "Installing usr/lib/libruby.so.3.1..."
cp -pu "$MKXPZ_PREFIX/lib/libruby.so.3.1" "$MESON_INSTALL_PREFIX/usr/lib/"

# Copy Steamworks SDK SO library
if [[ -n "$STEAM_PATH" ]]; then
  echo "Installing usr/lib/libsteam_api.so..."
  cp -pu "$STEAM_PATH/libsteam_api.so" "$MESON_INSTALL_PREFIX/usr/lib/"
fi

# Run AppImageTool to export AppImage executable
$APPIMAGETOOL "$MESON_INSTALL_PREFIX" "$MESON_BUILD_ROOT/mkxp-z.AppImage"
