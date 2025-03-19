# Makefile

TARGET = SystemInfo

# Explicitly set platform at the beginning
export THEOS_PLATFORM_NAME=iphoneos
export THEOS_TARGET_PLATFORM=iphone
export THEOS_PLATFORM_SDK=iphoneos

include $(THEOS)/makefiles/common.mk

TUSD_FRAMEWORKS = UIKit
ARCHS = iphoneos-arm64

include $(THEOS_MAKE_PATH)/tweak.mk

$(TARGET)_FILES = InfoProvider.m CPUXLib.c CPUXLib.h InfoProvider.h Tweak.xm
$(TARGET)_PRIVATE_FRAMEWORKS = CoreGraphics
INSTALL_TARGET_PROCESSES = SpringBoard

all::
	@echo "Platform Name: $(THEOS_PLATFORM_NAME)"
	@echo "SDK Root: $(SDKROOT)"
	@echo "Building for iOS..."
	$(MAKE)

.PHONY: all