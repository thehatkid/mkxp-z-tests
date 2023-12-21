#!/bin/sh

if [[ -z "$MESON_SOURCE_ROOT" ]] || [[ -z "$MESON_INSTALL_PREFIX" ]]; then
  echo "This script can be only used in Meson builds." >&2
  exit 1
fi

STEAM_PATH=$1
STEAM_LIBNAME=$2

source "$MESON_SOURCE_ROOT/windows/vars.sh"

RB_PREFIX=$(ruby "$MESON_SOURCE_ROOT/windows/msys-detect.rb")

# Copy Ruby DLL
echo "Installing $RB_PREFIX-ruby310.dll..."
cp -pu "$MKXPZ_PREFIX/bin/$RB_PREFIX-ruby310.dll" "$MESON_INSTALL_PREFIX/"

# Copy Steamworks SDK DLL
if [[ -n "$STEAM_PATH" ]] && [[ -n "$STEAM_LIBNAME" ]]; then
  echo "Installing $STEAM_LIBNAME.dll..."
  cp -pu "$STEAM_PATH/$STEAM_LIBNAME.dll" "$MESON_INSTALL_PREFIX/"
fi

# Copy mkxp-z config file
if [[ ! -f "$MESON_INSTALL_PREFIX/mkxp.json" ]]; then
  echo "Installing mkxp.json..."
  cp -pu "$MESON_SOURCE_ROOT/mkxp.json" "$MESON_INSTALL_PREFIX/"
fi

# Copy mkxp-z Scripts directory
echo "Installing scripts..."
cp -pur "$MESON_SOURCE_ROOT/scripts/." "$MESON_INSTALL_PREFIX/scripts/"

# Copy Ruby library
echo "Installing Ruby library..."
cp -pur "$MKXPZ_PREFIX/lib/ruby/3.1.0/." "$MESON_INSTALL_PREFIX/rubylib/"
