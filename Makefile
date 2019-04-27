GO_EASY_ON_ME=1
FINAL_PACKAGE=1
DEBUG=0
VERSION=1.2

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Dragspring
Dragspring_FILES = Tweak.xm
Dragspring_LIBRARIES = colorpicker
ARCHS = armv7 arm64 arm64e

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += prefs
include $(THEOS_MAKE_PATH)/aggregate.mk