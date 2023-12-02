# This is Makefile for building dependencies for ARM64 (Apple Silicon).
# Minimal deployment target is macOS 11.0 and higher.

ARCH := arm64
HOST := aarch64-apple-darwin

MINIMUM_REQUIRED := 11.0
OPENSSL_TARGET := darwin64-$(ARCH)-cc

include common.make
