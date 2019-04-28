GO_EASY_ON_ME=1
DEBUG=0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Dragspring
Dragspring_FILES = Tweak.xm
Dragspring_LIBRARIES = colorpicker
ARCHS = arm64 arm64e

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += prefs
include $(THEOS_MAKE_PATH)/aggregate.mk