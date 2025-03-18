include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CPUInfoOverlay
CPUInfoOverlay_FILES = Tweak.xm cpux_lib.c
CPUInfoOverlay_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"