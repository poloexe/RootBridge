ARCHS ?= armv7 armv7s arm64 arm64e
TARGET ?= iphone:clang:14.5:8.0

include $(THEOS)/makefiles/common.mk

FRAMEWORK_NAME = RootBridge

# control is the single source of truth for the version
VERSION := $(shell sed -n 's/^Version: //p' control)

RootBridge_FILES = RootBridge.m
RootBridge_INSTALL_PATH = /Library/Frameworks
RootBridge_PUBLIC_HEADERS = Headers/RootBridge.h
RootBridge_CFLAGS = -fobjc-arc -IHeaders
RootBridge_LDFLAGS = -install_name @rpath/RootBridge.framework/RootBridge -Wl,-current_version,$(VERSION) -Wl,-compatibility_version,1.0
RootBridge_FRAMEWORKS = Foundation

include $(THEOS_MAKE_PATH)/framework.mk
