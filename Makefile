include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CPUInfoOverlay
CPUInfoOverlay_FILES = Tweak.xm cpux_lib.c
CPUInfoOverlay_FRAMEWORKS = UIKit

# Hardcode the path if you're sure of the location
include $HOME/theos/makefiles/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"