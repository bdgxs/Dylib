TARGET := SystemInfo

include $(THEOS)/makefiles/common.mk

TUSD_FRAMEWORKS = UIKit
ARCHS = iphoneos-arm64

include $(THEOS_MAKE_PATH)/tweak.mk

$(TARGET)_FILES = Tweak.x \
                  InfoProviders/CPUInfoProvider.swift \
                  InfoProviders/MemoryInfoProvider.swift \
                  UI/InfoWindow.swift \
                  UI/FloatingButton.swift \
                  SystemInfo.swift

$(TARGET)_PRIVATE_FRAMEWORKS = CoreGraphics

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS_MAKE_PATH)/aggregate.mk # Add this if you need an aggregate target