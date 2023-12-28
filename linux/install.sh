#!/bin/bash

if [[ -z "$MESON_SOURCE_ROOT" ]] || [[ -z "$MESON_INSTALL_PREFIX" ]]; then
  echo "This script can be only used in Meson builds." >&2
  exit 1
fi

BITS=$1
STEAM_PATH=$2

source "$MESON_SOURCE_ROOT/linux/vars.sh"

mkdir -p "$MESON_INSTALL_PREFIX/lib$BITS"

# Patch RPATH in executables
echo "Patching mkxp-z RPATH..."
patchelf "$MESON_INSTALL_PREFIX/mkxp-z" --set-rpath "\$ORIGIN/lib$BITS"

if [[ -n "$STEAM_PATH" ]]; then
  echo "Patching steamshim RPATH..."
  patchelf "$MESON_INSTALL_PREFIX/steamshim" --set-rpath "\$ORIGIN/lib$BITS"
fi

# Copy Ruby SO file
echo "Installing lib$BITS/libruby.so.3.1..."
cp -pu "$MKXPZ_PREFIX/lib/libruby.so.3.1" "$MESON_INSTALL_PREFIX/lib$BITS/"

# Copy Steamworks SDK SO file
if [[ -n "$STEAM_PATH" ]]; then
  echo "Installing libsteam_api.so..."
  cp -pu "$STEAM_PATH/libsteam_api.so" "$MESON_INSTALL_PREFIX/lib$BITS/"
fi

# Copy mkxp-z config file
if [[ ! -f "$MESON_INSTALL_PREFIX/mkxp-z.json" ]]; then
  echo "Installing mkxp-z.json..."
  cp -pu "$MESON_SOURCE_ROOT/mkxp-z.json" "$MESON_INSTALL_PREFIX/"
fi

# Copy mkxp-z Scripts directory
echo "Installing scripts..."
cp -pur "$MESON_SOURCE_ROOT/scripts/." "$MESON_INSTALL_PREFIX/scripts/"

# Copy Ruby library
echo "Installing Ruby library..."
cp -pur "$MKXPZ_PREFIX/lib/ruby/3.1.0/." "$MESON_INSTALL_PREFIX/rubylib/"
