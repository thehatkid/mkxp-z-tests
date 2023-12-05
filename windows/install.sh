#!/bin/sh

if [[ -z "$MESON_BUILD_ROOT" ]]; then
  echo "This script can be only used in Meson builds." >&2
  exit 1
fi

STEAM_PATH=$1
STEAM_LIBNAME=$2

source "$MESON_SOURCE_ROOT/windows/vars.sh"

RUBY_PREFIX=$(ruby "$MESON_SOURCE_ROOT/windows/msys-detect.rb")

# Copy mkxp-z JSON config
echo "Installing mkxp.json..."
cp -pu "$MESON_SOURCE_ROOT/mkxp.json" "$MESON_INSTALL_PREFIX/"

# Copy mkxp-z Scripts directory
echo "Installing scripts..."
cp -pur "$MESON_SOURCE_ROOT/scripts" "$MESON_INSTALL_PREFIX/scripts"

# Copy Ruby DLL
echo "Installing $RUBY_PREFIX-ruby310.dll..."
cp -pu "$MKXPZ_PREFIX/bin/$RUBY_PREFIX-ruby310.dll" "$MESON_INSTALL_PREFIX/"

# Copy Ruby library
echo "Installing Ruby library..."
cp -pur "$MKXPZ_PREFIX/lib/ruby/3.1.0" "$MESON_INSTALL_PREFIX/rubylib"

if [[ -n "$STEAM_PATH" ]] && [[ -n "$STEAM_LIBNAME" ]]; then
  # Copy Steamshim executable
  echo "Installing steamshim.exe..."
  cp -pu "$MESON_BUILD_ROOT/steamshim.exe" "$MESON_INSTALL_PREFIX/"

  # Copy Steamworks SDK DLL
  echo "Installing $STEAM_LIBNAME.dll..."
  cp -pu "$STEAM_PATH/$STEAM_LIBNAME.dll" "$MESON_INSTALL_PREFIX/"
fi
