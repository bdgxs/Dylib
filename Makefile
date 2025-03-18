include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CPUInfoOverlay
CPUInfoOverlay_FILES = Tweak.xm cpux_lib.c
CPUInfoOverlay_FRAMEWORKS = UIKit

# Directly reference the relative path from THEOS
include $(THEOS)/makefiles/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"