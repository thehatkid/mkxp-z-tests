# This is Makefile for building dependencies for x86_64 (Universal/Intel).
# Minimal deployment target is macOS 10.12 and higher.

ARCH := x86_64
HOST := $(ARCH)-apple-darwin

MINIMUM_REQUIRED := 10.12
OPENSSL_TARGET := darwin64-$(ARCH)-cc

include common.make
