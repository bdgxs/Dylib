# Makefile

TARGET = SystemInfo

include $(THEOS)/makefiles/common.mk

TUSD_FRAMEWORKS = UIKit

ARCHS = iphoneos-arm64

include $(THEOS_MAKE_PATH)/tweak.mk

$(TARGET)_FILES = InfoProvider.m CPUXLib.c CPUXLib.h InfoProvider.h Tweak.xm

$(TARGET)_PRIVATE_FRAMEWORKS = CoreGraphics

INSTALL_TARGET_PROCESSES = SpringBoard

# Force iOS build even if run on macOS
all::
	@echo "Platform Name: $(THEOS_PLATFORM_NAME)"
	@echo "SDK Root: $(SDKROOT)"
	$(MAKE) THEOS_PLATFORM_NAME=iphoneos

.PHONY: all