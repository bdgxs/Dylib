# Makefile

TARGET = SystemInfo

include $(THEOS)/makefiles/common.mk

TUSD_FRAMEWORKS = UIKit

# Specify architectures for iOS only
ARCHS = iphoneos-arm64

include $(THEOS_MAKE_PATH)/tweak.mk

$(TARGET)_FILES = InfoProvider.m CPUXLib.c CPUXLib.h InfoProvider.h Tweak.xm

$(TARGET)_PRIVATE_FRAMEWORKS = CoreGraphics

INSTALL_TARGET_PROCESSES = SpringBoard

# Add conditional to check if the platform is not macOS before proceeding
ifneq ($(THEOS_PLATFORM_NAME),macosx)
# This Makefile is only for iOS builds
all::
	@echo "Building for iOS"
else
# Optionally, you can define what to do for macOS, or just exit
all::
	@echo "This Makefile is not supported on macOS"
	@exit 1
endif